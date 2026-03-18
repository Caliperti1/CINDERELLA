%% Classifier Model Trainer
% Trains classifier models used by tournament simulation and saves
% validation-based weights for weighted ensemble voting.
%
% Why this script exists:
% - We no longer use regression models in production tournament voting.
% - This script centralizes classifier training + consistent weight export.
% - We keep RegressionModelTrain.m in the repo for optional experiments.

%% Load Data
matlabDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(matlabDir);
trainingDataFile = fullfile(matlabDir, 'TrainingData.mat');
modelsDir = fullfile(projectRoot, 'Models');

if ~isfile(trainingDataFile)
    TrainingDataGen
end

load(trainingDataFile)

if ~isfolder(modelsDir)
    mkdir(modelsDir)
end

% Shared cross-validation object so model metrics are directly comparable.
k = 5;
cvp = cvpartition(Y_clas, 'KFold', k);

% We accumulate comparable metrics per saved model.
ModelMetrics = struct('Name', {}, 'Accuracy', {}, 'CVLoss', {}, 'Weight', {});

%% 1) Tree Ensemble Classifier (strong nonlinear baseline)
TreeTic = tic;
TreeModel = fitcensemble(X, Y_clas, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 200, ...
    'Learners', templateTree('MaxNumSplits', 20));

cvTree = crossval(TreeModel, 'CVPartition', cvp);
TreeLoss = kfoldLoss(cvTree);
TreeAcc = 1 - TreeLoss;

fprintf('Tree Ensemble Accuracy: %.4f\n', TreeAcc);
fprintf('Tree Ensemble Training Time: %.2f sec\n', toc(TreeTic));
save(fullfile(modelsDir, 'TreeClassifier.mat'), 'TreeModel');

ModelMetrics(end+1) = struct( ...
    'Name', 'TreeClassifier.mat', ...
    'Accuracy', TreeAcc, ...
    'CVLoss', TreeLoss, ...
    'Weight', TreeAcc ...
);

%% 2) KNN Classifier
KNNTic = tic;
KNNModel = fitcknn(X, Y_clas, ...
    'NumNeighbors', 15, ...
    'Distance', 'euclidean', ...
    'Standardize', true);

cvKNN = crossval(KNNModel, 'CVPartition', cvp);
KNNLoss = kfoldLoss(cvKNN);
KNNAcc = 1 - KNNLoss;

fprintf('KNN Accuracy: %.4f\n', KNNAcc);
fprintf('KNN Training Time: %.2f sec\n', toc(KNNTic));
save(fullfile(modelsDir, 'KNN.mat'), 'KNNModel');

ModelMetrics(end+1) = struct( ...
    'Name', 'KNN.mat', ...
    'Accuracy', KNNAcc, ...
    'CVLoss', KNNLoss, ...
    'Weight', KNNAcc ...
);

%% 3) Logistic Regression Classifier
LRTic = tic;
LRModel = fitclinear(X, Y_clas, ...
    'Learner', 'logistic', ...
    'Regularization', 'ridge', ...
    'Lambda', 1e-3);

cvLR = crossval(LRModel, 'CVPartition', cvp);
LRLoss = kfoldLoss(cvLR);
LRAcc = 1 - LRLoss;

fprintf('Logistic Regression Accuracy: %.4f\n', LRAcc);
fprintf('Logistic Regression Training Time: %.2f sec\n', toc(LRTic));
save(fullfile(modelsDir, 'LR.mat'), 'LRModel');

ModelMetrics(end+1) = struct( ...
    'Name', 'LR.mat', ...
    'Accuracy', LRAcc, ...
    'CVLoss', LRLoss, ...
    'Weight', LRAcc ...
);

%% Convert raw metric scores to normalized voting weights
% We normalize weights to sum to 1 so each model contribution is directly
% interpretable in weighted voting.
rawWeights = [ModelMetrics.Weight];
rawWeights = max(rawWeights, 1e-4);
normalizedWeights = rawWeights ./ sum(rawWeights);

for ii = 1:numel(ModelMetrics)
    ModelMetrics(ii).Weight = normalizedWeights(ii);
end

% Save weight metadata where ModelAggregate can find it.
save(fullfile(modelsDir, 'ModelWeights.mat'), 'ModelMetrics');

fprintf('\nClassifier training complete. Saved %d weighted models.\n', numel(ModelMetrics));
