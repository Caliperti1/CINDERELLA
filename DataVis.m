%% Data Visualization 
% Workbook for visualizing data before training models 

%% Load Data 
if ~exist('Features.mat','file')
    TrainingDataGen
end 

load('Features.mat')

%% TSNE on Classification data 

YTSNE_mahl = tsne(X,'Algorithm','exact','Distance','cityblock');
YTSNE_cos = tsne(X,'Algorithm','exact','Distance','cosine');
YTSNE_euc = tsne(X,'Algorithm','exact','Distance','chebychev');
YTSNE_cheb = tsne(X,'Algorithm','exact','Distance','euclidean');

figure()
subplot(2,2,1)
gscatter(YTSNE_mahl(:,1),YTSNE_mahl(:,2),Y_clas)
title('NCAA Tournament W/L City Block')

subplot(2,2,2)
gscatter(YTSNE_cos(:,1),YTSNE_cos(:,2),Y_clas)
title('NCAA Tournament W/L Cosine')

subplot(2,2,3)
gscatter(YTSNE_euc(:,1),YTSNE_euc(:,2),Y_clas)
title('NCAA Tournament W/L Euclidean')

subplot(2,2,4)
gscatter(YTSNE_cheb(:,1),YTSNE_cheb(:,2),Y_clas)
title('NCAA Tournament W/L Chebychev')