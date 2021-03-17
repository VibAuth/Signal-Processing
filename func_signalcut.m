function [cExt, cSpec] = func_signalcut (path, filename)

%% Parameter Setting
numVib = 3;

vibLength = 1.44;   % 진동이 울리는 길이
vibSectionLength = vibLength + 0.5; % 진동이 울리는 길이 + 0.5  앞뒤로 여유 둔 분석용 section 길이

%% Read data & Plotting
raw = csvread([path, filename], 1, 4);          % (1,4)부터 가져옴

rate = 1000;
[data, t] = resample(raw(:, 2:4), raw(:, 1)/1000, rate);    % 2~4열(xout_scaled,you_scaled,zout_scaled)를, 각 t열 값에 /1000 해서? 1000hz로 resampling
data = data(rate * 1.65:end - rate * 0.1, :);               % 1.5초 sleep 이후 pilot chirp

hp_data = highpass(data, 100, rate);               % highpass filtering을 진행
hp_data = hp_data(rate* 0.03 : end - rate*0.02,:);  % 맨앞이랑 맨뒤에 튀는 값이 생겨서 임시로 잘라둠

% target에 highpass filtering을 거친 후의 hp_data를 대입
target = hp_data(:, 3);             % zout_scaled
target = target - mean(target);     % 각 요소-전체의 평균(편차)
target = target ./ max(target);     % 편차 / 최대편차

% highpass filtering 진행한 이후, accel vector의 크기(x*x + y*y + z*z)를 값으로 갖는 벡터(vecSize) 생성
vecSize = zeros(max(size(target)), 1);
for i = 1 : max(size(target))
    vecSize(i,1) = hp_data(i,1)*hp_data(i,1) + hp_data(i,2)*hp_data(i,2) + hp_data(i,3)*hp_data(i,3);
end

% vecSize에서 findpeak을 통해 trigger vibration의 위치를 찾아 loc에 저장
maxVal = prctile(vecSize, 99);
minVal = prctile(vecSize, 1);
threshold = (maxVal - minVal) * 0.7;
[pks, locs, w, p] = findpeaks(vecSize, 'MinPeakHeight', threshold);   % peak가 나타나는 인덱스

 count = 1;
while p(count) > maxVal
    count = count + 1;
end

coarseInterval = rate * vibSectionLength;
cExt = zeros(numVib, coarseInterval);     % locs개 행, rate*3개 열 영행렬 생성
cSpec = zeros(numVib, coarseInterval/2);

for cnt = 1:numVib
    cExt(cnt, :) = target(locs(count) + rate * 1.4 + (cnt-1) * rate * (vibLength + 1) + (1:coarseInterval)); 
    cSpec(cnt, :) = vibFFT(cExt(cnt, :));
end

end