function [check, xSpec_wide, ySpec_wide, zSpec_wide] = func_signalcut_regi_final (path, filename, coarseInterval, numVib)
%% Parameter Setting
vibLength = 1.44;   % 진동의 길이
rate = 1500;        % Sampling rate
check = 1;          % 예외 처리 true

minW = 0.2;         % 가장 작은 축 가중치
medW = 0.3;         % 중간 축 가중치
maxW = 0.5;         % 가장 우세한 축 가중치

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

%% Highpass / Lowpass Filtering
[b, a] = butter(8, lowFreqCut / rate * 2, 'high');
hp_data = filtfilt(b, a, data);
[b, a] = butter(8, highFreqCut / rate * 2, 'low');
hp_data = filtfilt(b, a, hp_data);

hp_data = hp_data(rate* 0.03 : end - rate*0.02,:);  % 맨앞이랑 맨뒤에 튀는 값이 생겨서 임시로 잘라둠

%% Normalize target(for findpeaks)
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
convol_x = conv(target_x.^2, ones(1, 2160)');
convol_y = conv(target_y.^2, ones(1, 2160)');
convol_z = conv(target.^2, ones(1, 2160)');

%%HS debug
% figure('units', 'normalized','outerposition', [0 0.1 0.6 0.35]);
% plot(convol_x);
% disp("X mean: " + mean(convol_x));
% 
% hold on
% plot(convol_y);
% disp("Y mean: " + mean(convol_y));
% 
% hold on
% plot(convol_z);
% disp("Z mean: " + mean(convol_z));
% legend("convol_x", "convol_y", "convol_z");

% convol을 진행한 3개 축의 평균값을 구하기
meanX = mean(convol_x);
meanY = mean(convol_y);
meanZ = mean(convol_z);

meanVal = [meanX, meanY, meanZ];

% 가중치 설정하기 (일단 중간 weight로 설정 후, 최대, 최솟값에 따라 max,min weight 설정)
xWeight = medW;
yWeight = medW;
zWeight = medW;

[M, maxIdx] = max(meanVal);
[m, minIdx] = min(meanVal);

if maxIdx == 1
    xWeight = maxW;
elseif maxIdx == 2
    yWeight = maxW;
else
    zWeight = maxW;
end

if minIdx == 1
    xWeight = minW;
elseif minIdx == 2
    yWeight = minW;
else
    zWeight = minW;
end

%% Add convol. x, y, z axis
temp = convol_x + convol_y + convol_z;
% 
% hold on
% plot(temp);
% legend('x axis', 'y axis', 'z axis', 'ALL ADD')

%% Smooth data with window size of 300 for findpeaks
temp = smoothdata(temp, 'gaussian', 300);

%% Set thresholds for findpeaks
maxVal = prctile(temp,99);
minVal = prctile(temp,1);
threshold = (maxVal - minVal) * 0.3;

if numVib > 1
    [pks, locs, w, p] = findpeaks(temp,rate,'MinPeakDistance', 2.5, 'MinPeakHeight', threshold);
%     findpeaks(temp,rate,'MinPeakDistance', 2.5, 'MinPeakHeight', threshold);
else
    [pks, locs, w, p] = findpeaks(temp,rate,'MinPeakDistance', 1.5, 'MinPeakHeight', threshold);
end

%% Find three peaks in original raw data time domain
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

%% Find target(for harmonic freq) and Normalize
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

if check
    for cnt = 1:numVib
        % 더 넓은 구간(80-700Hz) 대역의 FFT결과를 zSpec_w, ySpec_w, xSpec_w에 저장
        z_slice_w(cnt, :) = target_wide(round((locs_original(cnt) - vibLength - 0.15) * rate) + (1:coarseInterval));
        zSpec_w(cnt, :) = vibFFT(z_slice_w(cnt, :));

        y_slice_w(cnt, :) = target_y_wide(round((locs_original(cnt) - vibLength - 0.15) * rate) + (1:coarseInterval)); 
        ySpec_w(cnt, :) = vibFFT(y_slice_w(cnt, :));

        x_slice_w(cnt, :) = target_x_wide(round((locs_original(cnt) - vibLength - 0.15) * rate) + (1:coarseInterval)); 
        xSpec_w(cnt, :) = vibFFT(x_slice_w(cnt, :));
    end
end

%% Find weight for each three slice
% 1st slice convol.
convol_x1 = conv(x_slice_w(1,:).^2, ones(1, 2160)');
convol_y1 = conv(y_slice_w(1,:).^2, ones(1, 2160)');
convol_z1 = conv(z_slice_w(1,:).^2, ones(1, 2160)');
meanVal1 = [mean(convol_x1), mean(convol_y1), mean(convol_z1)];


% 2nd slice convol.
convol_x2 = conv(x_slice_w(2,:).^2, ones(1, 2160)');
convol_y2 = conv(y_slice_w(2,:).^2, ones(1, 2160)');
convol_z2 = conv(z_slice_w(2,:).^2, ones(1, 2160)');
meanVal2 = [mean(convol_x2), mean(convol_y2), mean(convol_z2)];

% 3rd slice convol.
convol_x3 = conv(x_slice_w(3,:).^2, ones(1, 2160)');
convol_y3 = conv(y_slice_w(3,:).^2, ones(1, 2160)');
convol_z3 = conv(z_slice_w(3,:).^2, ones(1, 2160)');
meanVal3 = [mean(convol_x3), mean(convol_y3), mean(convol_z3)];

% Find weight for each slice
xWeight1 = medW; yWeight1 = medW; zWeight1 = medW;
xWeight2 = medW; yWeight2 = medW; zWeight2 = medW;
xWeight3 = medW; yWeight3 = medW; zWeight3 = medW;

% figure('units', 'normalized','outerposition', [0 0.6 0.6 0.35]);
% subplot 131
% plot(convol_x1);
% hold on
% plot(convol_y1);
% hold on
% plot(convol_z1);
% legend("convol-x", "convol-y", "convol-z");
% 
% subplot 132
% plot(convol_x2);
% hold on
% plot(convol_y2);
% hold on
% plot(convol_z2);
% legend("convol-x", "convol-y", "convol-z");
% 
% subplot 133
% plot(convol_x3);
% hold on
% plot(convol_y3);
% hold on
% plot(convol_z3);
% legend("convol-x", "convol-y", "convol-z");


[M1, maxIdx1] = max(meanVal1); [m1, minIdx1] = min(meanVal1);
[M2, maxIdx2] = max(meanVal2); [m2, minIdx2] = min(meanVal2);
[M3, maxIdx3] = max(meanVal3); [m3, minIdx3] = min(meanVal3);

% For 1st slice
if maxIdx1 == 1
    xWeight1 = maxW;
elseif maxIdx1 == 2
    yWeight1 = maxW;
else
    zWeight1 = maxW;
end

if minIdx1 == 1
    xWeight1 = minW;
elseif minIdx1 == 2
    yWeight1 = minW;
else
    zWeight1 = minW;
end

% For 2nd slice
if maxIdx2 == 1
    xWeight2 = maxW;
elseif maxIdx2 == 2
    yWeight2 = maxW;
else
    zWeight2 = maxW;
end

if minIdx2 == 1
    xWeight2 = minW;
elseif minIdx2 == 2
    yWeight2 = minW;
else
    zWeight2 = minW;
end

% For 3rd slice
if maxIdx3 == 1
    xWeight3 = maxW;
elseif maxIdx3 == 2
    yWeight3 = maxW;
else
    zWeight3 = maxW;
end

if minIdx3 == 1
    xWeight3 = minW;
elseif minIdx3 == 2
    yWeight3 = minW;
else
    zWeight3 = minW;
end

%% Save each weight
xWeight_all = [xWeight1, xWeight2, xWeight3];
yWeight_all = [yWeight1, yWeight2, yWeight3];
zWeight_all = [zWeight1, zWeight2, zWeight3];

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
        xSpec_wide(cnt, :) = tmp_x * xWeight_all(cnt);
        ySpec_wide(cnt, :) = tmp_y * yWeight_all(cnt);
        zSpec_wide(cnt, :) = tmp_z * zWeight_all(cnt);
        disp([ cnt, " slice weight ",  xWeight_all(cnt), yWeight_all(cnt), zWeight_all(cnt)]);
    end
end


% % HS debug
% figure('units', 'normalized','outerposition', [0 0.5 1 0.5]);
% subplot 131
% plot(x_slice_w(1,:))
% hold on
% plot(x_slice_w(2,:))
% hold on
% plot(x_slice_w(3,:))
% legend('x slice #1', 'x slice #2', 'x slice #3')
% xlim([0 max(size(x_slice_w(1,:)))])
% 
% subplot 132
% plot(y_slice_w(1,:))
% hold on
% plot(y_slice_w(2,:))
% hold on
% plot(y_slice_w(3,:))
% legend('y slice #1', 'y slice #2', 'y slice #3')
% xlim([0 max(size(y_slice_w(1,:)))])
% 
% subplot 133
% plot(z_slice_w(1,:))
% hold on
% plot(z_slice_w(2,:))
% hold on
% plot(z_slice_w(3,:))
% legend('z slice #1', 'z slice #2', 'z slice #3')
% xlim([0 max(size(z_slice_w(1,:)))])