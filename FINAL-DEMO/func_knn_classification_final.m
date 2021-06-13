function [euclid_knn_answer, corr_knn_answer, corr_avg_answer, isAttack]=func_knn_classification_final (userNum, nDataPerUser, data, nn_k)

nData = (nDataPerUser * userNum) + 1; % 총 데이터 개수
class = zeros(1, nData); % 옳은 클래스 저장
for cnt = 1:userNum
    class((cnt - 1) * nDataPerUser + (2:nDataPerUser+1)) = cnt;    %class영행렬에 1...1 2..2 3...3 이렇게 숫자마다 nDataPerUser개 만큼 넣기 -> 데이터 마다 클래스 마크 
end
corrData = corr(data');

corrResult.raw = zeros(nData, nData - 1);
corrResult.summary = zeros(nData,2);
corrResult.summary(:,1) = class;
corrResult.summary2 = zeros(nData, 3);
corrResult.summary2(:,1) = class;

euclidDist.dist = zeros(1,nData);   % 거리 계산
euclidDist.raw = zeros(1,nData);    % 거리를 오름차순으로 소팅해서 그 거리에 있는 클래스 담는 곳
euclidDist.summary = zeros(nData,2);    % summary 1열은 정답, 2열은 knn 답
euclidDist.summary(:,1) = class;

%% data간 유클리드 거리 계산
 for cnt4 = 1:nData
     euclidDist.dist(1,cnt4) = pdist2(data(1,:),data(cnt4,:),'euclidean');     
 end
 euclidDist.dist(1,:) = normalize(euclidDist.dist(1,:), 'range');

%% KNN operation
range = 2:nData;
curData = corrData(1, range);     % cnt번째 data와 나머지의 corr값들 
curClass = class(range);            % 나머지의 클래스

%% 거리 가까운 k개 데이터 (knn)
curDist = euclidDist.dist(1, :);
[sorted_curDist, idx_euclid] = sort(curDist);                % idx_euclid에 curDist의 index값들이 cnt랑 가까운 애들부터 쫙 나옴. 
euclidDist.raw(1,:) = class(idx_euclid);      % 그 인덱스들의 class를 저장

nn = euclidDist.raw(1,2:nn_k+1);              % 1번은 자기자신이므로 2부터 nn_k개 가져와서 nn에 저장
euclidDist.summary(1,2) = mode(nn);           % mode: 최빈값 함수. nn에서 가장 많이 나온 클래스를 cnt 데이터의 knn 답으로 함.
euclid_knn_answer = euclidDist.summary(1,2);

k_dist_avg = sum(sorted_curDist(2:nn_k+1))/nn_k;

 %% 유사도 높은 k개 클래스 구하기 (knn)
[sorted_curData, idx] = sort(curData, 'descend');            % corr내림차순 소팅; idx에 cnt와 유사도 높은 순서로 인덱스 넣음
corrResult.raw(1, :) = curClass(idx);             % result.raw에 class 입력; cnt번째 데이터와 유사도가 높은 순서로 클래스 입력함.
nn = corrResult.raw(1,1:nn_k);
corrResult.summary(1,2) = mode(nn);
corr_knn_answer = corrResult.summary(1,2);

k_corr_avg = sum(sorted_curData(1:nn_k))/nn_k;

%% 유사도 평균 가장 높은 클래스 선택
for cnt2 = 1:userNum
    tmp = mean(corrData(1, (cnt2 - 1) * nDataPerUser + (2:nDataPerUser+1)));    % cnt번째 데이터에 대한 각 class 마다의 corr 평균
    if corrResult.summary2(1, 3) < tmp     % cnt번째 데이터와 유사도가 가장 높은 클래스와 그 corr 평균 입력; cnt번째 데이터가 corr으로 어떤 데이터인지 판단. 
        corrResult.summary2(1, 3) = tmp;       
        corrResult.summary2(1, 2) = cnt2;
    end
end
corr_avg_answer = corrResult.summary2(1, 2);

highest_corr_val = corrResult.summary2(1,3);


%% attacker 구분

fprintf("k_dist_avg %f    \n", k_dist_avg);

registeredData = corrData(2:end,2:end);
registered_corr_avg = 0;
for cnt = 1:userNum
    temp = registeredData(1 + (cnt-1)*nDataPerUser:12 + (cnt-1)*nDataPerUser,1 + (cnt-1)*nDataPerUser:12 + (cnt-1)*nDataPerUser);
    registered_corr_avg = registered_corr_avg + sum(temp, 'all')/numel(temp);
end
registered_corr_avg = registered_corr_avg/userNum;



top5prc = prctile(registeredData, 95);
top5prc_avg = sum(top5prc, 'all')/numel(top5prc);



isAttack = 0;
if k_dist_avg > 0.2
    isAttack = isAttack + 1;
end
if k_corr_avg < top5prc_avg + 0.01
    isAttack = isAttack + 1;
end
if highest_corr_val < registered_corr_avg
    isAttack = isAttack + 1;
end
    
%     fprintf("k_corr_avg %f    ", k_corr_avg);
%     fprintf("top 5 percent avg %f    \n", top5prc_avg);
%     fprintf("highest_corr_val %f    ", highest_corr_val);
%     fprintf("registered_corr_avg %f    \n", registered_corr_avg);


if isAttack >= 2
    isAttack = 1;
else
    isAttack = 0;
end

% fprintf("isAttack : %d    ",isAttack);

