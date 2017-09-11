%VAD EVALUATION SCRIPT -- 2015 VERSION
clear;
close all;
clc;

format long
run('./path_and_defs.m')

% read and parse conf files;
conf_files = strsplit(ls('../conf_files/csp_phat/*.conf'));
conf_files = sort(conf_files(1:end-1))'

%setenv('LD_LIBRARY_PATH','/usr/lib64:/usr/local/MATLAB/R2013a/sys/os/glnxa64:/usr/local/MATLAB/R2013a/bin/glnxa64:/usr/local/MATLAB/R2013a/extern/lib/glnxa64:/usr/local/MATLAB/R2013a/runtime/glnxa64:/usr/local/MATLAB/R2013a/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/usr/local/MATLAB/R2013a/sys/java/jre/glnxa64/jre/lib/amd64/server:/usr/local/MATLAB/R2013a/sys/java/jre/glnxa64/jre/lib/amd64');

for cf = 1:numel(conf_files)
    %% Parse Conf File
    conf_file = conf_files{cf}
    verbose = true;
    args = parseConfFile( conf_file, verbose );
    
    %% parallel computing
    if isfield(args,'useParallel')
        useParallel = args.useParallel
    else
        useParallel = 0;
    end
    nPools = matlabpool('size');
    if (useParallel)
        if (nPools == 0)
            matlabpool('open',useParallel);
        elseif (nPools ~= useParallel)
            matlabpool close;
            matlabpool('open',useParallel);
        end
    else
        if (nPools > 0)
            matlabpool close;
        end
    end
    
    %% feat loading -> supports multiple mics
    if strcmp(args.dataset,'Real')
        N = 22; % tot scenes
        filename = 'real';
    elseif ((strcmp(args.dataset,'Simulations')) | (strcmp(args.dataset,'Mixed')))
        N = 80;
        filename = 'sim';
    end
    
    rand = false;
    if (strcmp(args.dataset,'Simulations'))
        [ train_idxs, val_idxs, test_idxs ] = IndexGen_2016( args, N, rand);
    elseif (strcmp(args.dataset,'Real'))
        [ train_idxs, val_idxs, test_idxs ] = IndexGen_2016_REAL( args, N, rand);
    end
    
    %% features loading
    
    feat_struct = cell(N,2);
    ngcc = numel(args.gcc);
    feat_dir = getenv('DATASET_DEV');
    acronym=[];
    
    for i = 1:N
        pre_path = [feat_dir,filesep,args.dataset,filesep,filename,num2str(i),filesep];
        if ~exist(pre_path,'dir')
            error([pre_path, '  --- not exist!!!']);
        end
        matr = [];
        acronym =[];
        
        if isfield(args,'gcc')
            acronym = [acronym,'Gcc_filt_max'];
            for j=1:ngcc
                name = args.gcc{j};
                name = regexprep(name,',','');
                name =  [name,'_16k'];
                if strncmp(name,'K',1)
                    mic_room = 'Kitchen';
                elseif strncmp(name,'L',1)
                    mic_room = 'Livingroom';
                end
                if isfield(args,'normBefore')
                    normBefore = args.normBefore;
                else
                    normBefore = false;
                end
                format_ = 'htk'; %% format = 'mat';
                tmp_matr = feat_loading_GCC_filt([pre_path,mic_room,filesep,name], format_, normBefore );
                matr = [matr, tmp_matr];
                clear tmp_matr
            end
            
        end
        
        
        tmp.scene = [filename,num2str(i)];
        %tmp.mics = args.mics;
        tmp.gcc = args.gcc;
        if (strcmp(args.room,'1net2rooms'))
            tmp.room = 'A';
        else
            tmp.room = args.room(1);
        end
        tmp.acronym = acronym;
        feat_struct{i,1} = tmp;
        feat_struct{i,2} = matr;
    end
    clear tmp pre_path name matr mic_room nmics i j
    
    %%    %% label loading
    ref_Liv = 'Livingroom.ref';
    ref_Kit = 'Kitchen.ref';
    if (~strcmp(args.room,'1net2rooms'))
        
        for i = 1:N
            path = [getenv('EVALITA_DEV'),filesep,args.dataset,filesep,filename,num2str(i),filesep];
            if strcmp(args.room,'Livingroom')
                ref_filename = [path,'Additional_info',filesep,ref_Liv];
                max_x = 4790;
                max_y = 4850;
            elseif strcmp(args.room,'Kitchen')
                ref_filename = [path,'Additional_info',filesep,ref_Kit];
                max_x = 4790;
                max_y = 3800;
            end
            L = size(feat_struct{i,2},1);
            tmp.ref_filename = ref_filename;
            tmp.size = L;
            label_struct{i,1} = tmp;
            label_X = labelLoad_SLOC( ref_filename, L );
            label_Xx = label_X(:,1);
            label_Xy = label_X(:,2);
            label_tmp=[label_Xx,label_Xy];
            label_struct{i,2} = label_tmp;
        end
        clear i nPools ref_Kit ref_Liv useParallel tmp ref_filename label_tmp
        
    else
        %             label_struct =
        %                             [1x1 struct]    [5994x2 double]
        %                               |
        %                               |_  ref_filename_K: [1x104 char] ==> KIT
        %                                   ref_filename_L: [1x107 char] ==> LIV
        %                                             size: 5994
        for i = 1:N
            path = [getenv('EVALITA_DEV'),filesep,args.dataset,filesep,filename,num2str(i),filesep];
            ref_filename_K = [path,'Additional_info',filesep,ref_Kit];
            ref_filename_L = [path,'Additional_info',filesep,ref_Liv];
            L = 5998;
            tmp.ref_filename_K = ref_filename_K;
            tmp.ref_filename_L = ref_filename_L;
            tmp.size = L;
            label_struct{i,1} = tmp;
            label_K = labelLoad_SLOC( ref_filename_K, L );
            max_Kx = 4790;
            max_Ky = 3800;
            label_Kx = label_K(:,1);
            label_Ky = label_K(:,2);
            
            label_L = labelLoad_SLOC( ref_filename_L, L );
            max_Lx = 4790;
            max_Ly = 4850;
            label_Lx = label_L(:,1);
            label_Ly = label_L(:,2);
            label_tmp=[label_Kx,label_Ky,label_Lx,label_Ly];
            label_struct{i,2} = label_tmp;
            
        end
        clear nPools ref_Kit ref_Liv useParallel tmp ref_filename label_tmp label_K label_Kx label_Ky label_L label_Lx label_Ly
    end
    %SELECT ONLY SPEECH FRAMES
    for n = 1:N   % foreach file in the test
        [feat_struct{n,2},label_struct{n,2}]=selectSpeech( feat_struct{n,2} ,label_struct{n,2} ) ;
    end
    %% POSITION ESTIMATION
    %TODO: creare struttura dati x i risultati, portare fuori if per
    %coordinate, scrivere funzione per valutazione
    H=[];
    DIST=[];
    POS=[];
    for k = 1:length(args.gcc)
        if (strcmp(args.gcc(k),'K1R,K1L'))
            d= 1400;
            h = max_y;
            pos = [d,0];
        elseif (strcmp(args.gcc(k),'K3L,K3C'))
            d= 1712;
            h = max_x;
            pos = [0,d];
        elseif (strcmp(args.gcc(k),'K3C,K3R'))
            d= 1863;
            h = max_x;
            pos = [0,d];
        elseif (strcmp(args.gcc(k),'K2L,K2R'))
            d= 1136;
            h = max_y;
            pos = [d,h];
        elseif (strcmp(args.gcc(k),'L1C,L1L'))
            d= 1698;
            h = max_y;
            pos = [d,0];
        elseif (strcmp(args.gcc(k),'L1R,L1C'))
            d= 1840;
            h = max_y;
            pos = [d,0];
        elseif (strcmp(args.gcc(k),'L4L,L4R'))
            d= 1622;
            h = max_x;
            pos = [0,d];
        elseif (strcmp(args.gcc(k),'L3L,L3R'))
            d= 2062;
            h = max_y;
            pos = [d,max_y];
        elseif (strcmp(args.gcc(k),'L2L,L2R'))
            d= 3173;
            h = max_x;
            pos = [max_x,d];
        end
        DIST=[DIST,d];
        H=[H,h];
        POS=[POS;pos];
    end
    RMSE=cell(1,N);
    Coord=cell(1,N);
    parfor i = 1:N
        fold = [feat_struct(i,:),label_struct(i,:)];
        GCC = fold(2);
        LAB = fold(4);
        DOA = compute_DOA (GCC);
        InPoints = compute_Points(DOA, DIST, H);
        Positions = estimate_Positions (InPoints,POS);
        RMSE_dist = evaluate_Positions (Positions, LAB);
        Coord{i}=Positions;
        RMSE{i}=RMSE_dist;
    end
    
    
    
    %% EVALUATION RESULTS
    %- Localization accuracy:
    %– RMSE Fine
    %– RMSE Fine+Gross
    %– Pcor: number of fine errors over all the hypotheses produced = Fine/(Fine+Gross).
    %It basically measures the probability that a localization hypothesis is correct.
    base_dir = ['/home/a3lab/Projects/Fabio/SLOC/alternative/'];
    params=['.csv'];
    tags = cell(1,N);
    E_TOT_fold=[];
    
    
    for n = 1:N   % foreach file in the test
        tags{n} = [feat_struct{n,1}.scene];
    end
    
    fold = size(test_idxs,2);
    
    for n = 1 : fold
        test_idxs(:,n)
        ERROR_FOLD=RMSE(test_idxs(:,n));
        E_TOT_fold{n}=evaluateSLOC_CSP(ERROR_FOLD);
    end
    
    rms_seq_file=[base_dir,'rmse_seq_',args.exp_name,params];
    cell2csv_VES_CSP(rms_seq_file, tags, RMSE',';');
    
    %     pos_seq_file=[base_dir,'pos_seq_',args.exp_name,params];
    %     cell2csv_VES_2016(pos_seq_file, tags, POS_TOT,';');
    
    result_file=[base_dir,args.exp_name,params];
    print_results_SRP(E_TOT_fold,result_file);
    
%     E_TOT=evaluateSLOC_COMP(RMSE);
%     result_file=[base_dir,'results_',args.room,'_pre-filt.csv'];
%     cell2csv_VES(result_file, tags, E_TOT,';');
%     report_file=[base_dir,'REPORT_',args.room,'_pre-filt.csv'];
%     doscore
%     system(['perl doscore_SLOC.pl ',result_file,' ',report_file]);

end % foreach net
disp('done');
