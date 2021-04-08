function [cExt, cSpec] = func_signalcut_by_xcorr (path, filename, signal, axisSetting, coarseInterval)
%% Parameter Setting
numVib = 3;
vibLength = 1.44;       % 진동의 길이
rate = 1500;

lowFreqCut = 150;
highFreqCut = 190;
%% Read data and get Target
raw = csvread([path, filename], 1, 4);          % (1,4)열 가져옴

% Resampling
[data, t] = resample(raw(:, 2:4), raw(:, 1)/1000, rate);    % 2~4열(xout, yout, zout)을, 각 값에 /1000 해서, 지정한 rate로 resampling
data = data(rate * 2.8 :end - rate * 0.1, :);               % 앞뒤 sleep time 자르기

% Highpass / Lowpass Filtering
[b, a] = butter(8, lowFreqCut / rate * 2, 'high');
hp_data = filtfilt(b, a, data);
[b, a] = butter(8, highFreqCut / rate * 2, 'low');
hp_data = filtfilt(b, a, hp_data);

hp_data = hp_data(rate* 0.03 : end - rate*0.02,:);  % 앞뒤에 튀는 값 임시로 잘라둠

% Find target and Normalize
target = hp_data(:, axisSetting);               % axisSetting에 의해 원하는 축의 데이터를 target에 대입
target = target - mean(target);                 % 각 요소-전체의 평균(편차)
target = target ./ max(target);                 % 편차 / 최대편차

%% Get Transfer Function and findpeaks
% Find transfer by cross correlation between signal and data(target)
xcorr_data = xcorr(target, signal);

% Find largest three peaks in transfer
maxVal = prctile(xcorr_data,99);
minVal = prctile(xcorr_data, 1);
threshold = (maxVal - minVal) * 0.9;
% 최소높이(threshold)와 peak간 최소거리(700)을 지정해서 찾음
[pks, locs, w, p] = findpeaks(xcorr_data,'MinPeakHeight', threshold,'MinPeakDistance', 700);  
% figure()
% findpeaks(xcorr_data,'MinPeakHeight', threshold,'MinPeakDistance', 700);  
locs

% Find three peaks in original raw data time domain
locs_original = locs - max(size(target));
locs_original

%% Cut each signal(cExt) by the peaks, and FFT(cSpec)
cExt = zeros(numVib, coarseInterval);     % locs개 행, rate*3개 열 영행렬 생성
cSpec = zeros(numVib, floor(coarseInterval/2));

for cnt = 1:numVib
    cExt(cnt, :) = target(locs_original(cnt) + rate * 0.05 + (1:coarseInterval)); 
    cSpec(cnt, :) = vibFFT(cExt(cnt, :));
end

%% Plotting
figure('units', 'normalized','outerposition', [0.5 0 0.5 1]);  % empty left, empty bottom, width, height를 지정해 지정위치에 figure 띄우기
subplot 211
plot(target)
title('Raw Data (after filtering)')
xlim([0 max(size(target))]) 

subplot 212
findpeaks(xcorr_data,'MinPeakHeight', threshold,  'MinPeakDistance', 700);
title('Transfer')
xlim([0 max(size(xcorr_data))]);

figure('units', 'normalized','outerposition', [0.1 0.3 0.4 0.5]);
plot(cExt.');
xlim([0 max(size(cExt))])