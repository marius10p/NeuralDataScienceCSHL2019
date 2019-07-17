%% 5 Rasters
%Use the information computed in 3) - the timestampsPerSingularOrientation to make rasters
%We could align the rasters as a row or as a column, but it looks nicer to
%make it a circle. We can improve on what we're doing here by making 0
%horizontal, but this won't work anyway because we only go to 180. 

subplotOrder = [1 2 3 6 9 8 7 4 5]; %We use this to rearrange the subplots

figure
for ii = 1:length(timestampsPerSingularOrientation) %Go through all of them
    subplot(3,3,subplotOrder(ii)) %We will order all orientations and put the blank in the middle
    for jj = 1:length(timestampsPerSingularOrientation{ii})
        %We need to make sure to only consider trials that had spikes in
        %this period
        if isempty(timestampsPerSingularOrientation{ii}{jj}) == 0
        %We simply plot
        plot(timestampsPerSingularOrientation{ii}{jj},jj,'.','color','k')
        hold on
        end
    end
    title(num2str(ex.ORILIST(ii)))
end