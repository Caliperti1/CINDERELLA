%% MonteCarlo

% This will simulate the tournament n times and store the game structs in a
% larger sttruct so we can see the most common outcomes 

function monteResults = monteCarlo(n)

    for iter = 1:n
        TournamentSim
        monteResults(iter).gameMat = Games;
        monteResults(iter).winner = Games(63).WinnerName;
        fprintf("Iteration %f Complete... Winner: %s \n  ",iter,monteResults(iter).winner)
        fprintf("Final Four: %s   %s   %s   %s  \n \n  ",...
            monteResults(iter).gameMat(61).Team1Name,...
            monteResults(iter).gameMat(61).Team2Name,...
            monteResults(iter).gameMat(62).Team1Name,...
            monteResults(iter).gameMat(62).Team2Name)
    end 

    