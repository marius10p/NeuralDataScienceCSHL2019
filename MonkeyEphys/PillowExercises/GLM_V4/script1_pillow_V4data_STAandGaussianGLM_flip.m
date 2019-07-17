%script0_loadAndPreprocV2data.m
%
% Load data from V2 experiment and compute some basic quantities (spike
% counts per frame and STA). 

% Load the data
load testdata_v2.mat

% % Loads four variables (with training and test data):
% % ====================================================
% Training data (runs of unique 10-plaid stimuli, 1s each):
% -------------
% spikedata_train    1200x1193x33        377942400  double              
% stimarray_train      10x9x1193            858960  double  
%
% Test data (repeats of 2 different 10-plaid stimuli):
% ---------
% spikedata_test        1x2               79200224  cell                
% stimarray_test        1x2                   1664  cell                

%% Bin spike times in same bins as stimuli:

% get size of training data 
% (number of stim per plaid; dimensionality of stimulus, number of stimuli)
[nplaidperstim,nd,nstim] = size(stimarray_train);

% get number of neurons
nneur = size(spikedata_train,3);

% Set bin edges
ntignore = 100; % number of ms (bins) to ignore at beginning of each stimulus
taushift = 55; % time shift of spike count bins relative to stimulus (ms).
dtstim = 100; % # of ms in a single stimulus frame
binedges = [ntignore+taushift+ dtstim*(0:nplaidperstim)]; % edges of bins for summing spikes

% Compute binned spike counts: training data
spct_train = zeros(nplaidperstim,nstim,nneur);
for jj = 1:nplaidperstim
    spct_train(jj,:,:) = sum(spikedata_train(binedges(jj)+1:binedges(jj+1),:,:),1);
end

%% Make design matrix, spike count vectors, and compute STAs

% concatenate plaid stimuli from each trial to make design matrix
nTot = nplaidperstim*nstim;
% 10*trials x plaidID , stimulus matrix
Xdsgn = reshape(permute(stimarray_train,[1,3,2]),nTot,nd); % size: [nTot x 9]
Xmu = mean(Xdsgn); % mean of each stimulus bin
Xdsgn0 = Xdsgn-repmat(Xmu,nTot,1); % zero-mean design matrix (if desired)

% concatenate responses to make spike count vectors
Yrsp = reshape(spct_train,nTot,nneur); % size: [nTot x nneur]

% Compute STA
nsp = sum(Yrsp); % spike counts per neuron
STAs = (Xdsgn0'*Yrsp)./repmat(nsp,nd,1);

% Plot results:
% ------------
% Plot first five neurons' STAs
figure;
subplot(211);
plot(STAs(:,1:5)); xlabel('stim orientation'); ylabel('mean stim per spike');
legend('neuron 1','neuron 2','neuron 3','neuron 4','neuron 5');
title('STAs');

% Image all neuron STAs
subplot(212);
imagesc(STAs);
xlabel('neuron #'); ylabel('stim orientation');

%% Do least-squares regression

% Compute least-squares regression weights
wSTAs = (Xdsgn'*Xdsgn)\(Xdsgn'*Yrsp);  % whitened STAs
stimdc = sum(Xdsgn(1,:)); % all rows of Xdsgn have a mean of 2!
dc = mean(wSTAs); % separate out constant from weights
zwSTAs = wSTAs - repmat(dc,nd,1); % zero-mean whitened weights

% Plot results:
% ------------
% Show weights of first five neurons
figure;
subplot(211);
plot(zwSTAs(:,1:5)); xlabel('orientation'); ylabel('regression weight');
legend('neuron 1','neuron 2','neuron 3','neuron 4','neuron 5');
title('LS regression weights');

% Image all neuron STAs
subplot(212);
imagesc(zwSTAs);
xlabel('neuron #'); ylabel('stim orientation');

%% Compute least squares regression prediction on training data (if desired)

dcPerNeuron = dc*stimdc; % intercept (dc term) for each neuron
pred_train = Xdsgn*zwSTAs + repmat(dcPerNeuron,nTot,1);
% pred_train0 = Xdsgn*wSTAs;  %% Check that this is the same (if desired)

Ymu = mean(Yrsp,1);
Yvar = sum((Yrsp-repmat(Ymu,nTot,1)).^2);
R2_train = 1-sum((Yrsp - pred_train).^2)./Yvar;
fprintf('average training R^2: %.3f\n', mean(R2_train));

% These R2 values are pretty small, but remember this is single-trial spike
% train data


%% Compute test data PSTH and model performance
%
% To do:

%% test data PSTH

    %the dimensions are: time x trials x neurons

    %get the first or second test condition
spikedatatoplot = spikedata_test{2};
    
%neurons 17,31 are nicely responsive to condition 1
%neurons 17, 18, 24 31, are nicely responsive to condition 2
for i = 17%1:nneur
    neurontoplot = i;    
    
    figure;
    set(gcf,'color','w')
    
    spikecounts = sum(spikedatatoplot(:,:,neurontoplot),2);
    numTrials = size(spikedatatoplot(:,:,neurontoplot),2);
    
    % avg #sp per trial *1000 -> inst FR, in sp/s
    plot(spikecounts./numTrials.*1000) 
    hold on;
    plot([100 100],ylim,'r:','LineWidth',2)
    plot([1100 1100],ylim,'r:','LineWidth',2)
    
    xlabel('time (ms)')
    ylabel('spk/s')
    
    title(strcat('neuron:',num2str(neurontoplot)))
    
%     pause(2)
%     close;
end



%% compute model performance: 
% compute regression weights from training set STA applied to testing set

% Here I am concatenating both conditions for testing performance

% Get first stim stuff
spikedata_test_m = spikedata_test{1};
stimarray_test_m = stimarray_test{1};
nstim_T = size(spikedata_test_m,2);
stimarray_test_m = repmat(stimarray_test_m,[1 1 nstim_T]);

% Get second stim stuff
spikedata_test_m2 = spikedata_test{2};
stimarray_test_m2 = stimarray_test{2};
nstim_T2 = size(spikedata_test_m2,2);
stimarray_test_m2 = repmat(stimarray_test_m2,[1 1 nstim_T2]);

% Put them together
spikedata_test_m = cat(2,spikedata_test_m,spikedata_test_m2);
stimarray_test_m = cat(3,stimarray_test_m,stimarray_test_m2);

% Grab dimensions
[nplaidperstim_T,nd_T,nstm_T] = size(stimarray_test_m);
nstim_T = size(spikedata_test_m,2);

% Compute binned spike counts: testing data
spct_train_T = zeros(nplaidperstim_T,nstim_T,nneur);
for jj = 1:nplaidperstim_T
    spct_train_T(jj,:,:) = sum(spikedata_test_m(binedges(jj)+1:binedges(jj+1),:,:),1);
end

%%

% Make design matrix, spike count vectors, and compute STAs

% concatenate plaid stimuli from each trial to make design matrix
nTot_T = nplaidperstim_T*nstim_T;
Xdsgn_T = reshape(permute(stimarray_test_m,[1,3,2]),nTot_T,nd_T); % size: [nTot x 9]


% concatenate responses to make spike count vectors
Yrsp_T = reshape(spct_train_T,nTot_T,nneur); % size: [nTot x nneur]

% Compute prediction
pred_test = Xdsgn_T*zwSTAs + repmat(dcPerNeuron,nTot_T,1);

% Compute performance
Ymu_T = mean(Yrsp_T,1);
Yvar_T = sum((Yrsp_T-repmat(Ymu_T,nTot_T,1)).^2);
R2_test = 1-sum((Yrsp_T - pred_test).^2)./Yvar_T;
fprintf('average testing R^2: %.3f\n', mean(R2_test));



%% Plot more stuff

% You can run this plotting for one neuron, or cycle through all visually
% see notes below

%17 and 31 are good visually responsive neurons for this animal
for i = 17%1:nneur
    neurontoplot = i;    
    
    % This figure plots the comparison between data and fitted STA weights
    % collapsed across all stimuli; separated by training/testing data
    
    figure;
    set(gcf,'color','w')
    
    
    subplot(211)
    
    pred_train_bins = reshape(pred_train,[10 1193 33]);
    Yrsp_bins = reshape(Yrsp,[10 1193 33]);
    predbins = sum(pred_train_bins(:,:,i),2)./size(pred_train_bins,2);
    obsbins = sum(Yrsp_bins(:,:,i),2)./size(pred_train_bins,2);
    
    plot(1:10,obsbins,'k'); hold on;
    plot(1:10,predbins,'r')
    
    xlabel('training all stims')
    ylabel('avg spike ct')

    legend('obs','pred')
    
    
    subplot(212)
    
    pred_test_bins = reshape(pred_test,[10 250 33]);
    Yrsp_T_bins = reshape(Yrsp_T,[10 250 33]);
    predbins = sum(pred_test_bins(:,:,i),2)./size(pred_test_bins,2);
    obsbins = sum(Yrsp_T_bins(:,:,i),2)./size(pred_test_bins,2);
    
    plot(1:10,obsbins,'k'); hold on;
    plot(1:10,predbins,'r')
    
    xlabel('testing all stims')
    ylabel('avg spike ct')

    suptitle(strcat('neuron:',num2str(i)))



    % This figure plots the PSTH of the response to the SECOND stimulus
    % and then compares the binned PSTH to the response reconstructed from
    % the STA
    
    figure;
    set(gcf,'color','w')
    
    spikedatatoplot = spikedata_test{2};
    
    spikecounts = sum(spikedatatoplot(:,:,neurontoplot),2);
    numTrials = size(spikedatatoplot(:,:,neurontoplot),2);
    
    subplot(211)
    % avg #sp per trial *1000 -> inst FR, in sp/s
    plot(spikecounts./numTrials.*1000) 
    hold on;
    plot([100 100],ylim,'r:','LineWidth',2)
    plot([1100 1100],ylim,'r:','LineWidth',2)
    
    xlabel('time (ms)')
    ylabel('FR spk/s')
    
    title(strcat('neuron:',num2str(neurontoplot)))
    
    subplot(212)
    
    pred_test_bins = reshape(pred_test,[10 250 33]);
    Yrsp_T_bins = reshape(Yrsp_T,[10 250 33]);
    predplot_bins = sum(pred_test_bins(:,size(spikedata_test{1},2)+1:end,i),2)./size(spikedata_test{2},2).*10; %sp/s in bin
    Yrspplot_bins = sum(Yrsp_T_bins(:,size(spikedata_test{1},2)+1:end,i),2)./size(spikedata_test{2},2).*10;

    % align in time with PSTH
    plot(binedges(1:10),Yrspplot_bins,'k'); hold on;
    plot(binedges(1:10),predplot_bins,'r')
    xlim([0 1200])
    
    xlabel('obs (binned PSTH) v pred (from STA) response to stim 2')
    ylabel('mean FR spk/s')
    
    legend('obs','pred')

    
    %this is a general plot to look at all neurons
%     figure;
%     plot(1:nTot_T,Yrsp_T_bins(:,i),'k'); hold on;
%     plot(1:nTot_T,pred_test_bins(:,i),'r')
    
    % uncomment if you want to run this loop for all neurons
%     pause(2)
%     close;

end



%% SANITY CHECK : try switching train and test data, i.e. train on repeated data

% Make design matrix, spike count vectors, and compute STAs

Xmu_T = mean(Xdsgn_T); % mean of each stimulus bin
Xdsgn0_T = Xdsgn_T-repmat(Xmu_T,nTot_T,1); % zero-mean design matrix (if desired)


% Compute STA
nsp_T = sum(Yrsp_T); % spike counts per neuron
STAs_T = (Xdsgn0_T'*Yrsp_T)./repmat(nsp_T,nd_T,1);

% Plot results:
% ------------
% Plot first five neurons' STAs
figure;
subplot(211);
plot(STAs_T(:,1:5)); xlabel('stim orientation'); ylabel('mean stim per spike');
legend('neuron 1','neuron 2','neuron 3','neuron 4','neuron 5');
title('STAs  - TRAINING ON REPEATED (TEST) DATA');

% Image all neuron STAs
subplot(212);
imagesc(STAs_T);
xlabel('neuron # - TRAINING ON REPEATED (TEST) DATA'); ylabel('stim orientation');


% Compute least-squares regression weights
wSTAs_T = (Xdsgn_T'*Xdsgn_T)\(Xdsgn_T'*Yrsp_T);  % whitened STAs
stimdc = sum(Xdsgn(1,:)); % all rows of Xdsgn have a mean of 2!
dc_T = mean(wSTAs_T); % separate out constant from weights
zwSTAs_T = wSTAs_T - repmat(dc_T,nd_T,1); % zero-mean whitened weights

% Plot results:
% ------------
% Show weights of first five neurons
figure;
subplot(211);
plot(zwSTAs_T(:,1:5)); xlabel('orientation'); ylabel('regression weight');
legend('neuron 1','neuron 2','neuron 3','neuron 4','neuron 5');
title('LS regression weights - TRAINING ON REPEATED (TEST) DATA');

% Image all neuron STAs
subplot(212);
imagesc(zwSTAs_T);
xlabel('neuron # - TRAINING ON REPEATED (TEST) DATA'); ylabel('stim orientation');


dcPerNeuron_T = dc_T*stimdc; % intercept (dc term) for each neuron
pred_train_TT = Xdsgn_T*zwSTAs_T + repmat(dcPerNeuron_T,nTot_T,1);
% pred_train0 = Xdsgn*wSTAs;  %% Check that this is the same (if desired)

Ymu_T = mean(Yrsp_T,1);
Yvar_T = sum((Yrsp_T-repmat(Ymu_T,nTot_T,1)).^2);
R2_train_T = 1-sum((Yrsp_T - pred_train_TT).^2)./Yvar_T;
fprintf('average TRAINING ON REPEATED (TEST) R^2: %.3f\n', mean(R2_train_T));

% These R2 values are better than training on training data, 
% which makes sense
% BUT does it overfit?

pred_test_training = Xdsgn*zwSTAs_T + repmat(dcPerNeuron,nTot,1);

R2_test_training = 1-sum((Yrsp - pred_test_training).^2)./Yvar;
fprintf('average TESTING ON NON-REPEATED (TRAIN) R^2: %.3f\n', mean(R2_test_training));

% looks like using 2 repeated stimuli massively overfits, which 
% also makes sense since STA works best with white noise stimuli

