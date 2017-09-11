function  [POS,LAB,fn_error,fp_error,NOTES]=compute_SRP_PHAT_VAD(wav_files, mics_infos, lsb, usb ,label_fold, vad_fold, room)

mics_infos=str2double(mics_infos);
mics_infos=mics_infos./100;
sample_rate=16000;
frameSize=1024;
hopSize=160;
windowShape=@hamming;

AUDIO=[];
x_r_K = 4790;
y_r_K = 3800;
x_r_L = 4790;
y_r_L = 4850;

vad_fold=vad_fold';
fn_error = [];
fp_error = [];


error_K = (x_r_K^2+y_r_K^2);
error_L = (x_r_L^2+y_r_L^2);


for i=1:length(wav_files)
    fn_audio=wav_files{i};
    audio = audioread(fn_audio)';
    AUDIO = [AUDIO;audio];
end
clear audio

%numFrames=(floor(length(AUDIO)/hopSize));
NF=0;
LAB=[];
POS=[];
NOTES=[];

for j = 1:length(label_fold)
    xStart=(j-1)*(hopSize)+1;
    xEnd=(j-1)*(hopSize)+frameSize;
    %Break if frame index goes over length of x
    if(xEnd>length(AUDIO))
        break
    end
    if (vad_fold(j) == 1)
        if ~(sum(label_fold(j,:)) == 0)
            NF=NF+1;
            s=AUDIO(:,xStart:xEnd)';
            [finalpos,finalsrp,finalfe]=srplems(s, mics_infos, sample_rate, lsb, usb);
            %finalpos=[1,1,1];
            POS=[POS;finalpos];
            LAB=[LAB;label_fold(j,:)];
            NOTES=[NOTES;'TP'];
        else
            finalpos=[1000,1000,1000];
            POS=[POS;finalpos];
            LAB=[LAB;label_fold(j,:)];
            NOTES=[NOTES;'FP'];
            if strcmp(room,'Kitchen')
                fp_error=[fp_error;sqrt(error_K)];
            elseif strcmp(room,'Livingroom')
                fp_error=[fp_error;sqrt(error_L)];
            end
        end
    elseif ((vad_fold(j) == 0) && ~(sum(label_fold(j,:)) == 0))
        NOTES=[NOTES;'FN'];
        if strcmp(room,'Kitchen')
            fn_error=[fn_error;sqrt(error_K)];
        elseif strcmp(room,'Livingroom')
            fn_error=[fn_error;sqrt(error_L)];
        end
    end
    
end

end
