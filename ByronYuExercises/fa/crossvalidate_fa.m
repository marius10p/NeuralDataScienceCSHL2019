function dim = crossvalidate_fa(X, varargin)
%
% dim = crossvalidate_fa(X, ...)
%
% Cross-validation to determine optimal latent dimensionality for
% factor analysis
%
%   xDim: data dimensionality
%   N:    number of data points
%
% INPUTS: 
%
% X   - data matrix (xDim x N)
%
% OUTPUTS:
%
% dim - structure whose ith entry (corresponding to the ith latent
%       dimensionality) has fields 
%         zDim      -- latent dimensionality 
%         sumPE     -- cross-validated prediction error
%         sumLL     -- cross-validated log likelihood
%         estParams -- FA parameters estimated using all data
%
% OPTIONAL ARGUMENTS:
%
% numFolds    - number of cross-validation folds (default: 4)
% zDimList    - latent dimensionalities to compare (default: [1:10])
%               Note: dimensionality 0 corresponds to an independent
%               Gaussian model, where all variance is private. 
% showPlots   - logical specifying whether to show CV plots
%               (default: true)
% verbose     - logical specifying whether to show CV details
%               (default: false)
%
% @ 2011 Byron Yu  byronyu@cmu.edu

  numFolds  = 4;
  zDimList  = 1:10;
  showPlots = true;
  verbose   = false;
  extraOpts = assignopts(who, varargin);

  [xDim, N] = size(X);
  
  % Randomly reorder data points
  rand('state', 0);
  X = X(:, randperm(N));
    
  % Set cross-validation folds 
  fdiv = floor(linspace(1, N+1, numFolds+1));

  for i = 1:length(zDimList)
    zDim = zDimList(i);

    fprintf('Processing latent dimensionality = %d\n', zDim);
    
    dim(i).zDim  = zDim;
    dim(i).sumPE = 0;
    dim(i).sumLL = 0;
            
    for cvf = 0:numFolds      
      if cvf == 0
        fprintf('  Training on all data.\n');
      else
        fprintf('  Cross-validation fold %d of %d.\n', cvf, numFolds);
      end
      
      % Set cross-validation masks
      testMask = false(1, N);
      if cvf > 0
        testMask(fdiv(cvf):fdiv(cvf+1)-1) = true;
      end
      trainMask = ~testMask;
      
      Xtrain = X(:, trainMask);
      Xtest  = X(:, testMask);
      
      % Remove observed dimension if it takes on the same value for
      % every training data point
      dimToKeep = (var(Xtrain, 1, 2) > 0);    
      Xtrain    = Xtrain(dimToKeep,:);
      Xtest     = Xtest(dimToKeep,:);      
      if any(~dimToKeep)
        fprintf('Warning: Removing observed dimension(s) showing zero training variance.\n');
      end
              
      % Check if training data covariance is full rank
      if rcond(cov(Xtrain')) < 1e-8
        fprintf('ERROR: Training data covariance matrix ill-conditioned.\n');
        keyboard
      end

      if verbose
        fprintf('      (train, test, data dim) = (%d, %d, %d)\n',...
                size(Xtrain,2), size(Xtest, 2), size(Xtrain, 1));
      end
      
      % Fit model parameters to training data
      if zDim == 0
        estParams = indepGaussFit(Xtrain);        
      else
        % fastfa.m does the heavy lifting
        % (here, choose not to use private noise variance floor) 
        estParams = fastfa(Xtrain, zDim, 'minVarFrac', -Inf);
      end
      
      if cvf == 0
        % Save parameters
        dim(i).estParams = estParams;       
      else
        % sse: prediction error on test data
        % LL:  test likelihood
        if zDim == 0
          [LL, sse] = indepGaussEval(Xtest, estParams);
        else
          [blah, LL] = fastfa_estep(Xtest, estParams);
          
          Xcs = cosmoother_fa(Xtest, estParams);    
          sse = sum((Xcs(:) - Xtest(:)).^2);
        end
                
        dim(i).sumPE = dim(i).sumPE + sse;
        dim(i).sumLL = dim(i).sumLL + LL;
      end
    end
  end
  
  if showPlots
    figure;
    
    % Prediction error versus latent dimensionality
    subplot(2, 1, 1);
    sumPE = [dim.sumPE];
    plot(zDimList, sumPE);
    xlabel('Latent dimensionality');
    ylabel('Cross-validated Pred Error');
    
    hold on;
    istar = find(sumPE == min(sumPE));
    plot(zDimList(istar), sumPE(istar), '*', 'markersize', 5);
    fprintf('Optimal latent dimensionality (PE) = %d\n', zDimList(istar));
    
    % LL versus latent dimensionality
    subplot(2, 1, 2);
    sumLL = [dim.sumLL];
    plot(zDimList, sumLL);
    xlabel('Latent dimensionality');
    ylabel('Cross-validated LL');

    hold on;
    istar = find(sumLL == max(sumLL));
    plot(zDimList(istar), sumLL(istar), '*', 'markersize', 5);
    fprintf('Optimal latent dimensionality (LL) = %d\n', zDimList(istar));
  end