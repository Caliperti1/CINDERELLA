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

Y_BC_TournWeight_Norm = (Y_BC_TournWeight / max(max(Y_BC_TournWeight))) + 1;

%% Create conference tournament weights
Y_BC_conf = zeros(length(Y_BC),width(Y_BC)+1);
Y_BC_conf_Loser = zeros(length(Y_BC),width(Y_BC)+1);

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
Y_BC_confWeight = zeros(length(Y_BC),width(Y_BC)+1);

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
    X{i} = zeros(1,83);
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

    % col 57-69 summary stats for winner ( tourney weighted) 
    for col = 57:69
        X{WTeamIndex,yearIndex}(col) = X{WTeamIndex,yearIndex}(col) + ...
            (regularSeason{gm,col-48} *Y_BC_TournWeight_Norm(LTeamIndex,yearIndex));            
    end 

    % col 70-82 summary stats for loser ( tourney weighted) 
    for col = 70:82
        X{LTeamIndex,yearIndex}(col) = X{LTeamIndex,yearIndex}(col) + ...
            (regularSeason{gm,col-48} *Y_BC_TournWeight_Norm(WTeamIndex,yearIndex));            
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

        % Col 83: Conference Tournament Points 
        X{tm,yr}(83) = Y_BC_confWeight(tm,yr);
    end 
end 



%% Organize for use in model
YVec = NaN(numel(Y_BC),1);
XVec = NaN(numel(Y_BC),length(X{1,1}));
trainIdx = 1;

for tm = 1:length(Y_BC)
    for yr = 1:width(Y_BC)
     if Y_BC(tm,yr) > 0
        YVec(trainIdx) = Y_BC_TournWeight(tm,yr);
        XVec(trainIdx,:) = X{tm,yr};
        trainIdx = trainIdx + 1;
     end 
    end 
end 

%% Create X Test (using 2024 data)
regularSeason2024 = regularSeasonComp(regularSeasonComp.Season == 2024,:);

XTest = zeros(length(teams),57);

for gm = 1:height(regularSeason2024)

    % Find index of teams that played in this game for Y_BC matrix
    WTeamIndex = find(teams == regularSeason2024.WTeamID(gm));
    LTeamIndex = find(teams == regularSeason2024.LTeamID(gm));
    yearIndex = find(years == regularSeason.Season(gm));


    % Col 1: wins 
    XTest(WTeamIndex,1) = XTest(WTeamIndex,1) + 1 ;

    % col 2: losses 
    XTest(WTeamIndex,2) =  XTest(WTeamIndex,2) + 1 ;

    % col 3: Points for 
    XTest(WTeamIndex,3) = XTest(WTeamIndex,3) + regularSeason2024{gm,"WScore"};
    XTest(LTeamIndex,3) = XTest(LTeamIndex,3) + regularSeason2024{gm,"LScore"};

    % col 4: Points against 
    XTest(WTeamIndex,4) = XTest(WTeamIndex,4) + regularSeason2024{gm,"LScore"};
    XTest(LTeamIndex,4) = XTest(LTeamIndex,4) + regularSeason2024{gm,"WScore"};


    % col 5 - 17 straight summary stats in wins 
    for col = 5:17
        XTest(WTeamIndex,col) = XTest(WTeamIndex,col) + regularSeason2024{gm,col+4};
    end 

    % col 18 - 30 straight summary stats in losses 
    for col = 18:30
        XTest(LTeamIndex,col) = XTest(LTeamIndex,col) + regularSeason2024{gm,col+4};
    end 

    % col 31-43 summary stats for winner (conf tourney weighted) 
    for col = 31:43
        XTest(WTeamIndex,col) = XTest(WTeamIndex,col) + ...
            (regularSeason{gm,col-22} *Y_BC_confWeight_norm(LTeamIndex,yearIndex));            
    end 

    % col 43-56 summary stats for loser (conf tourney weighted) 
    for col = 44:56
        XTest(LTeamIndex,col) = XTest(LTeamIndex,col) + ...
            (regularSeason{gm,col-22} *Y_BC_confWeight_norm(WTeamIndex,yearIndex));             
    end 

end 

% Turn all stats into per game stats 

for tm = 1:length(Y_BC)
        % Games played 
        wins =  XTest(tm,1) ;
        losses =  XTest(tm,2) ;
        gp = wins + losses;

        % PPG and PAPG
        XTest(tm,3)  = XTest(tm,3)  / gp;
        XTest(tm,4)  = XTest(tm,4)  / gp;

        % Winning stats divided by wins 
        for col = 5:17
            XTest(tm,col)  = XTest(tm,col) / wins;
        end 

        % Losing  stats divided by losses  
        for col = 18:30
            XTest(tm,col) = XTest(tm,col) / losses;
        end 


        % Weighted winning stats divided by wins 
        for col = 31:43
            XTest(tm,col) = XTest(tm,col) / wins;
        end 

        % Weighted losing  stats divided by losses  
        for col = 44:56
            XTest(tm,col) = XTest(tm,col) / losses;
        end 


       % col 57: Conference Tournament Points 
       XTest(tm,57) = Y_BC_confWeight(tm,width(Y_BC_confWeight));
end 

%% Tournament Teams for 2024 
% Team indicies 

YTestIdx = NaN(64,1);

for pp = 1:length(YTestIdx)
    YTestIdx(pp) = find(teams == tournamentSeeds2024.TeamID(pp));
end 

%% Trim out NaN
YVec = YVec(~any(isnan(YVec), 2),:);
XVec = XVec(~any(isnan(YVec), 2),:);
XTestOrder = NaN(64,57);

for i = 1:length(YTestIdx)
    XTestOrder(i,:) = XTest(YTestIdx(i),:);
end 

% If nan replac with 0 (undefeated teams)
XVec(isnan(XVec)) = 0;

%% Save workspace to be used in model script 
% save('MM24_PreProc_Out','XVec','YVec', 'XTestOrder','YTestIdx','X');
save('MM24_PreProc_Out.mat')

%% Harry's Approach 
% Each row of YgamesReg is the score difernetial between the two teams
YGamesReg = NaN(height(tournamentResults),1);
XGamesReg = NaN(length(YGamesReg),104);
% Each row XGamesReg has the 
% team A stats in wins  col 1 - 13
% team A stats in losses col 14 - 26
% team A conf weighted stats in wins col 27 - 39
% team A conf weighted stats in losses col 40 - 52

% team B stats in wins col 53 - 65
% team B stats in losses col 66 - 78
% team B conf weighted stats in wins  col 79 - 91
% team B conf weighted stats in losses col 92 - 104


for ll = 1:height(tournamentResults)

    WTeamIndex = find(teams == regularSeason2024.WTeamID(ll));
    LTeamIndex = find(teams == regularSeason2024.LTeamID(ll));
    yearIndex = find(years == regularSeason.Season(ll));

    % Populate Y (Team A - Team B Score) 
    YGamesReg(ll) = tournamentResults.WScore(ll) - tournamentResults.LScore(ll);

    % Randomize which tema is Team A and whihc Team B 
    randomizer = randi([0,1]);

    if randomizer == 0 
        TeamA = WTeamIndex;
        TeamB = LTeamIndex;
    else
        TeamA = LTeamIndex;
        TeamB = WTeamIndex;
        YGamesReg(ll) = YGamesReg(ll) * -1;
    end 
   
    % Populate X 

    %team A stats in wins  col 1 - 13
    XGamesReg(ll,1:13) = X{TeamA,yearIndex}(5:17);

    % team A stats in losses col 14 - 26
    XGamesReg(ll,14:26) = X{TeamA,yearIndex}(18:30);

    % team A conf weighted stats in wins col 27 - 39
    XGamesReg(ll,27:39) = X{TeamA,yearIndex}(31:43);

    % team A conf weighted stats in losses col 40 - 52
    XGamesReg(ll,40:52) = X{TeamA,yearIndex}(44:56);

    % team B stats in wins col 53 - 65
     XGamesReg(ll,53:65) = X{TeamB,yearIndex}(5:17);

    % team B stats in losses col 66 - 78
    XGamesReg(ll,66:78) = X{TeamB,yearIndex}(18:30);

    % team B conf weighted stats in wins  col 79 - 91
    XGamesReg(ll,79:91) = X{TeamB,yearIndex}(31:43);

    % team B conf weighted stats in losses col 92 - 104
    XGamesReg(ll,92:104) = X{TeamB,yearIndex}(44:56);
end

% Y classifier (binary W/L)
YGamesClas(YGamesReg > 0) = 1;
YGamesClas(YGamesReg <= 0) = 0;



save('MM24_PreProc_OutGames1','XGamesReg','YGamesReg', 'YGamesClas','XTest');