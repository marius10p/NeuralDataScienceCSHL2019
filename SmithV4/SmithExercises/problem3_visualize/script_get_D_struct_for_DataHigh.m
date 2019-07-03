
%%%%  trial-averaged spike count vectors (no timecourse)

    % use DataHigh to view the high-d space with mean responses
    %       to single orientations (blue) and plaid stimuli (red)
    
    %%% load data
        load('../data/S_counts_grats.mat');

        num_conds = length(S);
        num_neurons = size(S(1).counts,1);

    %%%  trial-average the counts to get mean responses
        for icond = 1:num_conds
            S(icond).mean_responses = mean(S(icond).counts,2);
        end
        
        
    %%% get D struct with single orientation and plaid stimuli  
    
        D = [];
        
        grats = [S.grats];
        
        index_conds_single = grats(1,:) == grats(2,:) & grats(1,:) ~= 9 | grats(1,:) == 9 & grats(2,:) ~= 9 | grats(2,:) == 9 & grats(1,:) ~= 9;
                    %  gets stimuli at full contrast (1:8,1:8) and half contrast (9,1:8) and (1:8,9)
                    
        D(1).data = [S(index_conds_single).mean_responses];
        D(1).type = 'state';
        D(1).epochStarts = 1;
        D(1).epochColors = [0 0 1];
        D(1).condition = 'single';
        
        
        index_conds_plaid = grats(1,:) <= 8 & grats(2,:) <= 8 & grats(1,:) ~= grats(2,:);
            % all off-diagonal elements, not including (9,9) which is a blank
            
        D(2).data = [S(index_conds_plaid).mean_responses];
        D(2).type = 'state';
        D(2).epochStarts = 1;
        D(2).epochColors = [1 0 0];
        D(2).condition = 'plaid';
        
        save('D_struct_trialavg_spikecounts.mat', 'D');
        
%%%% single-trial neural trajectories 

    %%% get D struct for single-trial neural trajectories (two conditions)
    
    
        %%% load data
            load('../data/Wi170428_spikes.mat');

        %%% get mean spike counts for each of 81 conditions

            % NOTE: Ignore the last 1000 elements of ex.MOVIDX...they are just extra

            num_neurons = size(ex.EVENTS,1);
            num_conditions = size(ex.EVENTS,2);

            D = [];

            % find conditions that have the most repeats (should be two with >100 trials)
            [m,indices_sorted] = sort(ex.REPEATS, 'descend');
            
            lag = 50;  % 50ms lag
            time_per_frame = 100; % each frame shown for 100ms
            num_frames = 10;  % number of frames for each trial
            startTime = lag - 300;  % start 300ms before stimulus onset, and include lag
            endTime = lag + 1000 + 300;  % and run 300ms after stimulus onset

            colors = {[0 0 1]; [0 1 0]};
            index = 1;
            for icond = 1:2
                for itrial = 1:50 % 1:ex.REPEATS(indices_sorted(icond))
                    for ineuron = 1:num_neurons
                        D(index).data(ineuron,:) = histc(ex.EVENTS{ineuron,indices_sorted(icond), itrial}*1000, startTime:endTime);
                    end
                    D(index).condition = num2str(icond);
                    D(index).type = 'traj';
                    D(index).epochColors = [0.7 0.7 0.7; colors{icond}; 0.7 0.7 0.7];
                    D(index).epochStarts = [1 301 1301];
                    index = index + 1;
                end
            end
            
            save('D_struct_singletrial_trajs.mat', 'D');
            

        
    