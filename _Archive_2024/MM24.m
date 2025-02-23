%% March Madness 
clc 
clear 
close all 

%% Import Data 

% 2024 Tournament Seeds 

% Team Names 
teamIDs = readtable('MTeams.csv');

% Detailed regular season results 
regularSeasonComp = readtable('MRegularSeasonDetailedResults.csv');

% Detialed Tournament results 
tournamentResults = readtable('MNCAATourneyDetailedResults.csv');

% Conference Tournament results 
confTournamentResults = readtable('MConferenceTourneyGames.csv');

% 2024 Tournament Seeds 
tournamentSeeds2024 = readtable('2024_tourney_seeds.csv');

%% Bracket Challenge Scoring System 
% 1. Bracket Challenge Points Earned 
    % 0 - first round loss 
    % 10 - first round win (64 -> 32)
    % 20 - second round win (32 -> 16)
    % 40 - third round win ( 16 -> 8)
    % 80 - fourth roudn win (8 -> 4)
    % 160 - fifth round win (4 -> 2)
    % 320 - sixth round win (2 -> 1)

bcScoreChart = [0, 10, 20, 40, 80, 160, 320];
bcScores = cumsum(bcScoreChart);

% Build Bracket Challenge Scores array 
yearMin = min(tournamentResults.Season);
yearMax = 2023;

years = yearMin:yearMax;
teams = teamIDs.TeamID;
numteams = height(teamIDs);

%% Create Y
% Y_BC is a count of tournament wins by team per year 
Y_BC = zeros(numteams,length(years));
Y_BC_Loser = zeros(numteams,length(years));

for tt = 1:height(tournamentResults)

    % Find index of teams that played in this game for Y_BC matrix
    WTeamIndex = find(teams == tournamentResults.WTeamID(tt));
    LTeamIndex = find(teams == tournamentResults.LTeamID(tt));
    yearIndex = find(years == tournamentResults.Season(tt));
    
    % Count everytime a team appeared in a tounrmant game 
    Y_BC(WTeamIndex,yearIndex) = Y_BC(WTeamIndex,yearIndex) + 1;
    Y_BC_Loser(LTeamIndex,yearIndex) = Y_BC_Loser(LTeamIndex,yearIndex) + 1;
end


% Create weighted matrix basedon bracket points earned 
Y_BC_TournWeight = zeros(size(Y_BC));

for tm = 1:length(Y_BC)
    for yr = 1:width(Y_BC)
        % Check for winner and award extra point 
        if Y_BC(tm,yr) == 6
            Y_BC(tm,yr) = Y_BC(tm,yr) + 1;
        end 
        % Add in point for loser
        Y_BC(tm,yr) = Y_BC(tm,yr) + Y_BC_Loser(tm,yr);
        % Determine BRacket points earned
        if Y_BC(tm,yr) > 0
         Y_BC_TournWeight(tm, yr) = bcScores(Y_BC(tm,yr));
        end
    end 
end 


%% Create conference tournament weights
Y_BC_conf = zeros(size(Y_BC));
Y_BC_conf_Loser = zeros(size(Y_BC));

for tt = 1:height(confTournamentResults)

    % Find index of teams that played in this game for Y_BC matrix
    WTeamIndex = find(teams == confTournamentResults.WTeamID(tt));
    LTeamIndex = find(teams == confTournamentResults.LTeamID(tt));
    yearIndex = find(years == confTournamentResults.Season(tt));
    
    % Count everytime a team appeared in a tounrmant game 
    Y_BC_conf(WTeamIndex,yearIndex) = Y_BC_conf(WTeamIndex,yearIndex) + 1;
    Y_BC_conf_Loser(LTeamIndex,yearIndex) = Y_BC_conf_Loser(LTeamIndex,yearIndex) + 1;

end


% Create weighted matrix basedon bracket points earned 
Y_BC_confWeight = zeros(size(Y_BC));

for tm = 1:length(Y_BC)
    for yr = 1:width(Y_BC)
        % Check for winner and award extra point        
        if Y_BC_conf(tm,yr) == max(Y_BC_conf(:,yearIndex))
            Y_BC_conf(tm,yr) = Y_BC_conf(tm,yr) + 1;
        end 
        % Add in point for loser
        Y_BC_conf(tm,yr) = Y_BC_conf(tm,yr) + Y_BC_conf_Loser(tm,yr);
        % Determine Bracket points earned
        if Y_BC_conf(tm,yr) > 0
         Y_BC_confWeight(tm, yr) = bcScores(Y_BC_conf(tm,yr));
        end
    end 
end 


Y_BC_confWeight_norm = (Y_BC_confWeight / max(max(Y_BC_confWeight))) + 1;
% this is a little janky because each conf tournament is a different length

%% Create X 

% X is a cell array that corresponds to the location of teams and years in
% Y but each cell contains a 1x32 vector of stats about the team (explained
% in line as they are populated
X = cell(length(teams),length(years));
for i = 1:numel(X)
    X{i} = zeros(1,56);
end 

% For training data we need to trim off 2024 from the regular season 
regularSeason = regularSeasonComp(regularSeasonComp.Season ~= 2024,:);

for gm = 1:height(regularSeason)

    % Find index of teams that played in this game for Y_BC matrix
    WTeamIndex = find(teams == regularSeason.WTeamID(gm));
    LTeamIndex = find(teams == regularSeason.LTeamID(gm));
    yearIndex = find(years == regularSeason.Season(gm));

    % Col 1: wins 
    X{WTeamIndex,yearIndex}(1) = X{WTeamIndex,yearIndex}(1) + 1 ;

    % col 2: losses 
    X{LTeamIndex,yearIndex}(2) =  X{LTeamIndex,yearIndex}(2) + 1 ;

    % col 3: Points for 
    X{WTeamIndex,yearIndex}(3) = X{WTeamIndex,yearIndex}(3) + regularSeason{gm,"WScore"};
    X{LTeamIndex,yearIndex}(3) = X{LTeamIndex,yearIndex}(3) + regularSeason{gm,"LScore"};

    % col 4: Points against 
    X{WTeamIndex,yearIndex}(4) = X{WTeamIndex,yearIndex}(4) + regularSeason{gm,"LScore"};
    X{LTeamIndex,yearIndex}(4) = X{LTeamIndex,yearIndex}(4) + regularSeason{gm,"WScore"};


    % col 5 - 17 straight summary stats in wins 
    for col = 5:17
        X{WTeamIndex,yearIndex}(col) = X{WTeamIndex,yearIndex}(col) + regularSeason{gm,col+4};
    end 

    % col 18 - 30 straight summary stats in losses 
    for col = 18:30
        X{LTeamIndex,yearIndex}(col) = X{LTeamIndex,yearIndex}(col) + regularSeason{gm,col+4};
    end 

    % col 31-43 summary stats for winner (conf tourney weighted) 
    for col = 31:43
        X{WTeamIndex,yearIndex}(col) = X{WTeamIndex,yearIndex}(col) + ...
            (regularSeason{gm,col-22} *Y_BC_confWeight_norm(LTeamIndex,yearIndex));            
    end 

        % col 43-56 summary stats for loser (conf tourney weighted) 
    for col = 44:56
        X{LTeamIndex,yearIndex}(col) = X{LTeamIndex,yearIndex}(col) + ...
            (regularSeason{gm,col-22} *Y_BC_confWeight_norm(WTeamIndex,yearIndex));            
    end 
end 

% Turn all stats into per game stats 

for tm = 1:length(Y_BC)
    for yr = 1:width(Y_BC)

        % Games played 
        gp = X{tm,yr}(1) + X{tm,yr}(2);
        wins =  X{tm,yr}(1);
        losses =  X{tm,yr}(2);

        % PPG and PAPG
        X{tm,yr}(3) = X{tm,yr}(3) / gp;
        X{tm,yr}(4) = X{tm,yr}(4) / gp;

        % Winning stats divided by wins 
        for col = 5:17
            X{tm,yr}(col) = X{tm,yr}(col) / wins;
        end 

        % Losing  stats divided by losses  
        for col = 18:30
            X{tm,yr}(col) = X{tm,yr}(col) / losses;
        end 


        % Weighted winning stats divided by wins 
        for col = 31:43
            X{tm,yr}(col) = X{tm,yr}(col) / wins;
        end 

        % Weighted losing  stats divided by losses  
        for col = 44:56
            X{tm,yr}(col) = X{tm,yr}(col) / losses;
        end 


    end 
end 

%% Save workspace to be used in model script 

save('MM24_PreProc_Out');