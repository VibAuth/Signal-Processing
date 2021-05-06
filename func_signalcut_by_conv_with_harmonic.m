function [x_slice, y_slice, z_slice, xSpec_wide, ySpec_wide, zSpec_wide] = func_signalcut_by_conv_with_harmonic (path, filename, signal, coarseInterval)
%% Parameter Setting
numVib = 3;         % ���� ����
vibLength = 1.44;   % ������ ����
rate = 1500;        % Sampling rate

% �������� ���� ������ ��� ���� filtering �뿪
lowFreqCut = 140;
highFreqCut = 190;

% Harmonic frequency �뿪�� �κ� �κ� ��ġ�� ���� filtering �뿪
lowFreqWide = 80;
highFreqWide = 700;

%% Read data and get Target for findpeaks
raw = csvread([path, filename],1,1);          % 1�� 1������ �б�

% Resampling
[data, t] = resample(raw(:, 5:7), raw(:, 1)/1000, rate);    % 5~7�� (xout, yout, zout)��, �� ���� /1000 �ؼ�, ������ rate�� resampling
data = data(rate * 1.65 :end - rate * 0.1, :);              % �յ� sleep time �ڸ���

% Highpass / Lowpass Filtering
[b, a] = butter(8, lowFreqCut / rate * 2, 'high');
hp_data = filtfilt(b, a, data);
[b, a] = butter(8, highFreqCut / rate * 2, 'low');
hp_data = filtfilt(b, a, hp_data);

hp_data = hp_data(rate* 0.03 : end - rate*0.02,:);  % �Ǿ��̶� �ǵڿ� Ƣ�� ���� ���ܼ� �ӽ÷� �߶��

% Normalize target(for findpeaks)
% Z axis
target = hp_data(:, 3);               % axisSetting�� ���� ���ϴ� ���� �����͸� target�� ����
target = target - mean(target);       % �� ��� - ��ü�� ���(����)
target = target ./ max(target);       % ���� / �ִ�����

% Y axis
target_x = hp_data(:, 1);               
target_x = target_x - mean(target_x);                 
target_x = target_x ./ max(target_x);

% X axis
target_y = hp_data(:, 2);               
target_y = target_y - mean(target_y);                 
target_y = target_y ./ max(target_y);

%% Findpeaks - Get each vibration starting points(peaks) using convol
convol = conv(target.^2, ones(1, 2160)');
temp = convol;

% Set thresholds for findpeaks
maxVal = prctile(temp,99);
minVal = prctile(temp,1);
threshold = (maxVal - minVal) * 0.1;

[pks, locs, w, p] = findpeaks(convol,rate,'MinPeakDistance', 2.5, 'MinPeakHeight', threshold);

% Find three peaks in original raw data time domain
locs_original = locs;

%% Get target for Harmonic frequency
% Highpass / Lowpass Filtering
[b, a] = butter(8, lowFreqWide / rate * 2, 'high');  % 80Hz
hp_data_wide = filtfilt(b, a, data);
[b, a] = butter(8, highFreqWide / rate * 2, 'low');  % 700Hz
hp_data_wide = filtfilt(b, a, hp_data_wide);

hp_data_wide = hp_data_wide(rate* 0.03 : end - rate*0.02,:);  % �Ǿ��̶� �ǵڿ� Ƣ�� ���� ���ܼ� �ӽ÷� �߶��

% Find target(for harmonic freq) and Normalize
% Z axis
target_wide = hp_data_wide(:, 3);               % axisSetting�� ���� ���ϴ� ���� �����͸� target�� ����
target_wide = target_wide - mean(target_wide);  % �� ���-��ü�� ���(����)
target_wide = target_wide ./ max(target_wide);  % ���� / �ִ�����

% Y axis
target_y_wide = hp_data_wide(:, 2);               
target_y_wide = target_y_wide - mean(target_y_wide);                 
target_y_wide = target_y_wide ./ max(target_y_wide);

% X axis
target_x_wide = hp_data_wide(:, 1);               
target_x_wide = target_x_wide - mean(target_x_wide);                 
target_x_wide = target_x_wide ./ max(target_x_wide);

%% Cut each signal(cExt) by the peaks, and FFT(cSpec)
% variables for Data slices & FFT spectrum
z_slice_w = zeros(numVib, coarseInterval);     % locs�� ��, rate*3�� �� ����� ����
zSpec_w = zeros(numVib, floor(coarseInterval/2));
x_slice_w = zeros(numVib, coarseInterval);     % locs�� ��, rate*3�� �� ����� ����
xSpec_w = zeros(numVib, floor(coarseInterval/2));
y_slice_w = zeros(numVib, coarseInterval);     % locs�� ��, rate*3�� �� ����� ����
ySpec_w = zeros(numVib, floor(coarseInterval/2));

for cnt = 1:numVib 
    % �� ���� ����(80-700Hz) �뿪�� FFT����� zSpec_w, ySpec_w, xSpec_w�� ����
    z_slice_w(cnt, :) = target_wide(round((locs_original(cnt) - vibLength - 0.1) * rate) + (1:coarseInterval));
    zSpec_w(cnt, :) = vibFFT(z_slice_w(cnt, :));
    
    y_slice_w(cnt, :) = target_y_wide(round((locs_original(cnt) - vibLength - 0.1) * rate) + (1:coarseInterval)); 
    ySpec_w(cnt, :) = vibFFT(y_slice_w(cnt, :));
    
    x_slice_w(cnt, :) = target_x_wide(round((locs_original(cnt) - vibLength - 0.1) * rate) + (1:coarseInterval)); 
    xSpec_w(cnt, :) = vibFFT(x_slice_w(cnt, :));
end


%% Concatenate frequency ranges using Harmonic Frequency
% Harmonic freq�� �ش��ϴ� 140-200 / 250-310 / 360-410 / 600-660 Hz�� �뿪�� ��ħ
freqStartIdx = [140, 250, 360, 600];
freqEndIdx   = [200, 310, 410, 660];

% ���� FFT ������� �ش��ϴ� ����, �� index(startIdx, endIdx)�� ���� �����ϱ� ���� array
fftStartIdx = [];
fftEndIdx = [];

concatFreqLen = 0; % harmonic frequency �������� ��ģ ������ ����
length_target = max(size(z_slice_w)); 

for i = 1: max(size(freqStartIdx))
    
    % �ش��ϴ� ���� �ε���(startIdx, endIdx)�� ã��
    startIdx = floor(length_target * freqStartIdx(1, i) / rate);
    endIdx = floor(length_target * freqEndIdx(1, i) / rate);
    
    % (80-700Hz �뿪 fft���) ���� ������ ���� �ε����� ���۰� �� ��ġ�� ����
    fftStartIdx = [fftStartIdx, startIdx];
    fftEndIdx = [fftEndIdx, endIdx];
    
    concatFreqLen = concatFreqLen + (endIdx - startIdx) + 1
end

%% Get final FFT results using harmonic frequency
zSpec_wide = zeros(numVib, concatFreqLen);
ySpec_wide = zeros(numVib, concatFreqLen);
xSpec_wide = zeros(numVib, concatFreqLen);

for cnt = 1 : numVib
    tmp_z = [];
    tmp_y = [];
    tmp_x = [];
    
    % 4���� ���ļ� range(140-200, 250-310, ...)�� �ش��ϴ� �� ��� ����(fftStartIdx:fftEndIdx)�� ���� ����Ʈ������ �����ؼ� ��ġ��
    for idx = 1: max(size(fftStartIdx))
        tmp_z = [tmp_z, zSpec_w(cnt, fftStartIdx(1, idx) : fftEndIdx(1,idx))];
        tmp_y = [tmp_y, ySpec_w(cnt, fftStartIdx(1, idx) : fftEndIdx(1,idx))];
        tmp_x = [tmp_x, xSpec_w(cnt, fftStartIdx(1, idx) : fftEndIdx(1,idx))];
    end
    
    % �������� Ƚ������ ��� ����
    zSpec_wide(cnt, :) = tmp_z;
    ySpec_wide(cnt, :) = tmp_y;
    xSpec_wide(cnt, :) = tmp_x;
end