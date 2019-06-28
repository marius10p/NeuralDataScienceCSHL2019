% Matlab Exercises on analysis of Steinmetz Data for CSHL course
%   Authors: Michael Moore and Mark Reimers

%% Specify the path to the folder containing the datasets

% add path to npy-matlab-master
addpath(genpath('./npy-matlab-master'))

% specify path to data
mainPath = '/home/mmoore/Optical_Data_Analysis/Data/Electrode/Nick_Steinmetz/Raw/taskData2';

% generate list of available sessions
sessions = dir(mainPath);
sessions = sessions(3:end);

%% pick a session and create a data-structure

% specify session by row index of sessions variable
ses = 1;
sesName = sessions(ses).name;

% construct path to session file
sesPath = [mainPath filesep sesName];

% load all variables for session into a struct
S = loadSteinmetzSession(sesPath); % this calls a custom read function created for this dataset

clear ses sesName sesPath
clear mainPath sessions

%% Region Properties
% make a structure containing properties of the regions included in the
% session

region = struct;

region.name = unique(S.channels.brainLocation.allen_ontology,'rows'); % a character array 
region.color = hsv(size(region.name,1)); % unique rgb triplet for each region

%% Neuron Properties 

% neurons are the 'clusters'

% neuron properties of interest are distributed in a few different places,
% we can bring them together into a new struct called 'neurons'

neuron = struct;

% extract the neuron properties
neuron.id = unique(S.spikes.clusters);
    % note that id's in S.spikes.clusters run from 0 to (N-1), and do not
    % match row index of S.clusters 
N = length(neuron.id); % number of neurons
% identify region by row in region struct
[~,Loc] = ismember(S.channels.brainLocation.allen_ontology(S.clusters.peakChannel,:),region.name,'rows');
neuron.region = Loc;
clear Loc
neuron.depth = S.clusters.depths;
neuron.probe = S.clusters.probes;

%% compute the mean firing rate of each neuron
% add a field to the neuron struct giving the mean firing rate of each
% neuron

T =  max(S.spikes.times) - min(S.spikes.times);
for n = 1:N
    neuron.rate(n,1) = sum(S.spikes.clusters == neuron.id(n))/T;
end
clear n T

% plot the firing rate distribution over all neurons 
figure
histogram(neuron.rate,'normalization','probability','facecolor','b')
xlabel('firing rate [s^{-1}]')
title('Distribution of neuron firing rates')

%% plot firing rate versus depth colored by region
% simple exercise to assign color based on region

figure
scatter(neuron.rate,neuron.depth,18,region.color(neuron.region,:))
ylabel('depth')
xlabel('firing rate')
axis ij
box on

% force a reasonable legend
hold on
for n = 1:length(region.name)
    h(n) = plot(NaN,NaN,'o','color',region.color(n,:)); % make an invisible plot
end
legend(h,region.name); % use invisible plot to generate legend
clear n h

%% Raster Plot the spike data
% y-axis is depth
% x-axis is time
% color by region

interval = S.spikes.times > 1e3 & S.spikes.times < 1.01e3;

times = S.spikes.times(interval);
ids = S.spikes.clusters(interval);
depths = S.spikes.depths(interval);

figure
ax{1} = subplot(2,1,1);
hold(ax{1},'on')
ax{2} = subplot(2,1,2);
hold(ax{2},'on')
for n = 1:N
    plot(ax{neuron.probe(n)+1},times(ids==neuron.id(n)),depths(ids==neuron.id(n)),...
       '.','color',region.color(neuron.region(n),:))
end
clear n
axis(ax{1},'ij')
axis(ax{2},'ij')
title(ax{1},'probe 0')
title(ax{2},'probe 1')
xlabel(ax{1},'time [s]')
xlabel(ax{2},'time [s]')
ylabel(ax{1},'depth')
sgtitle('Spike Events')

clear interval times ids depths ax
  
%% Reproduce some parts of Figure 2 

% sort spikes by neuron and trial number
numTrials = length(S.trials.visualStim_times);
spikesNTR = cell(N,numTrials);
for n = 1:N
    % maks a list of neuron ids in the region
    spikes = S.spikes.times(S.spikes.clusters==neuron.id(n));
    % sort the spikes into trials
    for tr = 1:numTrials
        tstim = S.trials.visualStim_times(tr);
        t1 = tstim - 0.05;
        t2 = tstim + 0.30; 
        spikesNTR{n,tr} = spikes(spikes >= t1 & spikes <= t2) - tstim;
    end
    clear tr tstim t1 t2 spikes
end
clear n

%% bin with 5 ms bins

t1 = -.05;
t2 = 0.30;
dt = .005;
edges = t1:dt:t2;
times = edges(1:(end-1))+dt/2;
clear t1 t2 dt

Y = zeros(N,numTrials,length(edges)-1);

for n = 1:N
    for tr = 1:numTrials
        [Y(n,tr,:),~] = histcounts(spikesNTR{n,tr},edges);
    end
    clear tr
end
clear n edges spikesNTR

% compute PSTH for each neuron
PSTH = squeeze(mean(Y,2));
clear Y

%% Causal Smoothing
% under construction:

% % 20 ms std
% dt = .005;
% sig = .02;
% tmesh = 0:dt:.1;
% win = exp(-tmesh.^2/(2*sig^2));
% win = win/sum(win);
% 
% PSTH = convn(PSTH,win,'valid');
% 
% clear  dt sig tmesh win
%% plot results

numRegions = length(region.name);
figure
for r = 1:numRegions
    subplot(numRegions,1,r)
    plot(times,mean(PSTH(neuron.region==r,:),1),'.-','color',region.color(r,:))
    title(region.name(r,:))
end





