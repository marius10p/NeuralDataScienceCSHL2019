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

for zind = 1:length(zdims)
    params(zind).zDim = zdims(zind);
    params(zind).sumLL = 0;
    params(zind).sumLLtrain = 0;
    faparams.L = 0;
    faparams.Ph = 0;
    params(zind).estParams = faparams;
end

end