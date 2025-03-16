%% Regressions Trainer 
% Trains a variety of models, saves them to models folder and evaluates performance 

%% Load Data 
if ~exist('Features.mat','file')
    TrainingDataGen
end 

load('TrainingData.mat')

%% Gradient Boosted Bagged Trees 
GBtic = tic;

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
fprintf('Gradient Boosted Bagged Trees - Classification Accuracy: %.4f\n', GB_Bagged_Trees_Clas_Acc);
fprintf('Training Time: %.2f \n ',toc(GBtic))
save("Models\GBTreeReg","GB_BaggedTree")

%% Support Vector Machine (SVM) Regression
SVMtic = tic;

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
fprintf('Support Vector Machine - Classification Accuracy: %.4f\n', SVM_Class_acc);
fprintf('Training Time: %.2f \n ',toc(SVMtic))
save("Models\SVM","SVMModel")

%% Neural Network Regression
NNtic = tic;

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
fprintf('Shallow Neural Network - Classification Accuracy: %.4f\n', NN_class_acc);
fprintf('Training Time: %.2f \n ',toc(NNtic))
save("Models\NN_reg","NNModel")

%% KNN 
KNNtic = tic;

% Train KNN Regression Model
KNNModel = fitcknn(X, Y_clas, ...
    'NumNeighbors', 5, ... % Default number of neighbors
    'Distance', 'euclidean', ... % Euclidean distance metric
    'OptimizeHyperparameters', {'NumNeighbors', 'Distance'}, ... % Hyperparameter tuning
    'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName', 'expected-improvement-plus'));

% Perform k-fold cross-validation
k = 5; % Number of folds
cv_KNNModel = crossval(KNNModel, 'KFold', k);

% Compute Mean Squared Error (MSE)
KNN_mse = kfoldLoss(cv_KNNModel);

% Predict on training data
Y_pred_KNN_Train = predict(KNNModel, X);

% Compute performance metrics
KNN_acc = sum(Y_pred_KNN_Train == Y_clas) / length(Y_clas);
fprintf('KNN Accuracy: %.2f%%\n', KNN_acc * 100);

fprintf('K-Nearest Neighbor - Classification Accuracy: %.4f\n', KNN_acc);
fprintf('Training Time: %.2f \n ',toc(KNNtic))
% Save Model
save("Models\KNN", "KNNModel")

% %% GPR
% GPRtic = tic;
% % Train Gaussian Process Regression Model
% GPRModel = fitrgp(X, Y_reg, ...
%     'KernelFunction', 'squaredexponential', ... % Use Squared Exponential Kernel
%     'OptimizeHyperparameters', {'KernelScale', 'Sigma'}, ... % Tune these hyperparameters
%     'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName', 'expected-improvement-plus'));
% 
% % Perform k-fold cross-validation
% k = 5; % Number of folds
% cv_GPRModel = crossval(GPRModel, 'KFold', k);
% 
% % Compute Mean Squared Error (MSE)
% GPR_mse = kfoldLoss(cv_GPRModel);
% 
% % Make predictions on training data
% Y_pred_GPR_Train = predict(GPRModel, X);
% 
% % Compute performance metrics
% GPR_rmse = sqrt(mean((Y_reg - Y_pred_GPR_Train).^2)); % Root Mean Squared Error
% GPR_r2 = corr(Y_reg, Y_pred_GPR_Train)^2; 
% 
% fprintf('GPR Regression - RMSE: %.4f\n', GPR_rmse);
% 
% % Visualization of Results
% 
% % Define logical indices for the quadrants
% green_idx = (Y_reg > 0 & Y_pred_GPR_Train > 0) | (Y_reg < 0 & Y_pred_GPR_Train < 0); % Upper right & lower left
% red_idx = ~green_idx; % All other points
% 
% GPR_Class_acc = sum(green_idx) / (length(Y_pred_GPR_Train));
% 
% figure()
% hold on 
% 
% line([-30 30], [-30 30], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--') 
% 
% scatter(Y_reg(green_idx), Y_pred_GPR_Train(green_idx), 50, 'g'); 
% scatter(Y_reg(red_idx), Y_pred_GPR_Train(red_idx), 50, 'r'); 
% 
% xlabel('Actual Values');
% ylabel('Predicted Values');
% title('Gaussian Process Regression Predictions');
% legend({'Reference Line', 'Correct Quadrants (Green)', 'Incorrect Quadrants (Red)'}, 'Location', 'best');
% 
% grid on;
% xlim([-30 30])
% ylim([-30 30])
% hold off
% 
% % Save model
% fprintf('Gaussian Proccess Regression - Classification Accuracy: %.4f\n', GPR_Class_acc);
% fprintf('Training Time: %.2f \n ',toc(GPRtic))
% save("Models\GPR", "GPRModel")

%% Logistic Regression with Hyperparameter Tuning
LRtic = tic;
opts = struct('Optimizer', 'bayesopt', ...
              'ShowPlots', true, ...
              'AcquisitionFunctionName', 'expected-improvement-plus');

% Train with Hyperparameter Tuning (without 'Solver')
LRModel = fitclinear(X, Y_clas, 'Learner', 'logistic', ...
    'OptimizeHyperparameters', {'Regularization', 'Lambda'}, ...
    'HyperparameterOptimizationOptions', opts);

% Make Predictions
Y_pred = predict(LRModel, X);
accuracyOptimized = mean(Y_pred == Y_clas);
fprintf('Optimized Logistic Regression Accuracy: %.2f%%\n', accuracyOptimized * 100);

% Save Model
fprintf('Logistic Regression - Classification Accuracy: %.4f\n', SVM_Class_acc);
fprintf('Training Time: %.2f \n ',toc(LRtic))
save("Models\LR.mat", "LRModel");
