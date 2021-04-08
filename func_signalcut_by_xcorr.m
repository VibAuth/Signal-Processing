function [x_slice, y_slice, z_slice, xSpec, ySpec, zSpec] = func_signalcut_by_xcorr (path, filename, signal, coarseInterval)
%% Parameter Setting
numVib = 3;
vibLength = 1.44;       % ������ ����
rate = 1500;

lowFreqCut = 80;
highFreqCut = 350;
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
target = hp_data(:, 3);               % axisSetting�� ���� ���ϴ� ���� �����͸� target�� ����
target = target - mean(target);                 % �� ���-��ü�� ���(����)
target = target ./ max(target);                 % ���� / �ִ�����

target_x = hp_data(:, 1);               
target_x = target_x - mean(target_x);                 
target_x = target_x ./ max(target_x);

target_y = hp_data(:, 2);               
target_y = target_y - mean(target_y);                 
target_y = target_y ./ max(target_y);

%% Get Transfer Function and findpeaks
% Find transfer by cross correlation between signal and data(target)
xcorr_data = xcorr(target, signal);

% Find largest three peaks in transfer
maxVal = prctile(xcorr_data,99);
minVal = prctile(xcorr_data, 1);
threshold = (maxVal - minVal) * 0.9;
% �ּҳ���(threshold)�� peak�� �ּҰŸ�(700)�� �����ؼ� ã��
[pks, locs, w, p] = findpeaks(xcorr_data,'MinPeakHeight', threshold,'MinPeakDistance', 700);  
%figure()
%findpeaks(xcorr_data,'MinPeakHeight', threshold,'MinPeakDistance', 700);  
% locs

% Find three peaks in original raw data time domain
locs_original = locs - max(size(target));
% locs_original

%% Cut each signal(cExt) by the peaks, and FFT(cSpec)
z_slice = zeros(numVib, coarseInterval);     % locs�� ��, rate*3�� �� ����� ����
zSpec = zeros(numVib, floor(coarseInterval/2));
x_slice = zeros(numVib, coarseInterval);     % locs�� ��, rate*3�� �� ����� ����
xSpec = zeros(numVib, floor(coarseInterval/2));
y_slice = zeros(numVib, coarseInterval);     % locs�� ��, rate*3�� �� ����� ����
ySpec = zeros(numVib, floor(coarseInterval/2));

for cnt = 1:numVib
    z_slice(cnt, :) = target(locs_original(cnt) + rate * 0.05 + (1:coarseInterval)); 
    zSpec(cnt, :) = vibFFT(z_slice(cnt, :));
    x_slice(cnt, :) = target_x(locs_original(cnt) + rate * 0.05 + (1:coarseInterval)); 
    xSpec(cnt, :) = vibFFT(x_slice(cnt, :));
    y_slice(cnt, :) = target_y(locs_original(cnt) + rate * 0.05 + (1:coarseInterval)); 
    ySpec(cnt, :) = vibFFT(y_slice(cnt, :));
end

% %% Plotting
% figure('units', 'normalized','outerposition', [0.5 0 0.5 1]);  % empty left, empty bottom, width, height�� ������ ������ġ�� figure ����
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