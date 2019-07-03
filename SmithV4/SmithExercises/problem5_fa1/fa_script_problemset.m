% Factor analysis is a type of dimensionality reduction in which there is
% an explicit noise model, partitioning the variance into shared (that
% which can be explained by the factors) and private (that which is not
% explainable by the other neurons). Your job is to run Factor analysis
% (FA) on the data and create two functions, cv_fastfa.m that
% cross-validates FA by splitting data into train and test sets, and
% compute_shared.m that then estimates the percent shared variance. This
% script will do all the plotting work for you, the job is to work just on
% those two functions.
% 

clear all; close all
load('../data/S_counts_grats')

%% constants
thresh = 0.99;

%% Subtract mean firing rates for each condition and concatenate conditions
counts = [];
for n = 1:length(S)
    temp = S(n).counts;
    counts = [counts temp-repmat(mean(temp,2),1,size(temp,2))];
end

maxdim = size(counts,1);
maxtrials = 5000;

%% vary trial count
neuronnums = maxdim;
trialnums = 1000:1000:maxtrials;
percentsharedt = nan(1,length(trialnums));
d_sharedt = nan(1,length(trialnums));

for tind = 1:length(trialnums)
    neuroninds = 1:neuronnums;
    trialinds = randperm(maxtrials,trialnums(tind));

%% determine number of latent dimensions to crossvalidate over
    zdims = 2:2:20;
    
%% crossvalidate over zdims %%%% MODIFY THE FOLLOWING FUNCTION %%%%
   params =  cv_fastfa(counts(neuroninds,trialinds),zdims,4);

%% compute d_shared and percent shared %%%% MODIFY THE FOLLOWING FUNCTION %%%%
    [percentsharedt(tind), d_sharedt(tind) bestdimt(tind),sharedvar] = compute_shared(params, thresh);
    if bestdimt(tind) == max(zdims)
        fprintf('Reached zdim ceiling, trial num = %d',trialnums(tind))
        pause
    end
    %% pull out params for all neurons and all trials run
    if trialnums(tind)==max(trialnums)
        maxsharedvar = sharedvar;
    end
    if trialnums(tind) == min(trialnums)
        paramsmax = params;
    end
end

%% Compare train and test LL (matched number of trials)
trainLL = [paramsmax.sumLLtrain];
testLL = [paramsmax.sumLL];
zdimlist = [paramsmax.zDim];
figure
h(1) = scatter(zdimlist,trainLL,'k','fill');
hold on
h(2) = scatter(zdimlist,testLL,'k');
xlabel('Number of Latent Dimensions')
ylabel('Sum LL Across CV Folds')
box off; set(gca,'TickDir','out')
legend(h,'Train LL','Test LL')
legend('boxoff')

%% find shared variance by dimension
figure
scatter(1:length(maxsharedvar),cumsum(maxsharedvar))
xlabel('Dimension Index')
ylabel('Proportion of shared variance')
box off; set(gca,'TickDir','out')
ylim([0 1])

%% plot trial sweep
figure
subplot(1,2,1)
scatter(trialnums,d_sharedt,'k','fill')
box off; set(gca,'TickDir','out')
xlabel('Number of Trials')
ylabel('dshared')
ylim([0 max(d_sharedt)+1])

subplot(1,2,2)
scatter(trialnums,percentsharedt*100,'k','fill')
box off; set(gca,'TickDir','out')
xlabel('Number of Trials')
ylabel('Percent Shared')
ylim([0 50])







% %% vary neuron count (OPTIONAL - UNCOMMENT TO RUN)
% neuronnums = 10:5:maxdim;
% trialnums = maxtrials;
% percentshared = nan(1,length(neuronnums));
% d_shared = nan(1,length(neuronnums));
% for nind = 1:length(neuronnums)
%     neuroninds = randperm(maxdim,neuronnums(nind));
%     trialinds = 1:maxtrials;
% 
% %% determine number of latent dimensions to crossvalidate over
%     if neuronnums(nind)>20
%         zdims = 2:2:20;
%     else
%         zdims = 2:2:(neuronnums(nind)-1);%round(linspace(0,neuronnums(nind)-1,5));
%     end
% %% crossvalidate over zdims
%     params = cv_fastfa(counts(neuroninds,trialinds),zdims,4);
% 
% %% compute d_shared and percent shared
%     [percentshared(nind), d_shared(nind),bestdim(nind),sharedvar] = compute_shared(params, thresh);
%     if bestdim(nind) == max(zdims) && neuronnums(nind)>20
%         fprintf('Reached zdim ceiling, neuron num = %d',neuronnums(nind))
%         pause
%     end
%     
% 
% end
% 
% %% plot neuron sweep
% figure
% subplot(1,2,1)
% scatter(neuronnums,d_shared,'k','fill')
% box off; set(gca,'TickDir','out')
% xlabel('Number of Neurons')
% ylabel('dshared')
% ylim([0 max(d_shared)+1])
% xlim([5 35])
% subplot(1,2,2)
% scatter(neuronnums,percentshared*100,'k','fill')
% box off; set(gca,'TickDir','out')
% xlabel('Number of Neurons')
% ylim([0 50])
% xlim([5 35])
% ylabel('Percent Shared')
% 
