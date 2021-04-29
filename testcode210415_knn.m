
% load_data.m 이후 돌리세요!
userNum = 3;
nDataPerUser = 45;
data = avg_all_axis;

nData = nDataPerUser * userNum; % 총 데이터 개수
class = zeros(1, nData); % 옳은 클래스 저장
for cnt = 1:userNum
    class((cnt - 1) * nDataPerUser + (1:nDataPerUser)) = cnt;    %class영행렬에 1...1 2..2 3...3 이렇게 숫자마다 nDataPerUser개 만큼 넣기 -> 데이터 마다 클래스 마크 
end

corrData = corr(data');

corrResult.raw = zeros(nData, nData - 1);
corrResult.summary = zeros(nData,2);
corrResult.summary(:,1) = class;
corrResult.summary2 = zeros(nData, 3);
corrResult.summary2(:,1) = class;

euclidDist.dist = zeros(nData,nData);   % 거리 계산
euclidDist.raw = zeros(nData,nData);    % 거리를 오름차순으로 소팅해서 그 거리에 있는 클래스 담는 곳
euclidDist.summary = zeros(nData,2);    % summary 1열은 정답, 2열은 knn 답
euclidDist.summary(:,1)=class;

%% data간 유클리드 거리 계산
for cnt3 = 1:nData
        for cnt4 = 1:nData
            euclidDist.dist(cnt3,cnt4) = pdist2(data(cnt3,:),data(cnt4,:),'euclidean');     
        end
end

%% KNN operation
nn_k = 3;
for cnt = 1:nData       % Users data 개수 만큼
    
    if cnt == 1     %range에 1~nData 중 cnt 빼고 다 저장
        range = 2:nData;
    elseif cnt == nData    
        range = 1:nData - 1;
    else
        range = [1:cnt - 1, cnt + 1:nData];
    end
    
    curData = corrData(cnt, range);     % cnt번째 data와 나머지의 corr값들 
    curClass = class(range);            % 나머지의 클래스
    
    %% 거리 가까운 데이터 knn
    curDist = euclidDist.dist(cnt, :);
    [~, idx_euclid] = sort(curDist);                % idx_euclid에 curDist의 index값들이 cnt랑 가까운 애들부터 쫙 나옴. 
    euclidDist.raw(cnt,:) = class(idx_euclid);      % 그 인덱스들의 class를 저장
    
    nn = euclidDist.raw(cnt,2:nn_k+1);              % 1번은 자기자신이므로 2부터 nn_k개 가져와서 nn에 저장
    euclidDist.summary(cnt,2) = mode(nn);           % mode: 최빈값 함수. nn에서 가장 많이 나온 클래스를 cnt 데이터의 knn 답으로 함.
    
    %% 유사도 높은 클래스 구하기 knn & 평균
    [~, idx] = sort(curData, 'descend');            % corr내림차순 소팅; idx에 cnt와 유사도 높은 순서로 인덱스 넣음
    corrResult.raw(cnt, :) = curClass(idx);             % result.raw에 class 입력; cnt번째 데이터와 유사도가 높은 순서로 클래스 입력함.
    
    nn = corrResult.raw(cnt,2:nn_k+1);
    corrResult.summary(cnt,2) = mode(nn);
    
    for cnt2 = 1:userNum
        tmp = mean(corrData(cnt, (cnt2 - 1) * nDataPerUser + (1:nDataPerUser)));    % cnt번째 데이터에 대한 각 class 마다의 corr 평균
        
        if corrResult.summary2(cnt, 3) < tmp     % cnt번째 데이터와 유사도가 가장 높은 클래스와 그 corr 평균 입력; cnt번째 데이터가 corr으로 어떤 데이터인지 판단. 
            corrResult.summary2(cnt, 3) = tmp;       
            corrResult.summary2(cnt, 2) = cnt2;
        end
    end
end

%% Accuracy
% 실제 class와 비교하여 summary가 실제 클래스를 맞추면 1, 틀리면 0; sum:클래스를 맞춘 데이터의 개수
fprintf('<< euclid distance, k=%d >> \n',nn_k);
result = euclidDist.summary(:,2)'== class;
fprintf('user1: %d / %d \n',sum(result(1:nDataPerUser)), nDataPerUser);
fprintf('user2: %d / %d \n',sum(result(nDataPerUser+1:nDataPerUser*2)), nDataPerUser);
fprintf('user3: %d / %d \n', sum(result(nDataPerUser*2+1:nDataPerUser*3)), nDataPerUser);
fprintf('accuracy : %f \n\n', sum(result)/nData );

fprintf('<< correlation knn, k=%d >> \n',nn_k);
result = corrResult.summary(:,2)'== class;
fprintf('user1: %d / %d \n',sum(result(1:nDataPerUser)), nDataPerUser);
fprintf('user2: %d / %d \n',sum(result(nDataPerUser+1:nDataPerUser*2)), nDataPerUser);
fprintf('user3: %d / %d \n', sum(result(nDataPerUser*2+1:nDataPerUser*3)), nDataPerUser);
fprintf('accuracy : %f \n\n', sum(result)/nData );

fprintf('<< correlation average >> \n');
result = corrResult.summary2(:, 2)' == class;
fprintf('user1: %d / %d \n',sum(result(1:nDataPerUser)), nDataPerUser);
fprintf('user2: %d / %d \n',sum(result(nDataPerUser+1:nDataPerUser*2)), nDataPerUser);
fprintf('user3: %d / %d \n', sum(result(nDataPerUser*2+1:nDataPerUser*3)), nDataPerUser);
fprintf('accuracy : %f \n\n', sum(result)/nData );


% %% KNN Model
% i = 1;
% trainingData = [];
% for cnt = 1:9
%     trainingData = [trainingData; data(i:i+9,:)];
%     i = i+15;
% end
% for i = 1:3
%     trainingAnswer((i - 1) * 30 + (1:30)) = i;
% end
% 
% i = 11;
% testData = [];
% for cnt = 1:9
%     testData = [testData; data(i:i+4,:)];
%     i = i+15;
% end
% for i = 1:3
%     testAnswer((i - 1) * 15 + (1:15)) = i;
% end
% 
% knn_model = fitcknn(trainingData, trainingAnswer, 'NumNeighbors', nn_k);
% model_result = testAnswer'== predict(knn_model, testData);
% accuracy = sum(model_result)/length(testAnswer);
% fprintf('knn model accuracy : %f \n\n', accuracy);
