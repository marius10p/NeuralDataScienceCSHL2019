function [correlations] = computeCorrelation(C)
    [m, n] = size(C);
    if (m ~= n)
        error('The input matrix should be square');
    end
    correlations = nan(1, nchoosek(m,2));
    k = 1;
    for i = 1:m
        for j = (i+1):m
            correlations(k) = C(i, j)/sqrt(C(i,i)*C(j,j));
            k = k + 1;
        end
    end
end

