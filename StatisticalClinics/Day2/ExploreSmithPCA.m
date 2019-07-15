%% Explore Smith PCA

% Array holds counts by neurons x bins x presentations
FR = mean(SpikeCounts,2)/0.1;
histogram(FR,10) % should we treat all neurons equally?

%% Mean-Variance Fano relationships
bin.means = mean(binnedSpikes);
bin.SDs = std(binnedSpikes,1);
plot( bin.means, bin.SDs,'o')
plot( bin.means, bin.SDs.^2,'o'); grid; line( [0 1], [0 1], 'linewidth',3,'color','k')

%% first aggregate over presentations
StimTrials = sum(BinnedSpikeTrains(:,:,1:1000),2); % add up counts over time bins
[ loadings, scores, vars] = pca( squeeze(StimTrials)'); % 'squeeze' removes middle dimension

%% Explore results
bar(vars)
plot(loadings(:,1),loadings(:,2),'o'); grid
grid
plot(FR, loadings(:,1),'o'); grid; % show relationship with FR
% What's a simple fix? z-score

figure
[ loadingsz, scoresz, varsz] = pca( zscore(squeeze(StimTrials)'));
bar(varsz) % how different? Does this look useful?
figure
plot(loadingsz(:,1),loadingsz(:,2),'o'); grid
% what would PC1 mean?
plot(FR, loadingsz(:,1),'o'); grid; % less relationship with FR
plot( scoresz(:,1), scoresz(:,2),'o') % looks like a mess
% is this consistent with underlying model of PCA?


% about half of neurons have rates < 1
%% Do PCA on full data
StimTrials = sum(BinnedSpikeTrains,2); % add up counts over time bins
[ loadings, scores, vars] = pca( zscore(squeeze(StimTrials)'));

bar(vars) % how many reliable?
plot(loadings(:,1),loadings(:,2),'o'); grid
plot(scores(:,1),scores(:,2),'.')

nn = find( Grating1 == 1 & Grating2 == 1);
hold on
plot(scores(nn,1),scores(nn,2),'o')

for kk = 2:8
    nn = find( Grating1 == kk & Grating2 == kk);
    plot(scores(nn,1),scores(nn,2),'o')
end
hold off

%% Now try to visualize in 3D
figure
plot3(scores(:,1),scores(:,2),scores(:,3),'.')
hold on
for kk = 1:8
    nn = find( Grating1 == kk & Grating2 == kk);
    plot3(scores(nn,1),scores(nn,2),scores(nn,3),'o')
end
hold off


%% Now try to plot trajectories over time during presentations of same stimulus