function [neural_recordings, decisions] = generate_neural_data(n_trials,...
    n_neurons, n_bins_per_trial, noise_variance, drift_rate, mean_rate)
% function[neural_recordings, decisions] = generate_neural_data(n_trials, ...
%   n_neurons, n_bins_per_trial, noise_variance, drift_rate, mean_rate)
%
% Generates fake neural data of shape (n_trials, n_bins_per_trial,
% n_neurons) according to a drift diffusion process with given 
% parameters. Also generates decisions, which is 0 or 1 depending on the 
% "animal's decision" and is returned as an array of shape [n_trials,1]

decisions = binornd(1,.5,[n_trials,1]);
neural_recordings = nan([n_trials,n_bins_per_trial,n_neurons ]);

for tt =1:n_bins_per_trial
   
    if tt==1
        neural_recordings(:,tt,:) = ...
            mean_rate + randn([n_trials,n_neurons])+ noise_variance;
    else
        neural_recordings(:,tt,:) = squeeze(neural_recordings(:,tt-1,:)) ...
            + reshape(drift_rate*(decisions*2-1),[length(decisions),1])...
            + randn([n_trials,n_neurons]) * noise_variance;
    end
    
end


end

