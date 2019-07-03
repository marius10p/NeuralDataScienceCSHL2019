% load data into spike trains (1ms time bins, this can be changed)

% CHANGE data_location VARIABLE TO LOCAL DATA LOCATION
data_location = '/Users/kathrynbonnen/Dropbox/CSHL_neural_data_analysis/Smith_cshl_data_2019/';
which_data = 'Wi170428.mat'; % or Pe170417.mat
load([data_location which_data])


%% Convert data into 1 ms binned spike trains.

binSz = 1/1000; % seconds

% TODO what order were the trials completed in

[II] = find(~cellfun(@isempty,ex.EVENTS));   % find all non-empty cells in ex.EVENTS (i.e. all real trials)
[UNIT,CONDITION,REPEATS] = ind2sub(size(ex.EVENTS),II);

TIME = -2:binSz:2;
SPIKE_TRAINS = nan(length(TIME)-1,length(II));

for tr = 1:length(SPIKE_TRAINS)
    tmp = ex.EVENTS{UNIT(tr),CONDITION(tr),REPEATS(tr)};
    SPIKE_TRAINS(:,tr) = histcounts(tmp,TIME)';     % convert spike times to spike train
end



%% Plot raster of responses to condition c and unit u
u = 3;
c = 1;

bins = TIME(1:end-1) + diff(TIME)/2;
spikes = SPIKE_TRAINS(:,CONDITION==c & UNIT==u);
spikes = spikes.*(1:size(spikes,2));
spikes(spikes==0) = NaN;

figure(2); clf; hold on;
plot(bins,spikes,'k.','HandleVisibility','off')
xlabel('time relative to stimulus onset (s)')
ylabel('repeat');
ylim([-5,size(spikes,2)+6])


ax = gca;
plot(-.5*[1,1],ax.YLim,'Color',[.5,.5,.5],'LineWidth',1);
plot([0,0],ax.YLim,'g','LineWidth',1);
plot([1,1],ax.YLim,'r','LineWidth',1);

legend({'fixation on','stimulus on','stimulus off'});
box off;
