%% DataManager
% This will read all of the necessary data out of the data folder (Updated
% yearly from Kaggle's March Machine Learning Madness challenge)

% Set Data directory 

cd Data\

%% Tournament Seeds Key 
TournamentSeeds = readtable("2024_tourney_seeds.csv");
TournamentSeeds.Seed = string(TournamentSeeds.Seed);
TournamentSeeds.Tournament = string(TournamentSeeds.Tournament);
TournamentSeeds = TournamentSeeds(TournamentSeeds.Tournament == "M",:);
 % Tournament (M or W) // Seed // Team ID (Key for other tables)

%% Team Names 
teamIDs = readtable('MTeams.csv');

% Detailed Regular Season results 
RawData.regularSeason = readtable('MRegularSeasonDetailedResults.csv');

% Detialed Tournament results 
RawData.tournamentResults = readtable('MNCAATourneyDetailedResults.csv');

% Conference Tournament results 
RawData.confTournamentResults = readtable('MConferenceTourneyGames.csv');


%% Back to root 
cd ..