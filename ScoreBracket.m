%% Evaluate W/ Bracket Points 

function bracketPoints = ScoreBracket(netWinners, AnswerKey)

bracketPoints = zeros(1,6);
% Round 1 

for gg = 1:32
    if strcmp(netWinners(gg),AnswerKey(gg))
        bracketPoints(1) = bracketPoints(1) + 10;
    end 
end 

% Round of 32
for gg = 33:48
        if strcmp(netWinners(gg),AnswerKey(gg))
            bracketPoints(2) = bracketPoints(2) + 20;
        end 
end

% Sweet 16
for gg = 49:56
        if strcmp(netWinners(gg),AnswerKey(gg))
            bracketPoints(3) = bracketPoints(3) + 40;
        end 
end 

% Elite Eight 
for gg = 56:60
        if strcmp(netWinners(gg),AnswerKey(gg))
            bracketPoints(4) = bracketPoints(4) + 80;
        end 
end 

% Final Four
for gg = 61:62
        if strcmp(netWinners(gg),AnswerKey(gg))
            bracketPoints(5) = bracketPoints(5) + 160;
        end 
end 

% Championship 
    if strcmp(netWinners(63),AnswerKey(63))
        bracketPoints(6) = bracketPoints(6) + 320;
    end 