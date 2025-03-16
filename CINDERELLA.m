%% CINDERELLA 
clear; clc; close all

configs
% Main script - runs the MonteCarlo simulation n times and determines the
% most common outcomes 

% Number of iterations of monte Carlo Sim 
n = 1000;

% Run MonteCarlo

monteResults = monteCarlo(n);

% Accumulate results 
numGames = length(monteResults(1).gameMat);
netWinners = strings(numGames,1);
netWinners_confidence = NaN(numGames,1);

for game = 1:numGames
    % store winners of this game across all sims 
    gameWinners = strings(n,1);

    for sim = 1:n
        gameWinners(sim) = monteResults(sim).gameMat(game).WinnerName;
    end 

    [uniqueTeams, ~,ic] = unique(gameWinners);
    counts = accumarray(ic,1);

    [count, maxidx] = max(counts);
    netWinners(game) = uniqueTeams(maxidx);
    netWinners_confidence(game) = count / n;

end 

%% Visaulize Results 
root = pwd;
load(fullfile(root,"\Data\AnswerKey_2024.mat"));

BracketFigure = BracketVisualization(netWinners,netWinners_confidence, monteResults(1).gameMat,AnswerKey_2024);

%% Save Results 
fileName = "Results_" + num2str(n) + "iter_" + tournamentYear +".mat";
save(fileName,BracketFigure)


