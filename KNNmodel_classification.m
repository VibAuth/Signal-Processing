
%% KNN Model
% knn.m 이후 돌리기
nTestDataPerUser = 5;
nTrainingDataPerUser = nDataPerUser-nTestDataPerUser;
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
   
    knn_model = fitcknn(trainingData, trainingAnswer, 'NumNeighbors', nn_k);
    model_result = testAnswer'== predict(knn_model, testData);
    accuracy = sum(model_result)/length(testAnswer);
    thisTestIndexes
    total_accuracy = total_accuracy + accuracy;
    fprintf('%d : knn model accuracy : %f \n', cnt, accuracy);
end


 fprintf('knn model accuracy : %f \n\n', total_accuracy/length(testIndexes));




