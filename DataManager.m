%% DataManager
% This will read all of the necessary data out of the data folder (Updated
% yearly from Kaggle's March Machine Learning Madness challenge)

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


%% Helpers 
DetailedHeaders = RawData.regularSeason.Properties.VariableNames;

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


%% Create Summary Stats Table 
% load("RawData.mat");

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
    RawData.TeamStats(LTeamIndx,1) =  RawData.TeamStats(LTeamIndx,2) + 1;

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

%% Strength of Schedule Measures

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

% Second Degree NCAA Tournament wins 
for gg = 1:height(RawData.regularSeason)
    
    % Find teams that played in this game 
    WTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.WTeamIDYr(gg));
    LTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.LTeamIDYr(gg));

    % Col 40: 2nd Degree wins  
    RawData.TeamStats(WTeamIndx,40) =  RawData.TeamStats(WTeamIndx,40) + RawData.TeamStats(LTeamIndx,37);

    % Col 41: 2nd Degree Bracket Points 
     RawData.TeamStats(WTeamIndx,41) =  RawData.TeamStats(WTeamIndx,41) + RawData.TeamStats(LTeamIndx,39);
end 

% Third Degree NCAA Tournament wins 
% Find teams that played in this game 
for gg = 1:height(RawData.regularSeason)
    WTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.WTeamIDYr(gg));
    LTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.LTeamIDYr(gg));

    % Col 42: 3rd Degree wins  
    RawData.TeamStats(WTeamIndx,42) =  RawData.TeamStats(WTeamIndx,42) + RawData.TeamStats(LTeamIndx,40);

    % Col 43: 3rd Degree Bracket Points 
    RawData.TeamStats(WTeamIndx,43) =  RawData.TeamStats(WTeamIndx,43) + RawData.TeamStats(LTeamIndx,41);

end 
% FUTURE WORK: Weight each individual gane's stats by the quality of
% opponent they played - would require moving this earlier in code? Or just
% add additional cols for weighted stats 

%% Defense Stats (opponent stats against) 
for gm = 1:height(RawData.regularSeason)

    % Find teams that played in this game 
    WTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.WTeamIDYr(gm));
    LTeamIndx = find(RawData.TeamIDs == RawData.regularSeason.LTeamIDYr(gm));

    % Col 44 - 56 : Summary Stats 
    for col = 44:56
    RawData.TeamStats(LTeamIndx,col) = RawData.TeamStats(WTeamIndx,col) + RawData.regularSeason.(DetailedHeaders{col-35})(gm);
    RawData.TeamStats(WTeamIndx,col) = RawData.TeamStats(LTeamIndx,col) + RawData.regularSeason.(DetailedHeaders{col-22})(gm);
    end 
    
end 

% Turn stats into per game stats 

for tm = 1:length(RawData.TeamStats)
    gms = RawData.TeamStats(tm,1) + RawData.TeamStats(tm,2);

    for ss = 44:56
       RawData.TeamStats(tm,ss) = RawData.TeamStats(tm,ss) / gms;
    end 
end 


%% Back to root 
cd ..

%% save as .mat 
save("RawData.mat","RawData");

%% Timer 
fprintf("Data Management complete, %f seconds \n\n",toc(DataManTimer))


