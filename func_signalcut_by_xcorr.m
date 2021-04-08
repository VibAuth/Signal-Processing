function [cExt, cSpec] = func_signalcut_by_xcorr (path, filename, signal, axisSetting, coarseInterval)
%% Parameter Setting
numVib = 3;
vibLength = 1.44;       % ������ ����
rate = 1500;

lowFreqCut = 150;
highFreqCut = 190;
%% Read data and get Target
raw = csvread([path, filename], 1, 4);          % (1,4)�� ������

% Resampling
[data, t] = resample(raw(:, 2:4), raw(:, 1)/1000, rate);    % 2~4��(xout, yout, zout)��, �� ���� /1000 �ؼ�, ������ rate�� resampling
data = data(rate * 2.8 :end - rate * 0.1, :);               % �յ� sleep time �ڸ���

% Highpass / Lowpass Filtering
[b, a] = butter(8, lowFreqCut / rate * 2, 'high');
hp_data = filtfilt(b, a, data);
[b, a] = butter(8, highFreqCut / rate * 2, 'low');
hp_data = filtfilt(b, a, hp_data);

hp_data = hp_data(rate* 0.03 : end - rate*0.02,:);  % �յڿ� Ƣ�� �� �ӽ÷� �߶��

% Find target and Normalize
target = hp_data(:, axisSetting);               % axisSetting�� ���� ���ϴ� ���� �����͸� target�� ����
target = target - mean(target);                 % �� ���-��ü�� ���(����)
target = target ./ max(target);                 % ���� / �ִ�����

%% Get Transfer Function and findpeaks
% Find transfer by cross correlation between signal and data(target)
xcorr_data = xcorr(target, signal);

% Find largest three peaks in transfer
maxVal = prctile(xcorr_data,99);
minVal = prctile(xcorr_data, 1);
threshold = (maxVal - minVal) * 0.9;
% �ּҳ���(threshold)�� peak�� �ּҰŸ�(700)�� �����ؼ� ã��
[pks, locs, w, p] = findpeaks(xcorr_data,'MinPeakHeight', threshold,'MinPeakDistance', 700);  
% figure()
% findpeaks(xcorr_data,'MinPeakHeight', threshold,'MinPeakDistance', 700);  
locs

% Find three peaks in original raw data time domain
locs_original = locs - max(size(target));
locs_original

%% Cut each signal(cExt) by the peaks, and FFT(cSpec)
cExt = zeros(numVib, coarseInterval);     % locs�� ��, rate*3�� �� ����� ����
cSpec = zeros(numVib, floor(coarseInterval/2));

for cnt = 1:numVib
    cExt(cnt, :) = target(locs_original(cnt) + rate * 0.05 + (1:coarseInterval)); 
    cSpec(cnt, :) = vibFFT(cExt(cnt, :));
end

%% Plotting
figure('units', 'normalized','outerposition', [0.5 0 0.5 1]);  % empty left, empty bottom, width, height�� ������ ������ġ�� figure ����
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