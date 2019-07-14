% Matlab Exercises on PSTH analysis of Steinmetz Data for CSHL course
%   Authors: Michael Moore and Mark Reimers

%% Specify the path to the folder containing the datasets
% -each dataset consists of a set of data files
% -each dataset should reside in its own folder
% -no other files should be added to this folder
% -files in the folder of type '.npy' or '.tsv' will be treated as data 
%   and loaded into the session struct. Other file types will be ignored.

% add path to npy-matlab-master
% addpath(genpath('./npy-matlab-master'))
addpath(genpath('.\npy-matlab-master'))

% specify path to data
% mainPath = '/home/mmoore/Optical_Data_Analysis/Data/Electrode/Nick_Steinmetz/Raw/taskData2';
mainPath = 'C:\Users\micha\Documents\Data\taskData2\';
% generate list of available sessions
sessionList = dir(mainPath);

%% pick a session and create a data-structure

% specify session by row index of sessions variable
sesName = sessionList(3).name;

% construct path to session file
sesPath = [mainPath filesep sesName];

% load all variables for session into a struct
S = loadSession(sesPath); % this calls a custom read function created for this dataset

clear ses sesName sesPath
clear mainPath sessionList

%% Region Properties
% make a structure containing properties of the regions included in the
% session

regions = struct;

regions.name = unique(S.channels.brainLocation.allen_ontology,'rows'); % a character array 
regions.N = size(regions.name,1);
regions = orderfields(regions,{'N','name'});
regions.color = hsv(size(regions.name,1)); % assign unique rgb triplet for each region

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

%% Visualize trial structure
% quick look to see the pattern of trials

figure
hold on
for tr = 1:20
    h1 = plot(S.trials.visualStim_times(tr),tr,'k+');
    h2 = plot(S.trials.goCue_times(tr),tr,'g+');
    h3 = plot(S.trials.response_times(tr),tr,'r+');
    h4 = plot(S.trials.feedback_times(tr),tr,'mo');
    h5 = plot(S.trials.intervals(tr,:),[tr;tr],'k');
end
clear tr
legend([h1 h2 h3 h4 h5],'stim','cue','response','feedback','trial','location','southeast')
title('trial structure')
ylabel('trial number')
xlabel('time [s]')
clear h1 h2 h3 h4 h5

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

%% Create a trials struct
% Later we will want to classify neurons by those whose firings rate
% encodes stimulus and movement

trials = struct;
trials.N = size(S.trials.intervals,1);
trials.isStimulus = S.trials.visualStim_contrastLeft > 0 & S.trials.visualStim_contrastRight > 0;
% did the mouse move the wheel in response
trials.isMovement = S.trials.response_choice ~= 0;

% quick look at results
figure
stem(trials.isMovement & trials.isStimulus,'k.')
ylim([-.1,1.1])
xlabel('trial')
ylabel('Stimulus and Movement')
yticks([0,1])

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

%% Exercise: make a histogram of neuron mean firing rates

% plot the firing rate distribution over all neurons 
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
axis ij
box on
legend(regions.name)

%% Exercise: Raster Plot the spike data
% y-axis is depth
% x-axis is time
% color by region
% separate subplots by probe

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
    axis ij
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
  
%% Which neurons encode Stimulus + Movement?
% use Wilcoxon rank sum test to determine which neurons have a
% statistically
% significantly higher firing rate on trials with stimulus and movement

alpha = .01; % threshold probability that null hypothesis is correct

for n = 1:neurons.N
    x = neurons.rate(trials.isStimulus & trials.isMovement,n);
    y = neurons.rate(~(trials.isStimulus & trials.isMovement),n);
    p(n,1) = ranksum(x,y); % p-value for null hypothesis (both trial subsets have same median) is correct
end
clear n 

% add a field to neurons showing results
neurons.test1 = p < alpha & (median(x) > median(y));
clear p x y

figure
stem(neurons.test1,'.')
xlabel('neuron')
ylabel('encoding')
title('Which neurons encode Stimulus + Movement')

%% Process for PSTH
% sort spikes by neuron and trial
% align data on visual stimulus presentation
% bin data with 5ms bins
% smooth data with 25ms causal gaussian kernel


%% Bin the data:
% spike binning parameters
bins = struct;
bins.width = .005; % in [s]
bins.t1 = -.1; % relative to stimulus [s]
bins.t2 = 0.4;
bins.edges = bins.t1:bins.width:bins.t2;
bins.centers = (bins.edges(2:end)-.5*bins.width)';
clear t1 t2

% create a struct for the processed data
Y = struct; 

% add some basic metadata
Y.numBins = length(bins.centers);
Y.numNeurons = neurons.N;
Y.numTrials = size(S.trials.visualStim_times,1);

% pre-allocate the binned data. Dims are (bin,neuron,trial).
Y.binned = zeros(Y.numBins,Y.numNeurons,Y.numTrials);
for n = 1:Y.numNeurons
    isNeuron = S.spikes.clusters==neurons.id(n);  
    nSpikes = S.spikes.times(isNeuron);
    for tr = 1:Y.numTrials   
        tStim = S.trials.visualStim_times(tr);
        isWindow = nSpikes-tStim >= bins.t1 & nSpikes-tStim <= bins.t2;                      
        [y1,~] = histcounts(nSpikes(isWindow)-tStim,bins.edges);         
        Y.binned(:,n,tr) = y1;
    end
end
clear n is isNeuron nSpikes tr tStim isWindow y1 

%% Smooth the data
% Causal Gaussian Kernel convolution

% causal Gaussian kernel parameters
kernel = struct;
kernel.sigma = .02; % STD of Gaussian [s]
kernel.tmesh = (0:bins.width:3*kernel.sigma)'; 
kernel.win = (kernel.tmesh >=0).*exp(-kernel.tmesh.^2/(2*kernel.sigma^2));
kernel.win = kernel.win/sum(kernel.win);

figure
stem(kernel.tmesh,kernel.win)
title('weights for causal Gaussian Smoothing')
xlabel('time [s]')
drawnow

Y.smoothed = convn(kernel.win,Y.binned); 
Y.smoothed = Y.smoothed(1:Y.numBins,:,:); 
% renormalize the kernel for cases where data was unavailable
for m = 1:length(kernel.win)
    Y.smoothed(m,:,:) = Y.smoothed(m,:,:)*sum(kernel.win)/sum(kernel.win(1:m));
end
clear m

%% average over trials
Y.data = mean(Y.smoothed,3);

%% plot a random sample of neurons
randset = randperm(neurons.N,20);

figure
cla
hold on
for m = 1:20
    plot(bins.centers,5*(m-1)+zscore(Y.data(:,randset(m))),...
        'color','k','linewidth',1)
end
hold off
clear m
title({'Random Sample of Neurons:','binned, smoothed, and averaged over trials'})
xlabel('time relative to stimulus [s]')
yticks([])

%% Plot total activity 
% sum over all neurons and trials

y1 = sum(Y.binned,[2,3]); % this requires R2018b or later, otherwise use nested sums
y2 = sum(Y.smoothed,[2,3]);
t = bins.centers;
figure
bar(t,y1)
hold on
plot(t,y2,'r','linewidth',2)
title('PSTH summed over all neurons and trials')
xlabel('time [s] relative to stimulus')
ylabel('Total activity')
legend('binned','smoothed','location','northwest')
clear y1 y2 t

%% Plot PSTH for each region
% include only neurons that pass test1 (encode stimulus AND movement)
% show standard error (uncertainty in the mean)

t = bins.centers;
figure
for r = 1:regions.N
    subplot(regions.N,1,r)
    y = Y.data(:,neurons.region==r & neurons.test1);
    plot(t,mean(y,2),'color',regions.color(r,:),'linewidth',2)
    title([regions.name(r,:),' (',num2str(size(y,2)),' neurons)'])
    se = std(y,1,2)/sqrt(length(y)); % standard error is uncertainty IN the mean
    hold on
    plot(t,mean(y,2)+se,'color',.5*regions.color(r,:))
    plot(t,mean(y,2)-se,'color',.5*regions.color(r,:))
    hold off
    
    
end
clear r t y se
xlabel('time relative to stim [s]')





