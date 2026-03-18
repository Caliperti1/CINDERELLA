%% Retrain Main 
% Run this when changes have been made to feature selection or data
% management to rebuild RawData, TrainingData, and retrain models 

%% Recreate RawData and Data
DMtic = tic;
DataManager
fprintf("Data Manager Complete: %.2f \n", toc(DMtic))

%% Regenerate Training DataSet 
TDtic = tic;
TrainingDataGen
fprintf("Training Data Generation Complete: %.2f \n", toc(TDtic))

% Train Models 
CLFtic = tic;
ClassifierModelTrain
fprintf("Classifier model training complete: %.2f \n", toc(CLFtic))

% NOTE:
% RegressionModelTrain is intentionally NOT called by default anymore.
% We keep that file in the repo for experimentation, but production voting
% now uses classifier-only models.

DNtic = tic;
DeepNetworkTrainer
fprintf("Deep Network Complete: %.2f \n", toc(DNtic))

% Aggregate Models 

ModelAggregate

fprintf("Retraining complete: %.2f", toc(DMtic))