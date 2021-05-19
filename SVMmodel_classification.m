%% SVM Model
userNum = 6;
nDataPerUser = 12;
nTestDataPerUser = 1;
nTrainingDataPerUser = nDataPerUser-nTestDataPerUser;

% test data setting
path = './';
idx = 0;
for cnt=1:userNum
   corr_file_name = strcat(int2str(cnt),'.csv');
   corr_data = csvread([path, corr_file_name],0,0);
   [m, n] = size(corr_data);
   
   data(idx+1:idx+m,:) = corr_data;
   idx = idx + m;
end

for i = 1:userNum
    trainingAnswer((i - 1) * nTrainingDataPerUser + (1:nTrainingDataPerUser)) = i;
end

for i = 1:userNum
    testAnswer((i - 1) * nTestDataPerUser + (1:nTestDataPerUser)) = i;
end

testIndexes = combnk(1:nDataPerUser,nTestDataPerUser);

total_accuracy = 0;

for cnt = 1:length(testIndexes)
    thisTestIndexes = [];
    for cnt2 = 1:userNum
        thisTestIndexes((cnt2-1)*nTestDataPerUser+(1:nTestDataPerUser)) = testIndexes(cnt,:)+(cnt2-1)*nDataPerUser;
    end
    
    trainingData = [];
    testData = [];
    
    for cnt3 = 1:userNum*nDataPerUser
        isContinue = false;
        for idx = thisTestIndexes
            if cnt3 == idx
                testData = [testData; data(cnt3,:)];
                isContinue = true;
                break;
            end
        end
        
        if isContinue
            continue;
        end
        
        trainingData = [trainingData; data(cnt3,:)];
    end
   
    svm_model = fitcecoc(trainingData, trainingAnswer);
    model_result = testAnswer'== predict(svm_model, testData);
    accuracy = sum(model_result)/length(testAnswer);
    predictAnswer = predict(svm_model, testData);
    total_accuracy = total_accuracy + accuracy;
    fprintf('%d : svm model accuracy : %f \n', cnt, accuracy);
end


 fprintf('svm model accuracy : %f \n\n', total_accuracy/length(testIndexes));
 