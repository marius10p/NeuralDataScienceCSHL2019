%%% Exercises for understanding r_sc

%% Modeling r_sc

% r_sc is the Pearson's correlation of the spike counts for a pair of 
% neurons (the "spike count correlation", or "noise correlation") to
% repeated presentations of an identical stimulus. However, the observed
% r_sc value can be affected by a number of neuronal characteristics and
% experimental choices. Many of these can be understood with a simple
% simulation of correlated variables. Here, you will implement just such a
% simulation and test the following:
%
% 1 - How does trial count affect the measured r_sc?
%
% 2 - How does the threshold nonlinearity impact r_sc? Compare the
% correlation in the underlying variables to the observed r_sc after
% thresholding. Consider how this relates to firing rates.
%
% 3 (Optional) - Consider how the addition or removal of spikes (such as
% with spike sorting errors) impacts r_sc

% Starter code: create a bivariate gaussian to generate correlated variables
rsc = 0.2; %desired latent correlation
sigma = [1,rsc;rsc,1]; %covariance matrix
fr1 = 10; % firing rate of neuron 1
fr2 = 10; % firing rate of neuron 2
trialCount = 200; % number of trials (draws from the distribution)
bivar_gauss = gmdistribution([fr1,fr2],sigma); 
vmdat = random(bivar_gauss,trialCount); 

% Now plot the 'fake' neuronal responses (each point is a trial)
plot(vmdat(:,1),vmdat(:,2),'ko','markerfacecolor','k','markeredgecolor','w'); 
box off; set(gca,'tickdir','out');
xlim([0 ceil(max(vmdat(:)))]); ylim([0 ceil(max(vmdat(:)))]);
xlabel('Neuron 1 spike count'); ylabel('Neuron 2 spike count');
lsline
[r,p]=corr(vmdat); % the r_sc value
title(['r_{sc}=',sprintf('%0.2f',r(1,2)),' ; p=',sprintf('%0.4f',p(1,2))]);

% Solution 1 - How does trial count affect r_sc?

nIter = 100;
trialCount = [10 20 40 80 100 150 200 250 300 350 400 500 600 700 800 900 1000];
rsave = nan(numel(trialCount),nIter);

% Your code here

errorbar(trialCount,nanmean(rsave'),nanstd(rsave'));
box off; set(gca,'tickdir','out');
xlabel('Number of trials');
ylabel('r_{sc} estimate');

% Solution 2 - How does the threshold affect r_sc?

nIter = 100;
trialCount = 200; %set a range of trial counts to test
exponent = 1.7; %FR = Vm^1.7 (from Cohen and Kohn [2011])

% high firing rate condition
fr1 = 10; fr2 = 10;
bivar_gauss = gmdistribution([fr1,fr2],sigma); %create a bivariate gaussian distribution object
rsave = nan(nIter,2);
% Your code here

% set one neuron to have a low firing rate
fr1 = .1; fr2 = 10;
bivar_gauss = gmdistribution([fr1,fr2],sigma); %create a bivariate gaussian distribution object
rsave2 = nan(nIter,2);

% Your code here

subplot(1,2,1);
plot(rsave(:,1),rsave(:,2),'ko','markerfacecolor','k','markeredgecolor','w');
box off; set(gca,'tickdir','out');
xlabel('V_m correlation'); ylabel('r_{sc}');
maxval = ceil(max(rsave(:))*100)/100;
xlim([0 maxval]); ylim([0 maxval]);
axis square; hold on;
line([0 maxval],[0 maxval]); hold off;

subplot(1,2,2);
plot(rsave2(:,1),rsave2(:,2),'ko','markerfacecolor','k','markeredgecolor','w');
box off; set(gca,'tickdir','out');
xlabel('V_m correlation'); ylabel('r_{sc}');
maxval = ceil(max(rsave2(:))*100)/100;
xlim([0 maxval]); ylim([0 maxval]);
axis square; hold on;
line([0 maxval],[0 maxval]); hold off;

% Solution 3 - How does random spike addition/removal affect r_sc?

% Currently an exercise for the student

%% Computing r_sc in real data

% In real data r_sc depends on a number of features of the neurons - how
% far apart they are, and what stimuli they like (their tuning curve). And,
% as we noted above, the mean rate of the pair. Compute the dependence of
% r_sc on these three properties

load('Wi170428_spikes.mat'); % just for the electrode map
load('S_counts_grats.mat');

num_conds = length(S);
num_neurons = size(S(1).counts,1);

%%% To compute a single r_sc value, we need to z-score the responses to
%%% each of the conditions. Do this for each neuron, and each condition.

%%%  z-score the counts
for icond = 1:num_conds
    S(icond).mean = mean(S(icond).counts,2);
    S(icond).stdev = std(S(icond).counts,0,2);
    S(icond).zcounts = S(icond).counts - repmat(S(icond).mean,1,size(S(icond).counts,2));
    S(icond).zcounts = S(icond).zcounts ./ repmat(S(icond).stdev,1,size(S(icond).counts,2));
end

%%% Pool all z-scored trial data
[alltrials{1:num_conds}] = deal(S.zcounts);
alltrials = cell2mat(alltrials);

% A convenient mask to deal with symmetry in the matrix
tmask = nan(num_neurons,num_neurons);
tmask = tril(tmask);
tmask = tmask + 1;

% Now plot correlation as a function of distance, and as a function of 
% tuning curve similarity, for every pair

% (1) Compute r_sc for every pair

% (2) Compute the distance for every pair

% (3) Compute r_signal for each pair (the tuning curve correlation)

% (4) Show that correlation is affected by firing rate

% (5) Plot the results
