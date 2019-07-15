% Lab - Introduction to multivariate methods in MATLAB and their issues using toy examples
load('CSHL_2019_1.mat') % load the data  
%% First work with data that is 'pure noise' in order to see what a meaningless PCA looks like
N = 100; P = 10; 
data0 = randn(N,P); % Generate N instances of P uncorrelated variables 
corr_mat = corr(data0); % compute correlations of columns
corr_mat(1:4,5:10) % look at some correlations - how big are they typically? How does this compare to correlations in real data?
corr_mat = corr_mat - diag(diag(corr_mat)); % set 1's on diagonal to 0 for next step
max(max(corr_mat)) % find maximum correlation (off-diagonal)
% Now do PCA on this data using the MATLAB function princomp
[ loadings, scores, vars ] = pca(data0); % does PCA on data and stores weights (coefficients, loadings) in wgts
% Now plot the variances (eigenvalues)
size(loadings); size( scores); % how big are these things?
bar( vars) % plot eigenvalues (variances)... if you saw this in real data, how many principal components would you say are real?

%% Now try to discover some real patterns hidden in simulated data 
% there are two data sets called data1a and data1b. They both
% have the same underlying factors combined in different ways. 
% Try each in turn -e.g. 
% >> data1 = data1a;
% do exercise... then
% >> data1 = data1b;

close all
data1 = data1a;
plot(data1)

% Try PCA
[ loadings1, scores1, vars1 ] = pca(data1); % does PCA on data and stores weights (coefficients, loadings) in wgts
% Plot the eigenvalues, and determine how many are well-estimated
plot( vars1, '--rs','MarkerSize', 10) % make a bit nicer plot; how many are real? how many can you estimate ?
loadings1(:,1:3) % what do the loadings look like? How would you interpret them?
% Compare loadings to true loadings
wgts1a
loadings1(:,1:3)' % The true loadings are in wgts1a and wgts1b; how accurately does PCA recover the true loadings?
% Examine scores
plot( times1, scores1(:,1:5)); % Plot the estimated underlying factors - these were chosen to be recognizable
corr( drivers1, scores1(:,1:5)) % % The true values are in drivers1; how accurately does PCA recover the underlying factors?

