%% DataManager
% This will read all of the necessary data out of the data folder (Updated
% yearly from Kaggle's March Machine Learning Madness challenge)

% Laod configs 
configs

% Timer 
DataManTimer = tic;
% Set Data directory 

cd Data\

%% Tournament Seeds Key 
TournamentSeeds = readtable("2024_tourney_seeds.csv");
TournamentSeeds.Seed = string(TournamentSeeds.Seed);
TournamentSeeds.Tournament = string(TournamentSeeds.Tournament);
TournamentSeeds = TournamentSeeds(TournamentSeeds.Tournament == "M",:);
 % Tournament (M or W) // Seed // Team ID (Key for other tables)

%% Load Data

% Team Names 
teamIDs = readtable('MTeams.csv');

% Detailed Regular Season results 
RawData.regularSeason = readtable('MRegularSeasonDetailedResults.csv');

% Detialed Tournament results 
RawData.tournamentResults = readtable('MNCAATourneyDetailedResults.csv');

% Conference Tournament results 
RawData.confTournamentResults = readtable('MConferenceTourneyGames.csv');

% Teams in each conference 
RawData.Conferences = readtable("MTeamConferences.csv");

% Current Year Tournament Seeds
RawData.TournamentSeeds = readtable('2024_tourney_seeds.csv');
RawData.TournamentSeeds = RawData.TournamentSeeds(RawData.TournamentSeeds.Tournament == "M",:);

% Team Names 
RawData.TeamNames = readtable('MTeams.csv');

% Secondary Tournament 
RawData.OtherTourns = readtable("MSecondaryTourneyCompactResults.csv");


%% Helpers 
DetailedHeaders = RawData.regularSeason.Properties.VariableNames;

%% Team Stats Cols 
    
    % 1: Wins
    % 2: Losses 
    % 3: Points For Per Game
    % 4: Points Against Per Game
    % 5: Field Goals Made Per Game
    % 6: Field Goals Attempted Per Game
    % 7: 3PT Field Goals Made Per Game
    % 8: 3PT Field Goals Attempted Per Game
    % 9: Free Throws Made Per Game
    % 10: Free Throws Attempted Per Game
    % 11: Offensive Rebounds Per Game
    % 12: Defensive Rebounds Per Game
    % 13: Assists Per Game
    % 14: Turnovers Per Game
    % 15: Steals Per Game
    % 16: Blocks Per Game
    % 17: Personal Fouls Per Game
    % 18: Conferenec Tournament Wins 
    % 19: Conference Tournament Losses 
    % 20: NCAA Tournament Wins 
    % 21: NCAA Tournament Losses 
    % 22: NCAA Tournament Points For Per Game
    % 23: NCAA Tournament Points Against Per Game
    % 24: NCAA Tournament Field Goals Made Per Game
    % 25: NCAA Tournament Field Goals Attempted Per Game
    % 26: NCAA Tournament 3PT Field Goals Made Per Game
    % 27: NCAA Tournament 3PT Field Goals Attempted Per Game
    % 28: NCAA Tournament Free Throws Made Per Game
    % 29: NCAA Tournament Free Throws Attempted Per Game
    % 30: NCAA Tournament Offensive Rebounds Per Game
    % 31: NCAA Tournament Defensive Rebounds Per Game
    % 32: NCAA Tournament Assists Per Game
    % 33: NCAA Tournament Turnovers Per Game
    % 34: NCAA Tournament Steals Per Game
    % 35: NCAA Tournament Blocks Per Game
    % 36: NCAA Tournament Personal Fouls Per Game
    % 37: NCAA Tournament Wins (DUPLICATE)
    % 38: NCAA Tournament Losses (DUPLICATE)
    % 39: NCAA Tournament Bracket Challenge Points Earned 
    % 40: 2nd Degree Regular Season Wins 
    % 41: 2nd Degree Regular Season Losses 
    % 42: 3rd Degree Regular Season Wins 
    % 43: 3rd Degree Regular Season Losses 
    % 44: 2nd Degree Regular Season Win Percentage 
    % 45: 3rd Degree Regular Season Win Percentage
    % 46: Field Goals Made Per Game Against 
    % 47: Field Goals Attempted Per Game Against
    % 48: 3PT Field Goals Made Per Game Against
    % 49: 3PT Field Goals Attempted Per Game Against
    % 50: Free Throws Made Per Game Against
    % 51: Free Throws Attempted Per Game Against
    % 52: Offensive Rebounds Per Game Against
    % 53: Defensive Rebounds Per Game Against
    % 54: Assists Per Game Against
    % 55: Turnovers Per Game Against
    % 56: Steals Per Game Against
    % 57: Blocks Per Game Against
    % 58: Personal Fouls Per Game Against

%% Create Combo TeamID - Year tags 
% Regular Season Table 
for ii = 1:height(RawData.regularSeason)
    RawData.regularSeason.WTeamIDYr(ii) = ...
        string(RawData.regularSeason.Season(ii)) + "_" +...
        string(RawData.regularSeason.WTeamID(ii));

        RawData.regularSeason.LTeamIDYr(ii) = ...
        string(RawData.regularSeason.Season(ii)) + "_" +...
        string(RawData.regularSeason.LTeamID(ii));
end 

% Tournament Results Table 
for ii = 1:height(RawData.tournamentResults)
    RawData.tournamentResults.WTeamIDYr(ii) = ...
        string(RawData.tournamentResults.Season(ii)) + "_" +...
        string(RawData.tournamentResults.WTeamID(ii));

    RawData.tournamentResults.LTeamIDYr(ii) = ...
        string(RawData.tournamentResults.Season(ii)) + "_" +...
        string(RawData.tournamentResults.LTeamID(ii));
end 

% Conference Tournament Results
for ii = 1:height(RawData.confTournamentResults)
    RawData.confTournamentResults.WTeamIDYr(ii) = ...
        string(RawData.confTournamentResults.Season(ii)) + "_" +...
        string(RawData.confTournamentResults.WTeamID(ii));

    RawData.confTournamentResults.LTeamIDYr(ii) = ...
        string(RawData.confTournamentResults.Season(ii)) + "_" +...
        string(RawData.confTournamentResults.LTeamID(ii));
end 

% Teams in each conference 
for ii = 1:height(RawData.Conferences)
    RawData.Conferences.TeamIDYr(ii) = ...
        string(RawData.Conferences.Season(ii)) + "_" +...
        string(RawData.Conferences.TeamID(ii));
end 

% Other Tournaments 
for ii = 1:height(RawData.OtherTourns)
    RawData.OtherTourns.WTeamIDYr(ii) = ...
        string(RawData.OtherTourns.Season(ii)) + "_" +...
        string(RawData.OtherTourns.WTeamID(ii));

    RawData.OtherTourns.LTeamIDYr(ii) = ...
        string(RawData.OtherTourns.Season(ii)) + "_" +...
        string(RawData.OtherTourns.LTeamID(ii));
end 


%% Create Summary Stats Table 

% Find all unique teams 
RawData.TeamIDs = unique([RawData.regularSeason.LTeamIDYr,RawData.regularSeason.WTeamIDYr]);

%Instantiate Matrix of stats (Each unique Team has its own row) (adjust
%ocls for num of fetures 
RawData.TeamStats = zeros(length(RawData.TeamIDs),100);

%% Straight Regular Season Stats 

for gm = 1:height(RawData.regularSeason)

    % Find teams that played in this game 
    WTeamIndx = find(RawData.TeamIDs  == RawData.regularSeason.WTeamIDYr(gm));
    LTeamIndx = find(RawData.TeamIDs  == RawData.regularSeason.LTeamIDYr(gm));

    % Col 1: Season Wins 
    RawData.TeamStats(WTeamIndx,1) =  RawData.TeamStats(WTeamIndx,1) + 1;

    % Col 2: Losses 
    RawData.TeamStats(LTeamIndx,2) =  RawData.TeamStats(LTeamIndx,2) + 1;

    % Col 3: Points for 
    RawData.TeamStats(WTeamIndx,3) =  RawData.TeamStats(WTeamIndx,3) + RawData.regularSeason.WScore(gm);
    RawData.TeamStats(LTeamIndx,3) =  RawData.TeamStats(LTeamIndx,3) + RawData.regularSeason.LScore(gm);

    % Col 4: Points Against
    RawData.TeamStats(LTeamIndx,4) = RawData.TeamStats(LTeamIndx,4) + RawData.regularSeason.WScore(gm);
    RawData.TeamStats(WTeamIndx,4) = RawData.TeamStats(LTeamIndx,4) + RawData.regularSeason.LScore(gm);

    % Col 5 - 17 : Summary Stats 
    for col = 5:17
    RawData.TeamStats(WTeamIndx,col) = RawData.TeamStats(WTeamIndx,col) + RawData.regularSeason.(DetailedHeaders{col+4})(gm);
    RawData.TeamStats(LTeamIndx,col) = RawData.TeamStats(LTeamIndx,col) + RawData.regularSeason.(DetailedHeaders{col+17})(gm);
    end 
    
end 

% Turn stats into per game stats 

for tm = 1:length(RawData.TeamStats)
    gms = RawData.TeamStats(tm,1) + RawData.TeamStats(tm,2);

    for ss = 3:17
       RawData.TeamStats(tm,ss) = RawData.TeamStats(tm,ss) / gms;
    end 
end 

%% Conference Tournament Stats 
for gm = 1:height(RawData.confTournamentResults)

    % Find teams that played in this game 
    WTeamIndx = find(RawData.TeamIDs == RawData.confTournamentResults.WTeamIDYr(gm));
    LTeamIndx = find(RawData.TeamIDs == RawData.confTournamentResults.LTeamIDYr(gm));

    % Col 18: Season Wins 
    RawData.TeamStats(WTeamIndx,18) =  RawData.TeamStats(WTeamIndx,18) + 1;

    % Col 19: Losses 
    RawData.TeamStats(LTeamIndx,19) =  RawData.TeamStats(LTeamIndx,19) + 1;

end

%% NCAA Tournament Stats 
for gm = 1:height(RawData.tournamentResults)

    % Find teams that played in this game 
    WTeamIndx = find(RawData.TeamIDs == RawData.tournamentResults.WTeamIDYr(gm));
    LTeamIndx = find(RawData.TeamIDs == RawData.tournamentResults.LTeamIDYr(gm));

    % Col 20: Wins
    RawData.TeamStats(WTeamIndx,20) =  RawData.TeamStats(WTeamIndx,20) + 1;

    % Col 21: Losses 
    RawData.TeamStats(LTeamIndx,21) =  RawData.TeamStats(LTeamIndx,21) + 1;

    % Col 22: Points for 
    RawData.TeamStats(WTeamIndx,20) =  RawData.TeamStats(WTeamIndx,20) + RawData.tournamentResults.WScore(gm);
    RawData.TeamStats(LTeamIndx,20) =  RawData.TeamStats(LTeamIndx,20) + RawData.tournamentResults.LScore(gm);

    % Col 23: Points Against
    RawData.TeamStats(LTeamIndx,21) =  RawData.TeamStats(WTeamIndx,21) + RawData.tournamentResults.WScore(gm);
    RawData.TeamStats(WTeamIndx,21) =  RawData.TeamStats(LTeamIndx,21) + RawData.tournamentResults.LScore(gm);

    % Col 24 - 36 : Summary Stats 
    for col = 24:36
    RawData.TeamStats(WTeamIndx,col) = RawData.TeamStats(WTeamIndx,col) + RawData.tournamentResults.(DetailedHeaders{col-15})(gm);
    RawData.TeamStats(LTeamIndx,col) = RawData.TeamStats(LTeamIndx,col) + RawData.tournamentResults.(DetailedHeaders{col-2})(gm);
    end 
    
end

for tm = 1:height(RawData.TeamStats)
    gms = RawData.TeamStats(tm,20) + RawData.TeamStats(tm,21);

    for ss = 24:36
       RawData.TeamStats(tm,ss) = RawData.TeamStats(tm,ss) / gms;
    end 
end 

%% Tournament Stats

% NCAA Tournament Wins 
for tt = 1:height(RawData.tournamentResults)

    % Find index of teams that played in this game 
    WTeamIndex = find(RawData.TeamIDs == RawData.tournamentResults.WTeamIDYr(tt));
    LTeamIndex = find(RawData.TeamIDs == RawData.tournamentResults.LTeamIDYr(tt));

    % Col 37: NCAA Tournament Wins 
    RawData.TeamStats(WTeamIndex,37) = RawData.TeamStats(tt,37) + 1;
    
    % Col 38: NCAA Tournament Losses 
    RawData.TeamStats(LTeamIndex,38) = RawData.TeamStats(tt,38) + 1;

end

% Convert wins to Tournament Challenge points

TCP = [10 20 40 80 160 320];

for tt = 1:height(RawData.TeamStats)

    % Col 39: Tournament challenge points
    if RawData.TeamStats(tt,37) > 0
        RawData.TeamStats(tt,39) = TCP(RawData.TeamStats(tt,37));
    end 
end 

%% Strength of Schedule measures 
% Second Degree wins 
for gg = 1:height(RawData.regularSeason)
    
    % Find teams that played in this game 
    WTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.WTeamIDYr(gg));
    LTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.LTeamIDYr(gg));

    % Col 40: 2nd Degree wins  
    RawData.TeamStats(WTeamIndx,40) =  RawData.TeamStats(WTeamIndx,40) + RawData.TeamStats(LTeamIndx,1);
    RawData.TeamStats(LTeamIndx,40) =  RawData.TeamStats(LTeamIndx,40) + RawData.TeamStats(WTeamIndx,1);
    % Col 41: 2nd Degree loses  
     
    RawData.TeamStats(WTeamIndx,41) =  RawData.TeamStats(WTeamIndx,41) + RawData.TeamStats(LTeamIndx,2);
    RawData.TeamStats(LTeamIndx,41) =  RawData.TeamStats(LTeamIndx,41) + RawData.TeamStats(WTeamIndx,2);
end 

% Third Degree wins 
% Find teams that played in this game 
for gg = 1:height(RawData.regularSeason)
    WTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.WTeamIDYr(gg));
    LTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.LTeamIDYr(gg));

    % Col 42: 3rd Degree wins  
    RawData.TeamStats(WTeamIndx,42) =  RawData.TeamStats(WTeamIndx,42) + RawData.TeamStats(LTeamIndx,40);
     RawData.TeamStats(LTeamIndx,42) =  RawData.TeamStats(LTeamIndx,42) + RawData.TeamStats(WTeamIndx,40);

    % Col 43: 3rd Degree Losses
    RawData.TeamStats(WTeamIndx,43) =  RawData.TeamStats(WTeamIndx,43) + RawData.TeamStats(LTeamIndx,41);
    RawData.TeamStats(LTeamIndx,43) =  RawData.TeamStats(LTeamIndx,43) + RawData.TeamStats(WTeamIndx,41);
end 

% 2nd an 3rd degree win percentages 
for tt = 1:length(RawData.TeamStats)
   
    % Col 44: 2nd degree Win Percentage 
    RawData.TeamStats(tt,44) = RawData.TeamStats(tt,40) / RawData.TeamStats(tt,41);

    % Col 45: 3rd Degree Win Percentage 
    RawData.TeamStats(tt,45) = RawData.TeamStats(tt,42) / (RawData.TeamStats(tt,43) + RawData.TeamStats(tt,42));
end 
% FUTURE WORK: Weight each individual gane's stats by the quality of
% opponent they played - would require moving this earlier in code? Or just
% add additional cols for weighted stats 

%% Defense Stats (opponent stats against) 
for gm = 1:height(RawData.regularSeason)

    % Find teams that played in this game 
    WTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.WTeamIDYr(gm));
    LTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.LTeamIDYr(gm));

    % Col 46 - 58 : Summary Stats 
    for col = 46:58
    RawData.TeamStats(LTeamIndx,col) = RawData.TeamStats(WTeamIndx,col) + RawData.regularSeason.(DetailedHeaders{col-37})(gm);
    RawData.TeamStats(WTeamIndx,col) = RawData.TeamStats(LTeamIndx,col) + RawData.regularSeason.(DetailedHeaders{col-24})(gm);
    end 
    
end 

% Turn stats into per game stats 

for tm = 1:length(RawData.TeamStats)
    gms = RawData.TeamStats(tm,1) + RawData.TeamStats(tm,2);

    for ss = 46:58
       RawData.TeamStats(tm,ss) = RawData.TeamStats(tm,ss) / gms;
    end 
end 

%% Method 2: Strucutre of all games per Team 

% Create structure called Data where each Team has a row 
Data = struct('TeamID', cell(1,numel(RawData.TeamIDs)));

for ii = 1:numel(RawData.TeamIDs)
    Data(ii).TeamID = RawData.TeamIDs(ii);
    Data(ii).Raw = [];
    Data(ii).NCAATourn = [];
    Data(ii).Weighted = [];
    Data(ii).sumStats = [];
end 

% The second Field will be a matrix contianing all stats from all games in 
% which this team played, where the first n columns are their stats and the
% second n columns are the stats against. The 2nd  to last column will be 
% the opponent TeamID   the last column will be a boolean% of it htye won or not 

% Regualr Season Games 
for gm = 1:height(RawData.regularSeason)

    % Find teams that played in this game 
    WTeamIndx = find(RawData.TeamIDs  == RawData.regularSeason.WTeamIDYr(gm));
    LTeamIndx = find(RawData.TeamIDs  == RawData.regularSeason.LTeamIDYr(gm)); 

    % store reg seaso ngames in Data.Raw matrix 
    WTeamData = [];
    WTeamDataOpp = [];
    LTeamData = [];
    LTeamDataOpp = [];

    for pp = 1:13
    WTeamData = [WTeamData, RawData.regularSeason.(DetailedHeaders{pp+8})(gm)];
    WTeamDataOpp = [WTeamDataOpp , RawData.regularSeason.(DetailedHeaders{pp+21})(gm)];
    LTeamData = [LTeamData, RawData.regularSeason.(DetailedHeaders{pp+21})(gm)];
    LTeamDataOpp = [LTeamDataOpp , RawData.regularSeason.(DetailedHeaders{pp+8})(gm)];
    end 

    WTeamData = [WTeamData, WTeamDataOpp, RawData.regularSeason.LTeamIDYr(gm),  1 ];
    LTeamData = [LTeamData, LTeamDataOpp, RawData.regularSeason.WTeamIDYr(gm), 0 ];
    Data(WTeamIndx).Raw = [Data(WTeamIndx).Raw; WTeamData];
    Data(LTeamIndx).Raw = [Data(LTeamIndx).Raw; LTeamData];

end 
% Regualr Season Games Weighted 

for gm = 1:height(RawData.regularSeason)

    % Find teams that played in this game 
    WTeamIndx = find(RawData.TeamIDs  == RawData.regularSeason.WTeamIDYr(gm));
    LTeamIndx = find(RawData.TeamIDs  == RawData.regularSeason.LTeamIDYr(gm)); 

    % store reg seaso ngames in Data.Raw matrix 
    WTeamData = [];
    WTeamDataOpp = [];
    LTeamData = [];
    LTeamDataOpp = [];

    for pp = 1:13
    WTeamData = [WTeamData, (RawData.regularSeason.(DetailedHeaders{pp+8})(gm) * RawData.TeamStats(LTeamIndx,45))];
    WTeamDataOpp = [WTeamDataOpp , (RawData.regularSeason.(DetailedHeaders{pp+21})(gm) * (1 - RawData.TeamStats(LTeamIndx,45)))];
    LTeamData = [LTeamData, (RawData.regularSeason.(DetailedHeaders{pp+21})(gm) * RawData.TeamStats(WTeamIndx,45))];
    LTeamDataOpp = [LTeamDataOpp , (RawData.regularSeason.(DetailedHeaders{pp+8})(gm) * (1 - RawData.TeamStats(LTeamIndx,45)))];
    end 

    WTeamData = [WTeamData, WTeamDataOpp, RawData.regularSeason.LTeamIDYr(gm),  1 ];
    LTeamData = [LTeamData, LTeamDataOpp, RawData.regularSeason.WTeamIDYr(gm), 0 ];
    Data(WTeamIndx).Weighted = [Data(WTeamIndx).Weighted; WTeamData];
    Data(LTeamIndx).Weighted = [Data(LTeamIndx).Weighted; LTeamData];

end 
%%
% Create per game and SD 
for tt = 1:length(Data)

    for vv =  1:(length(Data(1).Raw)-2)
        Data(tt).SumStats(1,vv) = mean(str2double(Data(tt).Weighted(:,vv)));
        Data(tt).SumStats(2,vv) = std(str2double(Data(tt).Weighted(:,vv)));
    end 
end 

%% Back to root 
cd ..

%% save as .mat 
save("RawData.mat","RawData","Data");

%% Timer 
fprintf("Data Management complete, %f seconds \n\n",toc(DataManTimer));


