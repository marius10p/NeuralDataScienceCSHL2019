%% 3 Formatting / bringing the data into the right representation

%We want to create rasters, PSTHs, and - ultimately - a tuning curve
%In most cases, data is initially stored in the format it came in, 
%namely as a time-series, e.g. a series of stimuli, and a series of
%responses. Unless you study timing itself, that is rarely useful. 
%So the data has to be brought into the right representation first.

%This segment - presumably just like in the brain - does most of the work. 
%So we will spend most the time here. Don't be alarmed. That is normal. 

%Before we can do an analysis of tuning curves, we need to understand the
%responsivity of a given neuron to visual stimulation in general,
%regardless of stimulus identity. In other words, we need to count al the
%spikes from a unit in order to determine response latency.

%Strago: Get spiketimes
%Logic: Let's create a vector that just holds the number of spikes from a
%given unit. Natively, the timestamps are in a structure, and a cell array
%at that. We need to put them all in a single vector
spikeTimes = []; %Preallocate because we need to start with an empty variable to add to
%In this framework, a spike can be represented by its time alone
for ii = 1:length(ex.EVENTS) %Go through all conditions
    for jj = 1:ex.REPEATS(ii) %Go through all repeats
        spikeTimes = cat(1,spikeTimes,ex.EVENTS{unit,ii,jj});
    end
end




%% Strago: Get timestamps of when an orientation was presented
%Complication: Each trial presented 10 orientations in a stream.
%We have to unpack this
%In order to make rasters and tuning curves, we now need to parse the
%condition by the orientations that were actually presented. The first pass
%at this is to find those frames were both gratings were the same, so there
%are no interference effects. Also, we'll ignore the repeats for now, so as
%not to bias the analysis

singularOrientations = cell(length(ex.ORILIST),1); %We want a cell that will contain the location of the respective frames across conditions

for ii = 1:length(ex.EVENTS) %Do this for all conditions
    temp = find(ex.MOVIDX{ii}(:,1) == ex.MOVIDX{ii}(:,2)); %For a given condition, find all frames where the grating in the first columns equals that in the 2nd
    if isempty(temp) == 0 %If there any hits (equal conditions)
        for jj = 1:length(temp) %Go through them 
            singularOrientations{ex.MOVIDX{ii}(temp(jj))} = ...
                cat(1,singularOrientations{ex.MOVIDX{ii}(temp(jj))},[ii temp(jj)]);
            %Add condition ID and frame to the cell array
        end
    end
end

%% Now combine this information to get responses to the grating orientations

% Get the timestamps of when the unit fired in response to conditions where
% both gratings were the same
timestampsPerSingularOrientation = cell(size(singularOrientations)); %Make it the same size
for ii = 1:length(timestampsPerSingularOrientation) %Go through all conditions
    for jj = 1:length(singularOrientations{ii}) %Go through all trials per condition
        temp = ex.EVENTS{unit, singularOrientations{ii}(jj,1),1}; %This will contain all spikes from the orientation in that frame
        %We need to find the ones after this frame came on
        spikesAfterOn = temp(find(temp>(singularOrientations{ii}(jj,2)-1)/10)); %All spikes after onset
        spikesBeforeOff = temp(find(temp<(singularOrientations{ii}(jj,2)-1)/10+fRate+offSet+0.05)); %Adding 0.05, so we can see a bit further
        timestampsPerSingularOrientation{ii}{jj} = intersect(spikesAfterOn,spikesBeforeOff)-(singularOrientations{ii}(jj,2)-1)/10;
        %We need to subtract the index of the frame at the end to bring it all into a window of 0 to 0.2.
    end
end


