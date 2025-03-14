%% Tournament Sim
% Tournament sim takes the 64 Teams in the NCAA March Madness Bracket and
% uses the GamePredict function to simulate the tournament and determine
% the winners of each matchup. 

%% Configss
configs

%% Load Models
% Loads all models into modelStruct 
ModelAggregate

%% Load data for testing 
if ~exist('RawData.mat','file')
    DataManager
end 

load('RawData.mat')
% RawData.TournamentSeeds = readtable('2024_tourney_seeds.csv');
% RawData.TeamNames = readtable('MTeams.csv');
% RawData.TournamentSeeds = RawData.TournamentSeeds(RawData.TournamentSeeds.Tournament == "M",:);

TournamentSeeds = RawData.TournamentSeeds;
TeamIDs = RawData.TeamNames;

%% Create some counters to build out the Game Structure 
% Counter for regions 
reg = repmat(1:4, 1, 16);

% Seed variables for round 1 
seeds1 = repelem(1:8, 4); 
seeds2 = repelem(16:-1:9,4);
seeds = [seeds1 seeds2];

% Seed variables for Round of 32
round2seeds1 = [1 16; 2 15; 3 14; 4 13];
round2seeds2 = [ 8 9; 7 10; 6 11; 5 12];
round2seeds1 = kron(round2seeds1, ones(4,1));
round2seeds2 = kron(round2seeds2, ones(4,1));

% Seed variables for Sweet Sixteen 
round3seeds1 = [1 16 8 9; 2 15 7 10];
round3seeds2 = [5 12 4 13; 3 14 6 11];
round3seeds1 = kron(round3seeds1, ones(4,1));
round3seeds2  = kron(round3seeds2, ones(4,1));

% Seed variables for Elite Eight 
round4seeds1 = [1 16 8 9 5 12 4 13];
round4seeds2 = [3 14 6 11 2 15 7 10];
round4seeds1 = kron(round4seeds1, ones(4,1));
round4seeds2  = kron(round4seeds2, ones(4,1));

%% Instantiate Games struct 

regions = ["W","X","Y","Z"];

rounds = {'Round of 64','Round of 32', 'Sweet Sixteen', 'Elite Eight', 'Final Four', 'Championship'};

for gg = 1:62

    % Set regions 
    Games(gg).Region = regions(reg(gg));

    % Set rounds 
    if gg <= 32
        Games(gg).Rounds = rounds{1};

    elseif gg <= 48
        Games(gg).Rounds = rounds{2};

    elseif gg <= 56
        Games(gg).Rounds = rounds{3};
        
    else
        Games(gg).Rounds = rounds{4};
    end 

    % Set Seeds
  
    if gg <= 32
        % set seeds
        Games(gg).Team1Seed = seeds1(gg);
        Games(gg).Team2Seed = seeds2(gg);


    end 

        % Make Array of possible seeds for Round of 32  

        if gg >32 && gg <= 48 
            Games(gg).Team1Seed = round2seeds1(gg-32,:);
            Games(gg).Team2Seed = round2seeds2(gg-32,:);
        end 

        % Make array of possible seeds for Sweet 16 
        if gg >48 && gg <= 56 
            Games(gg).Team1Seed = round3seeds1(gg-48,:);
            Games(gg).Team2Seed = round3seeds2(gg-48,:);
        end 

        % Make array of possible seeds for Elite 8 
        if gg >56 && gg <= 60 
            Games(gg).Team1Seed = round4seeds1(gg-56,:);
            Games(gg).Team2Seed = round4seeds2(gg-56,:);
        end 
        
         % Make seeds that match the Kaggle dataset format  
       for ii = 1:length(Games(gg).Team1Seed)
             if Games(gg).Team1Seed(ii) < 10
                Games(gg).Team1Seedstr(ii) = ...
                    strcat(Games(gg).Region, "0", num2str(Games(gg).Team1Seed(ii)));
            else 
                Games(gg).Team1Seedstr(ii) = ...
                    strcat(Games(gg).Region,  num2str(Games(gg).Team1Seed(ii)));
             end 

            if Games(gg).Team2Seed(ii) < 10
                Games(gg).Team2Seedstr(ii) = ...
                    strcat(Games(gg).Region, "0", num2str(Games(gg).Team2Seed(ii)));
            else 
                Games(gg).Team2Seedstr(ii) = ...
                    strcat(Games(gg).Region,  num2str(Games(gg).Team2Seed(ii)));
            end
       end 

        % Add final four and championship 

        Games(61).Rounds = rounds{5};
        Games(61).Region = strcat(regions(1),regions(2));
        Games(61).Team1Seedstr = [Games(57).Team1Seedstr, Games(57).Team2Seedstr];
        Games(61).Team2Seedstr = [Games(58).Team1Seedstr, Games(58).Team2Seedstr];

        Games(62).Rounds = rounds{5};
        Games(62).Region = strcat(regions(3),regions(4));
        Games(62).Team1Seedstr = [Games(59).Team1Seedstr, Games(59).Team2Seedstr];
        Games(62).Team2Seedstr = [Games(60).Team1Seedstr, Games(60).Team2Seedstr];

        Games(63).Rounds = rounds{6};
        Games(63).Region = strcat(regions(1),regions(2),regions(3),regions(4));

       if gg <= 32
            % Populate fields for first round 
            % get team ID
            idx1 = find(TournamentSeeds.Seed == Games(gg).Team1Seedstr);
            idx2 = find(TournamentSeeds.Seed == Games(gg).Team2Seedstr);
    
            Games(gg).Team1ID = TournamentSeeds.TeamID(idx1);
            Games(gg).Team2ID = TournamentSeeds.TeamID(idx2);

            % Add col with TeamIDYr to match RawData
            Games(gg).Team1IDYr = tournamentYear + "_" +  ...
                string(Games(gg).Team1ID);
            Games(gg).Team2IDYr = tournamentYear + "_" +  ...
                string(Games(gg).Team2ID);
               
       end 
end 


%% Predict Winners for round 1 

for gg = 1:32

            % Get Team features 
            Games = UpdateWithFeatures(RawData,gg,Games,Data);

            % Predict winner 
            Games = UpdateWithWinner(Games,gg,modelStruct);
end 

%% Populate Round of 32

winningSeeds = [Games(1:32).WinnerSeedstr];
   
   for gg = 33:48
       Games(gg).Team1Seedstr = intersect([Games(gg).Team1Seedstr], winningSeeds);
       Games(gg).Team2Seedstr = intersect([Games(gg).Team2Seedstr], winningSeeds);

       

        Games = UpdateNextRound(Games,gg,TournamentSeeds,RawData,modelStruct,Data);
                   
   end 
    
%% Populate Round of 16

winningSeeds = [Games(33:48).WinnerSeedstr];
   
   for gg = 49:56
       Games(gg).Team1Seedstr = intersect([Games(gg).Team1Seedstr], winningSeeds);
       Games(gg).Team2Seedstr = intersect([Games(gg).Team2Seedstr], winningSeeds);

        Games = UpdateNextRound(Games,gg,TournamentSeeds,RawData,modelStruct,Data);
                   
   end 

%% Populate Elite 8

winningSeeds = [Games(49:56).WinnerSeedstr];
   
   for gg = 57:60
       Games(gg).Team1Seedstr = intersect([Games(gg).Team1Seedstr], winningSeeds);
       Games(gg).Team2Seedstr = intersect([Games(gg).Team2Seedstr], winningSeeds);

        Games = UpdateNextRound(Games,gg,TournamentSeeds,RawData,modelStruct,Data);
               
   end 

   %% Populate Final 4 

winningSeeds = [Games(57:60).WinnerSeedstr];
   
   for gg = 61:62
       Games(gg).Team1Seedstr = intersect([Games(gg).Team1Seedstr], winningSeeds);
       Games(gg).Team2Seedstr = intersect([Games(gg).Team2Seedstr], winningSeeds);

        Games = UpdateNextRound(Games,gg,TournamentSeeds,RawData,modelStruct,Data);
                   
   end 

   %% Populate Championship

   Games(63).Team1ID = Games(61).WinnerID;
   Games(63).Team1Seedstr = Games(61).WinnerSeedstr;

   Games(63).Team2ID = Games(62).WinnerID;
   Games(63).Team2Seedstr = Games(62).WinnerSeedstr;

   Games = UpdateNextRound(Games,63,TournamentSeeds,RawData,modelStruct,Data);
                   
%% Add Additional Data to Games for completeness

for gg = 1:length(Games)
    name1idx = find(Games(gg).Team1ID == TeamIDs.TeamID);
    Games(gg).Team1Name = string(TeamIDs.TeamName(name1idx));

    name2idx = find(Games(gg).Team2ID == TeamIDs.TeamID);
    Games(gg).Team2Name = string(TeamIDs.TeamName(name2idx));

    namewidx = find(Games(gg).WinnerID == TeamIDs.TeamID);
    Games(gg).WinnerName = string(TeamIDs.TeamName(namewidx));

end

%% Functions for repeated updates 

function Games = UpdateWithFeatures(RawData,counter,Games,Data)

            % idx1 = find( [Features.TeamID] == Games(counter).Team1ID);
            % idx2 = find( [Features.TeamID] == Games(counter).Team2ID);
            % 
            % Games(counter).Team1Features = Features(idx1).Features;
            % Games(counter).Team2Features = Features(idx2).Features;

            Team1rand = -1.5 + (3 * rand);
            Team2rand = -1.5 + (3 * rand);
            Games(counter).Features = FeatureEngineer(...
                    Games(counter).Team1IDYr,...
                    Games(counter).Team2IDYr,...
                    RawData, ...
                    Data, ...
                    Team1rand, ...
                    Team2rand);
end 

function Games = UpdateWithWinner(Games,counter,modelStruct)


        winner = GamePredictClassifier(Games(counter).Features,modelStruct);

        if winner == 1 
            Games(counter).WinnerID = Games(counter).Team1ID;
            Games(counter).WinnerSeedstr = Games(counter).Team1Seedstr;
        else 
            Games(counter).WinnerID = Games(counter).Team2ID;
            Games(counter).WinnerSeedstr = Games(counter).Team2Seedstr;
        end 

end 

function Games = UpdateNextRound(Games,counter,TournamentSeeds,RawData,modelStruct,Data)       

    configs
      % Populate fields for second round 
            % get team ID
            idx1 = find(TournamentSeeds.Seed == Games(counter).Team1Seedstr,1);
            idx2 = find(TournamentSeeds.Seed == Games(counter).Team2Seedstr,1);

            % [~, idx1] = ismember(Games(counter).Team1Seedstr, [TournamentSeeds.Seed]);
            % [~, idx2] = ismember(Games(counter).Team2Seedstr, [TournamentSeeds.Seed]);
            
            Games(counter).Team1ID = TournamentSeeds.TeamID(idx1);
            Games(counter).Team2ID = TournamentSeeds.TeamID(idx2);

            Games(counter).Team1IDYr = tournamentYear + "_" + string(Games(counter).Team1ID);
            Games(counter).Team2IDYr = tournamentYear + "_" + string(Games(counter).Team2ID);

        % Get features 
            Games = UpdateWithFeatures(RawData,counter,Games,Data);

        % Predict winner 
            Games = UpdateWithWinner(Games,counter,modelStruct);


end 