%% GamePredictClassifier

% This will be a binary classifier take in features for 2 different teams 
% and return a 1 if team 1 is winner and 2 if team 2 is winner 

% We'll make another GamePredictRegression that returns a score
% differnetial too 

% For now This just randomy returns a 1 or a 2 to test the tournmantSim
% funciton 

function winner = GamePredictClassifier(Features)

Features = Features;

winner = randi(2,1);
end