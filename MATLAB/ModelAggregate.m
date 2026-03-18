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
matlabDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(matlabDir);
folderPath = fullfile(projectRoot, 'Models');
fileList = dir(fullfile(folderPath, '*.mat'));

% Optional model performance metadata used for weighted voting.
weightsPath = fullfile(folderPath, 'ModelWeights.mat');
weightsMap = containers.Map('KeyType', 'char', 'ValueType', 'double');

if isfile(weightsPath)
    weightsData = load(weightsPath);
    if isfield(weightsData, 'ModelMetrics')
        for ww = 1:numel(weightsData.ModelMetrics)
            modelName = char(weightsData.ModelMetrics(ww).Name);
            weightsMap(modelName) = double(weightsData.ModelMetrics(ww).Weight);
        end
    end
end

% Initialize struct array
modelStruct = struct([]);

%% Loop through each file and load the model
for i = 1:length(fileList)
    % ModelWeights.mat is metadata, not a predictor model.
    if strcmp(fileList(i).name, 'ModelWeights.mat')
        continue
    end

    filePath = fullfile(folderPath, fileList(i).name);
    modelmat = load(filePath);  % Load .mat file
    
    % Assuming each .mat file contains a single variable (the trained model)
    modelFields = fieldnames(modelmat);
    model = modelmat.(modelFields{1}); % Extract the model

    % Determine the model type
    if isa(model, 'ClassificationSVM') || ...
       isa(model, 'ClassificationTree') || ...
       isa(model, 'ClassificationEnsemble') || ...
       isa(model, 'ClassificationKNN') || ...
       isa(model, 'ClassificationLinear') || ...
       contains(class(model), 'Classification')
        modelType = "Classifier";
    elseif isa(model, 'DAGNetwork') || isa(model, 'SeriesNetwork')
        % Deep learning classifier networks should use classify(...).
        modelType = "DeepLearning";
    elseif isa(model, 'network')
        modelType = "NeuralNet";
    elseif isa(model, 'RegressionSVM') || ...
           isa(model, 'RegressionTree') || ...
           isa(model, 'RegressionEnsemble') || ...
           contains(class(model), 'Regression')
        modelType = "Regressor";
    else
        modelType = "Unknown"; % Fallback if type can't be determined
    end

    % Production voting explicitly excludes regressors and unknown objects.
    if modelType == "Regressor" || modelType == "Unknown"
        continue
    end

    % Store in struct
    modelStruct(end+1).Model = model; %#ok<AGROW>
    modelStruct(end).Type = modelType;
    modelStruct(end).Name = fileList(i).name;

    if isKey(weightsMap, fileList(i).name)
        modelStruct(end).Weight = weightsMap(fileList(i).name);
    else
        % If no metric was saved for this model, keep it but give neutral weight.
        modelStruct(end).Weight = 1;
    end
end

% Normalize weights so they sum to 1 in downstream weighted voting.
if ~isempty(modelStruct)
    allWeights = [modelStruct.Weight];
    allWeights = max(allWeights, 1e-4);
    allWeights = allWeights ./ sum(allWeights);

    for ii = 1:numel(modelStruct)
        modelStruct(ii).Weight = allWeights(ii);
    end
end
