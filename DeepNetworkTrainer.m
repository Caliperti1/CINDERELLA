%% Deep Network Trainer 
%% Load Data 
if ~exist('Features.mat','file')
    TrainingDataGen
end 

load('TrainingData.mat')

numFeatures = size(X, 2);

%% Define the Deep Learning Model
layers = [
    featureInputLayer(numFeatures, 'Normalization', 'zscore') % Input layer with normalization

    fullyConnectedLayer(64)         % First hidden layer
    reluLayer
    dropoutLayer(0.2)               % Dropout to prevent overfitting

    fullyConnectedLayer(32)         % Second hidden layer
    reluLayer
    dropoutLayer(0.2) 

    fullyConnectedLayer(1)          % Output layer (1 neuron for binary classification)
    sigmoidLayer                    % Sigmoid activation for probability output
    classificationLayer              % Cross-entropy loss for binary classification
];

%% Set Training Options
options = trainingOptions('adam', ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 32, ...
    'InitialLearnRate', 0.001, ...
    'Shuffle', 'every-epoch', ...
    'ValidationSplit', 0.2, ... % 80% training, 20% validation
    'Plots', 'training-progress', ...
    'Verbose', false);

%% Train the Model
fprintf('Training the deep learning model...\n');
DeepNet = trainNetwork(X, Y, layers, options);

%% Evaluate the Model
% Predict labels on the training data
YPred = classify(DeepNet, X);

% Compute accuracy
accuracy = mean(YPred == Y);
fprintf('Model Accuracy: %.2f%%\n', accuracy * 100);

%% Save & Use the Model
save("Models\DeepNet", "DeepNet")

% Example usage: Predicting a new game outcome

predictedWinner = classify(DeepNet, newGameStats);
fprintf('Predicted Winner: %s\n', char(predictedWinner));
