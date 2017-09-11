function [ heq_norm ] = my_HEQandNORM( train_data, test_data )
% Histogram Equalization of Validation | Test file

heq_norm=[];

 for i = 1: size(test_data,2)
   observed=(test_data(:,i));
   target=(train_data(:,i));
   [bc, trans] = EstimateHeqTrans(target, observed, 0);  
   observed(observed > bc(end)) = bc(end);
   observed(observed < bc(1))   = bc(1);
   equalized = interp1(bc, trans, observed, 'linear', 'extrap');
   equalized_norm = (equalized- min(equalized)) / ( max(equalized) - min(equalized) );
   heq_norm=[heq_norm, equalized_norm];
 end

