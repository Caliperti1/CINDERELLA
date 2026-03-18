%% GamePredictClassifier

% This is a weighted binary voting classifier.
% Input feature vector represents Team1 vs Team2.
% Output is 1 when Team1 is selected, 0 when Team2 is selected.

function winner = GamePredictClassifier(Features,modelStruct)
Team1 = 0;
Team2 = 0;

for mm = 1:length(modelStruct)
    modelType = modelStruct(mm).Type;

    % Weight defaults to 1 if older model metadata does not have weights.
    if isfield(modelStruct, 'Weight')
        thisWeight = modelStruct(mm).Weight;
    else
        thisWeight = 1;
    end

    % Produce both a class prediction and (when available) a probability.
    [predClass, pTeam1] = getModelVote(modelStruct(mm).Model, modelType, Features);

    if ~isnan(pTeam1)
        % Probability-aware weighted voting gives smoother aggregation than
        % hard labels when models expose calibrated/confidence outputs.
        Team1 = Team1 + thisWeight * pTeam1;
        Team2 = Team2 + thisWeight * (1 - pTeam1);
    else
        % Fallback for models that only expose hard classes.
        if predClass == 1
            Team1 = Team1 + thisWeight;
        else
            Team2 = Team2 + thisWeight;
        end
    end
end

if Team1 >= Team2
    winner = 1;
else 
    winner = 0;
end 

end

function [predClass, pTeam1] = getModelVote(model, modelType, features)
% Returns class in {0,1} and optional P(Team1 wins).
% pTeam1 = NaN when the model does not expose class probabilities.

pTeam1 = NaN;

switch modelType
    case "NeuralNet"
        raw = model(features');
        if isscalar(raw)
            pTeam1 = max(0, min(1, double(raw)));
            predClass = double(pTeam1 >= 0.5);
        else
            [~, idx] = max(raw(:));
            predClass = double(idx == 2);
            if numel(raw) >= 2
                pTeam1 = double(raw(2));
            end
        end

    case "DeepLearning"
        [label, scores] = classify(model, features);
        predClass = normalizeBinaryLabel(label);
        if size(scores, 2) >= 2
            % Class ordering is categorical; choose column matching class "1" when possible.
            classNames = string(model.Layers(end).Classes);
            idx1 = find(classNames == "1", 1);
            if isempty(idx1)
                idx1 = min(2, size(scores, 2));
            end
            pTeam1 = double(scores(1, idx1));
        end

    otherwise
        % Most MATLAB classifier objects support predict(...) and may return scores.
        try
            [label, scores] = predict(model, features);
            predClass = normalizeBinaryLabel(label);
            if size(scores, 2) >= 2
                idx1 = 2;
                if isprop(model, 'ClassNames')
                    classNames = string(model.ClassNames);
                    mappedIdx = find(classNames == "1", 1);
                    if ~isempty(mappedIdx)
                        idx1 = mappedIdx;
                    end
                end
                pTeam1 = double(scores(1, idx1));
            end
        catch
            label = predict(model, features);
            predClass = normalizeBinaryLabel(label);
        end
end

% Safety clamp in case an upstream model emits out-of-range confidence.
if ~isnan(pTeam1)
    pTeam1 = max(0, min(1, pTeam1));
end
end

function predClass = normalizeBinaryLabel(label)
% Normalizes model outputs into the expected 0/1 class space.

if iscategorical(label)
    label = string(label);
end

if isstring(label) || ischar(label)
    labelNum = str2double(string(label));
    if isnan(labelNum)
        predClass = double(strcmp(string(label), "1"));
    else
        predClass = double(labelNum >= 0.5);
    end
elseif isnumeric(label) || islogical(label)
    predClass = double(label >= 0.5);
else
    predClass = 0;
end

end


