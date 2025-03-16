%% Deep Network Trainer 
%% Load Data 
if ~exist('TrainingData.mat','file')
    TrainingDataGen
end 

load('TrainingData.mat')

numFeatures = size(X, 2);

%% Manually Split Data into Training and Validation Sets
cv = cvpartition(Y_clas, 'HoldOut', 0.1); % 80% training, 20% validation
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
save("Models\DeepNet.mat", "DeepNet")

% Example usage: Predicting a new game outcome
predictedWinner = classify(DeepNet, newGameStats);
fprintf('Predicted Winner: %s\n', char(predictedWinner));
