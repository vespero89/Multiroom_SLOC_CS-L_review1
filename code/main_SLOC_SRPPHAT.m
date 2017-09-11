%SLOC EXPERIMENT SCRIPT -- 2016 VERSION
clear;
close all;
clc;

format long
run('./path_and_defs.m')

% read and parse conf files;
conf_files = strsplit(ls('../conf_files/test_SRP/*.conf'));
conf_files = sort(conf_files(1:end-1))'

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
    
    %% mic info
    
    micList = args.mics;
    mic_file = 'channel_lst.txt';
    fid = fopen(mic_file,'r');
    micInfo= textscan(fid,'%s');
    micInfo=micInfo{1,1};
    
    mic_struct=cell(length(micInfo),1);
    for i=1:length(micInfo)
        mic_str=strsplit(micInfo{i},';');
        tmp_mic.mic=mic_str(1);
        x_tmp=strsplit(mic_str{4},'=');
        tmp_mic.x=x_tmp(2);
        y_tmp=strsplit(mic_str{5},'=');
        tmp_mic.y=y_tmp(2);
        z_tmp=strsplit(mic_str{6},'=');
        tmp_mic.z=z_tmp(2);
        tmp_mic.room=mic_str(2);
        tmp_mic.pos=mic_str(3);
        mic_struct{i}=tmp_mic;
    end
    clear tmp_mic mic_str micInfo mic_file
    
    mic_infos=[];
    for j=1:length(micList)
        MIC=char(micList(j));
        for k=1:length(mic_struct)
            mic_t=mic_struct{k};
            mic=char(mic_t.mic);
            if(strfind(MIC,mic))
                coord=[mic_t.x,mic_t.y,mic_t.z];
                mic_infos=[mic_infos;coord];
            end
        end
    end
    
    
    %% features loading
    
    % create list dep on micList
    fixedPath = '/home/a3lab/Projects/Dataset/DIRHA_DATASET/info/';
    %fixedPath = 'info/';
    
    micList=args.mics;
    
    list = cell(numel(micList),1);
    for g=1:numel(micList)
        if (strcmp(args.dataset,'Simulations'))
            if strncmp(micList{g},'K',1)
                list{g,1} = [fixedPath,'Simulations_wavfiles_Kitchen_',micList(g),'.txt'];
            elseif strncmp(micList{g},'L',1)
                list{g,1} = [fixedPath,'Simulations_wavfiles_Livingroom_',micList(g),'.txt'];
            end
        elseif (strcmp(args.dataset,'Real'))
            if strncmp(micList{g},'K',1)
                list{g,1} = [fixedPath,'Real_wavfiles_Kitchen_',micList(g),'.txt'];
            elseif strncmp(micList{g},'L',1)
                list{g,1} = [fixedPath,'Real_wavfiles_Livingroom_',micList(g),'.txt'];
            end
        end
        
    end
    
    % read
    waveFiles_TOT = [];
    for i=1:numel(list)
        fid = fopen(strjoin(list{i},''),'r');
        waveFiles_tmp= textscan(fid,'%s');
        waveFiles_tmp = waveFiles_tmp{1,1};
        waveFiles_TOT = [waveFiles_TOT,waveFiles_tmp];
    end
    
    wavs_struct = cell(N,2);
    
    for i=1:N
        tmp.mics = args.mics;
        if (strcmp(args.room,'1net2rooms'))
            tmp.room = 'A';
        else
            tmp.room = args.room(1);
        end
        
        tmp.dataset = args.dataset;
        tmp.acronym = args.exp_name;
        tmp.scene = [filename,num2str(i)];
        wavs_struct{i,1} = tmp;
        wavs_struct{i,2} = waveFiles_TOT(i,:);
    end
    
    
    
    
    %%    %% label loading
    
    load L-REAL.mat;
    ref_Liv = 'Livingroom.ref';
    ref_Kit = 'Kitchen.ref';
    load L-REAL.mat;
    if (~strcmp(args.room,'1net2rooms'))
        for i = 1:N
            path = [getenv('EVALITA_DEV'),filesep,args.dataset,filesep,filename,num2str(i),filesep];
            if strcmp(args.room,'Livingroom')
                ref_filename = [path,'Additional_info',filesep,ref_Liv];
                max_x = 4.790;
                max_y = 4.850;
                max_z = 1.500;
                
            elseif strcmp(args.room,'Kitchen')
                ref_filename = [path,'Additional_info',filesep,ref_Kit];
                max_x = 4.790;
                max_y = 3.800;
                max_z = 1.500;
            end
            
            if (strcmp(args.dataset,'Simulations'))
                L = 5998;
                LSB = [0  0 0];
                USB = [max_x max_y max_z];
            else
                L=LReal(i);
                LSB = [0  0 0];
                USB = [max_x max_y max_z];
            end
            
            tmp.ref_filename = ref_filename;
            tmp.size = L;
            label_struct{i,1} = tmp;
            label_X = labelLoad_SLOC( ref_filename, L );
            label_Xx = label_X(:,1)./1000;
            label_Xy = label_X(:,2)./1000;
            label_tmp=[label_Xx,label_Xy];
            label_struct{i,2} = label_tmp;
        end
        clear i nPools ref_Kit ref_Liv useParallel tmp ref_filename label_tmp
    end
    
    tags = cell(1,N);
    for n = 1:N   % foreach file in the test
        tags{n} = [wavs_struct{n,1}.scene];
    end
    
    
    %% POSITION ESTIMATION SRP PHAT
    
    fold = size(test_idxs,2);
    POS_TOT=[];
    LAB=[];
    RMSE=[];
    
    %FAKE_WAV={'wavs/K1L_16k.wav';'wavs/K1R_16k.wav';'wavs/K3L_16k.wav';'wavs/K3C_16k.wav';'wavs/K3R_16k.wav';'wavs/K2L_16k.wav';'wavs/K2R_16k.wav'};
    
%     for m = 1:numel(test_idxs)
%         m
%         [POS_TOT{m},LAB{m}] = compute_SRP_PHAT(wavs_struct{m,2},mic_infos,LSB,USB,label_struct{m,2});
%         %[POS_TOT{m},LAB{m}] = compute_SRP_PHAT(FAKE_WAV,mic_infos,LSB,USB,label_struct{m,2});
%         RMSE_dist = evaluate_PositionsSRP(POS_TOT{m},LAB{m});
%         RMSE{m,1}=RMSE_dist;
%     end
    
        for m = 1:fold
            for n =  1 : size(test_idxs,1)
                test_idxs(n,m)
                [POS_TOT{test_idxs(n,m),1},LAB{test_idxs(n,m),1}] = compute_SRP_PHAT(wavs_struct{test_idxs(n,m),2},mic_infos,LSB,USB,label_struct{test_idxs(n,m),2});
                %[POS_TOT{m},LAB{m}] = compute_SRP_PHAT(FAKE_WAV,mic_infos,LSB,USB,label_struct{m,2});
                RMSE_dist = evaluate_PositionsSRP(POS_TOT{test_idxs(n,m)},LAB{test_idxs(n,m)});
                RMSE{test_idxs(n,m),1}=RMSE_dist;
            end
        end
    
    %% EVALUATION RESULTS
    %- Localization accuracy:
    %– RMSE Fine
    %– RMSE Fine+Gross
    %– Pcor: number of fine errors over all the hypotheses produced = Fine/(Fine+Gross).
    %It basically measures the probability that a localization hypothesis is correct.
    base_dir = ['/home/a3lab/Projects/Fabio/SLOC/alternative/'];
    params=['FT=2048_ran=5000_n=20;0.05;50000.csv'];
    %base_dir = [''];
    E_TOT_fold=[];
    win_length = 1;
    
    for n = 1 : fold
        ERROR_FOLD=RMSE(test_idxs(:,n));
        E_TOT_fold{n}=evaluateSLOC_SRP(ERROR_FOLD);
    end
    
    rms_seq_file=[base_dir,'rmse_seq_',args.exp_name,params];
    cell2csv_VES_2016(rms_seq_file, tags, RMSE,';');
    
    %     pos_seq_file=[base_dir,'pos_seq_',args.exp_name,params];
    %     cell2csv_VES_2016(pos_seq_file, tags, POS_TOT,';');
    
    result_file=[base_dir,args.exp_name,params];
    print_results_SRP(E_TOT_fold,result_file);
    
    
end % foreach net
disp('done');
