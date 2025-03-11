%% Evaluate W/ Bracket Points 

function bracketPoints = ScoreBracket(netWinners, AnswerKey)

bracketPoints = 0;
% Round 1 

for gg = 1:32
    if strcmp(netWinners(gg),AnswerKey(gg))
        bracketPoints = bracketPoints + 10;
    end 
end 

% Round of 32
for gg = 33:48
        if strcmp(netWinners(gg),AnswerKey(gg))
            bracketPoints = bracketPoints + 20;
        end 
end

% Sweet 16
for gg = 49:56
        if strcmp(netWinners(gg),AnswerKey(gg))
            bracketPoints = bracketPoints + 40;
        end 
end 

% Elite Eight 
for gg = 56:60
        if strcmp(netWinners(gg),AnswerKey(gg))
            bracketPoints = bracketPoints + 80;
        end 
end 

% Final Four
for gg = 61:62
        if strcmp(netWinners(gg),AnswerKey(gg))
            bracketPoints = bracketPoints + 160;
        end 
end 

% Championship 
    if strcmp(netWinners(63),AnswerKey(63))
        bracketPoints = bracketPoints + 320;
    end 