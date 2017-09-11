function  [POS,LAB]=compute_SRP_PHAT(wav_files, mics_infos, lsb, usb ,label_fold)

mics_infos=str2double(mics_infos);
mics_infos=mics_infos./100;
sample_rate=16000;
frameSize=2048;
hopSize=160;
windowShape=@hamming;

AUDIO=[];

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

for j = 1:length(label_fold) 
    xStart=(j-1)*(hopSize)+1;
    xEnd=(j-1)*(hopSize)+frameSize;
    %Break if frame index goes over length of x
    if(xEnd>length(AUDIO))
        break
    end
    if ~(sum(label_fold(j,:)) == 0)
        NF=NF+1;
        s=AUDIO(:,xStart:xEnd)';
        [finalpos,finalsrp,finalfe]=srplems_VES(s, mics_infos, sample_rate, lsb, usb);
        POS=[POS;finalpos];
        LAB=[LAB;label_fold(j,:)];
    end
end

end
