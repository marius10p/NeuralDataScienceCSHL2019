%% Example script for plaid data

load Wi170428_spikes.mat;

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

% EVENTS is cells X conditions X repeats
% there are 33 cells in this file, 1000 conditions, and a max of 126
% repeats

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

%% Now you should be able to make a tuning curve for the low contrast stimuli
% (hint: there are two sets of them)

% Insert your code here


% here's some plotting code for you (if you put your data in
% orifr/oristd/orin
hold on;
errorbar(ex.ORILIST(1:noris-1),orifr,oristd./sqrt(orin),'bo-'); box off;
hold off;

t = get(gca,'ylim');
set(gca,'ylim',[0 t(2)]);
legend({'100% contrast','50% contrast','50% contrast'})
