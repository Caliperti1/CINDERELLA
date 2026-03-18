%% Deep Network Trainer 
%% Load Data 
matlabDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(matlabDir);
trainingDataFile = fullfile(matlabDir, 'TrainingData.mat');
modelsDir = fullfile(projectRoot, 'Models');

if ~isfile(trainingDataFile)
    TrainingDataGen
end 

load(trainingDataFile)

numFeatures = size(X, 2);

%% Manually Split Data into Training and Validation Sets
cv = cvpartition(Y_clas, 'HoldOut', 0.1); % 90% training, 10% validation
XTrain = X(training(cv), :);
YTrain = Y_clas(training(cv), :);
XValidation = X(test(cv), :);
YValidation = Y_clas(test(cv), :);

YTrain = categorical(YTrain);
YValidation = categorical(YValidation);

%% Define the Deep Learning Model
layers = [
    featureInputLayer(numFeatures, 'Normalization', 'zscore') % Input layer with normalization

    fullyConnectedLayer(64)         % First hidden layer
    reluLayer
    dropoutLayer(0.2)               % Dropout to prevent overfitting

    fullyConnectedLayer(32)         % Second hidden layer
    reluLayer
    dropoutLayer(0.2) 

    fullyConnectedLayer(2)          % Output layer (1 neuron for binary classification)
    sigmoidLayer                    % Sigmoid activation for probability output
    classificationLayer              % Cross-entropy loss for binary classification
];

%% Set Training Options (Removed 'ValidationSplit', added Validation Data)
options = trainingOptions('adam', ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 32, ...
    'InitialLearnRate', 0.001, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {XValidation, YValidation}, ... % Manually specify validation set
    'Plots', 'training-progress', ...
    'Verbose', false);

%% Train the Model
fprintf('Training the deep learning model...\n');
DeepNet = trainNetwork(XTrain, YTrain, layers, options);

%% Evaluate the Model
% Predict labels on the training data
YPred = classify(DeepNet, XValidation);

% Compute accuracy
accuracy = mean(YPred == YValidation);
fprintf('Validation Accuracy: %.2f%%\n', accuracy * 100);

%% Save & Use the Model
save(fullfile(modelsDir, 'DeepNet.mat'), "DeepNet")

% Persist deep model weight metadata so weighted voting can include it.
% We append to ModelWeights.mat if it already exists.
weightsPath = fullfile(modelsDir, 'ModelWeights.mat');
deepMetric = struct('Name', 'DeepNet.mat', 'Accuracy', double(accuracy), ...
    'CVLoss', double(1 - accuracy), 'Weight', double(accuracy));

if isfile(weightsPath)
    data = load(weightsPath);
    if isfield(data, 'ModelMetrics')
        ModelMetrics = data.ModelMetrics;
    else
        ModelMetrics = struct('Name', {}, 'Accuracy', {}, 'CVLoss', {}, 'Weight', {});
    end
else
    ModelMetrics = struct('Name', {}, 'Accuracy', {}, 'CVLoss', {}, 'Weight', {});
end

% Replace existing DeepNet entry if present; otherwise append.
idx = [];
for ii = 1:numel(ModelMetrics)
    if strcmpi(ModelMetrics(ii).Name, 'DeepNet.mat')
        idx = ii;
        break
    end
end

if isempty(idx)
    ModelMetrics(end+1) = deepMetric;
else
    ModelMetrics(idx) = deepMetric;
end

% Renormalize all model weights after adding the deep model metric.
rawWeights = [ModelMetrics.Weight];
rawWeights = max(rawWeights, 1e-4);
rawWeights = rawWeights ./ sum(rawWeights);

for ii = 1:numel(ModelMetrics)
    ModelMetrics(ii).Weight = rawWeights(ii);
end

save(weightsPath, 'ModelMetrics');
