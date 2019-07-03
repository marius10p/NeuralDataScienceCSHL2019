%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%    PROBLEM SET    %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%   Principal Component Analysis (PCA) for neural data
% 
%     PCA is a versatile method used in many different fields of science.
%     We will first familiarize you with PCA with some questions, and then
%     motivate why we would apply PCA to neural data.
    
    
%%%%%%   Background on PCA
% 
%     If you are not familiar with PCA, spend a few minutes to 
%     read about it on Wikipedia, etc.  
% 
%     Answer the following open-ended questions about PCA.
%     
%       1.  What is the covariance matrix?
%
%       2.  What is an eigenvalue?
%
%       3.  Consider two M-dimensional vectors, u and v.  What does is mean 
%             if u and v are orthogonal to one another?
%
%       4.  What is an eigenvector?
%
%       5.  For PCA, how do you compute the latent variables (also called the
%             principal components or PC scores)?
%
%       6.  How can we use PCA for dimensionality reduction?
%
%       7.  In the context of PCA, what does "dimensionality" mean?
%
%       8.  What metrics can we use to assess the dimensionality of data?
%
%       9.  Should we z-score the data before applying PCA?
%

    
    
%%%%%%   Matlab's 'pca' function
% 
%     Familiarize yourself with Matlab's built-in pca() function.
%     
%     1. What are the inputs of pca()?
%
%     2. What are the outputs of pca()?
%
%         
% 
%     Let's quickly practice with pca().
%     
%     1.  Run the following code.
%         Z = randn(1,100);
%         X1 = Z + 0.05 * randn(1,100);
%         X2 = Z + 0.05 * randn(1,100);
%         X = [X1; X2];   % 2 x 100
%         
%         
%     2.  Now perform PCA on the data X (2 x 100).  
%             (Hint: don't forget to transpose X).
%     
%         Code:
%         
%             [U, sc, lat] = pca(X');
%         
%         1. Check the eigenvalues or variances.  Do they make sense?
%
%         2. Check the loadings or weights of the eigenvectors.  Do
%             they make sense?
%
        


%%%%%%   Motivating the use of PCA for neural data
%
%     We would like to understand how M neurons respond to different conditions,
%     such as different stimuli or different behaviors.  One could plot
%     the firing rate of one neuron on top of one another for all conditions,
%     but often no discernible pattern exists across the M neurons.  The 
%     M neurons are clustered into two to three groups, but these hard
%     placements can be disconcerting.  Instead, we would like to consider
%     the responses of all neurons together.  In other words, instead of
%     considering the marginal distributions of firing rates, we would
%     like to consider the high-dimensional joint distribution of firing rates.
%     One approach to describing a high-dimensional joint distribution is
%     with dimensionality reduction.  In this approach, we consider a
%     multi-neuronal firing rate space, where each axis corresponds to the
%     firing rate of one neuron.
%     
%     In many cases, because neural variability is large, we would like
%     to understand trial-averaged responses (or peri-stimulus time
%     histograms, PSTHs).  The assumption is that we have averaged away
%     neural variability to have reliable estimates of the responses to
%     different conditions.  Thus, we do not need a dimensionality
%     reduction method that has a noise model, like factor analysis.  Instead,
%     we can apply PCA to trial-averaged responses.  
%     
%     Answer the following (open-ended) questions.
%     
%     1.  What are some questions that we can ask with PCA that would be
%     difficult or impossible to ask by looking at single-neuron responses?
%
%     2.  Does it make sense to say V1 neurons have an absolute dimensionality (e.g., 100 dimensions)?
%         Why or why not?
%


%%%%%%   Getting hands dirty with neural data


%%% run the following code

    %%% run this code once to get S_counts_grats.mat (may take a while)
        %script_get_S_struct
        
    %%% load data
        load('../data/S_counts_grats.mat');

        num_conds = length(S);
        num_neurons = size(S(1).counts,1);

    %%%  trial-average the counts to get mean responses
        for icond = 1:num_conds
            S(icond).mean_responses = mean(S(icond).counts,2);
        end
    
    
    
%%% 1. Apply PCA to mean responses to all conditions
    % and plot cumulative percent variance explained vs. dimensionality
    %  Hints:
    %    - use pca()
    %    - the struct S contains the mean responses, where
    %       S(icond).grats(1 x 2) contains the coordinates of the stimuli matrix, 
    %       where S(icond).grats(1,1) is the row and (1,2) is the column.
    %       Example: grats = [9, 9] is a blank stimulus; grats [5, 9] is a single orientation;
    %               grats = [1, 3] is a plaid orientation
    %    - you can concatenate responses of a struct S like so:
    %        responses = [S.mean_responses]

    
    % -------------
    %  CODE HERE
    % -------------
    
    lat = [];
    U = [];
    
    % plotting code needs:
    %  lat: (num_neurons x 1), the eigenvalues
    %  U: (num_neurons x num_neurons), the eigenvectors as columns
    
    % plot percent variance explained
    f = figure;
    plot([0 num_neurons+1], [95 95], '--r');
    hold on;
    plot(100*cumsum(lat)/sum(lat), 'b');
    ylim([0 100]);
    
    xlabel('number of dimensions');
    ylabel('cumulative percent variance explained');
    
    
    % plot weights of the top 5 eigenvectors
    f = figure;
    for idim = 1:5
        subplot(5,1,idim);
        stem(U(:,idim));
        ylabel(sprintf('dim %d, %0.0f%%', idim, 100*lat(idim)/sum(lat)));
        
        if (idim == 5)
            xlabel('neuron index');
        end
    end
    
    
    
%%% 2. Apply PCA to increasing number of conditions.
    % Compute dimensionality of 5, 10, 15, ... number of conditions.
    % For each dimensionality interval, randomly sample conditions for 10 runs.
    %    Hints:

        
    % -------------
    %  CODE HERE
    % -------------
    
    
    mean_dims = [];
    std_dims = [];
    
    % plotting code needs:
    %   mean_dims (number of candidate dimensionalities x 1), the mean dimensionality of each dimensionality interval over the 10 runs
    %   std_dims (number of candidate dimensionalities x 1), the std dimensionality of each dimensionality interval over the 10 runs
    %                                                   
    f = figure;
    errorbar(nums_conds, mean_dims,std_dims);
    ylim([0 8]);
    
    ylabel('number of dimensions');
    xlabel('number of stimuli');
    
        
        
    
   
    
    
%%% 3. Apply Pattern Aggregation Method to compare patterns between single and plaid stimuli
%     
%   This is going to be tougher than the other sections.  But it's also the last section for PCA!
%
%   We would like to ask if the patterns (i.e., eigenvectors) for the responses to single orientations
%   are similar to the patterns for the responses to the plaid stimuli.  
%   
%   Would you expect the patterns to be similar or different?
%
%   First, apply PCA to the single and plaid stimuli separately.  Plot the loadings of the eigenvectors
%   with the given plotting code.
%
%
%   Hints: 
%       - The single orientations correspond to the diagonal, bottom row, and rightmost column of
%           the stimulus matrix, excluding element (9,9), which is the blank stimulus.  
%           The plaid stimuli are the rest of the elements, again excluding the element (9,9).
%
%   Are the loadings similar across conditions?  If different, does this mean that the
%       patterns are different across conditions?  Why or why not?
%


    % -------------
    %  CODE HERE
    % -------------
    

    U_single = [];
    U_plaid = [];
    
    % plot the loadings of the top four PCs as stem plots
    %  needs:
    %   U_single: (num_neurons x num_neurons) eigenvectors of single orientations as columns
    %   U_plaid: (num_neurons x num_neurons) eigenvectors of plaid stimuli as columns
    
    f = figure;
    
    for idim = 1:4
        subplot(4,2,2*(idim-1)+1);
        stem(U_single(:,idim));
        ylabel(sprintf('dim %d', idim));
        
        if (idim == 1)
            title('single orientation stimuli');
        elseif (idim == 4)
            xlabel('dimension index');
        end
        
        subplot(4,2,2*idim);
        stem(U_plaid(:,idim));
        if (idim == 1)
            title('plaid stimuli');
        elseif (idim == 4)
            xlabel('dimension index');
        end
    end
    
    



%%%  4. Employ the pattern aggregation method to see if patterns are similar or different
%
%     1. Assess the dimensionality of the responses to the single orientations by
%         computing the number of eigenvectors that capture at least 95% of the variance.
%     2. Assess the dimensionality of the responses to the plaid stimuli in the same manner.
%     3. Compute the minimum possible number of dimensions between the two conditions.
%     4. Compute the maximum possible number of dimensions between the two conditions.
%     5. We would now like to assess the dimensionality when considering both sets of
%         patterns together.  One approach is to concatenate the responses from both
%         conditions, and apply PCA to the concatenated responses.  However, if one condition
%         has a higher variance but lower number of patterns, the dimensionality would be
%         lower than expected.  Instead, we can aggregate the patterns and compute the effective rank.
%         Use the rank() function with tolerance = 0.5 to compute the rank of the aggregated patterns.
%     6. We would also like to have some notion of what we would expect the dimensionality to
%         be if the patterns were random.  For 100 runs, generate random, orthonormal patterns
%         for both conditions, and compute the rank of the aggregated dimensions.  You may want to
%         use the randn() and orth() functions.

        
    % -------------
    %  CODE HERE
    % -------------
    
    num_dims_single = [];
    num_dims_plaid = [];
    num_dims_aggregated = [];
    min_dim = [];
    max_dim = [];
    dims_random = [];
    
    % plotting code needs:
    %   num_dims_single: (1 x 1), number of dimensions for single orientations
    %   num_dims_plaid: (1 x 1), number of dimensions for plaid stimuli
    %   num_dims_aggregated: (1 x 1), number of dimensions for aggregated patterns
    %   min_dim: (1 x 1), smallest possible number of dimensions
    %   max_dim: (1 x 1), largest possible number of dimensions
    %   dims_random: (100 x 1), number of dimensions for aggregated random patterns
    
    f = figure;
    
    plot(1, num_dims_single, '.b', 'MarkerSize', 20);
    hold on;
    plot(2, num_dims_plaid, '.b', 'MarkerSize', 20);
    plot(3, num_dims_aggregated, '.b', 'MarkerSize', 20);

    errorbar(3, min_dim, 0.01, 'k');
    errorbar(3, max_dim, 0.01, 'k');
    errorbar(3, mean(dims_random), std(dims_random), '.r');
    
    ylim([0 15]);
    xlim([0 4]);
    set(gca, 'XTick', [1 2 3]);
    set(gca, 'XTickLabels', {'single', 'plaid', 'aggregated'});
    ylabel('number of dimensions');
    
    
    
    
    
    
    
    
   
    
    
   
    
