%% MonteCarlo

% This will simulate the tournament n times and store the game structs in a
% larger sttruct so we can see the most common outcomes 

function monteResults = monteCarlo(n)

    for iter = 1:n
        TournamentSim
        monteResults(iter).gameMat = Games;
        monteResults(iter).winner = Games(63).WinnerName;
    end 

    