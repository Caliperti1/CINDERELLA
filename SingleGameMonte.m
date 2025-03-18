%% Single Game Motne 
function [Winner,confidence] = SingleGameMonte(TeamIDYr1,TeamIDYr2,RawData,Data,modelStruct,n)

Team1Count = 0;
Team2Count = 0;

for ii = 1:n
% Feature Engineer 
Features = FeatureEngineer(TeamIDYr1,TeamIDYr2, RawData, Data,"RAND");

% Predict Game 

    SimWin = GamePredictClassifier(Features,modelStruct);
    
    if SimWin == 1
        Team1Count = Team1Count + 1;
    else 
        Team2Count = Team2Count + 1;
    end 

end 
if Team1Count > Team2Count 
    Winner = TeamIDYr1;
    WinnerCount = Team1Count;
else 
    Winner = TeamIDYr2;
    WinnerCount = Team2Count;
end 

confidence = WinnerCount / n;


    