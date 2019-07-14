% Demo of Neuropixels Data Analysis
%       Authors: Michael Moore and Mark Reimers

%% Load a Dataset into Matlab for Analysis
% -each dataset consists of a set of data files
% -each dataset should reside in its own folder
% -no other files should be added to this folder
% -files in the folder of type '.npy' or '.tsv' will be treated as data 
%   and loaded into the session struct. Other files types will be ignored.

% add path to npy-matlab-master
addpath(genpath('C:\Users\micha\Documents\mmCode\npy-matlab-master'))
% specify path to data
mainPath = 'C:\Users\micha\Documents\Data\taskData2';
% specify path to functions
addpath(genpath('C:\Users\micha\Documents\mmCode\myFunctions'))

% pick a session and create a data-structure
% specify session by name
sesName = 'Moniz_2017-05-15';

% construct path to session file
sesPath = [mainPath filesep sesName];

% load all variables for session into a struct
S = loadSession(sesPath); % this calls a custom read function created for this dataset

clear ses sesName sesPath
clear mainPath sessionList

%% ************************************************************************
% Create some derived variables for convenience
% *************************************************************************
%% Region Properties
% make a structure containing properties of the regions included in the
% session

regions = struct;

% make a list of region names:
regions.name = unique(S.channels.brainLocation.allen_ontology,'rows'); % a character array 
% number of unique regions in the dataset
regions.N = size(regions.name,1);
regions = orderfields(regions,{'N','name'}); % this step is just cosmetic
% assign unique rgb triplet for each region
regions.color = hsv(size(regions.name,1)); % 'hsv' is a matlab defined colormap generating function

% go further: add probe and depth fields to regions struct

%% Neuron Properties 
% neurons are the 'clusters'

% neuron properties of interest are distributed in a few different places,
% we can bring them together into a new struct called 'neurons'

neurons = struct;

% extract the neuron properties
neurons.id = unique(S.spikes.clusters);
    % note that id's in S.spikes.clusters run from 0 to (N-1), and do not
    % match row index of S.clusters 
neurons.N = length(neurons.id); % number of neurons
neurons = orderfields(neurons,{'N','id'});

% identify region by row in region struct
[~,Loc] = ismember(S.channels.brainLocation.allen_ontology(S.clusters.peakChannel,:),regions.name,'rows');
neurons.region = Loc; % index that correlates to rows in regions struct
clear Loc
neurons.depth = S.clusters.depths;
neurons.probe = S.clusters.probes;

%% Create a trials struct

trials = struct;
trials.N = size(S.trials.intervals,1);
trials.tstim = S.trials.visualStim_times;
% add to tstim to indicate if non-zero stimulus was presented at stim time)
trials.isStim = logical(trials.tstim.*S.trials.visualStim_contrastLeft.*S.trials.visualStim_contrastRight);
% for each trial, find the movement onset time
trials.tmov = nan(trials.N,1); % initialize with "Not a Number"
for tr = 1:trials.N
   for m = 1:size(S.wheelMoves.intervals,1)
       t = S.wheelMoves.intervals(m,1); % move initiation time for trial m
       cond1 = t > trials.tstim(tr); % wheel move initiated after stimulus
       cond2 = t - trials.tstim(tr) < 0.4; % wheel move initiated within 400 ms after stimulus
       cond3 = isnan(trials.tmov(tr)); % no previous wheel move initiation for this trial
       if cond1 && cond2 && cond3
          trials.tmov(tr) = t;
       end           
   end
   clear m t cond1 cond2 cond3
end
clear tr

%% bin the data
% spike binning parameters
bins = struct;
bins.width = .005; % in [s]
% to make a smaller dataset, reduce the distance between bins.t1 and bins.t2
bins.t1 = min(S.trials.intervals(:)); % start of first trial
bins.t2 = max(S.trials.intervals(:)); % end of last trial
bins.edges = (bins.t1:bins.width:bins.t2)';
bins.centers = (bins.edges(2:end)-.5*bins.width);
bins.N = size(bins.centers,1);
clear t1 t2

F = struct;
F.numBins = bins.N;
F.numNeurons = neurons.N;
F.binned = zeros(F.numBins,F.numNeurons); % requires 1.5 Gb

%% Exercise: write a loop to bin the data:
for n = 1:F.numNeurons
    isNeuron = S.spikes.clusters==neurons.id(n);  
    nSpikes = S.spikes.times(isNeuron);                     
    [f1,~] = histcounts(nSpikes,bins.edges);         
    F.binned(:,n) = f1;
end
clear n isNeuron nSpikes f1 

%% smooth the data with Causal Gaussian Kernel
% causal Gaussian kernel parameters
kernel = struct;
kernel.sigma = .025; % STD of Gaussian [s]
kernel.tmesh = (0:bins.width:3*kernel.sigma)'; 
kernel.win = (kernel.tmesh >=0).*exp(-kernel.tmesh.^2/(2*kernel.sigma^2));
kernel.win = kernel.win/sum(kernel.win);

% Exercise: Plot the smoothing kernel
figure
stem(kernel.tmesh,kernel.win)
title('weights for causal Gaussian Smoothing')
xlabel('time [s]')
drawnow

% Y.smoothed has the same dimensions as Y.binned
F.smoothed = convn(kernel.win,F.binned); 
F.smoothed = F.smoothed(1:F.numBins,:,:); 
% renormalize the kernel for cases where data was unavailable (first frames)
for m = 1:length(kernel.win)
    F.smoothed(m,:,:) = F.smoothed(m,:,:)*sum(kernel.win)/sum(kernel.win(1:m));
end
clear m

%% Exercise: raster plot the smoothed dataset
% choose a time interval to show in figure
% use imagesc() to plot the smoothed data array
% use log(1+F) scaling to prevent high-rate neurons from dominating image

t1 = 300;
t2 = 400;
% label all the bins that line inside the interval
interval = bins.centers > t1 & bins.centers < t2;

figure
imagesc([t1,t2],[1,neurons.N],log(1+F.smoothed(interval,:)')) 
title([S.sesName,': binned and smoothed'], 'Interpreter', 'none')
axis ij
ylabel('neuron')
xlabel('time [s]')

%% Exercise: plot face motion energy
% get the face motion energy and iterpolate onto the bin timestamps      
faceDimension = interp1(S.face.timestamps(:,2),S.face.motionEnergy,bins.centers);
% clip the big outliers
faceDimension = filloutliers(faceDimension,'clip','thresholdfactor',10);

figure
plot(bins.centers,faceDimension)

%% Demo: sort neurons by region and combine face and neuron data for side-by-side comparison
% sort neurons by region
% indicate region along y-axis
% add vertical lines for stimulus presentation and movement 

t1 = 300;
t2 = 400;
% label all the bins that line inside the interval
interval = bins.centers > t1 & bins.centers < t2;
[R,I] = sort(neurons.region,'ascend');

% image the neurons
f1 = figure;
ax1 = axes(f1,'outerposition',[0,.2,1,.8]); % axes to plot neuron data
ax2 = axes(f1,'outerposition',[0,0,1,.2]); % axes reserved to show face motion data

imagesc(ax1,[t1,t2],[1,neurons.N],log(1+F.smoothed(interval,I)')) 
% colormap(flipud(gray))
title(ax1,['Session ',S.sesName,': binned and smoothed'], 'Interpreter', 'none')
% add region indicators
hold(ax1,'on')
hold(ax2,'on')
set(ax1,'clipping','off')
for r = 1:regions.N
    x = t1-.01*(t2-t1);
    y = [find(R==r,1,'first'),find(R==r,1,'last')];
    line(ax1,[x,x],y,'color',regions.color(r,:),'linewidth',4)
    text(ax1,t1-.02*(t2-t1),mean(y),regions.name(r,:),'color',regions.color(r,:),'horizontalalignment','right')
end
clear r x y

% add faceDimsion to second axes
plot(ax2,bins.centers(interval),zscore(faceDimension(interval)),'k')
title(ax2,'face motion energy')

% add stim and movement initiation
for tr = 1:trials.N
    x = trials.tstim(tr);
    if x > t1 && x < t2 
        h1=plot(ax1,[x,x],ax1.YLim,'g');
        plot(ax2,[x,x],ax2.YLim,'g');
    end
    x = trials.tmov(tr);
    if x > t1 && x < t2
        h2=plot(ax1,[x,x],ax1.YLim,'m');
        plot(ax2,[x,x],ax2.YLim,'m');
    end
end
clear tr x
legend(ax1,[h1,h2],'stim','move','location','northeast')
xlabel(ax2,'time [s]')
yticks(ax1,[])
hold(ax1,'off')

% it looks like face motion energy is a fairly decent predictor of the
% total activity

clear ax1 ax2 t1 t2 f1 h1 h2 interval I R 

%% Regress neural activity onto face motion energy
% use zscore(face) as regressor

% Equation: F = P*R + error      [T x N] = [T x 1]*[1 x N] + [T x N]
%   P is the predictor
%   R is the regression coefficient
% Regression: find the R that minimizes the "error" term
% Exercise: compute regression coefficients 
P = zscore(faceDimension);
R = P\F.smoothed;

% remove motion-energy dimension from data
F.noface = F.smoothed - P*R;
% store the regression coefficient and predictor
F.facePredictor = P;
F.faceCoef = R;

% compute explained variance 
varI = var(F.smoothed,1,1);
varF = var(F.noface,1,1);
FVE = 1-varF./varI;

% plot results
figure
hold on
[R,I] = sort(neurons.region,'ascend');
for r=1:regions.N
    x = find(R == r);
    y = FVE(1,I);   
    y = y(1,R == r);
    bar(x,y,'facecolor',regions.color(r,:),'edgecolor',regions.color(r,:))
end
clear r x y R I
ylabel('FVE')
title('Variance Explained by face motion energy')
legend(regions.name)

clear P R varI varF FVE

%% Kernel Regression Demo
% *************************************************************************
% Construct stimulus kernel regressors

%   find which bins contain visual stimulus
v = zeros(bins.N,1); 
for tr = 1:trials.N
    bin = ceil((trials.tstim(tr)-bins.t1)/bins.width); % bin containing Stim
    v(bin) = trials.isStim(tr); % only set to 1 if non-zero stimulus presented
end
clear tr bin
% v is now a vector with 1's at each bin with nonzero stimulus

% these are the lag ranges for the stimulus kernel
lag1 = -10; % 50 ms before stim
lag2 = 80; % 400 ms after stim

c = cat(1,v((1-lag1):end),zeros(-lag1,1));
r = cat(2,v(1-lag1),zeros(1,lag2-lag1-1));
Pstim = toeplitz(c,r);
Pstim = Pstim - mean(Pstim,1); % predictors should have zero mean
clear c r v lag1 lag2
% Rstim is now a vector of 90 predictors that define the kernel

%% train the model on the data for a single neuron
% cost function: E = ||f - P*K]]^2      R is the matris of regressors and C is the matrix of regression coefficients
% algebraic solution:  f = P*K   [T x 1] = [T x 90]*[90 x 1]

% choose a neuron 
n = randperm(neurons.N,1);
f = F.smoothed(:,n);
Kstim = Pstim\f;

% figure
bar(Kstim,'facecolor','g')
title(['neuron ',num2str(n),' stim kernel'])

clear n f Cstim

%% Tikhonov Regularization (Ridge Regression)
% cost function: f = ||y - R*C||^2 + lambda*||G*C||^2
% solution:   (R^T*R + G^T*G)*C = R^T*y 

% create the regularization matirs
%    G*C = dC/dt % G is the first-derivative matrix

c = zeros(size(Pstim,2),1);
c(1) = -1;
c(2) = 1;
r = zeros(1,size(Pstim,2));
r(1) = -1;
Gtik = toeplitz(c,r);
Gtik(end,:) = 0;
clear c r

%% Compare Least Squares and Tikhonov
n = randperm(neurons.N,1);
f = F.smoothed(:,n);
Kstim = Pstim\f;

lambda = 1e2;
KstimTik = (Pstim'*Pstim +lambda*Gtik'*Gtik)\Pstim'*f;

% figure
subplot(2,1,1)
bar(Kstim,'facecolor','g')
title('least squares')
subplot(2,1,2)
bar(KstimTik,'facecolor','b')
title('Tikhonov Regularized')
sgtitle(['neuron ',num2str(n),' stim kernel'])

clear n f 

%% Run on all neurons and compute FVE
%   each neuron gets it's own optimized stimulus kernel
KstimTik = (Pstim'*Pstim +lambda*(Gtik'*Gtik))\Pstim'*F.smoothed;

varI = var(F.smoothed,1,1);
varF = var(F.smoothed - Pstim*KstimTik,1,1);
FVE = 1 - varF./varI;

% plot results
figure
hold on
[R,I] = sort(neurons.region,'ascend');
for r=1:regions.N
    x = find(R == r);
    y = FVE(1,I);   
    y = y(1,R == r);
    bar(x,y,'facecolor',regions.color(r,:),'edgecolor',regions.color(r,:))
end
clear r x y R I
hold off
ylabel('FVE')
title('Variance Explained by Stimulus Kernel Regression')
legend(regions.name)

clear varI varF FVE 

%% Reduced Rank Regression

% use function from: MouseLand/stringer-pachitariu-et-al-2018a/
addpath(genpath('C:\Users\micha\Documents\mmCode\stringer-pachitariu-et-al-2018a-master'))
lam = 1e2;
[Wt,B,R2,V] = CanonCor2(F.smoothed,Pstim,lam); % this is another name for Reduced Rank Regression
% finds the factorizaiton K = B*W from the data F and the predictors P,
% such that the error is minimized at each succesive rank of B and W

% lam is a regularization parameter on the L2 norm of 
W = Wt';
clear Wt lam R2 V

%% look at kernel approximations for individual neurons
n = randperm(neurons.N,1);
f = F.smoothed(:,n);

k_lsq = Pstim\f;

figure
subplot(3,1,1)
bar(k_lsq)
title('least squares')

%% add smoothing
lam_tik = 1e2;
k_tik =  (Pstim'*Pstim +lam_tik*(Gtik'*Gtik))\Pstim'*f;

subplot(3,1,2)
bar(k_tik)
title('Tikhonov')

%% change rank of Reduced Rank Regression and replot

rank = 3; 
w = Pstim*B(:,1:rank)\f;
k_rrr = B(:,1:rank)*w;
subplot(3,1,3)
bar(k_rrr)
title(['Rank ',num2str(rank),' Regression'])











































