%% Example script for plaid data

clear all;

load Wi170428.mat;
numNeurons = 33; % uncomment for Wi170428


% load Pe170417.mat;
% numNeurons = 31; % uncomment for Pe170417

prewin = 100;       %ms before trial to store
postwin = 100;      %ms after trial to store
trialLength = 1000; %trial duration, ms

%% STIMULI

% STIMULI:  each stimulus was a plaid composed of 2 gratings drawn from a set of 
% 8 unique orientations + a blank.  This means we can think about representing each stimulus
% as a sparse 9-vector: all zeros with two 1's indicating the identity of the gratings making 
% up the plaid (and having a 2 in a single bin if both were the same grating, or both blank).    
% 
% Thus, for stimuli we should have Nframes x 9 matrix  (composed of 0s, 1s, and 2s)

%% RESPONSES
% 
% RESPONSES: a binary representation of each neuron's spike train, in 1ms bins.
% Includes time before and after stimulus as defined above.


%%

% set up training (non-repeat data)

% this is everything but the first two conditions (unique plaid sequences)
ntrials = sum(ex.REPEATS(3:end));

% set up stimulus representation for nonrepeat stimuli
stimarray_train = zeros(10,9,ntrials); % frame #, plaid ID, trial #

% 3rd dimension holds chronological order of
% this stimulus - see ex.TRIAL_SEQUENCE

% spike data (response) array
% time x # trials x nneurons
spikedata_train = zeros(prewin+trialLength+postwin,sum(ex.REPEATS(3:end)),numNeurons);
    
% set a separate counter since we're omitting some trials
trialcounter = 1;

% omit the first two conditions 
for i = 1:length(ex.TRIAL_SEQUENCE)
    
    movieID = ex.TRIAL_SEQUENCE(i);
    
    if(movieID > 2)
        % grab the correct stimulus
        stimshown = ex.MOVIDX{movieID};

        for j = 1:length(stimshown) %should be 10
            if(stimshown(j,1) == stimshown(j,2))
                stimarray_train(j,stimshown(j,:),trialcounter) = 2;
            else
                stimarray_train(j,stimshown(j,:),trialcounter) = 1;
            end
        end

        
        % NOW, FIND AND STORE THE RESPONSE FOR THIS TRIAL
         % figure out whether this stimulus has been presented before 
         % to get the correct raster
         repeatNum = length(find(ex.TRIAL_SEQUENCE(1:i) == movieID)); %should be 1 or 2 typically
             

         for K = 1:numNeurons
             
            %(EVENTS is a cell array of unit # X condition # X repeat). 
            tmp = ex.EVENTS{K,movieID,repeatNum}*1000; 

            % initialize raster
            raster = zeros(1,prewin+trialLength+postwin);

            %shift spike times to place in bins correctly
            tmp = tmp+prewin;
            % round up to nearest 1ms bin (ceil)
            tmp = ceil(tmp);        
            %truncate spikes outside window of interest
            tmp(tmp<=0) = [];
            tmp(tmp>length(raster)) = [];

            % populate raster
            if(~isempty(tmp))
                raster(tmp) = 1;
            end

            spikedata_train(:,trialcounter,K) = raster;

         end
        
         %this must have been a valid trial, so increment counter before
         %moving on
         trialcounter = trialcounter + 1;

    end
    
end



% HOW TO ACCESS:

% stimarray_train(1,:,1) - trial 1, frame 1 - stim in row vector
% stimarray_train(:,:,1) - trial 1, all frames - stims in row vectors


        % sanity check - neuron 1, all trials
        % should see onset and offset of stimulus
    %     plot(sum(spikedata_train(:,:,1),2))    % good test for Pe
    %     plot(sum(spikedata_train(:,:,7),2))    % good test for Wi


%%
% set up testing (repeat) data
% each entry in cell array is one condition
% in each condition, frames are in row vectors, as above

stimarray_test = {};

for i = 1:2

movieID = i;
stimshown = ex.MOVIDX{movieID};
stimarray_1 = zeros(10,9);

for j = 1:length(stimshown) %should be 10
    if(stimshown(j,1) == stimshown(j,2))
        stimarray_1(j,stimshown(j,:)) = 2;
    else
        stimarray_1(j,stimshown(j,:)) = 1;
    end
end
    
stimarray_test{i} = stimarray_1;

end

% HOW TO ACCESS:

% stimarray_test{1} - condition 1, all frames - stims in row vectors



% extract testing (repeated) spike data

% these are conditions 1&2 for both animals

% this cell array will hold the repeat data;
% each entry is one condition
spikedata_test = {};

for I=1:2 %for each repeated condition
        
    % time x repeats x neurons
    spikedatatemp = zeros(prewin+trialLength+postwin,ex.REPEATS(I),numNeurons);
    
    for K = 1:numNeurons

        for J=1:ex.REPEATS(I) %each time that condition appeared

            %(EVENTS is a cell array of unit # X condition # X repeat). 
            tmp = ex.EVENTS{K,I,J}*1000; 

            % initialize raster
            raster = zeros(1,prewin+trialLength+postwin);

            %shift spike times to place in bins correctly
            tmp = tmp+prewin;
            % round up to nearest 1ms bin (ceil)
            tmp = ceil(tmp);        
            %truncate spikes outside window of interest
            tmp(tmp<=0) = [];
            tmp(tmp>length(raster)) = [];

            % populate raster
            if(~isempty(tmp))
                raster(tmp) = 1;
            end

            % store repeat and move on to next one
            spikedatatemp(:,J,K) = raster;

        end
    end
    
    % store in final cell array
    spikedata_test{I} = spikedatatemp;
    
end

    
    % sanity check - PSTH
    % should see onset and offset of stimulus
%     spikedata = spikedata_test{1};
%     plot(sum(spikedata(:,:,7),2)) % good test for Wi
%     plot(sum(spikedata(:,:,30),2)) % good test for Pe


%% SAVE

 save('testdata_v2.mat','spikedata_test','spikedata_train','stimarray_test','stimarray_train')