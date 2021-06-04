close all;
clearvars;

%% data setting

username_list = {'yj' 'ey' 'gh' 'is' 'jc' 'ksh' 'sh' 'mw' 'ej' 'sy' 'mj' 'sa' 'ny' 'db' 'hs' 'js'};
% username_list = {'ej' 'mj' 'sh' 'ey'};

userNum = 16;
nTestdataPerUser = 16;

%% confusion matrix

confusion = zeros(userNum); % userNum * userNum matrix (row : Ground Truth, column : Predict)

euclid = 0;
corr_knn = 0;
corr_avg = 0;
knn = 0;
svm = 0;

for user = 1:userNum
    fprintf("user %d\n",user)
    for testNum = 1:nTestdataPerUser
        test_filename = strcat(strcat(strcat(username_list{user},'_auth'),int2str(testNum)),'.csv'); % user_authN.csv file
        [test_result] = func_test_classification(test_filename, userNum);
        fprintf("test %d : %d, %d, %d, %d, %d\n", testNum, test_result(1), test_result(2), test_result(3), test_result(4), test_result(5));
        
        % accuracy
        if user == test_result(1)
            euclid = euclid + 1;
        end
        if user == test_result(2)
            corr_knn = corr_knn + 1;
        end
        if user == test_result(3)
            corr_avg = corr_avg + 1;
        end
        if user == test_result(4)
            knn = knn + 1;
        end
        if user == test_result(5)
            svm = svm + 1;
        end
        
        result = mode([test_result(2), test_result(3), test_result(5)]);
        fprintf("%d\n",result)
        
        confusion(user,result) = confusion(user,result) + 1;
    end
    fprintf("\n")
end

%% accuracy
euclid = euclid/(userNum*nTestdataPerUser)
corr_knn = corr_knn/(userNum*nTestdataPerUser)
corr_avg = corr_avg/(userNum*nTestdataPerUser)
knn = knn/(userNum*nTestdataPerUser)
svm = svm/(userNum*nTestdataPerUser)

confusion
confusion_matrix = confusion / nTestdataPerUser;
confusion_matrix   % accuracy matrix
