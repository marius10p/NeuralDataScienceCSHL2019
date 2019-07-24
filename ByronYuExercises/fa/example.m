% Generate fake data using FA model
% Data dimensionality: 20
% Latent dimensionality: 5
params.L  = randn(20, 5);
params.Ph = 0.1 * (1:20)';
params.mu = ones(20, 1);

X = simdata_fa(params, 100);

% Cross-validation
dim = crossvalidate_fa(X);

% Identify optimal latent dimensionality
istar = ([dim.sumLL] == max([dim.sumLL]));

% Project training data into low-d space
Z = fastfa_estep(X, dim(istar).estParams);