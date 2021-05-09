function [check, xSpec_wide, ySpec_wide, zSpec_wide] = func_signalcut_demo (path, filename, coarseInterval, numVib)
%% Parameter Setting
vibLength = 1.44;   % 진동의 길이
rate = 1500;        % Sampling rate
check = 1;          % 예외 처리 true

% 진동패턴 시작 기준점 잡기 위한 filtering 대역
lowFreqCut = 140;
highFreqCut = 190;

% Harmonic frequency 대역을 부분 부분 합치기 이전 filtering 대역
lowFreqWide = 80;
highFreqWide = 700;

%% Read data and get Target for findpeaks
raw = csvread([path, filename],1,1);          % 1행 1열부터 읽기

% Resampling
[data, t] = resample(raw(:, 5:7), raw(:, 1)/1000, rate);    % 5~7열 (xout, yout, zout)을, 각 값에 /1000 해서, 지정한 rate로 resampling

data = data(rate * 0.25 :end - rate * 0.1, :);      % 앞뒤 sleep time 자르기

% Highpass / Lowpass Filtering
[b, a] = butter(8, lowFreqCut / rate * 2, 'high');
hp_data = filtfilt(b, a, data);
[b, a] = butter(8, highFreqCut / rate * 2, 'low');
hp_data = filtfilt(b, a, hp_data);

hp_data = hp_data(rate* 0.03 : end - rate*0.02,:);  % 맨앞이랑 맨뒤에 튀는 값이 생겨서 임시로 잘라둠

% Normalize target(for findpeaks)
% Z axis
target = hp_data(:, 3);               % axisSetting에 의해 원하는 축의 데이터를 target에 대입
target = target - mean(target);       % 각 요소 - 전체의 평균(편차)
target = target ./ max(target);       % 편차 / 최대편차

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

if numVib > 1
    [pks, locs, w, p] = findpeaks(convol,rate,'MinPeakDistance', 2.5, 'MinPeakHeight', threshold);
else
    [pks, locs, w, p] = findpeaks(convol,rate,'MinPeakDistance', 1.5, 'MinPeakHeight', threshold);
end

% Find three peaks in original raw data time domain
locs_original = locs;

% 예외 처리 false
if length(locs_original) < 3 && numVib > 1
    check = 0;
end

%% Get target for Harmonic frequency
% Highpass / Lowpass Filtering
[b, a] = butter(8, lowFreqWide / rate * 2, 'high');  % 80Hz
hp_data_wide = filtfilt(b, a, data);
[b, a] = butter(8, highFreqWide / rate * 2, 'low');  % 700Hz
hp_data_wide = filtfilt(b, a, hp_data_wide);

hp_data_wide = hp_data_wide(rate* 0.03 : end - rate*0.02,:);  % 맨앞이랑 맨뒤에 튀는 값이 생겨서 임시로 잘라둠

% Find target(for harmonic freq) and Normalize
% Z axis
target_wide = hp_data_wide(:, 3);               % axisSetting에 의해 원하는 축의 데이터를 target에 대입
target_wide = target_wide - mean(target_wide);  % 각 요소-전체의 평균(편차)
target_wide = target_wide ./ max(target_wide);  % 편차 / 최대편차

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
z_slice_w = zeros(numVib, coarseInterval);     % locs개 행, rate*3개 열 영행렬 생성
zSpec_w = zeros(numVib, floor(coarseInterval/2));
x_slice_w = zeros(numVib, coarseInterval);     % locs개 행, rate*3개 열 영행렬 생성
xSpec_w = zeros(numVib, floor(coarseInterval/2));
y_slice_w = zeros(numVib, coarseInterval);     % locs개 행, rate*3개 열 영행렬 생성
ySpec_w = zeros(numVib, floor(coarseInterval/2));
figure();
if check
    for cnt = 1:numVib
        % 더 넓은 구간(80-700Hz) 대역의 FFT결과를 zSpec_w, ySpec_w, xSpec_w에 저장
        z_slice_w(cnt, :) = target_wide(round((locs_original(cnt) - vibLength - 0.15) * rate) + (1:coarseInterval));
        zSpec_w(cnt, :) = vibFFT(z_slice_w(cnt, :));
        plot(z_slice_w(cnt,:))
        hold on;
        y_slice_w(cnt, :) = target_y_wide(round((locs_original(cnt) - vibLength - 0.15) * rate) + (1:coarseInterval)); 
        ySpec_w(cnt, :) = vibFFT(y_slice_w(cnt, :));

        x_slice_w(cnt, :) = target_x_wide(round((locs_original(cnt) - vibLength - 0.15) * rate) + (1:coarseInterval)); 
        xSpec_w(cnt, :) = vibFFT(x_slice_w(cnt, :));
    end
end

%% Concatenate frequency ranges using Harmonic Frequency
% Harmonic freq에 해당하는 140-200 / 250-310 / 360-410 / 600-660 Hz의 대역을 합침
freqStartIdx = [140, 250, 360, 600];
freqEndIdx   = [200, 310, 410, 660];

% 실제 FFT 결과에서 해당하는 시작, 끝 index(startIdx, endIdx)를 구해 저장하기 위한 array
fftStartIdx = [];
fftEndIdx = [];

concatFreqLen = 0; % harmonic frequency 범위들을 합친 이후의 길이
length_target = max(size(z_slice_w)); 

for i = 1: max(size(freqStartIdx))
    
    % 해당하는 실제 인덱스(startIdx, endIdx)를 찾기
    startIdx = floor(length_target * freqStartIdx(1, i) / rate);
    endIdx = floor(length_target * freqEndIdx(1, i) / rate);
    
    % (80-700Hz 대역 fft결과) 에서 추출한 실제 인덱스의 시작과 끝 위치를 저장
    fftStartIdx = [fftStartIdx, startIdx];
    fftEndIdx = [fftEndIdx, endIdx];
    
    concatFreqLen = concatFreqLen + (endIdx - startIdx) + 1;
end

%% Get final FFT results using harmonic frequency
zSpec_wide = zeros(numVib, concatFreqLen);
ySpec_wide = zeros(numVib, concatFreqLen);
xSpec_wide = zeros(numVib, concatFreqLen);

if check
    for cnt = 1 : numVib
        tmp_z = [];
        tmp_y = [];
        tmp_x = [];

        % 4개의 주파수 range(140-200, 250-310, ...)에 해당하는 각 결과 범위(fftStartIdx:fftEndIdx)만 기존 스펙트럼에서 추출해서 합치기
        for idx = 1: max(size(fftStartIdx))
            tmp_z = [tmp_z, zSpec_w(cnt, fftStartIdx(1, idx) : fftEndIdx(1,idx))];
            tmp_y = [tmp_y, ySpec_w(cnt, fftStartIdx(1, idx) : fftEndIdx(1,idx))];
            tmp_x = [tmp_x, xSpec_w(cnt, fftStartIdx(1, idx) : fftEndIdx(1,idx))];
        end

        % 진동패턴 횟수별로 결과 저장
        zSpec_wide(cnt, :) = tmp_z;
        ySpec_wide(cnt, :) = tmp_y;
        xSpec_wide(cnt, :) = tmp_x;
    end
end
