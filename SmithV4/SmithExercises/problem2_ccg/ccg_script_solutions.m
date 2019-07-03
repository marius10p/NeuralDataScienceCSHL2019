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
sp1 = [rand(nTimePts,1) > 0.9]*nTimePts;
sp2 = circshift(sp1,10);

[c,lag] = xcorr(sp1,sp2,'unbiased');
plot(lag,c);

% (2) Incorporate some variation in the lagged spike train across
% trials, and then compute an average CCG
ntrials = 100;
c = [];
for I=1:ntrials
    timeshift=ceil(rand(1,1)*10)+10;
    sp1 = [rand(nTimePts,1) > 0.9];
    sp2 = circshift(sp1,timeshift);
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
    timeshift=ceil(rand(1,1)*10)+10;
    sp1(I,:) = [rand(1,nTimePts) > 0.9];
    sp2(I,:) = circshift(sp1(I,:)',timeshift)';
end
sidx = randperm(ntrials,ntrials);
for I=1:ntrials
    [c(I,:),lag] = xcorr(sp1(I,:),sp2(I,:),'unbiased');
    [cs(I,:),lag] = xcorr(sp1(I,:),sp2(sidx(I),:),'unbiased');
end
plot(lag,nanmean(c)); hold on;
plot(lag,nanmean(cs),'r'); hold off;
clf;

plot(lag,nanmean(c)-nanmean(cs)); % note this is now centered on zero

%% Computing CCGs in real data

% (1) Compute the average shuffle-corrected CCG for all pairs of neurons

load('../data/Wi170428_spikes.mat');

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

count = 1;
sidx = randperm(nRep,nRep);
csave = nan(nchoosek(nCells,2),nTimePts*2-1);
csaveshuf = nan(nchoosek(nCells,2),nTimePts*2-1);
for I=1:nCells
    disp(['Pairing cell ',num2str(I)]);
    for J = I+1:nCells
        c = nan(nRep,nTimePts*2-1);
        cs = nan(nRep,nTimePts*2-1);        
        for K=1:nRep
            [c(K,:),~] = xcorr(squeeze(sMat1(I,K,:)),squeeze(sMat1(J,K,:)),'unbiased');
            [cs(K,:),lag] = xcorr(squeeze(sMat1(I,K,:)),squeeze(sMat1(J,sidx(K),:)),'unbiased');
        end
        csave(count,:) = nanmean(c);
        csaveshuf(count,:) = nanmean(cs);
        count = count + 1;
    end
end
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
       [rsave1(I,J),~]=corr(sCount1(I,:)',sCount1(J,:)'); 
       [rsave2(I,J),~]=corr(sCount2(I,:)',sCount2(J,:)'); 
    end
end

% Now compute the autocorrelogram (ACG) for each neuron and plot
asave = nan(nCells,nTimePts*2-1);
asaveshuf = nan(nCells,nTimePts*2-1);
sidx = randperm(nRep,nRep);
for I=1:nCells
    disp(['ACG for cell ',num2str(I)]);
    a = nan(nRep,nTimePts*2-1);
    as = nan(nRep,nTimePts*2-1);
    for K=1:nRep
        [a(K,:),~] = xcorr(squeeze(sMat1(I,K,:)),squeeze(sMat1(I,K,:)),'unbiased');
        [as(K,:),lag] = xcorr(squeeze(sMat1(I,K,:)),squeeze(sMat1(I,sidx(K),:)),'unbiased');
    end
    asave(I,:) = nanmean(a);
    asaveshuf(I,:) = nanmean(as);
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

clear PSTH1 PSTH2 ACG1_AVE ACG2_AVE ACG2_shuffle ACG1_shuffle PSTH_shuffle
% ----------------------------------
% Computes the ACGs for cell1 and 2
for l=1:size(CELL1,2)       % number of stim
    ACG1=[];ACG2=[];CCG=[];
    for j=1:size(CELL1,1);  % number of trials
        clear bb cc
        bb=zeros(1,nTimePts);
        cc=zeros(1,nTimePts);
        
        bbidx = CELL1{j,l};
        bbidx(bbidx <= 0 | bbidx >= nTimePts) = [];
        ccidx = CELL2{j,l};
        ccidx(ccidx <= 0 | ccidx >= nTimePts) = [];
        bb(bbidx)=1;
        cc(ccidx)=1;
        bb=bb';
        cc=cc';
        
        ACG1=[ACG1 xcorr(bb,bb,nTimePts)];
        ACG2=[ACG2 xcorr(cc,cc,nTimePts)];
        CCG=[CCG xcorr(bb,cc,nTimePts)];
    end
    ACG1_AVEW(:,l)=mean(ACG1,2);
    ACG2_AVEW(:,l)=mean(ACG2,2);
    CCG_NEW_AVE(:,l)=mean(CCG,2);
end
clear cc dd ACG1 ACG2 bb cc
        
bins=(0:1:nTimePts);
for l=1:size(CELL1,2)       % number of stim
    PSTH_CELL1=[];
    PSTH_CELL2=[];
    for i=1:length(CELL1)
        xx=ceil(CELL1{i,l})';
        PSTH_CELL1=[PSTH_CELL1 xx];
        xx=ceil(CELL2{i,l})';
        PSTH_CELL2=[PSTH_CELL2 xx];
    end
    if size(PSTH_CELL1,1)>0 & size(PSTH_CELL2,1)>0
        PSTH1(l,:)=histc(PSTH_CELL1,bins)/length(CELL1);
        PSTH2(l,:)=histc(PSTH_CELL2,bins)/length(CELL1);
    else
        PSTH1(l,1:length(bins))=0;
        PSTH2(l,1:length(bins))=0;
    end
end
clear PSTH_CELL1 PSTH_CELL2
        
for l=1:size(CCG_NEW_AVE,2)
    [PSTH_shuffle(l,:),lag]=xcorr(PSTH1(l,:),PSTH2(l,:),nTimePts);
    % Computes the shuffle predictor based on the PSTHs
    ACG1_shuffle(l,:)=xcorr(PSTH1(l,:),PSTH1(l,:),nTimePts);
    % Computes the shuffle predictor based on the PSTHs
    ACG2_shuffle(l,:)=xcorr(PSTH2(l,:),PSTH2(l,:),nTimePts);
    % Computes the shuffle predictor based on the PSTHs
end
ACG1_shuffle=ACG1_shuffle';
ACG2_shuffle=ACG2_shuffle';
SHUFFLE=PSTH_shuffle';
        
% Computes the corrected CCG
CCG_CORRW=CCG_NEW_AVE-SHUFFLE;
ACG1_CORRW=ACG1_AVEW-ACG1_shuffle;
ACG2_CORRW=ACG2_AVEW-ACG2_shuffle;
        
clear ACG1_shuffle ACG2_shuffle PSTH_shuffle
        
% Compute the r_sc by integrating the CCG        
for l=1:size(CELL1,2)       % number of stim
    for k=1:nTimePts
        rsc_integrate(l,k)=sum(CCG_CORRW(nTimePts+1-k:nTimePts+1+k,l))/((sum(ACG1_CORRW(nTimePts+1-k:nTimePts+1+k,l))*sum(ACG2_CORRW(nTimePts+1-k:nTimePts+1+k,l)))^0.5);
    end
end

% Plot the results
subplot(4,1,1);
plot(lag,CCG_NEW_AVE(:,1),'b'); hold on;
plot(lag,SHUFFLE(:,1),'r');
plot(lag,CCG_CORRW(:,1),'k'); hold off; 
box off; set(gca,'tickdir','out');
legend({'raw','shuffled','corrected'});

subplot(4,1,2);
plot(PSTH1(1,:),'b'); hold on;
plot(PSTH2(1,:),'r'); hold off;
xlim([0 nTimePts]);
box off; set(gca,'tickdir','out');
legend({'Neuron1','Neuron2'});

subplot(4,1,3);
plot(lag,ACG1_CORRW(:,1),'b'); hold on;
plot(lag,ACG2_CORRW(:,1),'r'); hold off;
box off; set(gca,'tickdir','out');
xlim([-30 30]);
legend({'Neuron1','Neuron2'});

subplot(4,1,4);
plot(rsc_integrate(2,:),'k'); hold on;
xlim([0 nTimePts]);
line([0 nTimePts],[rsave2(n1,n2) rsave2(n1,n2)],'color','r'); hold off;
box off; set(gca,'tickdir','out');




