%% Regressions Trainer 
% Trains a variety of models, saves them to models folder and evaluates performance 

%% Load Data 
if ~exist('Features.mat','file')
    TrainingDataGen
end 

load('TrainingData.mat')

%% Gradient Boosted Bagged Trees 

GB_BaggedTree = fitrensemble(X, Y_reg, ...
    'Method', 'LSBoost', ... % Gradient Boosting
    'Learners', templateTree('Surrogate','on'), ... % Use tree learners
    'OptimizeHyperparameters', {'NumLearningCycles', 'LearnRate', 'MaxNumSplits'}, ... % Tune these hyperparameters
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName', 'expected-improvement-plus'));

k = 5; % Number of folds
cv_GB_BaggedTree = crossval(GB_BaggedTree, 'KFold', k); % Perform cross-validation

% Compute Mean Squared Error (MSE)
GB_BaggedTree_mse = kfoldLoss(cv_GB_BaggedTree);

Y_pred_GB_BaggedTree_Train = predict(GB_BaggedTree, X);

% Compute performance metrics
GB_BaggedTree_rmse = sqrt(mean((Y_reg - Y_pred_GB_BaggedTree_Train).^2)); % Root Mean Squared Error
GB_BaggedTree_r2 = corr(Y_reg, Y_pred_GB_BaggedTree_Train)^2; 

fprintf('Gradient Boosted Bagged Trees - RMSE: %.4f\n', GB_BaggedTree_rmse);
fprintf('Gradient Boosted Bagged Trees - R-squared: %.4f\n', GB_BaggedTree_r2);

% Define logical indices for the quadrants
green_idx = (Y_reg > 0 & Y_pred_GB_BaggedTree_Train > 0) | (Y_reg < 0 & Y_pred_GB_BaggedTree_Train < 0); % Upper right & lower left
red_idx = ~green_idx; % All other points

GB_Bagged_Trees_Clas_Acc = sum(green_idx) / length(Y_pred_GB_BaggedTree_Train);


figure()
hold on 


line([-30 30], [-30 30], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--')

scatter(Y_reg(green_idx), Y_pred_GB_BaggedTree_Train(green_idx), 50, 'g'); 
scatter(Y_reg(red_idx), Y_pred_GB_BaggedTree_Train(red_idx), 50, 'r'); 

% Labels and title
xlabel('Actual Values');
ylabel('Predicted Values');
title('Random Forrest Regression');
legend({'Reference Line', 'Correct Quadrants (Green)', 'Incorrect Quadrants (Red)'}, 'Location', 'best');

% Formatting
grid on;
xlim([-30 30])
ylim([-30 30])
hold off

% save
save("Models\GBTreeReg","GB_BaggedTree")

%% Support Vector Machine (SVM) Regression

SVMModel = fitrsvm(X, Y_reg, ...
    'KernelFunction', 'gaussian', ... % Use Gaussian (RBF) kernel
    'OptimizeHyperparameters', {'BoxConstraint', 'KernelScale', 'Epsilon'}, ... % Tune these hyperparameters
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName', 'expected-improvement-plus'));

k = 5; % Number of folds
cv_SVMModel = crossval(SVMModel, 'KFold', k); % Perform cross-validation

% Compute Mean Squared Error (MSE)
SVM_mse = kfoldLoss(cv_SVMModel);

Y_pred_SVM_Train = predict(SVMModel, X);

% Compute performance metrics
SVM_rmse = sqrt(mean((Y_reg - Y_pred_SVM_Train).^2)); % Root Mean Squared Error
SVM_r2 = corr(Y_reg, Y_pred_SVM_Train)^2; 

fprintf('SVM Regression - RMSE: %.4f\n', SVM_rmse);
fprintf('SVM Regression - R-squared: %.4f\n', SVM_r2);

% Visualization of Results

% Define logical indices for the quadrants
green_idx = (Y_reg > 0 & Y_pred_SVM_Train > 0) | (Y_reg < 0 & Y_pred_SVM_Train < 0); % Upper right & lower left
red_idx = ~green_idx; % All other points

SVM_Class_acc = sum(green_idx) / (length(Y_pred_SVM_Train));

figure()
hold on 

line([-30 30], [-30 30], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--') 


scatter(Y_reg(green_idx), Y_pred_SVM_Train(green_idx), 50, 'g'); 
scatter(Y_reg(red_idx), Y_pred_SVM_Train(red_idx), 50, 'r'); 


xlabel('Actual Values');
ylabel('Predicted Values');
title('SVM Regression Predictions');
legend({'Reference Line', 'Correct Quadrants (Green)', 'Incorrect Quadrants (Red)'}, 'Location', 'best');

grid on;
xlim([-30 30])
ylim([-30 30])
hold off

% save
save("Models\SVM","SVMModel")

%% Neural Network Regression

NNModel = fitrnet(X, Y_reg, ...
    'OptimizeHyperparameters', {'LayerSizes', 'Lambda', 'Standardize'}, ... % Tune all hyperparameters
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName', 'expected-improvement-plus'));

k = 5; % Number of folds
cv_NNModel = crossval(NNModel, 'KFold', k); % Perform cross-validation

% Compute Mean Squared Error (MSE)
NN_mse = kfoldLoss(cv_NNModel);

Y_pred_NN_Train = predict(NNModel, X);

% Compute performance metrics
NN_rmse = sqrt(mean((Y_reg - Y_pred_NN_Train).^2)); % Root Mean Squared Error
NN_r2 = corr(Y_reg, Y_pred_NN_Train)^2; 

fprintf('Neural Network Regression - RMSE: %.4f\n', NN_rmse);
fprintf('Neural Network Regression - R-squared: %.4f\n', NN_r2);

% Visualization of Results

% Define logical indices for the quadrants
green_idx = (Y_reg > 0 & Y_pred_NN_Train > 0) | (Y_reg < 0 & Y_pred_NN_Train < 0); % Upper right & lower left
red_idx = ~green_idx; % All other points

NN_class_acc = sum(green_idx) / length(Y_pred_NN_Train);
figure()
hold on 

line([-30 30], [-30 30], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--') 


scatter(Y_reg(green_idx), Y_pred_NN_Train(green_idx), 50, 'g'); 
scatter(Y_reg(red_idx), Y_pred_NN_Train(red_idx), 50, 'r'); 

% Labels and title
xlabel('Actual Values');
ylabel('Predicted Values');
title('Neural Network Regression Predictions');
legend({'Reference Line', 'Correct Quadrants (Green)', 'Incorrect Quadrants (Red)'}, 'Location', 'best');

% Formatting
grid on;
xlim([-30 30])
ylim([-30 30])
hold off

% save
save("Models\NN_reg","NNModel")

%% Export Models 