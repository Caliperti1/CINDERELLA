%% GamePredictClassifier

% This will be a binary classifier take in features for 2 different teams 
% and return a 1 if team 1 is winner and 2 if team 2 is winner 

% We'll make another GamePredictRegression that returns a score
% differnetial too 

% For now This just randomy returns a 1 or a 2 to test the tournmantSim
% funciton 

function winner = GamePredictClassifier(Features)

Features = Features;

%% We will have multiple models that are chosen using the ModelNum param and case switching. 
% This will allow the montecarlo to randomly selected a model (or ensamble)
% for each individual game

% Will need to update Tournamentsim to have randi 
winner = randi(2,1);
end