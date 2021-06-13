function result = func_authentication_final (userNum, nDataPerUser, nn_k)
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
    = func_signalcut_auth_final(path, filename, coarseInterval, 1);

data_xf(1,:) = temp_xf(1,:);
data_yf(1,:) = temp_yf(1,:);
data_zf(1,:) = temp_zf(1,:);

%% Correlation
test_data(1,:) = (data_xf + data_yf + data_zf)/3;

path = './Data/';
idx = 1;
for cnt=1:userNum
   corr_file_name = strcat(path, strcat(int2str(cnt),'.mat'));
   load_data = load(corr_file_name, 'avg_all_axis');
   corr_data = getfield(load_data, 'avg_all_axis');
   
   [m, n] = size(corr_data);
   test_data(idx+1:idx+m,:) = corr_data;
   idx = idx + m;
end

figure();
set(gcf,'units', 'normalized','outerposition',[0.05 0.5 0.35 0.5]);
imagesc(corr(test_data'))
xticks(1:nDataPerUser:nDataPerUser*userNum+1);
yticks(1:nDataPerUser:nDataPerUser*userNum+1);
caxis([0.825 1])

%% KNN
[euclid, corr_knn, corr_avg, isAttack] = func_knn_classification_final(userNum, nDataPerUser, test_data, nn_k);

if isAttack == 0 % not attacker
    for i = 1:userNum
        trainingAnswer((i - 1) * nDataPerUser + (1:nDataPerUser)) = i;
    end

    knn_model = fitcknn(test_data(2:end,:), trainingAnswer, 'NumNeighbors', nn_k);
    knn_model_result = predict(knn_model, test_data(1,:));

    svm_model = fitcecoc(test_data(2:end,:), trainingAnswer);
    svm_model_result = predict(svm_model, test_data(1,:));

    %% Return the result
%     fprintf("%d, %d, %d, %d, %d\n", euclid, corr_knn, corr_avg, knn_model_result, svm_model_result)
%     fprintf("Attack %d\n",isAttack)
    result = mode([euclid, corr_knn, corr_avg, knn_model_result, svm_model_result]);
else
    result = 0;
end
