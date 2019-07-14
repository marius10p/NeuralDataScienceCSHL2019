function [percentshared, d_shared,bestdim,normevals] = compute_shared(params, thresh)
%% extract parameters for the number of latents with highest likelihood
        [~,maxLLind] = max([params.sumLL]);
        bestdim = params(maxLLind).zDim;
        if params(maxLLind).zDim>0
            L = params(maxLLind).estParams.L;
            Ph = params(maxLLind).estParams.Ph;
        else
            L = [];
            Ph = [];
        end
%% compute d_shared
        if ~isempty(L) % i.e., latent dimensions > 0
            shared = L*L';
            evals = eig(shared);
            normevals = sort(evals,'descend')/sum(evals);
            d_shared = sum(cumsum(normevals)<thresh)+1;
        else % i.e., latent dimensions = 0
            d_shared = 0;
            percentshared = 0;
        end

%% compute % shared variance
        if ~isempty(L) && ~isempty(Ph) % i.e., latent dimensions > 0
            sharedvar = diag(L*L');
            percentshared = mean(sharedvar./(sharedvar+Ph));
        else % i.e., latent dimensions = 0
            percentshared = 0;
        end
end