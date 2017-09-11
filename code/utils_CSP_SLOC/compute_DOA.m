function [ DOA ] = compute_DOA( GCCs )
%compute DOA from TOA given from GCC-PHAT
% return an array of DOA from a given array of TOA corresponding to a
% single frame
c=340; %speed of sound in m/s
d=300;  %distance between each microphone of a pair (30 cm) in mm
GCCs=cell2mat(GCCs);
DOA=cell(size(GCCs));
for i = 1:length(GCCs)
    for j= 1:size(GCCs,2);
        gcc=GCCs(i,j);
        doa=acos((c*gcc)/d);
        DOA{i,j}=doa;    
    end
end

