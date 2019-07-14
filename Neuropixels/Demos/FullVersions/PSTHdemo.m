% Matlab Exercises on PSTH analysis of Steinmetz Data for CSHL course
%   Authors: Michael Moore and Mark Reimers
%   Version: V1 07/13/2019

%% Which neurons encode Stimulus + Movement?
% use Wilcoxon rank sum test to determine which neurons have a
% statistically significantly higher firing rate on trials with stimulus and movement

alpha = .01; % threshold p-valye for null hypothesis

for n = 1:neurons.N
    x = neurons.rate(trials.isStim & trials.isMovement,n);
    y = neurons.rate(~(trials.isStim & trials.isMovement),n);
    p(n,1) = ranksum(x,y); % p-value for null hypothesis (both trial subsets have same median) is correct
end
clear n 

% add a field to neurons showing results
neurons.test1 = p < alpha & (median(x) > median(y));
clear p x y alpha

figure
stem(neurons.test1,'.')
xlabel('neuron')
ylabel('encodes stimulus & movement')
yticks([0 1])

%% Process for PSTH
psth = struct;
% align data on visual stimulus presentation
psth.lag1 = -20; % bins before stim
psth.lag2 =  80;  % bins after stim

psth.times = (psth.lag1:psth.lag2)'*bins.width;

psth.numBins = size(psth.times,1);
psth.bins = zeros(psth.numBins,trials.N);
for tr = 1:trials.N
    % compute the bin containing stimulus onset
    bstim = ceil((trials.tstim(tr) - bins.t1)/bins.width);
    % list the psth bins for the trial
    psth.bins(:,tr) = bstim + (psth.lag1:psth.lag2)';
end
clear tr bstim

%% collect the data into a new structure
psth.F = zeros(psth.numBins,neurons.N,trials.N);

for tr = 1:trials.N
    psth.F(:,:,tr) = F.smoothed(psth.bins(:,tr),:);
end
clear tr

%% average over trials
psth.Fmean = mean(psth.F,3);

%% plot a random sample of neurons
randset = randperm(neurons.N,20);

figure
for m = 1:length(randset)
    labels{m} = ['neuron ',num2str(randset(m))];
end
stackedplot(psth.times,zscore(psth.Fmean(:,randset),1),'DisplayLabels',labels,'color','k','linewidth',1);
title('PSTH: binned, smoothed, and averaged over trials')
xlabel('time relative to stimulus [s]')

clear randset
%% Plot total activity 
% sum over all neurons and trials

y = sum(psth.F,[2,3]); % this requires R2018b or later, otherwise use nested sums
t = psth.times;
figure
bar(t,y,'r', 'BarWidth', 1)
title('PSTH summed over all neurons and trials')
xlabel('time [s] relative to stimulus')
ylabel('Total activity')
ylim([0 Inf])
legend('binned','smoothed','location','northwest')
clear y1 y2 t

%% Plot PSTH for each region
% include only neurons that pass test1 (encode stimulus AND movement)
% show standard error (uncertainty in the mean)

t = psth.times;
figure
for r = 1:regions.N
    subplot(regions.N,1,r)
    y = psth.Fmean(:,neurons.region==r & neurons.test1);
    plot(t,mean(y,2),'color',regions.color(r,:),'linewidth',2)
    title([regions.name(r,:),' (',num2str(size(y,2)),' neurons)'])
    se = std(y,1,2)/sqrt(length(y)); % standard error is uncertainty IN the mean
    hold on
    plot(t,mean(y,2)+se,'color',.5*regions.color(r,:))
    plot(t,mean(y,2)-se,'color',.5*regions.color(r,:))
    hold off
       
end
clear r t y se 
xlabel('time relative to stim [s]')
sgtitle('PSTH with Standard Error')





