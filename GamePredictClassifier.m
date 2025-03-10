%% GamePredictClassifier

% This will be a binary classifier take in features for 2 different teams 
% and return a 1 if team 1 is winner and 2 if team 2 is winner 

% Randomly selects a model from the modelstruct and passes features to
% predict winner 

% We'll make another GamePredictRegression that returns a score
% differnetial too 

function winner = GamePredictClassifier(Features,modelStruct)

    modelSelector = randi(length(modelStruct));

    modelType = modelStruct(modelSelector).Type;

    prediction = modelStruct(modelSelector).Model.predict(Features);

    if modelType == 'Regressor'
        if prediction > 0 
            winner = 1;
        else 
            winner = 0;
        end 
    elseif modelType =='Classifier'
        winner = prediction;
    end 


end 


