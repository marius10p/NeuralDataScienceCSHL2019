%% Example script for plaid data


load Wi170428.mat;


%% Plot an orientation tuning curve for one cell

cn = 11; % 11 is a good cell in Wi data file
lat = 50; % latency to shift the analysis window
msperstim = 100; % 100 ms per static grating/plaid
nstimperfix = size(ex.MOVIDX{1},1); % 10
noris = length(ex.ORILIST); % 9 - really 8 + one blank
stimbound = lat:msperstim:(nstimperfix*msperstim)+lat; % analysis bin edges

% to store responses into a cell array of 9x9 stimuli for this neuron
sp = cell(noris,noris); % for data
spr = zeros(noris,noris); % keep track of number of repeats

for I=1:length(ex.REPEATS)
    for J=1:ex.REPEATS(I)
        sp1 = ex.EVENTS{cn,I,J}*1000;
        stimvals = cell2mat(ex.MOVIDX(ex.ENV{I,J}.suffix));
        for K=1:nstimperfix
            newstimnum = spr(stimvals(K,1),stimvals(K,2))+1;
            spr(stimvals(K,1),stimvals(K,2)) = newstimnum;
            sp{stimvals(K,1),stimvals(K,2)}(newstimnum) = length(find(sp1>stimbound(K) & sp1<stimbound(K+1)));
            
        end
    end
end

% now, a tuning curve for the high contrast stim
for I=1:noris-1
    orifr(I) = nanmean(sp{I,I}*(1000/msperstim));
    oristd(I) = nanstd(sp{I,I}*(1000/msperstim));
    orin(I) = size(sp{I,I},2);
end

figure;
errorbar(ex.ORILIST(1:noris-1),orifr,oristd./sqrt(orin),'ko-'); box off;

xlabel('Grating orientation (degrees)');
ylabel('Firing rate (sp/s)');
set(gca,'tickdir','out');
xlim([-10 170]);

title([ex.FILENAME(1:8),' - ch',num2str(ex.CHANNELS(cn,1)),' - SNR: ',num2str(ex.SNR(cn))]);

% now, a tuning curve for the low contrast stim
for I=1:noris-1
    orifr(I) = nanmean(sp{I,noris}*(1000/msperstim));
    oristd(I) = nanstd(sp{I,noris}*(1000/msperstim));
    orin(I) = size(sp{I,noris},2);
end

hold on;
errorbar(ex.ORILIST(1:noris-1),orifr,oristd./sqrt(orin),'ro-'); box off;
hold off;

% and, the other tuning curve for the low contrast stim
for I=1:noris-1
    orifr(I) = nanmean(sp{noris,I}*(1000/msperstim));
    oristd(I) = nanstd(sp{noris,I}*(1000/msperstim));
    orin(I) = size(sp{noris,I},2);
end

hold on;
errorbar(ex.ORILIST(1:noris-1),orifr,oristd./sqrt(orin),'bo-'); box off;
hold off;

t = get(gca,'ylim');
set(gca,'ylim',[0 t(2)]);
legend({'100% contrast','50% contrast','50% contrast'})

%% Find average evoked potential for same unit

cn = ex.CHANNELS(11,1); % 11 is a good cell in Wi data file, it's on ch 19
lat = 0; % latency to shift the analysis window
msperstim = 100; % 100 ms per static grating/plaid
nstimperfix = size(ex.MOVIDX{1},1); % 10
noris = length(ex.ORILIST); % 9 - really 8 + one blank
stimbound = (0:msperstim:(nstimperfix*msperstim)) + 1; % analysis bin edges

% to store responses into a cell array of 9x9 stimuli for this neuron
sp = cell(noris,noris); % for data
spr = zeros(noris,noris); % keep track of number of repeats

for I=1:length(ex.REPEATS)
    for J=1:ex.REPEATS(I)
        l1 = ex.LFP{cn,I,J};
        t1 = ex.NSTIME{I,J};
        
        lidx = find(t1>=0,1)+lat;
        lidxe = lidx + stimbound(end) + lat;
        lt = l1(lidx:lidxe);
        
        stimvals = cell2mat(ex.MOVIDX(ex.ENV{I,J}.suffix));
        for K=1:nstimperfix
            newstimnum = spr(stimvals(K,1),stimvals(K,2))+1;
            spr(stimvals(K,1),stimvals(K,2)) = newstimnum;
            sp{stimvals(K,1),stimvals(K,2)}(newstimnum,:) = lt(stimbound(K):stimbound(K+1));
            %length(find(sp1>stimbound(K) & sp1<stimbound(K+1)));
        end
    end
end

% now, an average LFP for the high contrast stim
for I=1:noris-1
    orilfp(I,:) = nanmean(sp{I,I});
    orilfpsem(I,:) = nanstd(sp{I,I})./sqrt(size(sp{I,I},1));
end

figure;
for I=1:noris-1
    subplot(noris-1,1,I);
    plot(0:msperstim,orilfp(I,:));
    ylim([min(orilfp(:)) max(orilfp(:))]);
    set(gca,'tickdir','out');
    box off;
end

%% Extract a 3D matrix of LFP data

rptIdx = ones(numel(ex.REPEATS),1);
timeCut = -1000:1:2000;
lfp3D = nan(numel(ex.LFPCHANNELS),numel(timeCut),numel(ex.TRIAL_SEQUENCE));
eye3D = nan(size(ex.EYES,1),numel(timeCut),numel(ex.TRIAL_SEQUENCE));

for I=1:numel(ex.TRIAL_SEQUENCE)
    lfptmp = cell2mat(ex.LFP(:,ex.TRIAL_SEQUENCE(I),rptIdx(ex.TRIAL_SEQUENCE(I))));
    eyetmp = cell2mat(ex.EYES(:,ex.TRIAL_SEQUENCE(I),rptIdx(ex.TRIAL_SEQUENCE(I))));
    timeIdx = cell2mat(ex.NSTIME(ex.TRIAL_SEQUENCE(I), rptIdx(ex.TRIAL_SEQUENCE(I))));
    idx1 = find(timeIdx > timeCut(1)/1000,1);
    idx2 = find(timeIdx > timeCut(end)/1000,1);
    lfp3D(:,:,I) = lfptmp(:,idx1:idx2);
    eye3D(:,:,I) = eyetmp(:,idx1:idx2);
    rptIdx(ex.TRIAL_SEQUENCE(I)) = rptIdx(ex.TRIAL_SEQUENCE(I)) + 1;
end

% quick plot for one channel
cn = ex.CHANNELS(15,1);
evokedPotential = nanmean(squeeze(lfp3D(cn,:,:))');
plot(timeCut,evokedPotential);
set(gca,'tickdir','out');
box off;
xlabel('Time (ms)')
ylabel('Voltage (uV)');

% eye plots
eyex = squeeze(eye3D(1,:,:));
eyey = squeeze(eye3D(2,:,:));
subplot(2,1,1);
plot(timeCut,eyex); set(gca,'tickdir','out'); box off;
ylabel('Eye X (deg)');
subplot(2,1,2);
plot(timeCut,eyey); set(gca,'tickdir','out'); box off;
xlabel('Time (ms)')
ylabel('Eye Y (deg)');

