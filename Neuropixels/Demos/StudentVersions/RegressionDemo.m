% Demo of Neuropixels Data Analysis
%   ch1: Regress a single dimension of behavior from neural data
%   ch2: Simplified version of Kernel Regression and Reduced Rank
%   Regression as per Nick Steinmetz paper
% Student Version

% Authors: Michael Moore and Mark Reimers
% Version: V1 07/13.2019

% Assumes that prepareData.m has been run 

%% Exercise: plot face motion energy
% get the face motion energy variable and use interp1() to iterpolate onto 
% the bin timestamps   
% plot the results

%% Demo: sort neurons by region and combine face and neuron data for side-by-side comparison
% sort neurons by region
% indicate region along y-axis
% add vertical lines for stimulus presentation and movement 

t1 = 340;
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

% Model: F = P*R + E      [T x N] = [T x 1]*[1 x N] + [T x N]
%   P is the predictor
%   R is the regression coefficient

% Least-Squares Regression: find the R that minimizes the "error" term
%  E^2 = ||F - P*R||^2

% Demo: compute regression coefficients 
P = zscore(faceDimension);

% matlab does least squares automatically when division is called with
% matrices of different dimensions
R = P\F.smoothed;

% remove motion-energy dimension from data
F.noface = F.smoothed - P*R;
% store the regression coefficient and predictor
F.facePredictor = P;
F.faceCoef = R;

clear P R
%% compute explained variance 
varI = var(F.smoothed,1,1);
varF = var(F.noface,1,1);
FVE = 1-varF./varI;

%% plot results
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

clear varI varF FVE

%% Chapter 2: 
% *************************************************************************
% Regularized Kernel-Regression Demo
% *************************************************************************
%% Construct stimulus kernel Predictors

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

% Least squares (solve for K that minizes E^2)
%   E^2 = ||F - P*K]]^2
%   tends to give noisy (overfit) kernel

% Tihkonov Regularization
%   E^2 = ||F - P*K]]^2 + ||dK/dt||^2
%   smoother version of LSQ kernel

% build the time-derivative matrix
c = zeros(size(Pstim,2),1);
c(1) = -1;
c(2) = 1;
r = zeros(1,size(Pstim,2));
r(1) = -1;
Gtik = toeplitz(c,r);
Gtik(end,:) = 0;
clear c r

% Reduced Rank Regression
%   lower rank (less complex) kernels

% use function CanonCor2() from: MouseLand/stringer-pachitariu-et-al-2018a/
addpath(genpath('C:\Users\micha\Documents\mmCode\stringer-pachitariu-et-al-2018a-master'))
lam = 0; % lam regularizes the L2 norm of B and/or W (documentation unclear)
[Wt,B,R2,V] = CanonCor2(F.smoothed,Pstim,lam); 
W = Wt';
% this is another name for Reduced Rank Regression
% finds the factorization K = B*W from the data F and the predictors P,
%   i.e. minimize E^2 = ||K - P*B*W||^2
% such that the error is minimized at each succesive rank of B and W

clear Wt lam R2 V

%% look at kernel approximations for individual neurons
n = randperm(neurons.N,1); % pick a random neuron
f = F.smoothed(:,n);

k_lsq = Pstim\f;
% figure
cla
subplot(3,1,1)
bar(k_lsq, 'BarWidth', 1)
title('least squares')

lam_tik = 1e2;
k_tik =  (Pstim'*Pstim +lam_tik*(Gtik'*Gtik))\Pstim'*f;
subplot(3,1,2)
bar(k_tik, 'BarWidth', 1)
title('Tikhonov Regularization')

rank = 4; 
w = Pstim*B(:,1:rank)\f;
k_rrr = B(:,1:rank)*w;
subplot(3,1,3)
bar(k_rrr, 'BarWidth', 1)
title(['Rank ',num2str(rank),' Regression'])

sgtitle(['Neuron ',num2str(n),': Estimated stimulus kernel'])
clear n f k_lsq lam_tik k_tik rank w k_rrr

%% Run on all neurons and compute FVE
%   each neuron gets it's own optimized stimulus kernel
lam_tik = 1e2;
KstimTik = (Pstim'*Pstim +lam_tik*(Gtik'*Gtik))\Pstim'*F.smoothed;
rank = 4;
KstimRRR = B(:,1:rank)*(Pstim*B(:,1:rank)\F.smoothed);

varI = var(F.smoothed,1,1);
varF = var(F.smoothed - Pstim*KstimRRR,1,1);
FVE = 1 - varF./varI;

% plot results
figure
hold on
[R,I] = sort(neurons.region,'ascend');
for r=1:regions.N
    x = find(R == r);
    y = FVE(1,I);   
    y = y(1,R == r);
    bar(x,y,'BarWidth',1,'facecolor',regions.color(r,:),'edgecolor',regions.color(r,:))
end
clear r x y R I
hold off
ylabel('FVE')
title('Variance Explained by Stimulus Kernel Regression')
legend(regions.name)

clear varI varF FVE lam_tik rank

%% Clear all regression vars
% clear B f  faceDimension Gtik Kstim KstimRRR KstimTik Pstim  W










































