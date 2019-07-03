function params = cv_fastfa(counts,zdims,numfolds)
%% define constants
[numfeatures,numdatapoints] = size(counts);
% likelihood function for evaluating performance:
llfun = @(data,meandata,sigmainv,dim,numdata)(-(0.5)*(-numdata*log(det(sigmainv))+sum(diag(((sigmainv*(data-repmat(meandata,1,numdata))*(data-repmat(meandata,1,numdata))'))))+numdata*dim*log(2*pi)));

%% Do n-fold (where n = numfolds) cross validation over the number of latent dimensions (zdims)
% For each element of zdim do the following:
% 1. Divide trials into n groups.
% 2. Train factor analysis model using n-1 groups
% 3. Evaluate likelihood function using held out group
% 4. For later plotting, save the test likelihood and also compute/save
%       likelihood for one of the training groups (note: be carefull that
%       the same number of trials are used here as were used when
%       evaluating the held out test trials).
% 5. Repeat this process so that each group is held out once
% 6. Retrain a factor analysis model using all trials and save the
%       resulting parameters

% The output struct array 'params' should have the following fields:
%   - sumLL: The sum of test likelihood evaluations for a single zdim value
%   - sumLLtrain: the sum of the training group likelihood evalutations
%   - zDim: the zdim element being tested
%   - estParams: the parameter output of fastfa model evaluated on all
%       trials



% Define Cross Validation indices:
perminds = randperm(numdatapoints);
modinds = mod(perminds,numfolds);

% perform crossvalidation
for zind = 1:length(zdims)
    fprintf('CV Dim=%d, all data\n',zdims(zind));
    estParams = fastfa(counts,zdims(zind), 'minVarFrac', -Inf);
    params(zind).estParams = estParams;
    sumLL = 0;
    sumLLtrain = 0;
    % Insert cross
    
    for n = 1:numfolds
        traininds = perminds(modinds~=(n-1));
        testinds = perminds(modinds==(n-1));
        
        traindata = counts(:,traininds);
        testdata = counts(:,testinds);
        fprintf('CV Dim=%d, fold %d\n',zdims(zind),n);
        ptemp = fastfa(traindata, zdims(zind), 'minVarFrac', -Inf);

        L = ptemp.L;
        Ph = ptemp.Ph;
        % compute LL
        meandata = ptemp.d;
        sumLLtrain = sumLLtrain+llfun(traindata(:,randperm(length(traininds),length(testinds))),meandata,(L*L'+diag(Ph))^-1,numfeatures,length(testinds));
        sumLL = sumLL+llfun(testdata,meandata,(L*L'+diag(Ph))^-1,numfeatures,length(testinds));
    end
    fprintf('CV Dim=%d, log likelihood: %e\n',zdims(zind),sumLL);
    
    % Save likelihood nad dimension values for each zdim value
    params(zind).sumLL = sumLL;
    params(zind).sumLLtrain = sumLLtrain;
    params(zind).zDim = zdims(zind);
end

end