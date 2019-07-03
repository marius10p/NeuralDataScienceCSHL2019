function estParams = indepGaussFit(X)
%
% estParams = indepGaussFit(X) 
%
% Fit parameters of an independent Gaussian model
%
%   xDim: data dimensionality
%   N:    number of data points
%
% INPUT: 
%
% X    - data matrix (xDim x N)
%
% OUTPUTS:
%
% estParams.d  - mean of each observed dimension (xDim x 1)
% estParams.Ph - variance of each observed dimension (xDim x 1)
%
% @ 2011 Byron Yu -- byronyu@cmu.edu

% Note: parameter names are analogous to those in fastfa.m
estParams.Ph = var(X, 1, 2);
estParams.d  = mean(X, 2);
