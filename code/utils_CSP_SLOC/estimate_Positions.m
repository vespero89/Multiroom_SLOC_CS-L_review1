function [ Positions] = estimate_Positions( points, POS)
%estimate position with min of SSD;
Positions=cell(length(points),1);
for i=1:length(points)
    p=cell2mat(points(i,:));
    %b = square_sum_of_distances(v,p);
    a = fminsearch(@(v) square_sum_of_distances(v,p,POS),[0,0]);
    %a = fminsearch(@(v) square_sum_of_distances_2(v,p,POS),[0,0]);
    Positions{i}=a;
end
end

