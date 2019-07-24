%% Anscombe quartet in MATLAB
% taken from http://neurochannels.blogspot.com/2008/07/anscombes-quartet.html
% see also 'Datasaurus dozen' at https://www.autodeskresearch.com/publications/samestats
X = zeros(11,4);
X(:,1:3) = repmat([10 8 13 9 11 14 6 4 12 7 5]',1,3);
X(:,4) = [8 8 8 8 8 8 8 19 8 8 8]';

Y = zeros(11,4);
Y(:,1)=[8.04 6.95 7.58 8.81 8.33 9.96 7.24 4.26 10.84 4.82 5.68]';
Y(:,2)=[9.14 8.14 8.74 8.77 9.26 8.1 6.13 3.1 9.13 7.26 4.74]';
Y(:,3)=[7.46 6.77 12.74 7.11 7.81 8.84 6.08 5.39 8.15 6.42 5.73]';
Y(:,4)=[6.58 5.76 7.71 8.84 8.47 7.04 5.25 12.5 5.56 7.91 6.89]';

%% Summary statistics and correlations
mean(X)
mean(Y)
std(X)
std(Y)
for ii=1:4
    corr(X(:,ii),Y(:,ii))
end

%% Now plot all four
for ii = 1:4
    subplot(2,2,ii)
    plot(X(:,ii),Y(:,ii),'o'); grid
end
