%% Load Data from pre proccessing script 
load("MM24_PreProc_Out.mat")


%%%%% WEWRITE ALL OF THIS TO TRAIN MODELS AFTER PREPROC * WILL RUN IN A
%%%%% MAIN TRIAN SCRIPT 


%% Train / Validation Split 
% Create randomized cross validation holdout 
c = cvpartition(length(X),'Holdout',0.2);    

testidx = c.test;

% Splt data 

XTrain = X(~testidx,:);
YTrain = Y(~testidx,:);
XVal = X(testidx,:);
YVal = Y(testidx,:);


%% Visualize Data with Dimensionality Reduction
%% 2D t-Distributed Stochastic Neighbor Embedding 
 
[tsne2d,tsne2d_loss] = tsne(XTrain,'Algorithm','barneshut');

figure()
gscatter(tsne2d(:,1),tsne2d(:,2),YTrain)
title(['t-SNE 2D Visualization - Loss = ' num2str(tsne2d_loss)]);
xlabel('Dimension 1');
ylabel('Dimension 2');

%% Perform PCA
[coefficients, score, latent, ~, explained] = pca(XTrain);

figure()
gscatter(score(:, 1), score(:, 2), YTrain, 'filled');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
zlabel('Principal Component 3');
title('PCA: Reduced-dimensional Data (Training Set)');

%% Visualize Data 
figure()
for ii = 1:width(XTrain)
    subplot(8,8,ii)
    scatter(XTrain(:,ii),YTrain)
    ylabel('BC Score')
end 

%% Regression Tree 

rTreeModel = fitrtree(XTrain,YTrain);

view(rTreeModel,'mode','graph')

rTree_predicitons = predict(rTreeModel,XVal);

rmse_RTree = rmse(rTree_predicitons, YVal)

%% Pull in models from Classifier Learner 


