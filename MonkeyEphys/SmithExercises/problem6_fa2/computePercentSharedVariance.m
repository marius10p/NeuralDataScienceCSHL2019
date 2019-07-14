function [ shared_variance ] = computePercentSharedVariance(...
        shared_covariance, pvariances)
    % C - covariance matrix
    % shared_covariances - the shared covariance
    % Note C = shared_covariance + independent_covariances, where
    % independent_covariances is a diagonal matrix.
    [m, n] = size(shared_covariance);
    if (m ~= n)
        error('The input matrix should be square');
    end
    shared_variance = 0;
    for i = 1:n
        total_variance = shared_covariance(i, i) + pvariances(i, i);
        shared_variance = shared_variance + shared_covariance(i, i)/total_variance;
    end
    % averaged across all neurons
    shared_variance = shared_variance / n;
end

