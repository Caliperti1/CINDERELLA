%% Training Data Gen 
% This script will generate the training data sets to train the models in
% ModelTrain. Uses the stanard featureSet in FeatureEngineer but can be
% updated by reimplementing the case switching I took out of the last
% version of featureEngineer. 

% Trying something new, I think I can get away with doubling the dataset by
% flipping team 1 and team 2 

%% Load Data 
if ~exist('RawData.mat','file')
    DataManager
end 

load('RawData.mat')

%% NCAA Tournament Games 

for gm = 1:height(RawData.tournamentResults)

    % Find ID of teams 
    ii = rand(1);

    if ii >= 0.5
        Team1IDYr = RawData.tournamentResults.WTeamIDYr(gm);
        Team2IDYr = RawData.tournamentResults.LTeamIDYr(gm);
        Y_reg_NCAA(gm) = RawData.tournamentResults.WScore(gm)- ...
            RawData.tournamentResults.LScore(gm);
        Y_clas_NCAA(gm) = 1;
    else 
        Team2IDYr = RawData.tournamentResults.WTeamIDYr(gm);
        Team1IDYr = RawData.tournamentResults.LTeamIDYr(gm);
        Y_reg_NCAA(gm) = RawData.tournamentResults.LScore(gm) - ...
            RawData.tournamentResults.WScore(gm);
        Y_clas_NCAA(gm) = 0;
    end 

    if ii < 0.5
        Team1IDYr2 = RawData.tournamentResults.WTeamIDYr(gm);
        Team2IDYr2 = RawData.tournamentResults.LTeamIDYr(gm);
        Y_reg_NCAA2(gm) = RawData.tournamentResults.WScore(gm)- ...
            RawData.tournamentResults.LScore(gm);
        Y_clas_NCAA2(gm) = 1;
    else 
        Team2IDYr2 = RawData.tournamentResults.WTeamIDYr(gm);
        Team1IDYr2 = RawData.tournamentResults.LTeamIDYr(gm);
        Y_reg_NCAA2(gm) = RawData.tournamentResults.LScore(gm) - ...
            RawData.tournamentResults.WScore(gm);
        Y_clas_NCAA2(gm) = 0;
    end 

    X_NCAA(gm,:) = FeatureEngineer(Team1IDYr,Team2IDYr,RawData);
    X_NCAA2(gm,:) = FeatureEngineer(Team1IDYr2,Team2IDYr2, RawData);

end 


%% Export 

Y_reg = [Y_reg_NCAA Y_reg_NCAA2]';
Y_clas = [Y_clas_NCAA Y_clas_NCAA2]';
X = [X_NCAA; X_NCAA2];
save("TrainingData.mat","X","Y_clas","Y_reg");
