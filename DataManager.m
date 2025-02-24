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

%% Raw Data 

RawData = [];

%% Back to root 
cd ..