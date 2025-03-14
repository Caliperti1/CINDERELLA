%% GamePredictClassifier

% This will be a binary classifier take in features for 2 different teams 
% and return a 1 if team 1 is winner and 2 if team 2 is winner 

% Randomly selects a model from the modelstruct and passes features to
% predict winner 

% We'll make another GamePredictRegression that returns a score
% differnetial too 

function winner = GamePredictClassifier(Features,modelStruct)
Team1 = 0;
Team2 = 0;

    % modelSelector = randi(length(modelStruct));
    % % modelSelector = 2;
    for mm =1:length(modelStruct)
        modelType = modelStruct(mm).Type;

    switch modelType
        case "NeuralNet"
            prediction = modelStruct(mm).Model(Features'); % Neural networks expect transposed input
        case "DeepLearning"
            prediction = classify(modelStruct(mm).Model, Features);
        otherwise 
            prediction = modelStruct(mm).Model.predict(Features);
    end 

    
        if strcmp(modelType, "Regressor")
            if prediction > 0 
                Team1 = Team1 + 1;
            else 
                Team2 = Team2 + 1;
            end 
        else 
            if prediction == 1 
                Team1 = Team1 + 1;
            else 
                Team2 = Team2 + 1;
            end 
        end 
    end 

if Team1 > Team2 
    winner = 1;
else 
    winner = 0;
end 


