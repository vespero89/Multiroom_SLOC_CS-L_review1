function [ RMSErr] = evaluate_Positions( positions, labels)
%evaluate RMS error for each frame
positions=cell2mat(positions);
labels=cell2mat(labels);
RMSErr=cell(length(positions),1);
for i=1:length(positions)
    pos=positions(i,:);
    lab=labels(i,:);
    d1=pos(1)-lab(1);
    d2=pos(2)-lab(2);
    err= sqrt(d1^2 + d2^2);
    RMSErr{i}=err;
end
end

