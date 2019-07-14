function X = simdata_fa(params, N)
%
% X = simdata_fa(params, N)
%
% Generate fake data using FA model
%
%   xDim: data dimensionality
%   zDim: latent dimensionality
%
% INPUTS: 
%
% params - structure containing FA parameters
%            L  (xDim x zDim)
%            Ph (xDim x 1)
%            mu (xDim x 1)
% N      - number of data points to generate
%
% OUTPUTS:
%
% X      - generated fake data (xDim x N)
%
% @ 2011 Byron Yu  byronyu@cmu.edu

  randn('state', 0);
  
  L  = params.L;
  Ph = params.Ph;
  mu = params.mu;
  
  [xDim, zDim] = size(params.L);
  
  Z  = randn(zDim, N);
  ns = bsxfun(@times, randn(xDim, N), sqrt(Ph));
  
  X = bsxfun(@plus, L * Z + ns, mu);