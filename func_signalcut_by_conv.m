function [x_slice, y_slice, z_slice, xSpec, ySpec, zSpec] = func_signalcut_by_conv (path, filename, signal, coarseInterval)
%% Parameter Setting
numVib = 3;
vibLength = 1.44;       % 진동의 길이
rate = 1500;

lowFreqCut = 140;
highFreqCut = 190;
%% Read data and get Target
raw = csvread([path, filename], 1, 4);          % (1,4)열 가져옴

% Resampling
[data, t] = resample(raw(:, 2:4), raw(:, 1)/1000, rate);    % 2~4열(xout, yout, zout)을, 각 값에 /1000 해서, 지정한 rate로 resampling
data = data(rate * 1.65 :end - rate * 0.1, :);               % 앞뒤 sleep time 자르기

% Highpass / Lowpass Filtering
[b, a] = butter(8, lowFreqCut / rate * 2, 'high');
hp_data = filtfilt(b, a, data);
[b, a] = butter(8, highFreqCut / rate * 2, 'low');
hp_data = filtfilt(b, a, hp_data);

% Find target and Normalize
target = hp_data(:, 3);               % axisSetting에 의해 원하는 축의 데이터를 target에 대입
target = target - mean(target);                 % 각 요소-전체의 평균(편차)
target = target ./ max(target);                 % 편차 / 최대편차

target_x = hp_data(:, 1);               
target_x = target_x - mean(target_x);                 
target_x = target_x ./ max(target_x);

target_y = hp_data(:, 2);               
target_y = target_y - mean(target_y);                 
target_y = target_y ./ max(target_y);

%% Get Transfer Function and findpeaks

convol = conv(target.^2, ones(1, 2160)');

[pks, locs, w, p] = findpeaks(convol,rate,'MinPeakDistance', 2.5);
% [pks, locs, w, p] = findpeaks(convol,rate,'MinPeakDistance', 2.5, 'MinPeakHeight', threshold);

% Find three peaks in original raw data time domain
locs_original = locs;
% locs_original

%% Cut each signal(cExt) by the peaks, and FFT(cSpec)
z_slice = zeros(numVib, coarseInterval);     % locs개 행, rate*3개 열 영행렬 생성
zSpec = zeros(numVib, floor(coarseInterval/2));
x_slice = zeros(numVib, coarseInterval);     % locs개 행, rate*3개 열 영행렬 생성
xSpec = zeros(numVib, floor(coarseInterval/2));
y_slice = zeros(numVib, coarseInterval);     % locs개 행, rate*3개 열 영행렬 생성
ySpec = zeros(numVib, floor(coarseInterval/2));

num = 1;
if size(locs_original) <= 3
    num = 0;
end
    
for cnt = 1:numVib 
    z_slice(cnt, :) = target(round((locs_original(cnt+num) - vibLength - 0.15) * rate) + (1:coarseInterval));
    zSpec(cnt, :) = vibFFT(z_slice(cnt, :));
    x_slice(cnt, :) = target_x(round((locs_original(cnt+num) - vibLength - 0.15) * rate) + (1:coarseInterval)); 
    xSpec(cnt, :) = vibFFT(x_slice(cnt, :));
    y_slice(cnt, :) = target_y(round((locs_original(cnt+num) - vibLength - 0.15) * rate) + (1:coarseInterval)); 
    ySpec(cnt, :) = vibFFT(y_slice(cnt, :));
end

% %% Plotting
% figure('units', 'normalized','outerposition', [0.5 0 0.5 1]);  % empty left, empty bottom, width, height를 지정해 지정위치에 figure 띄우기
% subplot 211
% plot(target)
% title('Raw Data (after filtering)')
% xlim([0 max(size(target))]) 
% 
% subplot 212
% findpeaks(xcorr_data,'MinPeakHeight', threshold,  'MinPeakDistance', 700);
% title('Transfer')
% xlim([0 max(size(xcorr_data))]);
% 
% figure('units', 'normalized','outerposition', [0.1 0.3 0.4 0.5]);
% plot(z_slice.');
% xlim([0 max(size(z_slice))])
% figure('units', 'normalized','outerposition', [0.1 0.3 0.4 0.5]);
% plot(x_slice.');
% xlim([0 max(size(x_slice))])
% figure('units', 'normalized','outerposition', [0.1 0.3 0.4 0.5]);
% plot(y_slice.');
% xlim([0 max(size(y_slice))])