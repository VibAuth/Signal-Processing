close all;
clearvars;

% Vibration parameter setting
rate = 1500;
vibLength = 1.44;
vibSectionLength = vibLength + 0.25;
coarseInterval = rate * vibSectionLength;

% File parameter setting
path = '../Vib-Data/0405data_per_strength/';
signalfile = './chirp.csv'; 
signal = csvread(signalfile);

%% Dabin data
filename_list = {'db_s1_1.csv','db_s1_2.csv','db_s1_3.csv','db_s1_4.csv','db_s1_5.csv', ...
    'db_s2_1.csv','db_s2_2.csv','db_s2_3.csv','db_s2_4.csv','db_s2_5.csv', ...
    'db_s3_1.csv','db_s3_2.csv','db_s3_3.csv','db_s3_4.csv','db_s3_5.csv'};

cnt = 1;
for i = 1:length(filename_list)
    filename = filename_list{i};
    [db_x(cnt:cnt+2,:), db_y(cnt:cnt+2,:),db_z(cnt:cnt+2,:), db_xf(cnt:cnt+2,:),db_yf(cnt:cnt+2,:), db_zf(cnt:cnt+2,:)] ...
    = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
    cnt = cnt+3;
end

%% Heesu data
filename_list = {'hs_s1_1.csv','hs_s1_2.csv','hs_s1_3.csv','hs_s1_4.csv','hs_s1_5.csv', ...
    'hs_s2_1.csv','hs_s2_2.csv','hs_s2_3.csv','hs_s2_4.csv','hs_s2_5.csv', ...
    'hs_s3_1.csv','hs_s3_2.csv','hs_s3_3.csv','hs_s3_4.csv','hs_s3_5.csv'};

cnt = 1;
for i = 1:length(filename_list)
    filename = filename_list{i};
    [hs_x(cnt:cnt+2,:), hs_y(cnt:cnt+2,:),hs_z(cnt:cnt+2,:), hs_xf(cnt:cnt+2,:),hs_yf(cnt:cnt+2,:), hs_zf(cnt:cnt+2,:)] ...
    = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
    cnt = cnt+3;
end

%% Jinseon Data
filename_list = {'js_s1_1.csv','js_s1_2.csv','js_s1_3.csv','js_s1_4.csv','js_s1_5.csv', ...
    'js_s2_1.csv','js_s2_2.csv','js_s2_3.csv','js_s2_4.csv','js_s2_5.csv', ...
    'js_s3_1.csv','js_s3_2.csv','js_s3_3.csv','js_s3_4.csv','js_s3_5.csv'};

cnt = 1;
for i = 1:length(filename_list)
    filename = filename_list{i};
    [js_x(cnt:cnt+2,:), js_y(cnt:cnt+2,:),js_z(cnt:cnt+2,:), js_xf(cnt:cnt+2,:),js_yf(cnt:cnt+2,:), js_zf(cnt:cnt+2,:)] ...
    = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
    cnt = cnt+3;
end

%% gather all data
nDataPerUser = length(db_zf(:,1));
all_zf(1:nDataPerUser,:) = db_zf;
all_zf(nDataPerUser+1:nDataPerUser*2,:) = hs_zf;
all_zf((nDataPerUser*2)+1:nDataPerUser*3,:) = js_zf;

all_xf(1:nDataPerUser,:) = db_xf;
all_xf(nDataPerUser+1:nDataPerUser*2,:) = hs_xf;
all_xf((nDataPerUser*2)+1:nDataPerUser*3,:) = js_xf;

all_yf(1:nDataPerUser,:) = db_yf;
all_yf(nDataPerUser+1:nDataPerUser*2,:) = hs_yf;
all_yf((nDataPerUser*2)+1:nDataPerUser*3,:) = js_yf;

avg_all_axis = (all_xf + all_yf + all_zf)/3;

figure()
imagesc(corr(avg_all_axis'))
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('fft value avg corr (80~350)')
