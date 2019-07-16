%% Explore Smith PCA

% Array holds counts by neurons x bins x presentations
FR = mean(SpikeCounts,2)/0.1; title('Firing Rates')
histogram(FR,10) % How many neurons fire less than once per second?
% Should we treat all neurons equally?

%% first aggregate over time bins within each presentations
StimTrials = squeeze(sum(BinnedSpikeTrains,2))'; % add up counts over time bins;'squeeze' removes middle dimension; - transpose to variables in columns

%% Show Mean-Variance (Fano) relationships of firing across presentations
figure
bin.means = mean(StimTrials);
bin.SDs = std(StimTrials,1);
plot( bin.means, bin.SDs,'o')
plot( bin.means, bin.SDs.^2,'o'); grid; line( [0 2], [0 2], 'linewidth',3,'color','k')
% Do these neurons follow the expected Fano factor 1 relationship of a Poisson process?

%% now aggregate over presentations of same type to compute mean response - as if a Platonic Ideal
meanPatterns = nan(nUnits, 9, 9) ;
for ii = 1:9
    for jj = 1:9
        nn = find(Grating1 == ii & Grating2 == jj);
        meanPatterns(:,ii,jj) = mean( StimTrials(nn,:));
    end
end

%% PCA of average responses
dataMatrix = reshape(meanPatterns,nUnits,9*9)'; 
% I use reshape to put this 3-dim array into a 2-dim matrix; this stacks blocks of 2nd orientation on top of each other
% transpose so columns have neurons and rows are patterns; 
rowMaps = reshape(1:81,9,9); % do the reverse reshape to find row maps 
[ loadings, scores, vars] = pca( dataMatrix); 

%% Explore results
figure
bar(vars); title('Scree plot of mean pattern PCA')
figure
plot(FR, loadings(:,1),'o'); grid; xlabel('Firing Rate'); ylabel('PC 1')% show relationship with FR
% What's a simple fix? z-score

figure
[ loadingsz, scoresz, varsz] = pca( zscore(dataMatrix));
bar(varsz); title('Scree plot of z-scores of mean pattern PCA') % how different is this from previous? Can we identify directions reliably?

figure
% now check the relation to FR
plot(FR, loadingsz(:,1),'o'); grid; % shows weaker relationship with FR

figure
plot(loadingsz(:,1),loadingsz(:,2),'o'); grid; title('Loadings of mean Patterns')
xlabel('PC 1 loadings on neurons'); ylabel('PC 2 loadings on neurons');
% do the PC's have any obvious interpretation?

% Now map the state-space
figure
plot( scoresz(:,1), scoresz(:,2),'o'); title('State space of mean patterns (z-scored)') % shows a nice '+' structure
% is this consistent with underlying model of PCA?

% plot activity pattern of high-contrast grid images
hold on; grid
for kk = 1:8
    plot( scoresz(9*(kk-1)+kk,1),scoresz(9*(kk-1)+kk,2),'or')
    % grid images were on diagonal of dims 2 and 3 in original array; now rows 1,11,21,31,...
end
hold off
% Are the neural activity patterns evoked by high-contrast grids more like those evoked by 
% plaids made by combining similar orientation, or more like other grids of any orientation?

% explore relation of orientation to state-space
hold on; 
plot( scoresz(1:9,1),scoresz(1:9,2),'og')
plot( scoresz(9*(1:8)+1,1),scoresz(9*(1:8)+1,2),'ob')
hold off

%% PCA of trial responses
[ loadings, scores, vars] = pca( StimTrials); % 

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