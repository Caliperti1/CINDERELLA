% %% Model Aggregator 
% 
% % Get list of .mat files in the folder
% root = pwd;
% folderPath = root + "\Models"; % Update with your folder path
% fileList = dir(fullfile(folderPath, '*.mat'));
% 
% % Initialize struct array
% modelStruct = struct([]);
% 
% %% Loop through each file and load the model
% for i = 1:length(fileList)
%     filePath = fullfile(folderPath, fileList(i).name);
%     modelmat = load(filePath);  % Load .mat file
% 
%     % Assuming each .mat file contains a single variable (the trained model)
%     modelFields = fieldnames(modelmat);
%     model = modelmat.(modelFields{1}); % Extract the model
% 
%     % Determine if the model is a classifier or regressor
%     if isa(model, 'ClassificationSVM') || ...
%        isa(model, 'ClassificationTree') || ...
%        isa(model, 'ClassificationEnsemble') || ...
%        contains(class(model), 'Classification')
%         modelType = "Classifier";
%     elseif isa(model, 'RegressionSVM') || ...
%            isa(model, 'RegressionTree') || ...
%            isa(model, 'RegressionEnsemble') || ...
%            contains(class(model), 'Regression')
%         modelType = "Regressor";
%     else
%         modelType = 'Unknown'; % Fallback if type can't be determined
%     end
% 
%     % Store in struct
%     modelStruct(i).Model = model;
%     modelStruct(i).Type = modelType;
%     modelStruct(i).Name = fileList(i).name; % Store filename for reference
% end
%% Model Aggregator 

% Get list of .mat files in the folder
root = pwd;
folderPath = root + "\Models"; % Update with your folder path
fileList = dir(fullfile(folderPath, '*.mat'));

% Initialize struct array
modelStruct = struct([]);

%% Loop through each file and load the model
for i = 1:length(fileList)
    filePath = fullfile(folderPath, fileList(i).name);
    modelmat = load(filePath);  % Load .mat file
    
    % Assuming each .mat file contains a single variable (the trained model)
    modelFields = fieldnames(modelmat);
    model = modelmat.(modelFields{1}); % Extract the model

    % Determine the model type
    if isa(model, 'ClassificationSVM') || ...
       isa(model, 'ClassificationTree') || ...
       isa(model, 'ClassificationEnsemble') || ...
       contains(class(model), 'Classification')
        modelType = "Classifier";
    elseif isa(model, 'RegressionSVM') || ...
           isa(model, 'RegressionTree') || ...
           isa(model, 'RegressionEnsemble') || ...
           contains(class(model), 'Regression')
        modelType = "Regressor";
    elseif isa(model, 'network') || isa(model, 'SeriesNetwork') || isa(model, 'DAGNetwork') % Neural Networks
        modelType = "NeuralNet";
     elseif isa(model, 'DAGNetwork') || isa(model, 'SeriesNetwork') % Deep Learning Models
        modelType = "DeepLearning";
    else
        modelType = "Unknown"; % Fallback if type can't be determined
    end

    % Store in struct
    modelStruct(i).Model = model;
    modelStruct(i).Type = modelType;
    modelStruct(i).Name = fileList(i).name; % Store filename for reference
end
