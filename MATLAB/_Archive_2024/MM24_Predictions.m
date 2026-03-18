%% Looks like I was using this to train models using the GUI, 
% We're going to just rebuild a train script toi do that 

%% Load Data from pre proccessing script 
load("workspace20MAR.mat");
load('MM24_PreProc_Out.mat');

%% Update cost matrix to account for unbalanced classes 
class_counts = NaN(1,length(bcScores));

for jj = 1:7

    class_counts(jj) = numel(find(YTrain == bcScores(jj))); 
end 
% Calculate class frequencies
class_freqs = class_counts / sum(class_counts);

% Initialize base cost matrix with equal costs
num_classes = numel(class_counts);
base_cost = 1;  % You can adjust this based on your preference
cost_matrix = ones(num_classes, num_classes) * base_cost;

% Adjust costs based on class frequencies
for i = 1:num_classes
    for j = 1:num_classes
        if i ~= j
            cost_matrix(i, j) = cost_matrix(i, j) * (class_freqs(i) / class_freqs(j));
        else 
            cost_matrix(i, j) = 0;
        end
    end
end

cost_matrixT = cost_matrix';

%% Use Exported Model on classification data 

save('TrainedModels', 'WideNNClass1','RBagTree1','GausReg1')

WideNNPredicts1 = WideNNClass1.predictFcn(XTestOrder);

RBagTreePredicts1 = RBagTree1.predictFcn(XTestOrder);

GausRegPredicts1 = GausReg1.predictFcn(XTestOrder);

predictions = cell(64,4);

for ii = 1:64
    predictions{ii,1} = teamIDs.TeamName(YTestIdx(ii));
    predictions{ii,2} = WideNNPredicts1(ii);
    predictions{ii,3} = RBagTreePredicts1(ii);
    predictions{ii,4} = GausRegPredicts1(ii);
end 

save('predictions','WideNNPredicts1','RBagTreePredicts1',"GausRegPredicts1");

%% Use Exported Models on Game Based Data (Will have to be done on gae by game basis as model is created)
matchupX = NaN(1,104);
TeamAID = 1235;
TeamBID = 1266;
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


%Predict game 
save('TrainedGameModels','BoostedTreeGameReg1','TriNNGameReg1','WideNNGameReg1','NaiveBayesGameClas1','SVMGameClas1','BoostedTreesGamesClas1')

BoostedTreeGameReg1Predicts = BoostedTreeGameReg1.predictFcn(matchupX)
TriNNGameReg1Predicts = TriNNGameReg1.predictFcn(matchupX)
WideNNGameREg1predicts = WideNNGameReg1.predictFcn(matchupX)

NaiveBayesGameClas1predicts = NaiveBayesGameClas1.predictFcn(matchupX)
SVMGameClas1predicts = SVMGameClas1.predictFcn(matchupX)
BoostedTreesGamesClas1predicts = BoostedTreesGamesClas1.predictFcn(matchupX)

