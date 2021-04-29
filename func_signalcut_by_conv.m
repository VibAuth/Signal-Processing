function [x_slice, y_slice, z_slice, xSpec, ySpec, zSpec] = func_signalcut_by_conv (path, filename, signal, coarseInterval)
%% Parameter Setting
numVib = 3;
vibLength = 1.44;       % ������ ����
rate = 1500;

lowFreqCut = 140;
highFreqCut = 190;
%% Read data and get Target
raw = csvread([path, filename],1,1);          % 1�� 1������ �б�

% Resampling
[data, t] = resample(raw(:, 5:7), raw(:, 1)/1000, rate);    % 5~7��(xout, yout, zout)��, �� ���� /1000 �ؼ�, ������ rate�� resampling
data = data(rate * 1.65 :end - rate * 0.1, :);               % �յ� sleep time �ڸ���

% Highpass / Lowpass Filtering
[b, a] = butter(8, lowFreqCut / rate * 2, 'high');
hp_data = filtfilt(b, a, data);
[b, a] = butter(8, highFreqCut / rate * 2, 'low');
hp_data = filtfilt(b, a, hp_data);

hp_data = hp_data(rate* 0.03 : end - rate*0.02,:);  % �Ǿ��̶� �ǵڿ� Ƣ�� ���� ���ܼ� �ӽ÷� �߶��

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
convol = conv(target.^2, ones(1, 2500)');

% Find largest three peaks in transfer
maxVal = prctile(convol,99);
minVal = prctile(convol, 1);
threshold = (maxVal - minVal) * 0.1;

% [pks, locs, w, p] = findpeaks(convol,rate,'MinPeakDistance', 2);
[pks, locs, w, p] = findpeaks(convol,rate,'MinPeakDistance', 2.5, 'MinPeakHeight', threshold);
% figure();
% findpeaks(convol,rate,'MinPeakDistance', 2.5, 'MinPeakHeight', threshold)

% Find three peaks in original raw data time domain
locs_original = locs;
% locs_original

%% Cut each signal(cExt) by the peaks, and FFT(cSpec)
z_slice = zeros(numVib, coarseInterval);     % locs�� ��, rate*3�� �� ����� ����
zSpec = zeros(numVib, floor(coarseInterval/2));
x_slice = zeros(numVib, coarseInterval);     % locs�� ��, rate*3�� �� ����� ����
xSpec = zeros(numVib, floor(coarseInterval/2));
y_slice = zeros(numVib, coarseInterval);     % locs�� ��, rate*3�� �� ����� ����
ySpec = zeros(numVib, floor(coarseInterval/2));

for cnt = 1:numVib 
    z_slice(cnt, :) = target(round((locs_original(cnt) - vibLength - 0.1) * rate) + (1:coarseInterval));
%     plot(z_slice(cnt,:))
%     hold on;
    zSpec(cnt, :) = vibFFT(z_slice(cnt, :));
    x_slice(cnt, :) = target_x(round((locs_original(cnt) - vibLength - 0.1) * rate) + (1:coarseInterval)); 
    xSpec(cnt, :) = vibFFT(x_slice(cnt, :));
    y_slice(cnt, :) = target_y(round((locs_original(cnt) - vibLength - 0.1) * rate) + (1:coarseInterval)); 
    ySpec(cnt, :) = vibFFT(y_slice(cnt, :));
end