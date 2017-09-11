function [ POINTS ] = compute_Points( DOA, DIST_vect, H_vect )
%compute the dpuble pair of coordinates for each DOA line
POINTS=cell(size(DOA));
for i = 1:length(DOA)
    doa=cell2mat(DOA(i,:));
    for j = 1:size(DOA,2)
        h=H_vect(j);
        dist=DIST_vect(j);
        b = tan(doa(j))*h; %length of the cateto opposite to the angle DOA
        L=b+dist;
        POINTS{i,j} = [h,L];
    end
end
end

