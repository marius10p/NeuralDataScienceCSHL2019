
% converts ex.EVENTS into more-friendly struct
%
% OUTPUT:
%   S: (1 x 81), struct that contains counts for each trial and condition
%          where S(icond).counts (num_neurons x num_trials) are the spike
%           counts for the 'icond'-th condition
%          and S(icond).grats (1 x 2) denotes which gratings were combined
%%% load data
%     load('./data/Wi170428_spikes.mat');

%%% get mean spike counts for each of 81 conditions

    % NOTE: Ignore the last 1000 elements of ex.MOVIDX...they are just extra
    
    num_neurons = size(ex.EVENTS,1);
    num_conditions = size(ex.EVENTS,2);
    
    S = [];  % keeps the spikecounts
    for icond = 1:81
        S(icond).counts = [];
        S(icond).grats = [];
    end
    
    lag = 50;  % 50ms lag
    time_per_frame = 100; % each frame shown for 100ms
    num_frames = 10;  % number of frames for each trial
    times = lag + (1:time_per_frame:num_frames * time_per_frame);
    for icond = 1:num_conditions
        grats = ex.MOVIDX{icond};
        for irepeat = 1:ex.REPEATS(icond)
            for itime = 1:length(times)
                counts = [];
                for ineuron = 1:num_neurons
                    counts(ineuron) = sum(ex.EVENTS{ineuron,icond,irepeat}*1000 > times(itime) ...
                                                & ex.EVENTS{ineuron,icond,irepeat}*1000 < times(itime)+time_per_frame);
                end
                index = sub2ind([9 9], grats(itime,1), grats(itime,2));
                S(index).counts(:,end+1) = counts;
                S(index).grats = grats(itime,:)';
            end
        end
    end
    
    
    save('./S_counts_grats.mat', 'S');
    
    
    
    
    
    
    
    
    
    
    
    
%   ARCHIVED NOTES
%
%     ex = 
% 
%             EVENTS: {33x1000x126 cell}
%               EYES: {3x1000x126 cell}
%                LFP: {96x1000x126 cell}
%        LFPCHANNELS: [96x1 double]
%             NSTIME: {1000x126 cell}
%               MSGS: {1000x126 cell}
%              CODES: {1000x126 cell}
%           CHANNELS: [33x2 double]
%     TRIAL_SEQUENCE: [1443x1 double]
%            REPEATS: [1x1000 double]
%          PRE_TRIAL: {1x1443 cell}
%                ENV: {1000x126 cell}
%                MAP: [10x10 double]
%                SNR: [33x1 double]
%                 SC: [33x1 double]
%           FILENAME: 'Wi170428_s285a_plaidmovie_0004.nev'
%             MOVIDX: {1x2000 cell}
%             MOVORI: {1x2000 cell}
%            ORILIST: [1x9 double]
%               SEED: 1975