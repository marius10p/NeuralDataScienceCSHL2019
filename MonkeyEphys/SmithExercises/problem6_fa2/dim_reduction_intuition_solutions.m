% For this part of the problem set, we will work with simulated data. The 
% data you will be working with has been generated from an FA model with
% 1 latent dimension. So the activity of the neurons lies on a 1 
% dimensional space. Alternatively you can think about one major factor 
% that describes the shared activity of the neurons. We will consider
% different loadings for these factors and build some intution about how the
% loadings on these factors affect the activity of the individual neurons 
% and the pattern of activity described for the whole population of neruons. 

% Step (1): Load the 3 data sets (sim1_data.mat, sim2_data.mat, 
% sim3_data.mat). Each of these data sets will return an 'S' struct, where
% where D(factor).counts returns a (num_neurons x num_trials) spike counts 
% array.

data_sets = cell(3, 1);
load('sim1_data.mat');
data_sets{1, 1} = S;

load('sim2_data.mat');
data_sets{2, 1} = S;

load('sim3_data.mat');
data_sets{3, 1} = S;

% Step (2): For each of the data sets, perform FA on each 
% (num_neurons x num_trials) spike counts array. Since you have 3 different 
% data sets, each with 3 spikes counts arrays, you should perform FA 9 
% different times and store the factors and private variances that FA 
% returns for each of the arrays (you will need these for computations in 
% the steps below). Remember the data was generated from an FA model with
% 1 latent dimension. So when running FA on each of the data sets use 1
% latent dimension.

neurons_num = 30;
factors_num = 3;
data_set_num = 3;
fa_stats = cell(data_set_num, 4);
zDim = 1; % 1 latent dimensional model
for s = 1 : data_set_num
    factors = nan(neurons_num, data_set_num);
    data_set = data_sets{s, 1};
    for f = 1 : factors_num
        spike_array = data_set(f).counts;
        [est_params, LL] = fastfa(spike_array, zDim);
        factors(:, f) = est_params.L;
        fa_stats{s, f + 1} = diag(est_params.Ph);
    end
    fa_stats{s, 1} = factors;
end

% Step (3): Visualize the weights of the factors extracted from FA for
% each data set:
% Create 3 different figures, one for each data set. In each figure, plot 
% the 3 different factors isolated, one in each spike count array of the data 
% set. You should use imagesc(factors), where factors is a neurons_num x 3
% array. Also call colorbar to show the scale. Use caxis([-1 1]) so that 
% the colorbar scale is consistent among the 3 different figures.
%
% How do the weigths of the factors differ within a data set? How do the
% weigts of the factors differ across data sets? 

cur_figure = 1;

for s = 1 : data_set_num
    figure(cur_figure);
    cur_factors = fa_stats{s, 1};
    imagesc(cur_factors);
    colorbar;
    caxis([-1 1]);
    xlabel('factors');
    ylabel('factor loadings');
    title_text = sprintf('factors for data set %d', s);
    title(title_text);
    cur_figure = cur_figure + 1;
end

% Step (4): Compute percent shared variance for each spike count array.
% How to compute percent shared varaince?
% Let L be the neurons_num x 1 factor that FA identifies for a given array.
% First construct the shared covariance matrix L*L'. The percent shared 
% variance for an individual neuron is defined as the neuron?s shared
% variance (the corresponding diagonal entry in L*L') divided by 
% its total variance (shared variance + private variance). Then to compute
% percent shared variance for the population of neruons, just average
% across the percent shared variance for an individual neuron. 
% Percent shared variance indicates how much of the activity is shared 
% among neurons. Here since we have 1 latent dimensional model, 
% %sv indicates how well the extracted factor can explain the activity of 
% the population of neurons. 

% Step (5): Compute the correlation matrix for each spike count array. 
% Its dimension should be neurons_num x neurons_num. Then compute the r_sc
% mean from the correlation matrix.

psv_stats = nan(data_set_num, factors_num);
rsc_stats = nan(data_set_num, factors_num);

for s = 1 : data_set_num
    cur_factors = fa_stats{s, 1};
    for f = 1 : factors_num
        L = cur_factors(:, f);
        private_variances = fa_stats{s, f + 1};
        shared_covariance = L*L';
        C = shared_covariance + private_variances;
        correlations = computeCorrelation(C);
        corr_mean = mean(correlations);
        psv = computePercentSharedVariance(shared_covariance, private_variances);
        
        psv_stats(s, f) = psv;
        rsc_stats(s, f) = corr_mean;
    end
end

% Step (6): making conclusions: 
% - For a fixed data set, how does r_sc mean vary with the different 
%   factors identified by FA? Can you see a connection between the loadings 
%   on the factors and the rsc_mean?
% - For the same factor (i.e factor identified in array 1 of each data set)
%   in each data set, how does rsc_mean change? Can you make a connection
%   between rsc_mean and percent shared variance? 
