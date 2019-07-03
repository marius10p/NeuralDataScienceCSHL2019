% Smith dataset tour

%% load data set
load Wi170428.mat

%% examine contents of data set
% 
%  variable ex is a
%
%   struct with fields:
% 
%             EVENTS: {33×1000×126 cell}
%               EYES: {3×1000×126 cell}
%                LFP: {96×1000×126 cell}
%        LFPCHANNELS: [96×1 double]
%             NSTIME: {1000×126 cell}
%               MSGS: {1000×126 cell}
%              CODES: {1000×126 cell}
%           CHANNELS: [33×2 double]
%     TRIAL_SEQUENCE: [1443×1 double]
%            REPEATS: [1×1000 double]
%          PRE_TRIAL: {1×1443 cell}
%                ENV: {1000×126 cell}
%           FILENAME: 'Wi170428_s285a_plaidmovie_0004.nev'
%             MOVIDX: {1×2000 cell}
%             MOVORI: {1×2000 cell}
%            ORILIST: [1×9 double]
%               SEED: 1975
%                MAP: [10×10 double]
%                SNR: [33×1 double]
%                 SC: [33×1 double]
%

ex

%% Orientation/Definitions
% To orient you, there are 33 ?units? (single + multi-unit spikes) in this 
% file with 96 electrodes (the array was OK quality at this point, not great 
% but still good). 

fprintf('\n------------------------------------------------')

% ex.EVENTS has the spike times for all trials (it?s a cell array of 
% unit # X condition # X repeat). 
fprintf('\n\n ex.Events is a cell array from an experiment \nwith: %i units x %i conditions x %i repeats.\n',...
    size(ex.EVENTS))
%  NOTE: These cell arrays aren?t fully populated - there can be a different number 
% of repeats of each stimulus. 


% If you want to know the electrode for each unit, you refer to the row of 
% ex.CHANNELS (first element is electrode number, second is sort code). 
fprintf('\n\n The first unit in the ex.Events cell array \n was on electrode %i. \n',...
    ex.CHANNELS(1))


% ex.SNR is a SNR metric for each unit.


% Similarly, ex.LFP is a cell array of chan # X condition # X repeat. 


% The number of repeats for each sequence shown is in ex.REPEATS (indexed by 
% condition). So, for example, ex.REPEATS(1) is 124, because that first 
% condition was repeated 124 times. The first two ?movies? (10-frame plaid
% sequences) were repeated many times each, the rest of them were just shown 
% 1-2 times each. You can see this in ex.REPEATS. 


% ex.TRIAL_SEQUENCE shows the actual sequence of conditions shown to the animal.
fprintf('\n\n A total of %i trials were completed during \nthis experiment.\n\n',...
    size(ex.TRIAL_SEQUENCE,1))


%% STIMULI
% The stimuli were a 9x9 array of plaids (8 orientations and a blank, fully-crossed). 
%
% The possible stimulus conditions are listed in ex.MOVIDX and ex.MOVORI,
% where ex.MOVORI actually lists the two orientations (or blank) that were
% shown and ex.MOVIDX lists the indices which correspond to ex.ORILIST
%

fprintf('\n------------------------------------------------')

% for example the first condition:
fprintf('\n\nex.MOVORI{1}\n');
ex.MOVORI{1}
fprintf('\nex.MOVIDX{1}\n');
ex.MOVIDX{1}
fprintf('\nex.ORILIST\n');
ex.ORILIST

% TODO: SHOW an example of a plaid series
im = zeros(256);

%% Eye traces
% Eye data is in ex.EYES(channel X condition X repeat), where channels
% 1/2 are X/Y in degrees and channel 3 is pupil diameter. 
c = 1; r=1;

figure(1); clf; subplot(211); hold on;
plot(ex.NSTIME{c,r},  ex.EYES{1,c,r});
plot(ex.NSTIME{c,r},  ex.EYES{2,c,r});
ylim([-20,25])
ylabel('position (deg)');
xlabel('time relative to stimulus onset (s)');
xlim([min(ex.NSTIME{c,r}),max(ex.NSTIME{c,r})])
title('eye traces')

subplot(212); hold on;
plot(ex.NSTIME{c,r},  ex.EYES{3,c,r});
ylim([-2500,-1500])
ylabel('pupil diameter (?)');
xlabel('time relative to stimulus onset (s)');
xlim([min(ex.NSTIME{c,r}),max(ex.NSTIME{c,r})])
title('pupil diameter');

% the noticeable spikes are blinks

% ex.NSTIME(condition X repeat) is the time index in seconds of the LFP 
% and eye data. It?s aligned in the same way as the spikes, so zero is 
% stimulus onset (and up to -0.5 is the fixation before the stimulus). 

%% Other variables

% ex.MAP is the spatial layout of the array (channels in the 10x10 grid)

% ex.ENV contains a ton of variables from the stimulus and the experiment, 
% but can mostly be ignored given the alignment already done and the other 
% information I?ve given you. There?s plenty of other stuff you can ignore 
% as well for now, but has potentially useful info about the experiment.

%% Convert data into 1 ms binned spike trains.

binSz = 1/1000; % seconds


[II] = find(~cellfun(@isempty,ex.EVENTS));   % find all non-empty cells in ex.EVENTS (i.e. all real trials)
[UNIT,CONDITION,REPEATS] = ind2sub(size(ex.EVENTS),II);

time = -2:binSz:2;
SPIKE_TRAINS = nan(length(time)-1,length(II));

for tr = 1:length(SPIKE_TRAINS)
    tmp = ex.EVENTS{UNIT(tr),CONDITION(tr),REPEATS(tr)};
    SPIKE_TRAINS(:,tr) = histcounts(tmp,time)';     % convert spike times to spike train
end

%% Plot raster of responses to condition c and unit u
u = 3;
c = 1;

bins = time(1:end-1) + diff(time)/2;
SPIKES = SPIKE_TRAINS(:,CONDITION==c & UNIT==u);
SPIKES = SPIKES.*(1:size(SPIKES,2));
SPIKES(SPIKES==0) = NaN;

figure(2); clf; hold on;
plot(bins,SPIKES,'k.','HandleVisibility','off')
xlabel('time relative to stimulus onset (s)')
ylabel('repeat');
ylim([-5,size(SPIKES,2)+6])


ax = gca;
plot(-.5*[1,1],ax.YLim,'Color',[.5,.5,.5],'LineWidth',1);
plot([0,0],ax.YLim,'g','LineWidth',1);
plot([1,1],ax.YLim,'r','LineWidth',1);

legend({'fixation on','stimulus on','stimulus off'});
box off;

%% convert data into 10 ms binned spike trains.

binSz = 1/100; % seconds


[II] = find(~cellfun(@isempty,ex.EVENTS));   % find all non-empty cells in ex.EVENTS (i.e. all real trials)
[UNIT,CONDITION,REPEATS] = ind2sub(size(ex.EVENTS),II);

time = -2:binSz:2;
bins = time(1:end-1) + diff(time)/2;
SPIKE_TRAINS = nan(length(time)-1,length(II));

for tr = 1:length(SPIKE_TRAINS)
    tmp = ex.EVENTS{UNIT(tr),CONDITION(tr),REPEATS(tr)};
    SPIKE_TRAINS(:,tr) = histcounts(tmp,time)';     % convert spike times to spike train
end

%% Plot PSTH for condition c and unit u
u = 3;
c = 1;


figure(3); clf; hold on;
plot(bins,mean(SPIKE_TRAINS,2)/binSz,'k','LineWidth',2);
xlabel('time relative to stimulus onset (s)')
ylabel('spikes/s');
ax = gca;
plot(-.5*[1,1],ax.YLim,'Color',[.5,.5,.5],'LineWidth',1);
plot([0,0],ax.YLim,'g','LineWidth',1);
plot([1,1],ax.YLim,'r','LineWidth',1);

legend({'PSTH','fixation on','stimulus on','stimulus off'});

% ax = gca;
% for i=0:10
%    plot(i*.1*[1,1],ax.YLim)
% end

box off;
