%%% Perform DataHigh on trial-averaged spike count vectors (no timecourse)
    %  and single-trial neural trajectories
    
    
    % run this script first to get the D structs:
    
        script_get_D_struct_for_DataHigh
    
    %% trial-averaged spike count vectors
        
        load('D_struct_trialavg_spikecounts.mat');
        
        % Make sure DataHigh folders are on your path.  To do this,
        % go into the DataHigh folder and run "DataHigh()" in the console.
        %  The folders will be automatically added to your path.
        
        % Now run the following.  Choose PCA, and on the righthand side
        % for "Select dimensionality" choose 10, and hit "Perform dim reduction."
        
        % In the pop-up box, click "Upload to DataHigh".  Then play around
        % with DataHigh's features.
        
        DataHigh(D, 'DimReduce');
        
        
    %% single-trial neural trajectories 
    
        load('D_struct_singletrial_trajs.mat');
        
        %  Run the following.  Type "50ms" time bins (hit enter), and choose GPFA.
        %  On the righthand side for "Select dimensionality" choose 30,
        %  and hit "Perform dim reduction."  This will take 1-2minutes to run.
        
        % In the pop-up box, click "View each dim" to see the timecourse of
        % each latent variable.  Then choose "10" dimensions, and 
        % click "Upload to DataHigh" and have fun!
        % One thing you should notice is that there is a *ton* of trial-to-trial
        % variability---you can barely make out the PSTHs.  You can also check
        % out evolving the trajectories by the following:  Under "Analysis Tools,"
        % click "3d projection".  Then in the pop-up box, click "Evolve."
        
        DataHigh(D, 'DimReduce');
        
        
        
