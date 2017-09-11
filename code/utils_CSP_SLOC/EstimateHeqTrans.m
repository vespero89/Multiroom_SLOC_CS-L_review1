function [bc, trans] = EstimateHeqTrans(target, observed, symmetric)
%ESTIMATEHEQTRANS The function calculates the transformation to be applied
%to observed so that they match the same distribution of target.
%   Input:
%   - target: samples whose distribution will be matched.
%   - observed: samples that will be transformed to match the
%   distribution of target.
%   - symmetric: if true, trans is symmetric respect to the origin (the
%   positive part is replicated). This ensures that the trasnformed data
%   will have zero mean.
%   Output:
%   - bc: bin center values.
%   - trans: the output transformation.

% Calculate the target CDF
[cdfTarget, edges] = histcounts(target, 'Normalization', 'cdf');

% Calculate bin centers from bin edges
bc = edges(1:end-1) + (edges(2) - edges(1))/2; 

% Get the observed data CDF on the same bins
[cdfObserved, ~] = histcounts(observed, edges, 'Normalization', 'cdf');

% Discard duplicate values (otherwise interp1 gets angry...)
[cdfTargetUnique, ia, ~] = unique(cdfTarget);
bcTargetUnique = bc(ia);

% Calculate the transformation
trans = interp1(cdfTargetUnique, bcTargetUnique, cdfObserved, 'linear', 'extrap');

% Forces symmetric transformation (guarantees zero mean)
if (symmetric)
  k = find(bc >= 0, 1, 'first');
  trans = trans(k:end);
  trans = [-fliplr(trans), trans];
  bc = bc(k:end);
  bc = [-fliplr(bc), bc];
end

end

