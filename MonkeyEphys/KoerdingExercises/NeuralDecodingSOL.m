%% Decoding neural activity

% Machine learning for mind reading

% This tutorial introduces concepts that are central to the practice of 
% decoding neural activity using machine learning (or any method). 

%% OUTLINE
%
% 1. Overfitting
% 2. Crossvalidation
% 3. Regularization
% 4. Applying recurrent neural networks (This will be in python)
% 5. What methods work best and when?
clear; close all;
s = RandStream('mt19937ar','Seed',1);
RandStream.setGlobalStream(s);

%% Simulate some data
%
% generate some fake data
n_trials = 250;
n_neurons = 10;
n_bins_per_trial = 50;

% And generate some fake neural recordings
% We'll pretend we have a drift diffusion model
mean_rate = 50;
drift_rate = .05;
noise_variance = 1;


[neural_recordings, decisions] = generate_neural_data(n_trials, ...
    n_neurons, n_bins_per_trial, noise_variance, drift_rate, mean_rate);

%% Plot out trials for one neuron

neuron_id = 1;

figure(1); clf;
subplot(121); 
x = 0:10:n_bins_per_trial*10-1;
plot(x, squeeze(neural_recordings(:,:,neuron_id)),'LineWidth',2)
xlabel('Time (ms)');
ylabel('Spike rate (Hz)');
for ii=1:5, leg{ii} = sprintf('Trial %i\n',ii); end
legend(leg,'Location','Best')
box off;

subplot(122);
X = reshape(neural_recordings, n_trials,[]);
imagesc(X)
ylabel('Trial #');
xlabel('columns of neural traces');


%% Exercise 0: Look at the distribution of neural activity
% Let's gain an intuition for the data. Plot out the average neural 
% activity for each of the two choices.

% Average across trials and neurons ? we're going to assume they have the 
% same response properties. Then, plot out the averages for trials with a 
% choices of 0 vs a choice of 1.

% If you have extra time, overlay the standard deviations 

% SOLUTION
figure(2); clf; hold on;
x = 0:10:n_bins_per_trial*10-1;
means_0 = squeeze(mean(mean(neural_recordings(decisions==0,:,:),1),3))';
means_1 = squeeze(mean(mean(neural_recordings(decisions==1,:,:),1),3))';

p(1)=plot(x,means_0,'b','LineWidth',2);
p(2)=plot(x,means_1,'r','LineWidth',2);

% standard deviation overlay
n0 = reshape(permute(neural_recordings(decisions==0,:,:),[1,3,2]),sum(decisions==0)*n_neurons, n_bins_per_trial);
n1 = reshape(permute(neural_recordings(decisions==1,:,:),[1,3,2]),sum(decisions==1)*n_neurons, n_bins_per_trial);

std_0 = std(n0,1)';
plot(x,means_0+std_0,'b')
plot(x,means_0-std_0,'b')

std_1 = std(n1,1)';
plot(x,means_1+std_1,'r')
plot(x,means_1-std_1,'r')

legend(p,{'Choice 0','Choice 1'});
xlabel('time bins'); ylabel('spike rate (Hz)');

%% Exercise 1: Overfitting
im = imread('fitting.png');
figure(3); imshow(im);
title('Over-fitting');

% In common parlance, we call a classifier or regressor 'overfit' when it 
% has learned to explain noise in the training set at the expense of its 
% ability to generalize to new data.

% In that one-sentence description, we invoked the concepts of training set 
% and generalization. These are absolutely key to any modeling effort,
% including decoding.

% Training sets vs. testing sets
% You need to train your decoder, obviously, and for that you'll need 
% training data. No one cares how well your decoder works on your training 
% data, though. What we care about is its performance on **data not used** 
% for training. That is, we are interested in how well your decoder 
% generalizes to new data. The only way to rigorously know how well your 
% decoder **generalizes** is to test it on data not used for training. 

%% Fit a decoder using all your data

% We'll predict each decision using all neuron's activity throughout
X = reshape(neural_recordings, n_trials,[]);

% We'll use simple linear regression to learn some weights
[B0,stats] = lassoglm(X,decisions,...
    'binomial','Lambda',.05,'Alpha',.2,'link','identity');
cnst = stats.Intercept;
B1 = [cnst;B0];

% We'll apply those weights to predict our data set
pred= glmval(B1,X,'identity');
acc=sum(pred >.5 == decisions)/numel(pred);

% How did we do?
fprintf('\nLinear regression and prediction on data set\n')
fprintf('R2 was: %.2f; ', corr(pred,decisions)^2)
fprintf('Testing accuracy was: %.2f\n\n', acc)


%% Exercise 1.1

% Now, suppose you release your decoder in the world. Will it work? 
% Can't be better than perfect, right?

% Create some new data and calculate the R-squared of your model on new
% data.

%% Let's do new electrophysiology and take new data. This cost $2,000,000 in
%  NIH funding so it better work

[new_neural_recordings, new_decisions] = generate_neural_data(n_trials, ...
    n_neurons, n_bins_per_trial, noise_variance, drift_rate, mean_rate);

new_X = reshape(new_neural_recordings, n_trials,[]);

% Solution:
% predict the decisions
new_pred= glmval(B1,new_X,'identity');
acc=sum(new_pred >.5 == new_decisions)/numel(new_pred);

% calculate the accuracy and the R-squared for this new data
fprintf('\nLinear regression and prediction on new data set\n')
fprintf('R2 was: %.2f; ', corr(new_pred,new_decisions)^2)
fprintf('Testing accuracy was: %.2f\n\n', acc)


%% Exercise 1.2:
% You may have noticed that we're using linear regression, even though we 
% have a classification problem. It'd be better to use logistic regression.

% Fit and score this logistic regression method using your original data.

% Then, also score this method with the new data you just obtained with 
% your R01 funds. (That is, print both the test and train accuracy.)
X = reshape(neural_recordings, n_trials,[]);

[B0,stats] = lassoglm(X,decisions,...
    'binomial','Lambda',.05,'Alpha',.2,'link','logit');
cnst = stats.Intercept;
B1 = [cnst;B0];

% Solution
% 1) Make predictions for the original and the new data set
fprintf('\nLogistic regression and prediction on an original data set\n')
pred = glmval(B1,X,'logit');

% 2) calculate the r-squared and the accuracy
acc=sum(pred >.5 == decisions)/numel(pred);
fprintf('R2 was: %.2f; ', corr(pred,decisions)^2)
fprintf('Training accuracy was: %.2f\n', acc)


new_X = reshape(new_neural_recordings, n_trials,[]);
fprintf('\nLogistic regression and prediction on a new data set\n')
new_pred = round(glmval(B1,new_X,'logit'));
acc=sum(abs(new_pred-new_decisions) < 1e-12)/numel(pred);
fprintf('R2 was: %.2f; ', corr(new_pred,new_decisions)^2)
fprintf('Testing accuracy was: %.2f\n\n', acc)


% Once you've completed this, just run the next cell.
% It shows the coefficients of the fit you just made. Does it match your
% intuitions?


%% 

figure(4); clf; 
plot_coefs(B0,n_neurons, n_bins_per_trial)
colormap jet

%% Crossvalidation

% split the data
split = round(4/5*n_trials);
training_data = X(1:split,:);
validation_data = X(split+1:end,:);

training_decisions = decisions(1:split);
validation_decisions = decisions(split+1:end);

% Solution
% fit on the training data
[B0,stats] = lassoglm(X,decisions,...
    'binomial','Lambda',.05,'Alpha',.2,'link','logit');
cnst = stats.Intercept;
B1 = [cnst;B0];

pred = glmval(B1,training_data,'logit');
acc=sum(pred >.5 == training_decisions)/numel(pred);
fprintf('R2 was: %.2f; ', corr(pred,training_decisions)^2)
fprintf('Training accuracy was: %.2f\n', acc)

% score on the validation data

pred = glmval(B1,validation_data,'logit');
acc=sum(pred >.5 == validation_decisions)/numel(pred);
fprintf('R2 was: %.2f; ', corr(pred,validation_decisions)^2)
fprintf('Testing accuracy was: %.2f\n', acc)


% But right now we're only testing on 20% of the data! 
% Small data means high variance, so maybe we can't trust these scores much.

%% k-fold crossvalidation
% A common practice is therefore to perform k-fold crossvalidation. This 
% just means we rotate which segment of the original data is the validation 
% set. We can then average the scores.

%% Exercise 2
%
% Fill out the missing gaps in the script below.
% How close is the validation accuracy to the test set accuracy?
% How much did using 80% of the data affect the test set accuracy?
%

[training_sets, training_Ys, val_sets, val_Ys] = get_test_train_splits(X, decisions, 5);
figure(5);

% Iterate through the k=5 folds
for fold = 1:5
    
    training_X = training_sets{fold};
    training_Y = training_Ys{fold};
    
    validation_X = val_sets{fold};
    validation_Y = val_Ys{fold};
    
    % Solution
    % fit on the training data
    [B0,stats] = lassoglm(training_X,training_Y,...
        'binomial','Lambda',.05,'Alpha',.2,'link','logit');
    cnst = stats.Intercept;
    B1 = [cnst;B0];
    
    % predict for the training ata
    pred = glmval(B1,training_data,'logit');
    acc=sum(pred >.5 == training_decisions)/numel(pred);
    fprintf('R2 was: %.2f; ', corr(pred,training_decisions)^2)
    fprintf('Training accuracy was: %.2f\n', acc)
    
    % predict for the validation data
    pred = glmval(B1,validation_data,'logit');
    val_accuracy=sum(pred >.5 == validation_decisions)/numel(pred);
    fprintf('R2 was: %.2f; ', corr(pred,validation_decisions)^2)
    fprintf('Testing accuracy was: %.2f\n', val_acc)
    
    scores(fold) = val_accuracy;
    
    subplot(5,1,fold);
    plot_coefs(B0,n_neurons,n_bins_per_trial);
    title(sprintf('Testing accuracy was: %.2f\n', val_accuracy))
end

fprintf('Mean validation accuracy: %2f\n', mean(scores))

% lassoglm can actually also do this cross-validation for you. When you go
% to the documentation in the next section, you should check out the option
% 'CV' (stands for cross-validation)

%% Exercise 3. Regularization
%
% Here we'll investigate regularization, as talked about in the lecture.
%
% We've actually already been applying some regularization. 
%
% The 'Alpha' and 'Lamba' parameters control weights on the regularization
%
% Check out the documentation of lassoglm (hint: search for Alpha and
% Lambda): https://www.mathworks.com/help/stats/lassoglm.html
%
% Alpha = 1 -> Lasso or L1, where Alpha close to zero is ridge regression
% or (L2)
%
% Lambda is the weight on the regularization (see Alpha).  The lassoglm
% function allows multiple values of lambda but you will have to change the
% code a bit if you want to allow multiple values at once (I suggest taking
% advantage of the 'CV' option to get rid of the loop..... or take a look at
% the next cell)

alpha0 = .2;
lambda0 = .05;

[training_sets, training_Ys, val_sets, val_Ys] = get_test_train_splits(X, decisions, 5);
figure(5);

% Iterate through the k=5 folds
for fold = 1:5
    
    training_X = training_sets{fold};
    training_Y = training_Ys{fold};
    
    validation_X = val_sets{fold};
    validation_Y = val_Ys{fold};
    
    % fit on the training data
    [B0,stats] = lassoglm(training_X,training_Y,...
        'binomial','Lambda',lambda0,'Alpha', alpha0,'link','logit');
    cnst = stats.Intercept;
    B1 = [cnst;B0];
    
    pred = glmval(B1,training_data,'logit');
    acc=sum(pred >.5 == training_decisions)/numel(pred);
    fprintf('R2 was: %.2f; ', corr(pred,training_decisions)^2)
    fprintf('Training accuracy was: %.2f\n', acc)
    
    pred = glmval(B1,validation_data,'logit');
    val_acc=sum(pred >.5 == validation_decisions)/numel(pred);
    fprintf('R2 was: %.2f; ', corr(pred,validation_decisions)^2)
    fprintf('Testing accuracy was: %.2f\n', val_acc)
    
    scores(fold) = val_acc;

    subplot(5,1,fold);
    plot_coefs(B0,n_neurons,n_bins_per_trial);
    title(sprintf('Testing accuracy was: %.2f\n', val_acc))
end

fprintf('Mean validation accuracy: %2f\n', mean(scores))


%% Exercise 3.3: Choose the best regularization penalty
%
% place the code below in a set of loops to find the best alpha/lambda
% combination

alphas = [.001,.01,.1,.5,1];
lambdas = [.0001,.01,.1,.5];
reg_scores = nan(length(alphas),length(lambdas));
training_data = X(1:split,:);
validation_data = X(split+1:end,:);

training_decisions = decisions(1:split);
validation_decisions = decisions(split+1:end);

for ll=1:length(lambdas)
for aa=1:length(alphas)
    
     % fit on the training data
    [B0,stats] = lassoglm(training_data,training_decisions,...
        'binomial','Lambda',lambdas(ll),'Alpha', alphas(aa),'link','logit','CV',5);
    cnst = stats.Intercept;
    B1 = [cnst;B0];
    pred = glmval(B1,training_data,'logit');
    acc=sum(pred >.5 == training_decisions)/numel(pred);
    fprintf('R2 was: %.2f; ', corr(pred,training_decisions)^2)
    fprintf('Training accuracy was: %.2f\n', acc)
    
    % Solution
    % predict for validation set
    pred = glmval(B1,validation_data,'logit');
    val_acc=sum(pred >.5 == validation_decisions)/numel(pred);
    fprintf('R2 was: %.2f; ', corr(pred,validation_decisions)^2)
    fprintf('Validation accuracy was: %.2f\n', val_acc)
    
    reg_scores(aa,ll) = val_acc;
    
end
end

%%
figure(6); clf;
plot(reg_scores,'LineWidth',2);
xlabel('alpha')
ylabel('validation set accuracy')
legend(cellstr(num2str(lambdas')));

%% Now for some python...

