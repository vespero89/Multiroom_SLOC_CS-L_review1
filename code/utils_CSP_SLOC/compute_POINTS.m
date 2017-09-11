function [ POINTS ] = compute_POINTS( DOA, room )
%compute the dpuble pair of coordinates for each DOA line

if strcmp(args.room,'Livingroom')
    max_x = 4790;
    max_y = 4850;
elseif strcmp(args.room,'Kitchen')
    max_x = 4790;
    max_y = 3800;
end

POINTS=cell(length(DOA),2);
for i = 1:length(DOA)
    doa=DOA(i,:);
    % get direct distance of the mic pair from the other wall
    if (strcmp(doa{i,1},'K1') || strcmp(doa{i,1},'L1') || strcmp(doa{i,1},'K2') || strcmp(doa{i,1},'L3'))
        h = max_y;
    elseif (strcmp(doa{i,1},'K3') || strcmp(doa{i,1},'L2') || strcmp(doa{i,1},'L4'))
        h = max x;
    end
    
    b = tan(doa{i,2})*h; %length of the cateto opposite to the angle DOA
    POINTS{i,1} = h;
    
    
end
    
