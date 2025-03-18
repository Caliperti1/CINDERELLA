%% DistrobutionVisualiztion

function [DistFigure] = DistrobutionVisualiztion(monteResults,netWinners,answerKey)

% Score all resultant brackets 
Scores = NaN(length(monteResults),7);

for gg = 1:length(monteResults)
    Scores(gg,1:6) = ScoreBracket([monteResults(gg).gameMat.WinnerName]',answerKey);
    Scores(gg,7) = sum(Scores(gg,1:6));

end 


netScores(1:6) = ScoreBracket(netWinners,answerKey);
netScores(7) = sum(netScores(1:6));


lowers = min(Scores);
uppers = max(Scores);

% X-axis positions for columns
xPos = 1:width(Scores);

% Plot error bars
DistFigure = figure();
hold on;
errorbar(xPos, netScores, min(Scores)-netScores, max(Scores)-netScores, 'o', 'MarkerSize', 8, ...
    'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'CapSize', 10);
yline(320,"-r");

% Label axes
xlabel('Round');
ylabel('Bracket Points Earned');
titleText = "CINDERELLA Distrobutions: " + " "  + num2str(length(monteResults)) + " " + " Iterations";
title(titleText);
xticklabels({'Round of 64', ...
    'Round of 32', ...
    'Sweet 16', ...
    'Elite 8', ...
    'Final Four', ...
    'Championship', ...
    'Total'})
grid on;













