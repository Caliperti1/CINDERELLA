
load('Workspace21MAR.mat')

%% Improvements for next season
% 1. Momentum (weigh later games more)
% 2. Better strength of schedule metric 
%%
% round 1 
seeds = 1:16;
seeds = [seeds; 
    seeds+16;
    seeds+32;
    seeds+48];

games = cell(63,6);

for game = 1:8
    
        % Region 1 
        games{game,1} = tournamentSeeds2024.TeamID(seeds(1,game));
        games{game,2} = tournamentSeeds2024.TeamID(seeds(1,end - (game-1)));
        games{game,3} = teamIDs.TeamName(teamIDs.TeamID == games{game,1});
        games{game,4} = teamIDs.TeamName(teamIDs.TeamID == games{game,2});

        % Region 2
        games{game+8,1} = tournamentSeeds2024.TeamID(seeds(2,game));
        games{game+8,2} = tournamentSeeds2024.TeamID(seeds(2,end - (game-1)));
        games{game+8,3} = teamIDs.TeamName(teamIDs.TeamID == games{game+8,1});
        games{game+8,4} = teamIDs.TeamName(teamIDs.TeamID == games{game+8,2});

        % Region 3
        games{game+16,1} = tournamentSeeds2024.TeamID(seeds(3,game));
        games{game+16,2} = tournamentSeeds2024.TeamID(seeds(3,end - (game-1)));
        games{game+16,3} = teamIDs.TeamName(teamIDs.TeamID == games{game+16,1});
        games{game+16,4} = teamIDs.TeamName(teamIDs.TeamID == games{game+16,2});


        % Region 4
        games{game+24,1} = tournamentSeeds2024.TeamID(seeds(4,game));
        games{game+24,2} = tournamentSeeds2024.TeamID(seeds(4,end - (game-1)));
        games{game+24,3} = teamIDs.TeamName(teamIDs.TeamID == games{game+24,1});
        games{game+24,4} = teamIDs.TeamName(teamIDs.TeamID == games{game+24,2});
end 

% Predicitons for Round 1 

for gm = 1:32
    matchupX = NaN(1,104);
    TeamAID = games{gm,1};
    TeamBID = games{gm,2};
    year = 2024;

    TeamA = find(teams == TeamAID);
    TeamB = find(teams == TeamBID);
    yearIndex = find(years == year);


 %team A stats in wins  col 1 - 13
    matchupX(1,1:13) = XTest(TeamA,5:17);

    % team A stats in losses col 14 - 26
    matchupX(1,14:26) = XTest(TeamA,18:30);

    % team A conf weighted stats in wins col 27 - 39
    matchupX(1,27:39) = XTest(TeamA,31:43);

    % team A conf weighted stats in losses col 40 - 52
    matchupX(1,40:52) = XTest(TeamA,44:56);

    % team B stats in wins col 53 - 65
     matchupX(1,53:65) = XTest(TeamB,5:17);

    % team B stats in losses col 66 - 78
    matchupX(1,66:78) = XTest(TeamB,18:30);

    % team B conf weighted stats in wins  col 79 - 91
    matchupX(1,79:91) = XTest(TeamB,31:43);

    % team B conf weighted stats in losses col 92 - 104
    matchupX(1,92:104) = XTest(TeamB,44:56);

    % Run 3 models 
    pred1 = NaiveBayesGameClas1.predictFcn(matchupX);
    pred2 = SVMGameClas1.predictFcn(matchupX);
    pred3 = BoostedTreesGamesClas1.predictFcn(matchupX);
    pred4 = NarrowNeural.predictFcn(matchupX);
    pred5 = subSpace.predictFcn(matchupX);

    score = pred1 + pred2 + pred3 + pred4 + pred5;

    % pick winner 
    if score > 2
        games{gm,5} = games{gm,1};      
    else 
        games{gm,5} = games{gm,2};
    end 
    games{gm,6} = teamIDs.TeamName(teamIDs.TeamID == games{gm,5});

end 

%% Round 2


for gm = 1:4
    
        % Region 1 
        games{gm+32,1} = games{gm,5};
        games{gm+32,3} = games{gm,6};
        games{gm+32,2} = games{8 - (gm-1),5};
        games{gm+32,4} = games{8 - (gm-1),6};

        % Region 2
        games{gm+36,1} = games{gm+8,5};
        games{gm+36,3} = games{gm+8,6};
        games{gm+36,2} = games{16 - (gm-1),5};
        games{gm+36,4} = games{16 - (gm-1),6};

        % Region 3
        games{gm+40,1} = games{gm+16,5};
        games{gm+40,3} = games{gm+16,6};
        games{gm+40,2} = games{24 - (gm-1),5};
        games{gm+40,4} = games{24 - (gm-1),6};

        % Region 3
        games{gm+44,1} = games{gm+24,5};
        games{gm+44,3} = games{gm+24,6};
        games{gm+44,2} = games{32 - (gm-1),5};
        games{gm+44,4} = games{32 - (gm-1),6};

end 

% Predicitons for Round 2 

for gm = 33:48
    matchupX = NaN(1,104);
    TeamAID = games{gm,1};
    TeamBID = games{gm,2};
    year = 2024;

    TeamA = find(teams == TeamAID);
    TeamB = find(teams == TeamBID);
    yearIndex = find(years == year);


 %team A stats in wins  col 1 - 13
    matchupX(1,1:13) = XTest(TeamA,5:17);

    % team A stats in losses col 14 - 26
    matchupX(1,14:26) = XTest(TeamA,18:30);

    % team A conf weighted stats in wins col 27 - 39
    matchupX(1,27:39) = XTest(TeamA,31:43);

    % team A conf weighted stats in losses col 40 - 52
    matchupX(1,40:52) = XTest(TeamA,44:56);

    % team B stats in wins col 53 - 65
     matchupX(1,53:65) = XTest(TeamB,5:17);

    % team B stats in losses col 66 - 78
    matchupX(1,66:78) = XTest(TeamB,18:30);

    % team B conf weighted stats in wins  col 79 - 91
    matchupX(1,79:91) = XTest(TeamB,31:43);

    % team B conf weighted stats in losses col 92 - 104
    matchupX(1,92:104) = XTest(TeamB,44:56);

    % Run 3 models 
       pred1 = NaiveBayesGameClas1.predictFcn(matchupX);
    pred2 = SVMGameClas1.predictFcn(matchupX);
    pred3 = BoostedTreesGamesClas1.predictFcn(matchupX);
    pred4 = NarrowNeural.predictFcn(matchupX);
    pred5 = subSpace.predictFcn(matchupX);

    score = pred1 + pred2 + pred3 + pred4 + pred5;

    % pick winner 
    if score > 2
        games{gm,5} = games{gm,1};      
    else 
        games{gm,5} = games{gm,2};
    end 
    games{gm,6} = teamIDs.TeamName(teamIDs.TeamID == games{gm,5});

end 

%% Round 3 


for gm = 1:2
    
        % Region 1 
        games{gm+48,1} = games{gm+32,5};
        games{gm+48,3} = games{gm+32,6};
        games{gm+48,2} = games{36 - (gm-1),5};
        games{gm+48,4} = games{36 - (gm-1),6};

        % Region 2
        games{gm+50,1} = games{gm+36,5};
        games{gm+50,3} = games{gm+36,6};
        games{gm+50,2} = games{40 - (gm-1),5};
        games{gm+50,4} = games{40 - (gm-1),6};

        % Region 3
        games{gm+52,1} = games{gm+40,5};
        games{gm+52,3} = games{gm+40,6};
        games{gm+52,2} = games{44 - (gm-1),5};
        games{gm+52,4} = games{44 - (gm-1),6};

        % Region 3
        games{gm+54,1} = games{gm+44,5};
        games{gm+54,3} = games{gm+44,6};
        games{gm+54,2} = games{48 - (gm-1),5};
        games{gm+54,4} = games{48 - (gm-1),6};

end 

% Predicitons for Round 3

for gm = 49:56
    matchupX = NaN(1,104);
    TeamAID = games{gm,1};
    TeamBID = games{gm,2};
    year = 2024;

    TeamA = find(teams == TeamAID);
    TeamB = find(teams == TeamBID);
    yearIndex = find(years == year);


 %team A stats in wins  col 1 - 13
    matchupX(1,1:13) = XTest(TeamA,5:17);

    % team A stats in losses col 14 - 26
    matchupX(1,14:26) = XTest(TeamA,18:30);

    % team A conf weighted stats in wins col 27 - 39
    matchupX(1,27:39) = XTest(TeamA,31:43);

    % team A conf weighted stats in losses col 40 - 52
    matchupX(1,40:52) = XTest(TeamA,44:56);

    % team B stats in wins col 53 - 65
     matchupX(1,53:65) = XTest(TeamB,5:17);

    % team B stats in losses col 66 - 78
    matchupX(1,66:78) = XTest(TeamB,18:30);

    % team B conf weighted stats in wins  col 79 - 91
    matchupX(1,79:91) = XTest(TeamB,31:43);

    % team B conf weighted stats in losses col 92 - 104
    matchupX(1,92:104) = XTest(TeamB,44:56);

    % Run 3 models 
   pred1 = NaiveBayesGameClas1.predictFcn(matchupX);
    pred2 = SVMGameClas1.predictFcn(matchupX);
    pred3 = BoostedTreesGamesClas1.predictFcn(matchupX);
    pred4 = NarrowNeural.predictFcn(matchupX);
    pred5 = subSpace.predictFcn(matchupX);

    score = pred1 + pred2 + pred3 + pred4 + pred5;

    % pick winner 
    if score > 2
        games{gm,5} = games{gm,1};      
    else 
        games{gm,5} = games{gm,2};
    end 
    games{gm,6} = teamIDs.TeamName(teamIDs.TeamID == games{gm,5});

end 


%% Round 4 


gm = 1;
    
        % Region 1 
        games{gm+56,1} = games{gm+48,5};
        games{gm+56,3} = games{gm+48,6};
        games{gm+56,2} = games{50 - (gm-1),5};
        games{gm+56,4} = games{50 - (gm-1),6};

        % Region 2
        games{gm+57,1} = games{gm+50,5};
        games{gm+57,3} = games{gm+50,6};
        games{gm+57,2} = games{52 - (gm-1),5};
        games{gm+57,4} = games{52 - (gm-1),6};

        % Region 3
        games{gm+58,1} = games{gm+52,5};
        games{gm+58,3} = games{gm+52,6};
        games{gm+58,2} = games{54 - (gm-1),5};
        games{gm+58,4} = games{54 - (gm-1),6};

        % Region 3
        games{gm+59,1} = games{gm+54,5};
        games{gm+59,3} = games{gm+54,6};
        games{gm+59,2} = games{56 - (gm-1),5};
        games{gm+59,4} = games{56 - (gm-1),6};

% Predicitons for Round 3

for gm = 57:60
    matchupX = NaN(1,104);
    TeamAID = games{gm,1};
    TeamBID = games{gm,2};
    year = 2024;

    TeamA = find(teams == TeamAID);
    TeamB = find(teams == TeamBID);
    yearIndex = find(years == year);


 %team A stats in wins  col 1 - 13
    matchupX(1,1:13) = XTest(TeamA,5:17);

    % team A stats in losses col 14 - 26
    matchupX(1,14:26) = XTest(TeamA,18:30);

    % team A conf weighted stats in wins col 27 - 39
    matchupX(1,27:39) = XTest(TeamA,31:43);

    % team A conf weighted stats in losses col 40 - 52
    matchupX(1,40:52) = XTest(TeamA,44:56);

    % team B stats in wins col 53 - 65
     matchupX(1,53:65) = XTest(TeamB,5:17);

    % team B stats in losses col 66 - 78
    matchupX(1,66:78) = XTest(TeamB,18:30);

    % team B conf weighted stats in wins  col 79 - 91
    matchupX(1,79:91) = XTest(TeamB,31:43);

    % team B conf weighted stats in losses col 92 - 104
    matchupX(1,92:104) = XTest(TeamB,44:56);

    % Run 3 models 
       pred1 = NaiveBayesGameClas1.predictFcn(matchupX);
    pred2 = SVMGameClas1.predictFcn(matchupX);
    pred3 = BoostedTreesGamesClas1.predictFcn(matchupX);
    pred4 = NarrowNeural.predictFcn(matchupX);
    pred5 = subSpace.predictFcn(matchupX);

    score = pred1 + pred2 + pred3 + pred4 + pred5;

    % pick winner 
    if score > 2
        games{gm,5} = games{gm,1};      
    else 
        games{gm,5} = games{gm,2};
    end 
    games{gm,6} = teamIDs.TeamName(teamIDs.TeamID == games{gm,5});

end 

%% Round 5 
gm = 1;
    
        % Region 1 
        games{61,1} = games{57,5};
        games{61,3} = games{57,6};
        games{61,2} = games{58,5};
        games{61,4} = games{58,6};

        % Region 2
        games{62,1} = games{59,5};
        games{62,3} = games{59,6};
        games{62,2} = games{60,5};
        games{62,4} = games{60,6};

% Predicitons for Round 5

for gm = 61:62
    matchupX = NaN(1,104);
    TeamAID = games{gm,1};
    TeamBID = games{gm,2};
    year = 2024;

    TeamA = find(teams == TeamAID);
    TeamB = find(teams == TeamBID);
    yearIndex = find(years == year);


 %team A stats in wins  col 1 - 13
    matchupX(1,1:13) = XTest(TeamA,5:17);

    % team A stats in losses col 14 - 26
    matchupX(1,14:26) = XTest(TeamA,18:30);

    % team A conf weighted stats in wins col 27 - 39
    matchupX(1,27:39) = XTest(TeamA,31:43);

    % team A conf weighted stats in losses col 40 - 52
    matchupX(1,40:52) = XTest(TeamA,44:56);

    % team B stats in wins col 53 - 65
     matchupX(1,53:65) = XTest(TeamB,5:17);

    % team B stats in losses col 66 - 78
    matchupX(1,66:78) = XTest(TeamB,18:30);

    % team B conf weighted stats in wins  col 79 - 91
    matchupX(1,79:91) = XTest(TeamB,31:43);

    % team B conf weighted stats in losses col 92 - 104
    matchupX(1,92:104) = XTest(TeamB,44:56);

    % Run 3 models 
    pred1 = NaiveBayesGameClas1.predictFcn(matchupX);
    pred2 = SVMGameClas1.predictFcn(matchupX);
    pred3 = BoostedTreesGamesClas1.predictFcn(matchupX);
    pred4 = NarrowNeural.predictFcn(matchupX);
    pred5 = subSpace.predictFcn(matchupX);

    score = pred1 + pred2 + pred3 + pred4 + pred5;

    % pick winner 
    if score > 2
        games{gm,5} = games{gm,1};      
    else 
        games{gm,5} = games{gm,2};
    end 
    games{gm,6} = teamIDs.TeamName(teamIDs.TeamID == games{gm,5});

end 

%% Model Functions 



% % Combine models in 
% function score = runModels(matchupX)
% 
%     pred1 = NaiveBayesGameClas1.predictFcn(matchupX);
%     pred2 = SVMGameClas1.predictFcn(matchupX);
%     pred3 = BoostedTreesGamesClas1.predictFcn(matchupX);
%     pred4 = NarrowNeural.predictFcn(matchupX);
%     pred5 = subSpace.predictFcn(matchupX);
% 
%     score = pred1 + pred2 + pred3 + pred4 + pred5;
% end 
