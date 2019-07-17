% Pe170417_spikes.mat
load ~/Documents/NeuralDataScienceCSHL2019/MonkeyEphys/SmithExercises/data/Wi170428_spikes.mat
%% pull out responses to plaids (100ms chunks with latency of 50ms) 
% and convert those responses to spike count trains with 


sz = size(ex.EVENTS);
nUnits = sz(1);
nTrials = length(ex.TRIAL_SEQUENCE);

lat = 50; % latency to shift the analysis window
binSz = 10; % milliseconds
msperstim = 100; % 100 ms per static grating/plaid
nstimperfix = size(ex.MOVIDX{1},1); % 10
noris = length(ex.ORILIST); % 9 - really 8 + one blank
stimbound = lat:msperstim:(nstimperfix*msperstim)+lat; % analysis bin edges

nRows = nstimperfix*nTrials;

% pre-allocate memory for variables 
% If you don't do it this way the code takes much longer to run.
CellNum = nan(nRows,1);
TrialNum = nan(nRows,1);
Grating1 = nan(nRows,1);
Grating2 = nan(nRows,1);
EpochNum = nan(nRows,1);
Cond = nan(nRows,1);
CondRepeat = nan(nRows,1);
BinnedSpikeTrains= nan(nUnits,100/binSz,nRows);
SpikeTimes = cell(nUnits,nRows);
SpikeCounts = nan(nUnits, nRows);
time = 0:binSz:100;
bins = time(1:end-1) + diff(time)/2;

% extract data measured per unit
for u = 1:nUnits
    n=1;
    cnt = zeros([sz(2) 1]); % repeat counter
    spr = zeros(9,9);
    for t=1:length(ex.TRIAL_SEQUENCE)
        c = ex.TRIAL_SEQUENCE(t);
        cnt(c) = cnt(c)+1; % increment repeat counter for trial
        rep = cnt(c);
        stimvals = cell2mat(ex.MOVIDX(c));

        % spikes
        sp1 = ex.EVENTS{u,c,rep}*1000; % get spike timestamps for trial and convert to milliseconds

        % divide spikes into the 100ms chunks with 50ms latency
        for K=1:nstimperfix
            newstimnum = spr(stimvals(K,1),stimvals(K,2))+1;
            spr(stimvals(K,1),stimvals(K,2)) = newstimnum;

            CellNum(n) = u;
            TrialNum(n) = t;
            Grating1(n) = stimvals(K,1);
            Grating2(n) = stimvals(K,2);
            EpochNum(n) = K;
            Cond(n) = c;
            CondRepeat(n) = rep;
            SpikeTimes{u,n} = sp1(sp1>stimbound(K) & sp1<stimbound(K+1)) - ((K-1)*100+lat);
            SpikeCounts(u,n) = length(SpikeTimes{u,n});
            BinnedSpikeTrains(u,:,n) =  histcounts(SpikeTimes{u,n},time)';
            n=n+1;
        end

    end

end
