%% 6 Tuning curves

%We can use the same information that we used to create the rasters to
%create the tuning curve. We just have to do a little bit more work in
%order to find the right window and to simply count the number of times the
%neuron spiked, abstracting from when it spiked. We lose information here,
%in order to do a computation. Information about when in the window it
%spiked. Heisenberg.

spCount = cell(length(timestampsPerSingularOrientation),1); %We will use this variable to represent spike counts

for ii = 1:length(timestampsPerSingularOrientation) %Go through all orientations
    for jj = 1:length(timestampsPerSingularOrientation{ii}) %Go through all trials per orientation
        spCount{ii}(jj) = length(find(timestampsPerSingularOrientation{ii}{jj} > offSet ...
           ... %Find those spikes that happened after the offset and at the
           ... %same time smaller than the frame Rate plus the offset
            & timestampsPerSingularOrientation{ii}{jj} < fRate+offSet)); %This counts the spikes in the relevant interval
    end            
    spMean(ii) = mean(spCount{ii})./fRate; %To get at firing rates per second, we have to take the frame rate into account
    spSTD(ii) = std(spCount{ii})./fRate; %Same idea, but with standard deviation
    spN(ii) = length(spCount{ii}); %How many trials - we need this for the SEM
    spSEM(ii) = spSTD(ii)./sqrt(spN(ii)); %Divide SD by sqrt of n to arrive at SEM
end %This loop yields the mean firing rate, the STD and the SEM, which is all we need to do the tuning curve

%Actually plotting the tuning curve (mean firing rate)
figure
xBase = ex.ORILIST(1:numOri);
plot(xBase,spMean(1:length(xBase)),'color','k','linewidth',3)
hold on

%% 
%Put on some error bars
errorbar(xBase,spMean(1:length(xBase)),spSEM(1:length(xBase)),'color','r','linestyle','none')
xlim([-12.5 170])
xlabel('Stimulus orientation in deg')
ylabel('Firing rate in sp/s')

%Make the figure nicer
set(gca,'fontsize',26)
box off
set(gca,'tickDir','out')
set(gcf,'color','w')
set(gca,'fontAngle','italic')
title(['Tuning curve of unit ', num2str(unit)])

%Shading?