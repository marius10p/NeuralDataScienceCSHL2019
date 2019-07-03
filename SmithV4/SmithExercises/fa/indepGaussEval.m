function [LL, sse] = indepGaussEval(X, params)
%
% [LL, sse] = indepGaussEval(X, params)
%
% Evaluate log likelihood and sum-of-squared prediction error given
% an independent Gaussian model
%
%   xDim: data dimensionality
%   N:    number of data points
%
% INPUT: 
%
% X      - data matrix (xDim x N)
% params - parameters of independent Gaussian model 
%          (structure with fields d and Ph)
%
% OUTPUTS:
%
% LL  - log likehood of data
% sse - sum-of-squared prediction error
%
% @ 2011 Byron Yu -- byronyu@cmu.edu

  [xDim, N] = size(X);
  
  Ph   = params.Ph;
  d    = params.d;
  
  Xc2  = bsxfun(@minus, X, d).^2;
  Xstd = bsxfun(@rdivide, Xc2, Ph);
  
  LL = -0.5 * (N*xDim*log(2*pi) + N*sum(log(Ph)) + sum(Xstd(:)));
  
  sse = sum(Xc2(:));