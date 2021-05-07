close all;
clearvars;

userNum = 6;

%% Get registration data

% temp data set
path = './';
filename = 'db5.csv';

%% Vibration parameter setting
rate = 1500;
vibLength = 1.44;
vibSectionLength = vibLength + 0.3;
coarseInterval = rate * vibSectionLength;

%% SignalCut
[check, temp_xf(1,:),temp_yf(1,:), temp_zf(1,:)] ...
    = func_signalcut_demo(path, filename, coarseInterval, 1);

data_xf(1,:) = temp_xf(1,:);
data_yf(1,:) = temp_yf(1,:);
data_zf(1,:) = temp_zf(1,:);

%% Correlation
test_data(1,:) = (data_xf + data_yf + data_zf)/3;

path = './';
idx = 1;
for cnt=1:userNum
   corr_file_name = strcat(int2str(cnt),'.csv');
   corr_data = csvread([path, corr_file_name],0,0);
   [m, n] = size(corr_data);
   
   test_data(idx+1:idx+m,:) = corr_data;
   idx = idx + m;
end

figure();
imagesc(corr(test_data'))
xticks(1:12:73);
yticks(1:12:73);

%% KNN

%% Return the result
