function [ norm ] = my_NORM( data )
% Histogram Equalization of Validation | Test file

norm=[];

 for i = 1: size(data,2)
   v =(data(:,i));
   v_norm = (v- min(v)) / ( max(v) - min(v) );
   norm=[norm, v_norm];
 end

