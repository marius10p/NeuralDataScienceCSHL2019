function[] = plot_coefs(B,n_neurons, n_bins_per_trial)
% Makes a nice plot of the coefficients. fit_model is the model instance 
% after fitting.

% get the coefficients of your fit

coefficients = reshape(B,[n_bins_per_trial,n_neurons])';

imagesc(coefficients,[-max(coefficients(:)), max(coefficients(:))])

ylabel('Neuron # ')
xlabel('Time (ms)')
hcb=colorbar;
title(hcb,'Contribution of bin to a decision');

