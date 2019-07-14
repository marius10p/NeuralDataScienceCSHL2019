%%% Exercises for understanding the CCG

%% Modeling the CCG

% The CCG, or cross-correlogram, is a plot of the spike times of one neuron
% relative to another. In order to understand a CCG, however, we need to
% think about how it is constructed, how a chance expectation is computed,
% and how it relates to r_sc. Let's start with some models.

% Simple model of two "spike trains".
nTimePts = 1000;
sp1 = [rand(nTimePts,1)];
sp2 = [rand(nTimePts,1)];

% Compute the CCG and plot it (xcorr does this for us in matlab)
[c,lag] = xcorr(sp1,sp2);
plot(lag,c);

% Question - Why does the CCG look like a triangle for two different sets
% of random numbers? Once we understand why, we can let matlab compensate
% for it:
[c,lag] = xcorr(sp1,sp2,'unbiased');
plot(lag,c);

% Now let's make 'realistic' spike trains 
sp1 = [rand(nTimePts,1) > 0.9];
sp2 = [rand(nTimePts,1) > 0.9];

[c,lag] = xcorr(sp1,sp2,'unbiased');
plot(lag,c);

% (1) Correlate the spike trains and see what happens to the CCG. 
% Hint - try using circshift to create a lagged spike train.
sp1 = [];
sp2 = [];

[c,lag] = xcorr(sp1,sp2,'unbiased');
plot(lag,c);

% (2) Incorporate some variation in the lagged spike train across
% trials, and then compute an average CCG
ntrials = 100;
c = [];
for I=1:ntrials

    % Your code here
    
    [c(I,:),lag] = xcorr(sp1,sp2,'unbiased');
end
plot(lag,nanmean(c))

% (3) Subtract off a trial-shuffled version (note what happens to
% the vertical axis values)
ntrials = 100;
c = []; cs = [];
sp1 = nan(ntrials,nTimePts);
sp2 = nan(ntrials,nTimePts);
for I=1:ntrials
    % Your code here
    sp1(I,:) = [];
    sp2(I,:) = [];
end

for I=1:ntrials
    % Your code here
end
plot(lag,nanmean(c)); hold on;
plot(lag,nanmean(cs),'r'); hold off;
clf;

plot(lag,nanmean(c)-nanmean(cs)); % note this is now centered on zero

%% Computing CCGs in real data

% (1) Compute the average shuffle-corrected CCG for all pairs of neurons

load('Wi170428_spikes.mat');

% Focusing on the first stimulus, let's extract out the spikes for every 
% neuron in the first two 1s stimulus

nTimePts = 1000;
stimNum = [1 2];
nCells = size(ex.EVENTS,1);
nRep = min(ex.REPEATS(1:2));
stimTime = 1000;
sMat1 = zeros(nCells,nRep,stimTime);
sMat2 = zeros(nCells,nRep,stimTime);

for I=1:nCells
    for J=1:nRep
        spks = ex.EVENTS{I,stimNum(1),J};
        spks = ceil(spks(spks>0 & spks<(stimTime/1000))*1000);
        sMat1(I,J,spks)=1;
        spks = ex.EVENTS{I,stimNum(2),J};
        spks = ceil(spks(spks>0 & spks<(stimTime/1000))*1000);
        sMat2(I,J,spks)=1;
    end
end

% Now, compute the correlation between every pair, and average
% Plot the raw, the shuffle, and the shuffle-subtracted versions

% Your code here

plot(lag,nanmean(csave)); hold on;
plot(lag,nanmean(csaveshuf),'r'); hold off;

clf;
plot(lag,nanmean(csave)-nanmean(csaveshuf));

% (2) Compare r_sc to the CCG

% First, compute r_sc in this data for each stimulus
rsave1 = nan(nCells,nCells);
rsave2 = nan(nCells,nCells);
sCount1 = sum(sMat1,3);
sCount2 = sum(sMat2,3);
for I=1:nCells
    for J = I+1:nCells
        % Compute r_sc here and store it in rsave1/rsave2
    end
end

% Now compute the autocorrelogram (ACG) for each neuron and plot
asave = nan(nCells,nTimePts*2-1);
asaveshuf = nan(nCells,nTimePts*2-1);
for I=1:nCells
    disp(['ACG for cell ',num2str(I)]);
    % Your code here
end
plot(lag,nanmean(asave)-nanmean(asaveshuf));

% Pick two cells and let's compute a CCG, and then ACG, and then r_ccg
% The goal here is to compute the CCG (don't need to use the 'unbiased'
% option) and ACG for each trial, then average. Then compute a shuffled
% prediction, in this case using a new method. Just compute the PSTH, and
% xcorr that (this is the expected average of all possible shuffles). Then,
% the r_ccg is the area under the shuffle-corrected CCG, divided by the
% square root of the product of the areas under the ACGs. Try this for a
% pair of neurons, and visualize the CCG, the ACGs, and r_ccg. Show that
% the full value of r_ccg (integrated across the trial) is equal to r_sc.

%% Some code to get you started:
n1 = 3;
n2 = 31;
CELL1=squeeze(ex.EVENTS(n1,1:2,1:min(ex.REPEATS(1:2))))';
tdiv = num2cell(ones(size(CELL1)) * .001); % convert to ms
CELL1 = cellfun(@rdivide,CELL1,tdiv,'UniformOutput',false);
CELL1 = cellfun(@round,CELL1,'UniformOutput',false);
CELL2=squeeze(ex.EVENTS(n2,1:2,1:min(ex.REPEATS(1:2))))';
tdiv = num2cell(ones(size(CELL2)) * .001); % convert to ms
CELL2 = cellfun(@rdivide,CELL2,tdiv,'UniformOutput',false);
CELL2 = cellfun(@round,CELL2,'UniformOutput',false);

% Your code here

% Plot the results



