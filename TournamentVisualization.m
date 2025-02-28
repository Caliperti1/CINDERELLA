% %% Tournament Visualiztion
% 
% function Bracket = TournamentVisualization(Games)
% 
% reg = repmat(1:4, 1, 16);
% 
% % Seed variables for round 1 
% seeds1 = repelem(1:8, 4); 
% seeds2 = repelem(16:-1:9,4);
% seeds = [seeds1 seeds2];
% 
% % Seed variables for Round of 32
% round2seeds1 = [1 16; 2 15; 3 14; 4 13];
% round2seeds2 = [ 8 9; 7 10; 6 11; 5 12];
% round2seeds1 = kron(round2seeds1, ones(4,1));
% round2seeds2 = kron(round2seeds2, ones(4,1));
% 
% % Seed variables for Sweet Sixteen 
% round3seeds1 = [1 16 8 9; 2 15 7 10];
% round3seeds2 = [5 12 4 13; 3 14 6 11];
% round3seeds1 = kron(round3seeds1, ones(4,1));
% round3seeds2  = kron(round3seeds2, ones(4,1));
% 
% % Seed variables for Elite Eight 
% round4seeds1 = [1 16 8 9 5 12 4 13];
% round4seeds2 = [3 14 6 11 2 15 7 10];
% round4seeds1 = kron(round4seeds1, ones(4,1));
% round4seeds2  = kron(round4seeds2, ones(4,1));
% 
% % Make an array formatted to look like a bracket 
% 
% Bracket = NaN(65,11);
% 
% % Populate round of 64 
% for gg = 1:32
%     % "X" Region
%     if reg(gg) == 1
% 
