%% 1 Loader - This segmented "transduces" the data into Matlab format
%This can be quite involved, e.g. in the case of raw data coming out 
%of a rig. Here, it has been pre-processed and saved as a .mat file
%cd Data %If data is in a "Data" folder
%load('Pe170417.mat') %If we want data with LFP and eye traces
load('Pe170417_spikes.mat') %Just the spikes

%cd .. %If data is in a "Data" folder