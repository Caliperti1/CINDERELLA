%% March Madness 
clc 
clear 
close all 

%% Import Data 

% 2024 Tournament Seeds 

% Team Names 
teamIDs = readtable('MTeams.csv');

% Detailed regular season results 
regularSeason = readtable('MRegularSeasonDetailedResults.csv');

% Detialed Tournament results 
tournamentResults = readtable('MNCAATourneyDetailedResults.csv');

% Conference Tournament results 
confTournamentResults = readtable('MConferenceTourneyGames.csv');

% 2024 Tournament Seeds 
tournamentSeeds2024 = readtable('2024_tourney_seeds.csv');

%% Create Y 

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
yearMax = max(tournamentResults.Season);

years = yearMin:yearMax;
numteams = height(teamIDs);

Y_BC = ones(numteams,length(years));

% Builds team x year matrix with count of tournament wins 
for yy = 1:length(years)
    tourneyDataidx = tournamentResults.Season == years(yy);
    tourneyData = tournamentResults(tourneyDataidx,:);

    for tt = 1:numteams
    teamID = teamIDs.TeamID(tt);
    
        for ll = 1:height(tourneyData)
          if tourneyData.WTeamID(ll) == teamID || tourneyData.LTeamID(ll) == teamID
              Y_BC(tt,yy) = Y_BC(tt,yy) + 1;
          end 
        end 
    end
end 

% Creates Y vector with team ID team year and tounrnament score 
count = 1;
YTrain = NaN(numel(Y_BC), 3);

for tms = 1:length(Y_BC)
    for yrs = 1:width(Y_BC)
    
    
    if Y_BC(tms,yrs) > 0
        YTrain(count,1) = years(yrs);
        YTrain(count,2) = teamIDs.TeamID(tms);
        YTrain(count,3) = bcScores(Y_BC(tms,yrs));
        count = count + 1;
    end 
    end 
end 

YTrain = YTrain(~any(isnan(YTrain), 2),:);

%% Conference Tournament Results 

X_BC_conf = zeros(numteams,length(years));

% Builds team x year matrix with count of tournament wins 
for yy = 1:length(years)
    confDataidx = confTournamentResults.Season == years(yy);
    confData = confTournamentResults(confDataidx,:);

    for tt = 1:numteams
    teamID = teamIDs.TeamID(tt);
    
        for ll = 1:height(tourneyData)
          if confData.WTeamID(ll) == teamID || confData.LTeamID(ll) == teamID
            X_BC_conf(tt,yy) = X_BC_conf(tt,yy) + 1;
          end 
        end 
    end
end 



%% Create season summary statistics 

XTotal = zeros(numteams*numel(years),35);
    % col 1: Year 
    % col 2: Team
    % col 3: Wins 

index = 1;
for tm = 1:numteams
    team = teamIDs.TeamID(tm);

    for yr = 1:length(years)
        year = years(yr);

        XTotal(index,1) = year;
        XTotal(index,2) = team;

        for ii = 1:height(regularSeason)

            % Collect all stats for winning games 
            if and(regularSeason.Season(ii) == year,regularSeason.WTeamID(ii) == team)

                % Count wins 
                XTotal(index,3) = XTotal(index,3) + 1;
                
                % col 9 - 21 correspond to winner stats in regularSeason 
                for col = 9:21
                    XTotal(index,col-4) = XTotal(index,col-4) + regularSeason{ii,col};
                end 
            end 

            % Collect all stats for losing games 
            if and(regularSeason.Season(ii) == year,regularSeason.LTeamID(ii) == team)

                % Count losses
                XTotal(index,4) = XTotal(index,4) + 1;

                 % col 22 - 34 correspond to loser stats in regularSeason 
                for col = 22:34
                XTotal(index,col-4) = XTotal(index,col-4) + regularSeason{ii,col};
                end
            end 
        end 

        % move to next row (new team / year combo)
         index = index + 1;

    end 
end 

%% Add conference Tournament Data to X 

for tms = 1:length(X_BC_conf)
    team = teamIDs.TeamID(tm);

    for yrs = 1:width(X_BC_conf)
        year = years(yr);
        index_X = find(and(XTotal(:,1) == year, XTotal(:,2) == team));

        XTotal(index_X,31)= bcScores(X_BC_conf(tms,yrs));
    end 
end 

%% Collect Weighting Factor from conference Tounrey (col 32) and Natty (col 33) and teams they lost to's score factor (col 34) and (col 35)

% Re run once complete becuase I added cols 34 adn 35 at 853pm 19MAR
for tm = 1:numteams
    team = teamIDs.TeamID(tm);

    for yr = 1:length(years)
        year = years(yr);

        index_X = find(and(XTotal(:,1) == year, XTotal(:,2) == team));

        for ii = 1:height(regularSeason)

            % Collect all stats for winning games 
            if and(regularSeason.Season(ii) == year,regularSeason.WTeamID(ii) == team)

                % find index of team that this team beat in XTotal to get
                % conf tournament weight 
                index_opp = find(and(XTotal(:,1) == year, XTotal(:,2) == regularSeason.LTeamID(ii)));
                XTotal(index_X,32) = Xtotal(index_X,32) + XTotal(index_opp,31);
                
                % find index of team that this team beat in YTrain to get
                % natty tournament weight 
                index_opp_Nat = find(and(YTrain(:,1) == year, Ytrain(:,2) == regularSeason.LTeamID(ii)));
                XTotal(index_X,33) = Xtotal(index_X,33) + Ytrain(index_opp_Nat,3);

            end 
            % Collect all stats for winning games 
            if and(regularSeason.Season(ii) == year,regularSeason.LTeamID(ii) == team)

                % find index of team that beat this team to get
                % conf tournament weight 
                index_opp = find(and(XTotal(:,1) == year, XTotal(:,2) == regularSeason.WTeamID(ii)));
                XTotal(index_X,34) = Xtotal(index_X,34) + XTotal(index_opp,31);

                % find index of team that beat this team in YTrain to get
                % natty tournament weight 
                index_opp_Nat = find(and(YTrain(:,1) == year, Ytrain(:,2) == regularSeason.WTeamID(ii)));
                XTotal(index_X,35) = Xtotal(index_X,35) + Ytrain(index_opp_Nat,3);
            end
        end 
    end 
end 

%%  Organize to correspond to YTrain 
XTrain = zeros(length(YTrain),35);

for tm = 1:numteams
    team = teamIDs.TeamID(tm);

    for yr = 1:length(years)
        year = years(yr);

        % find index in Y that corresponds to the current year and team
        % combo
        index_Y = find(and(YTrain(:,1) == year, YTrain(:,2) == team));
        index_X = find(and(XTotal(:,1) == year, XTotal(:,2) == team));
    
        % Create enry in X that correponds to index in Y 
        if and( ~isempty(index_X), ~isempty(index_Y))
            XTrain(index_Y,1) = year;
            XTrain(index_Y,2) = team;
            %wins 
            XTrain(index_Y,3) = XTotal(index_X,3);
            %losses
            XTrain(index_Y,4) = XTotal(index_X,4);

            % creates X Train array that corresponds to the proper Y index and is
            % averaged to provide 'per game' totals for wins and losses 
            for pp = 1:13
                XTrain(index_Y,pp+4) = XTotal(index_X,pp+4) / XTotal(index_X,3);
                XTrain(index_Y,pp+17) = XTotal(index_X,pp+17) / XTotal(index_X,4); 
            end 

            % Pull in wieghting factors 
            XTrain(index_Y,31) = XTotal(index_X,31);
            XTrain(index_Y,32) = XTotal(index_X,32);
            XTrain(index_Y,33) = XTotal(index_X,33);
            XTrain(index_Y,34) = XTotal(index_X,34);
            XTrain(index_Y,35) = XTotal(index_X,35);
        end 
    end 
end 


