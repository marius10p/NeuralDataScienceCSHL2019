%% 4 PSTH
%Visual inspection of raw data:
figure
plot(spikeTimes,1:length(spikeTimes),'.','color','k')
shg
%% Integrating over that => the PSTH
binEdges = -2:0.01:2; %We need some bins
PSTH = histcounts(spikeTimes,binEdges); %This contains the parsed spike train
figure
plot(binEdges(1:end-1)+diff(binEdges)./2,PSTH) %Fencepost problem, hence -1