function [test_result] = func_test_classification (test_filename, userNum)
%% test data
path = './test/';

%% Vibration parameter setting
rate = 1500;
vibLength = 1.44;
vibSectionLength = vibLength + 0.3;
coarseInterval = rate * vibSectionLength;

%% SignalCut
[check, xWeight, yWeight, zWeight, xSpec_wide, ySpec_wide, zSpec_wide]...
     = func_signalcut_weight(path, test_filename, coarseInterval, 1);

data_xf(1,:) = xSpec_wide;
data_yf(1,:) = ySpec_wide;
data_zf(1,:) = zSpec_wide;

test_data(1,:) = (data_xf + data_yf + data_zf)/3;

%% training data setting
path = './train_origin/';
nDataPerUser = 12;
% train_list = {'9' '11' '7' '2'};

idx = 1;
for cnt=1:userNum
   corr_file_name = strcat(int2str(cnt),'.csv');
%    corr_file_name = strcat(train_list{cnt},'.csv');
   corr_data = csvread([path, corr_file_name],0,0);
   [m, n] = size(corr_data);
   
   test_data(idx+1:idx+m,:) = corr_data;
   idx = idx + m;
end
% 
% figure();
% set(gcf,'units', 'normalized','outerposition',[0.05 0.5 0.35 0.5]);
% imagesc(corr(test_data'))
% xticks(1:nDataPerUser:userNum*nDataPerUser+1);
% yticks(1:nDataPerUser:userNum*nDataPerUser+1);
% caxis([0.825 1])

%% Classification
nn_k = 3;
[euclid, corr_knn, corr_avg] = func_knn_classification(userNum, nDataPerUser, test_data, nn_k);

for i = 1:userNum
    trainingAnswer((i - 1) * nDataPerUser + (1:nDataPerUser)) = i;
end

knn_model = fitcknn(test_data(2:end,:), trainingAnswer, 'NumNeighbors', nn_k);
knn_model_result = predict(knn_model, test_data(1,:));

svm_model = fitcecoc(test_data(2:end,:), trainingAnswer);
svm_model_result = predict(svm_model, test_data(1,:));

test_result = [euclid, corr_knn, corr_avg, knn_model_result, svm_model_result];
