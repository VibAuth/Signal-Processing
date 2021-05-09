function result = func_authentication_module (userNum, nDataPerUser, nn_k)
%% Get registration data
path = './';
filename = 'new_file_auth.csv';

%% Vibration parameter setting
rate = 1500;
vibLength = 1.44;
vibSectionLength = vibLength + 0.3;
coarseInterval = rate * vibSectionLength;

%% SignalCut
[check, temp_xf(1,:),temp_yf(1,:), temp_zf(1,:)] ...
    = func_signalcut_demo(path, filename, coarseInterval, 1);

data_xf(1,:) = temp_xf(1,:);
data_yf(1,:) = temp_yf(1,:);
data_zf(1,:) = temp_zf(1,:);

%% Correlation
test_data(1,:) = (data_xf + data_yf + data_zf)/3;

path = './';
idx = 1;
for cnt=1:userNum
   corr_file_name = strcat(int2str(cnt),'.csv');
   corr_data = csvread([path, corr_file_name],0,0);
   [m, n] = size(corr_data);
   
   test_data(idx+1:idx+m,:) = corr_data;
   idx = idx + m;
end

figure();
set(gcf,'units', 'normalized','outerposition',[0.05 0.5 0.35 0.5]);
imagesc(corr(test_data'))
xticks(1:12:73);
yticks(1:12:73);
caxis([0.825 1])

%% KNN
[euclid, corr_knn, corr_avg] = func_knn_classification_demo (userNum, nDataPerUser, test_data, nn_k);
% func_knn_classification_demo
for i = 1:userNum
    trainingAnswer((i - 1) * nDataPerUser + (1:nDataPerUser)) = i;
end

knn_model = fitcknn(test_data(2:end,:), trainingAnswer, 'NumNeighbors', nn_k);
model_result = predict(knn_model, test_data(1,:));

%% Return the result
fprintf("%d, %d, %d, %d \n", euclid, corr_knn, corr_avg, model_result)
result = mode([euclid, corr_knn, model_result]);

