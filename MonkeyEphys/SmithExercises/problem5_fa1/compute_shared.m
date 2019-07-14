function [percentshared, d_shared,bestdim,normevals] = compute_shared(params, thresh)
%% extract parameters for the number of latents with highest likelihood
% what was the optimal number of latent dimensions?
bestdim = 0; 
% what was the optimal L?
% what was the optimal Ph?

%% compute d_shared
% first compute the amount of shared variance explained by each eigenvalue
% of the shared covariance matrix. Then apply the threshold
normevals = [10:-1:1]/sum([10:-1:1]); 
d_shared = 0;

%% compute % shared variance
percentshared = 0;
end