close all;
clearvars;

userNum = 9;

%% Get registration data

userNum = userNum + 1;

path = './';
filename_list = {'new_file_training1.csv', 'new_file_training2.csv', 'new_file_training3.csv', 'new_file_training4.csv'};
%% Vibration parameter setting
rate = 1500;
vibLength = 1.44;
vibSectionLength = vibLength + 0.3;
coarseInterval = rate * vibSectionLength;

%% SignalCut
cnt = 1;
for i = 1:length(filename_list)
    filename = filename_list{i};
    [check, temp_xf(1:3,:),temp_yf(1:3,:), temp_zf(1:3,:)] ...
    = func_signalcut_regi_final(path, filename, coarseInterval, 3);
    
    if check
        data_xf(cnt:cnt+2,:) = temp_xf(1:3,:);
        data_yf(cnt:cnt+2,:) = temp_yf(1:3,:);
        data_zf(cnt:cnt+2,:) = temp_zf(1:3,:);
        
        cnt = cnt+3;
    end
end

%% Correlation
avg_all_axis = (data_xf + data_yf + data_zf)/3;

path = './Data/';
save(strcat(path, strcat(int2str(userNum),'.mat')),'avg_all_axis');
