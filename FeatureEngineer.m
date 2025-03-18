%% Feature Engineering
% Generates feature set for a game between Team1 and Team2 using Data from
% RawData.TeamStats. featureSet input determines which set of features is
% generated for the two teams, options explained below

function FeatureSet = FeatureEngineer(TeamIDYr1,TeamIDYr2, RawData,Data, varargin)

% Find ID of teams 
    Team1Idx= find(RawData.TeamIDs  == TeamIDYr1);
    Team2Idx = find(RawData.TeamIDs  == TeamIDYr2);

% %% Team Stats Cols 
% 
%     % 1: Wins
%     % 2: Losses 
%     % 3: Points For Per Game
%     % 4: Points Against Per Game
%     % 5: Field Goals Made Per Game
%     % 6: Field Goals Attempted Per Game
%     % 7: 3PT Field Goals Made Per Game
%     % 8: 3PT Field Goals Attempted Per Game
%     % 9: Free Throws Made Per Game
%     % 10: Free Throws Attempted Per Game
%     % 11: Offensive Rebounds Per Game
%     % 12: Defensive Rebounds Per Game
%     % 13: Assists Per Game
%     % 14: Turnovers Per Game
%     % 15: Steals Per Game
%     % 16: Blocks Per Game
%     % 17: Personal Fouls Per Game
%     % 18: Conferenec Tournament Wins 
%     % 19: Conference Tournament Losses 
%     % 20: NCAA Tournament Wins 
%     % 21: NCAA Tournament Losses 
%     % 22: NCAA Tournament Points For Per Game
%     % 23: NCAA Tournament Points Against Per Game
%     % 24: NCAA Tournament Field Goals Made Per Game
%     % 25: NCAA Tournament Field Goals Attempted Per Game
%     % 26: NCAA Tournament 3PT Field Goals Made Per Game
%     % 27: NCAA Tournament 3PT Field Goals Attempted Per Game
%     % 28: NCAA Tournament Free Throws Made Per Game
%     % 29: NCAA Tournament Free Throws Attempted Per Game
%     % 30: NCAA Tournament Offensive Reboudns Per Game
%     % 31: NCAA Tournament Defensive Rebounds Per Game
%     % 32: NCAA Tournament Assists Per Game
%     % 33: NCAA Tournament Turnovers Per Game
%     % 34: NCAA Tournament Steals Per Game
%     % 35: NCAA Tournament Blocks Per Game
%     % 36: NCAA Tournament Personal Fouls Per Game
%     % 37: NCAA Tournament Wins (DUPLICATE)
%     % 38: NCAA Tournament Losses (DUPLICATE)
%     % 39: NCAA Tournament Bracket Challenge Points Earned 
%     % 40: 2nd Degree Regular Season Wins 
%     % 41: 2nd Degree Regular Season Losses 
%     % 42: 3rd Degree Regular Season Wins 
%     % 43: 3rd Degree Regular Season Losses 
%     % 44: 2nd Degree Regular Season Win Percentage 
%     % 45: 3rd Degree Regular Season Win Percentage
%     % 46: Field Goals Made Per Game Against 
%     % 47: Field Goals Attempted Per Game Against
%     % 48: 3PT Field Goals Made Per Game Against
%     % 49: 3PT Field Goals Attempted Per Game Against
%     % 50: Free Throws Made Per Game Against
%     % 51: Free Throws Attempted Per Game Against
%     % 52: Offensive Rebounds Per Game Against
%     % 53: Defensive Rebounds Per Game Against
%     % 54: Assists Per Game Against
%     % 55: Turnovers Per Game Against
%     % 56: Steals Per Game Against
%     % 57: Blocks Per Game Against
%     % 58: Personal Fouls Per Game Against
% 
% 
% %% Weighting Parameters 
%     % Col 1 - 2nd degree reg season win pct (TeamStats Col 44)
%     % Col 2 - 3rd degree reg season win pct (TeamStats Col 45)
%     % Col 3 - 1 - 2nd degree reg season win pct (For scaling Defense Stats)
%     % Col 4 - 1 - 3rd degree reg season win pct (For scaling Defense Stats)
%     weights(:,1:2) = RawData.TeamStats(:,44:45);
%     weights(:,3:4) = 1 - weights(:,1:2);
% 
% %% Generate Features 
% 
% %% Team 1 Stats
%     % Raw Summary Stats
%     Team1OffFeats = RawData.TeamStats(Team1Idx,5:17);
% 
%     % Percetnages 
%         % FG %
%     Team1OffFeats = [ Team1OffFeats , RawData.TeamStats(Team1Idx,5) / RawData.TeamStats(Team1Idx, 6)];
%         % 3PT FG
%     Team1OffFeats = [ Team1OffFeats , RawData.TeamStats(Team1Idx,7) / RawData.TeamStats(Team1Idx,8)];
% 
%         % FT %
%     Team1OffFeats = [ Team1OffFeats , RawData.TeamStats(Team1Idx,9) / RawData.TeamStats(Team1Idx,10)];
% 
%         % Rebound % 
%     Team1OffFeats = [  Team1OffFeats , (RawData.TeamStats(Team1Idx,11) + RawData.TeamStats(Team1Idx,12)) / ...
%         (RawData.TeamStats(Team1Idx,52) + RawData.TeamStats(Team1Idx,53))];
% 
%     % Raw Stats Against 
%     Team1DefFeats = RawData.TeamStats(Team1Idx,46:57);
% 
%         % Defensive Percentages 
%         % FG %
%     Team1DefFeats = [ Team1DefFeats , RawData.TeamStats(Team1Idx,46) / RawData.TeamStats(Team1Idx, 47)];
%         % 3PT FG
%     Team1DefFeats = [ Team1DefFeats, RawData.TeamStats(Team1Idx,48) / RawData.TeamStats(Team1Idx,49)];
% 
% 
%     % Team 1 2nd deg weighted Offense Stats
%     Team1OffFeats = [Team1OffFeats , Team1OffFeats * weights(Team1Idx,1)];
% 
%     % Team 1 2nd deg weighted Defense Stats
%     Team1DefFeats = [ Team1DefFeats, Team1DefFeats * weights(Team1Idx,3)];
% 
%     % Team 1 3rd deg weighted Offense Stats
%     Team1OffFeats = [ Team1OffFeats , Team1OffFeats * weights(Team1Idx,2)];
% 
%     % Team 1 3rd deg weighted Defense Stats
%     Team1DefFeats = [Team1DefFeats Team1DefFeats * weights(Team1Idx,4)];
% 
%     %% Team 2  Stats
% 
%  % Raw Summary Stats
%     Team2OffFeats = RawData.TeamStats(Team2Idx,5:17);
% 
%     % Percetnages 
%         % FG %
%     Team2OffFeats = [ Team2OffFeats , RawData.TeamStats(Team2Idx,5) / RawData.TeamStats(Team2Idx, 6)];
%         % 3PT FG
%     Team2OffFeats = [ Team2OffFeats , RawData.TeamStats(Team2Idx,7) / RawData.TeamStats(Team2Idx,8)];
% 
%         % FT %
%     Team2OffFeats = [ Team2OffFeats , RawData.TeamStats(Team2Idx,9) / RawData.TeamStats(Team2Idx,10)];
% 
%         % Rebound % 
%     Team2OffFeats = [ Team2OffFeats ,  (RawData.TeamStats(Team2Idx,11) + RawData.TeamStats(Team2Idx,12)) / ...
%         (RawData.TeamStats(Team2Idx,52) + RawData.TeamStats(Team2Idx,53))];
% 
%     % Raw Stats Against 
%     Team2DefFeats = RawData.TeamStats(Team2Idx,46:57);
% 
%         % Defensive Percentages 
%         % FG %
%     Team2DefFeats = [ Team2DefFeats , RawData.TeamStats(Team2Idx,46) / RawData.TeamStats(Team2Idx, 47)];
%         % 3PT FG
%     Team2DefFeats =[ Team2DefFeats ,  RawData.TeamStats(Team2Idx,48) / RawData.TeamStats(Team2Idx,49)];
% 
%     % Team 2 2nd deg weighted Offense Stats
%     Team2OffFeats = [ Team2OffFeats , Team2OffFeats * weights(Team2Idx,1)];
% 
%     % Team 2 2nd deg weighted Defense Stats
%     Team2DefFeats = [ Team2DefFeats , Team2DefFeats * weights(Team2Idx,3)];
% 
%     % Team 2 3rd deg weighted Offense Stats
%     Team2OffFeats= [ Team2OffFeats , Team2OffFeats * weights(Team2Idx,2)];
% 
%     % Team 2 3rd deg weighted Defense Stats
%     Team2DefFeats = [ Team2DefFeats , Team2DefFeats * weights(Team2Idx,4)];
% 
%     %% Interaction Features
%         % Team 1 Offense - Team 2 Defense Stat differential 
%             % FG %
%             InteractionFeats(1) = RawData.TeamStats(Team1Idx,5) / RawData.TeamStats(Team1Idx,6) -...
%             RawData.TeamStats(Team2Idx,46) / RawData.TeamStats(Team2Idx,47);
% 
%             % 3PT FG % 
%             InteractionFeats(2) = RawData.TeamStats(Team1Idx,7) / RawData.TeamStats(Team1Idx,8) -...
%             RawData.TeamStats(Team2Idx,48) / RawData.TeamStats(Team2Idx,49);
% 
%             % Offensive v Defensive Rebounds
%             InteractionFeats(3) = RawData.TeamStats(Team1Idx, 11) - ...
%                 RawData.TeamStats(Team2Idx, 53);
% 
%             % Deffensive v Offensive Rebounds
%             InteractionFeats(4) = RawData.TeamStats(Team1Idx, 12) - ...
%                 RawData.TeamStats(Team2Idx, 52);
% 
%         % Team 2 Offense - Team 1 Defense Stat differential 
%             % FG %
%             InteractionFeats(5) = RawData.TeamStats(Team2Idx,5) / RawData.TeamStats(Team2Idx,6) -...
%             RawData.TeamStats(Team1Idx,46) / RawData.TeamStats(Team1Idx,47);
% 
%             % 3PT FG % 
%             InteractionFeats(6) = RawData.TeamStats(Team2Idx,7) / RawData.TeamStats(Team2Idx,8) -...
%             RawData.TeamStats(Team1Idx,48) / RawData.TeamStats(Team1Idx,49);
% 
%             % Offensive v Defensive Rebounds
%             InteractionFeats(7) = RawData.TeamStats(Team2Idx, 11) - ...
%                 RawData.TeamStats(Team1Idx, 53);
% 
%             % Deffensive v Offensive Rebounds
%             InteractionFeats(8) = RawData.TeamStats(Team2Idx, 12) - ...
%                 RawData.TeamStats(Team1Idx, 52);
% 
%         % Team 1 Ofense  - Team 2 Defense 2nd weighted stat differnetial 
%             % FG %
%             InteractionFeats(9) = (RawData.TeamStats(Team1Idx,5) / RawData.TeamStats(Team1Idx,6)) * weights(Team1Idx,1) -...
%             (RawData.TeamStats(Team2Idx,46) / RawData.TeamStats(Team2Idx,47)) * weights(Team2Idx,3);
% 
%             % 3PT FG % 
%             InteractionFeats(10) = (RawData.TeamStats(Team1Idx,7) / RawData.TeamStats(Team1Idx,8)) * weights(Team1Idx,1) -...
%             (RawData.TeamStats(Team2Idx,48) / RawData.TeamStats(Team2Idx,49)) * weights(Team2Idx,3);
% 
%             % Offensive v Defensive Rebounds
%             InteractionFeats(11) = RawData.TeamStats(Team1Idx, 11) * weights(Team1Idx,1) - ...
%                 RawData.TeamStats(Team2Idx, 53) * weights(Team2Idx,1);
% 
%             % Deffensive v Offensive Rebounds
%             InteractionFeats(12) = RawData.TeamStats(Team1Idx, 12) * weights(Team1Idx,1)- ...
%                 RawData.TeamStats(Team2Idx, 52) * weights(Team2Idx,1);
% 
%         % Team 1 Offense - Team 2 Defense  3rd weighted stat differnetial 
%             % FG %
%             InteractionFeats(13) = (RawData.TeamStats(Team1Idx,5) / RawData.TeamStats(Team1Idx,6)) * weights(Team1Idx,2) -...
%             (RawData.TeamStats(Team2Idx,46) / RawData.TeamStats(Team2Idx,47)) * weights(Team2Idx,4);
% 
%             % 3PT FG % 
%             InteractionFeats(14) = (RawData.TeamStats(Team1Idx,7) / RawData.TeamStats(Team1Idx,8)) * weights(Team1Idx,2) -...
%             (RawData.TeamStats(Team2Idx,48) / RawData.TeamStats(Team2Idx,49)) * weights(Team2Idx,4);
% 
%             % Offensive v Defensive Rebounds
%             InteractionFeats(15) = RawData.TeamStats(Team1Idx, 11) * weights(Team1Idx,2) - ...
%                 RawData.TeamStats(Team2Idx, 53) * weights(Team2Idx,2);
% 
%             % Deffensive v Offensive Rebounds
%             InteractionFeats(16) = RawData.TeamStats(Team1Idx, 12) * weights(Team1Idx,2)- ...
%                 RawData.TeamStats(Team2Idx, 52) * weights(Team2Idx,2);
% 
%     % Team 2 Ofense  - Team 1 Defense 2nd weighted stat differnetial 
%             % FG %
%             InteractionFeats(17) = (RawData.TeamStats(Team2Idx,5) / RawData.TeamStats(Team2Idx,6)) * weights(Team2Idx,1) -...
%             (RawData.TeamStats(Team1Idx,46) / RawData.TeamStats(Team1Idx,47)) * weights(Team1Idx,3);
% 
%             % 3PT FG % 
%             InteractionFeats(18) = (RawData.TeamStats(Team2Idx,7) / RawData.TeamStats(Team2Idx,8)) * weights(Team2Idx,1) -...
%             (RawData.TeamStats(Team1Idx,48) / RawData.TeamStats(Team1Idx,49)) * weights(Team1Idx,3);
% 
%             % Offensive v Defensive Rebounds
%             InteractionFeats(19) = RawData.TeamStats(Team2Idx, 11) * weights(Team2Idx,1) - ...
%                 RawData.TeamStats(Team1Idx, 53) * weights(Team1Idx,1);
% 
%             % Deffensive v Offensive Rebounds
%             InteractionFeats(20) = RawData.TeamStats(Team2Idx, 12) * weights(Team2Idx,1)- ...
%                 RawData.TeamStats(Team1Idx, 52) * weights(Team1Idx,1);
% 
%         % Team 2 Offense - Team 1 Defense  3rd weighted stat differnetial 
%             % FG %
%             InteractionFeats(21) = (RawData.TeamStats(Team2Idx,5) / RawData.TeamStats(Team2Idx,6)) * weights(Team2Idx,2) -...
%             (RawData.TeamStats(Team1Idx,46) / RawData.TeamStats(Team1Idx,47)) * weights(Team1Idx,4);
% 
%             % 3PT FG % 
%             InteractionFeats(22) = (RawData.TeamStats(Team2Idx,7) / RawData.TeamStats(Team2Idx,8)) * weights(Team2Idx,2) -...
%             (RawData.TeamStats(Team1Idx,48) / RawData.TeamStats(Team1Idx,49)) * weights(Team1Idx,4);
% 
%             % Offensive v Defensive Rebounds
%             InteractionFeats(23) = RawData.TeamStats(Team2Idx, 11) * weights(Team2Idx,2) - ...
%                 RawData.TeamStats(Team1Idx, 53) * weights(Team1Idx,2);
% 
%             % Deffensive v Offensive Rebounds
%             InteractionFeats(24) = RawData.TeamStats(Team2Idx, 12) * weights(Team2Idx,2)- ...
%                 RawData.TeamStats(Team1Idx, 52) * weights(Team1Idx,2);
% 
%         % Team 1 Offense - Team 2 Defense  momentum (conf tourney wins
%             InteractionFeats(25) = RawData.TeamStats(Team1Idx,18) - ...
%                 RawData.TeamStats(Team2Idx,18);
% 
%% Method 2: Monte Carlo the Features
% Radom number between -1.5 and 1.5 SD to account for ' good day and bad day'
    if ~isempty(varargin)
        for jj = 1:length(Data(Team1Idx).SumStats(1,:))
            Team1rand = randn(1);
            Team2rand = randn(1);
            Team1Feats(jj) = Data(Team1Idx).SumStats(1,jj) + (Team1rand * Data(Team1Idx).SumStats(2,jj));
            Team2Feats(jj) = Data(Team2Idx).SumStats(1,jj) + (Team2rand * Data(Team2Idx).SumStats(2,jj));
        end 
    else 

        Team1Feats = Data(Team1Idx).SumStats(1,:);
        Team2Feats = Data(Team2Idx).SumStats(1,:);
    end 
 
    % Add Hotness stats (conf tounry wins, wins last 10, weighted wins last
    % 10)
    Team1Feats = [Team1Feats RawData.TeamStats(Team1Idx,18) Data(Team1Idx).Hotness(1) Data(Team1Idx).Hotness(2)];
    Team2Feats = [Team2Feats RawData.TeamStats(Team2Idx,18) Data(Team2Idx).Hotness(2) Data(Team2Idx).Hotness(2)];
%% Combine Features 

FeatureSet = [Team1Feats Team2Feats];

% FeatureSet = [Team1OffFeats Team1DefFeats Team2OffFeats Team2DefFeats InteractionFeats];    
    % FeatureSet = Team1OffFeats;
    % For trainign data we can add response variable in the training data gen
    % funciton 

end 