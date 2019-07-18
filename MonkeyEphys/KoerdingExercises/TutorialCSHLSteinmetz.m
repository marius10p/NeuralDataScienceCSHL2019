%% get the data
clear all
close all
clc

load NS_sp_count.mat
%% some minimal processing
figure
sp_count=double(sp_count); %% because Matlab likes doubles
nTrials=size(sp_count,3);
% when doing with LFP
%sp_count=cat(1,sp_count,lfp_power);

corrects=zeros(max(rawLabel),nTrials);
for j=1:nTrials
    corrects(rawLabel(j),j)=1;
end
imagesc(corrects); colorbar;
title('Trials (stimulus contrast)')

shg
%% get an intuition
figure
%let us get an intuition on why decoding should be possible
% for each of the stimuli we want to have an index variable (sorry, cell)
for i=min(rawLabel):max(rawLabel)
    indices{i}=find(rawLabel==i);
end

imagesc((mean(sp_count(:,:,indices{1}),3)-mean(sp_count(:,:,indices{3}),3))./std(sp_count(:,:,:),[],3))
%compare two very different orientations (left vs. right).
title('Activity difference in conditions')
colormap(jet); colorbar; shg

%% Now pack all these things into a feature matrix
features=reshape(sp_count,[size(sp_count,1)*size(sp_count,2) size(sp_count,3)]);
features=cat(1,features,trial_seq/max(trial_seq));
% reminder. From here onward simple problem: 
% model=function(trainFeatures,trainLabels).
% predict=function(model, testFeatures).
%%% Explain naive Bayes KPK
%% calculate means and standard deviations
for i=min(rawLabel):max(rawLabel)
    means(i,:)=mean(features(:,indices{i}),2);
    stds(i,:)=std(features(:,indices{i}),[],2)+0.2;
end

%% now lets make some predictions using naive Bayes
figure
clear p scores guess
numCond = length(unique(rawLabel));
for j=1:nTrials
    featuresThisTrial=repmat(features(:,j)',[numCond,1]);
    deviation=featuresThisTrial-means; %%% KPK
    scores(:,j)=sum(deviation.^2./(2*stds.^2),2); %%% KPK
    p(:,j)=exp(-scores(:,j)/max(scores(:,j))); %%% KPK
    p(:,j)=p(:,j)/sum(p(:,j)); %%% KPK
    guess(:,j)=(p(:,j)==max(p(:,j)));
end
imagesc(p); colorbar; shg
title('Imaging probabilities from Bayes')

% evaluate
pCorrect=mean(sum(p.*corrects))
guessCorrect=mean(sum(guess.*corrects))

%% Compare prediction vs. guess
figure
subplot(2,1,1); imagesc(corrects); title('Ground truth')
subplot(2,1,2); imagesc(guess); title('Prediction')
shg


%% Let us do 2 classes from now onward
label=matchLabel; %Correct or incorrect?
mouseAccuracy = sum(label)./length(label) %Is the animal actually doing the task?
% Matlab is way awkward for maching learning
%% choose a random test/training separation
%%% KKK discuss 
%Training: Odd trials. Test: Even trials.
shuffle=randperm(length(label));
trainFeatures=features(:,shuffle(1:end/2));
trainLabels=label(shuffle(1:end/2));
testFeatures=features(:,shuffle(end/2+1:end));
testLabels=label(shuffle(end/2+1:end));

%% naive Bayes overfitting
clear means stds scores p guess
%describe distributions as Gaussians. With apologies for the Poisson
%fanpeople.

% fit means and stds only to the training data
for i=0:1
    means(i+1,:)=mean(trainFeatures(:,find(trainLabels==i)),2);
    stds(i+1,:)=std(trainFeatures(:,find(trainLabels==i)),[],2)+0.2;
end
% now we will estimate labels on the test data and see how good we do on
% the training set
for j=1:size(trainFeatures,2)
    featuresThisTrial=repmat(trainFeatures(:,j)',[2,1]);
    deviation=featuresThisTrial-means;
    scores(:,j)=sum(deviation.^2./(2*stds.^2),2);
    p(:,j)=exp(-scores(:,j)/max(scores(:,j)));
    p(:,j)=p(:,j)/sum(p(:,j));
    guess(:,j)=(p(:,j)==max(p(:,j)));
end

figure
subplot(6,1,1)
imagesc(p)
title('p training')

subplot(6,1,2)
imagesc(trainLabels+1)
title('Ground truth')

subplot(6,1,3)
imagesc(guess)
title('Guess training')
%cheaply evaluate how well we do
c=corrcoef([guess(2,:)' trainLabels']);
correlation=c(2,1)
%% now see it overfit
%%% KPK do all this
for j=1:size(testFeatures,2)
    featuresThisTrial=repmat(testFeatures(:,j)',[2,1]);
    deviation=featuresThisTrial-means;
    scores(:,j)=sum(deviation.^2./(2*stds.^2),2);
    p(:,j)=exp(-scores(:,j)/max(scores(:,j)));
    p(:,j)=p(:,j)/sum(p(:,j));
    guess(:,j)=(p(:,j)==max(p(:,j)));
end
subplot(6,1,4)
imagesc(p)
title('p test')

subplot(6,1,5)
imagesc(testLabels+1)
title('Ground truth')

subplot(6,1,6)
imagesc(guess)
title('Guess test')
% evaluate how well we did
c=corrcoef([guess(2,:)' testLabels']);
correlation=c(2,1)
shg




