% Script to load and pre-process a session from the Nick-Steinmetz
% Neuropixels dataset, with exercises
% Full Version

% author: Michael Moore and Mark Reimers, Michigan State University
% version: V1   07/13/2019

%% Chapter 1
% *************************************************************************
% Load the data into matlab
% *************************************************************************

% -each dataset consists of a set of data files
% -each dataset should reside in its own folder
% -no other files should be added to this folder
% -files in the folder of type '.npy' or '.tsv' will be treated as data 
%   and loaded into the session struct. Other files types will be ignored.

% specify path to data
mainPath = 'C:\Users\micha\Documents\Data\taskData2';
% specify session by name
sesName = 'Moniz_2017-05-15';

% add path to npy-matlab-master (tool to read python files into matlab)
addpath(genpath('C:\Users\micha\Documents\mmCode\npy-matlab-master'))
% add path to custom functions
addpath(genpath('C:\Users\micha\Documents\mmCode\myFunctions'))


% construct path to session file
sesPath = [mainPath filesep sesName];
% load all variables for session into a struct
S = loadSession(sesPath); % this calls a custom read function created for this dataset

clear ses sesName sesPath
clear mainPath sessionList

%% Chapter 2
% *************************************************************************
% Quick visualization of structure of experiment
% *************************************************************************

%% Visualize stimulus structure
% quick look to see the pattern of presented stimulus

figure
hold on
for tr = 1:40
    x = S.trials.intervals(tr,:);
    yL = S.trials.visualStim_contrastLeft(tr);
    yR = S.trials.visualStim_contrastRight(tr);
    hL = area(x,[yL;yL],'facecolor','r','facealpha',.5);
    hold on
    hR = area(x,[yR;yR],'facecolor','b','facealpha',.5);
    plot([x(1),x(1)],[0,1],'k')
end
clear tr x yL yR
legend([hL,hR],'left contrast','right contrast')
xlabel('time [s]')
ylabel('contrast')
title('Visual Stimulus Structure')
clear hL hR

%% Chapter 3
% ************************************************************************
% Create some derived variables for convenience
% *************************************************************************

%% Region Properties
% make a structure containing properties of the regions included in the
% session

regions = struct;

% make a list of region names:
regions.name = unique(S.channels.brainLocation.allen_ontology,'rows'); % a character array 
% number of unique regions in the dataset
regions.N = size(regions.name,1);
regions = orderfields(regions,{'N','name'}); % this step is just cosmetic
% assign unique rgb triplet for each region
regions.color = hsv(size(regions.name,1)); % 'hsv' is a matlab defined colormap generating function

% go further: add probe and depth fields to regions struct

%% Neuron Properties 
% neurons are the 'clusters'

% neuron properties of interest are distributed in a few different places,
% we can bring them together into a new struct called 'neurons'

neurons = struct;

% extract the neuron properties
neurons.id = unique(S.spikes.clusters);
    % note that id's in S.spikes.clusters run from 0 to (N-1), and do not
    % match row index of S.clusters 
neurons.N = length(neurons.id); % number of neurons
neurons = orderfields(neurons,{'N','id'});

% identify region by row in region struct
[~,Loc] = ismember(S.channels.brainLocation.allen_ontology(S.clusters.peakChannel,:),regions.name,'rows');
neurons.region = Loc; % index that correlates to rows in regions struct
clear Loc
neurons.depth = S.clusters.depths;
neurons.probe = S.clusters.probes;

%% Create a trials struct

trials = struct;
trials.N = size(S.trials.intervals,1);
trials.tstim = S.trials.visualStim_times;
% indicate if non-zero stimulus was presented at stim time
trials.isStim = logical(trials.tstim.*S.trials.visualStim_contrastLeft.*S.trials.visualStim_contrastRight);
% did the mouse move the wheel in response
trials.isMovement = S.trials.response_choice ~= 0;
% for each trial, find the movement onset time
trials.tmov = nan(trials.N,1); % initialize with "Not a Number"
for tr = 1:trials.N
   for m = 1:size(S.wheelMoves.intervals,1)
       t = S.wheelMoves.intervals(m,1); % move initiation time for trial m
       cond1 = t > trials.tstim(tr); % wheel move initiated after stimulus
       cond2 = t - trials.tstim(tr) < 0.4; % wheel move initiated within 400 ms after stimulus
       cond3 = isnan(trials.tmov(tr)); % no previous wheel move initiation for this trial
       if cond1 && cond2 && cond3
          trials.tmov(tr) = t;
       end           
   end
   clear m t cond1 cond2 cond3
end
clear tr

%% Exercise: compute average firing rate for each neuron-trial
% add a field to neurons structure giving rate 

neurons.rate = zeros(trials.N,neurons.N);
for n = 1:neurons.N
    % pull all spikes for the neuron
    spikes = S.spikes.times(S.spikes.clusters==neurons.id(n));
    for tr = 1:trials.N
        t1 = S.trials.intervals(tr,1);
        t2 = S.trials.intervals(tr,2);
        % compute rate for the trial
        neurons.rate(tr,n) = sum(spikes > t1 & spikes < t2)/(t2-t1);
    end
end
clear n tr spikes t1 t2

%% Exercise: make a histogram of the firing rates
% plot the firing rate distribution across all neurons 
% for each neuron, sum over trials

figure
histogram(mean(neurons.rate,1),'normalization','probability','facecolor','b')
xlabel('firing rate [s^{-1}]')
ylabel('% neurons')
title('Distribution of neuron firing rates')

%% Exercise: plot mean firing rate versus depth colored by region
% assign color based on region
% add a legend 

figure
hold on
for r = 1:regions.N
    scatter(mean(neurons.rate(:,neurons.region==r),1),neurons.depth(neurons.region==r),18,regions.color(r,:))
end 
clear rsum
xlabel('firing rate')
ylabel('depth')
box on
legend(regions.name)

%% Exercise: Raster Plot the spike data
% y-axis is depth
% x-axis is time

% advanced options:
%   color by region
%   separate subplots by probe

% choose a time interval
t1 = 1000;
t2 = 1010;
interval = S.spikes.times > t1 & S.spikes.times < t2;

spikes = S.spikes.times(interval);
ids = S.spikes.clusters(interval);
depths = S.spikes.depths(interval);
prob = neurons.probe(ids+1); % add 1 to get row index from neuron id;
reg = neurons.region(ids+1);

figure
for p = 0:1 % separate subplot for each probe
    subplot(2,1,p+1)
    hold on
    for r = 1:regions.N % plot all spikes in a given region against depth
        plot(spikes(reg==r&prob==p),depths(reg==r&prob==p),'.','color',regions.color(r,:))
    end
    clear r
    box on
    grid on
    title(['probe ',num2str(p)])
    ylabel('depth \mum')
    legend(regions.name)
end
clear p
xlabel('time [s]')
sgtitle('Spike Events')

clear t1 t2 interval spikes ids depths prob reg

% go further: add stim times and response times as vertical lines

%% Chapter 4
% *************************************************************************
% Pre-process the data (Bin and smooth)
% *************************************************************************

%% bin the data
% spike binning parameters
bins = struct;
bins.width = .005; % in [s]
% to make a smaller dataset, reduce the distance between bins.t1 and bins.t2
bins.t1 = min(S.trials.intervals(:)); % start of first trial
bins.t2 = max(S.trials.intervals(:)); % end of last trial
bins.edges = (bins.t1:bins.width:bins.t2)';
bins.centers = (bins.edges(2:end)-.5*bins.width);
bins.N = size(bins.centers,1);
clear t1 t2

F = struct;
F.numBins = bins.N;
F.numNeurons = neurons.N;
F.binned = zeros(F.numBins,F.numNeurons); % requires 1.5 Gb

%% Exercise: write a loop to bin the data:
% hint: use histcounts()
for n = 1:neurons.N
    isNeuron = S.spikes.clusters==neurons.id(n);  
    neuronSpikes = S.spikes.times(isNeuron);                     
    [f1,~] = histcounts(neuronSpikes,bins.edges);         
    F.binned(:,n) = f1;
end
clear n isNeuron nSpikes f1 

%% smooth the data with Causal Gaussian Kernel
% causal Gaussian kernel parameters
smooth = struct;
smooth.sigma = .025; % STD of Gaussian [s]
smooth.tmesh = (0:bins.width:3*smooth.sigma)'; 
smooth.kernel = (smooth.tmesh >=0).*exp(-smooth.tmesh.^2/(2*smooth.sigma^2));
smooth.kernel = smooth.kernel/sum(smooth.kernel);

%% Exercise: Plot the smoothing kernel
figure
stem(smooth.tmesh,smooth.kernel)
title('weights for causal Gaussian Smoothing')
xlabel('time [s]')
drawnow

%% Smooth the data using convolution with smoothing kernel
F.smoothed = convn(smooth.kernel,F.binned); 
F.smoothed = F.smoothed(1:F.numBins,:,:); 
% renormalize the kernel for cases where data was unavailable (first frames)
for m = 1:length(smooth.kernel)
    F.smoothed(m,:,:) = F.smoothed(m,:,:)*sum(smooth.kernel)/sum(smooth.kernel(1:m));
end
clear m

%% Exercise: compare binned vs smoothed for total activity
% plot over any interval of 1sec

f1 = sum(F.binned,2);
f2 = sum(F.smoothed,2);
figure
hold on
bar(bins.centers,f1, 'BarWidth', 1,'facecolor','b')
plot(bins.centers,f2,'r','linewidth',2)
title(['total activity'])
legend('binned','smoothed')
xlim([500 501])

clear f1 f2

