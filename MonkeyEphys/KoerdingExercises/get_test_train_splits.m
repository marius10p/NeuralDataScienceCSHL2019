function [training_sets, training_Y, val_sets, val_Y] = get_test_train_splits(data, decisions, n_folds)
% Returns matched train sets and validation sets, rotating 
% through the data.
  
fold_size = size(data,1)/n_folds;
training_sets = cell(n_folds,1); val_sets = cell(n_folds,1);
training_Y = cell(n_folds,1); val_Y = cell(n_folds,1);

for ff = 1:n_folds
    tmp = circshift(data,(ff-1)*fold_size,1);
    tmpy = circshift(decisions,(ff-1)*fold_size,1);
    
    training_sets{ff} = tmp(fold_size+1:end,:);
    training_Y{ff} = tmpy(fold_size+1:end,:);
    
    val_sets{ff} = tmp(1:fold_size,:);
    val_Y{ff} = tmpy(1:fold_size);
    
end



end

