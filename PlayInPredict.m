%% PlayIn Predictor 

W16a = "2025_1110";
W16b = "2025_1291";

X11a = "2025_1400";
X11b = "2025_1462";

Y11a = "2025_1314";
Y11b = "2025_1361";

Y16a = "2025_1106";
Y16b = "2025_1384";

n = 10000;


[Winner_W16,confidence_W16] = SingleGameMonte(W16a,W16b,RawData,Data,modelStruct,n);

[Winner_X11,confidence_X11] = SingleGameMonte(X11a,X11b,RawData,Data,modelStruct,n);

[Winner_Y11,confidence_Y11] = SingleGameMonte(Y11a,Y11b,RawData,Data,modelStruct,n);

[Winner_Y16,confidence_Y16] = SingleGameMonte(Y16a,Y16b,RawData,Data,modelStruct,n);

%% Visualize 

Winner_W16 = char(Winner_W16);
Winner_X11 = char(Winner_X11);
Winner_Y11 = char(Winner_Y11);
Winner_Y16 = char(Winner_Y16);

Winner_W16idx = find(RawData.TeamNames.TeamID == str2num(Winner_W16(end-3:end)));
Winner_X11idx = find(RawData.TeamNames.TeamID == str2num(Winner_X11(end-3:end)));
Winner_Y11idx = find(RawData.TeamNames.TeamID == str2num(Winner_Y11(end-3:end)));
Winner_Y16idx = find(RawData.TeamNames.TeamID == str2num(Winner_Y16(end-3:end)));

W16Name = RawData.TeamNames.TeamName(Winner_W16idx);
X11Name = RawData.TeamNames.TeamName(Winner_X11idx);
Y11Name = RawData.TeamNames.TeamName(Winner_Y11idx);
Y16Name =  RawData.TeamNames.TeamName(Winner_Y16idx);

fprintf("W Region 16 Seed Playin Winner: %s \n Confidence: %.2f \n \n ", ...
    W16Name{1}, confidence_W16)
fprintf("X Region 11 Seed Playin Winner: %s \n Confidence: %.2f \n \n ", ...
    X11Name{1}, confidence_X11)
fprintf("Y Region 11 Seed Playin Winner: %s \n Confidence: %.2f \n \n ", ...
    Y11Name{1}, confidence_Y11)
fprintf("Y Region 16 Seed Playin Winner: %s \n Confidence: %.2f \n \n ", ...
   Y16Name{1}, confidence_Y16)

