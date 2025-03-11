%% CINDERELLA 
% Main script - runs the MonteCarlo simulation n times and determines the
% most common outcomes 

% Number of iterations of monte Carlo Sim 
n = 25;

% Run MonteCarlo

monteResults = monteCarlo(n);


% Accumulate results 
numGames = length(monteResults(1).gameMat);
netWinners = strings(numGames,1);


for game = 1:numGames
    % store winners of this game across all sims 
    gameWinners = strings(n,1);

    for sim = 1:n
        gameWinners(sim) = monteResults(sim).gameMat(game).WinnerName;
    end 

    [uniqueTeams, ~,ic] = unique(gameWinners);
    counts = accumarray(ic,1);

    [~, maxidx] = max(counts);
    netWinners(game) = uniqueTeams(maxidx);

end 

%% Visaulize Results 

load("AnswerKey_2024.mat")

BracketVisualization(netWinners,monteResults(1).gameMat,AnswerKey_2024)