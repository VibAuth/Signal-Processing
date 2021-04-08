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

% figure('Name','Jinseon Data','NumberTitle','off');
% for cnt = 1:45
%     subplot(5,9,cnt)
%     plot(js_z(cnt,:))
% end

%% Correlation

% gather all data
all_zf(1:45,:) = db_zf;
all_zf(46:90,:) = hs_zf;
all_zf(91:135,:) = js_zf;
figure()
imagesc(corr(all_zf'))
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('zaxis fft corr (140~190)')

all_xf(1:45,:) = db_xf;
all_xf(46:90,:) = hs_xf;
all_xf(91:135,:) = js_xf;
figure()
imagesc(corr(all_xf'))
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('xaxis fft corr (140~190)')

all_yf(1:45,:) = db_yf;
all_yf(46:90,:) = hs_yf;
all_yf(91:135,:) = js_yf;
figure()
imagesc(corr(all_yf'))
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('yaxis fft corr (140~190)')

avg_all_axis = (all_xf + all_yf + all_zf)/3;
figure()
imagesc(corr(avg_all_axis'))
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('fft value avg corr (140~190)')

avg_all_axis_corr = (corr(all_zf') + corr(all_xf') + corr(all_yf'))/3;
figure()
imagesc(avg_all_axis_corr)
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('fft corr value avg corr (140~190)')
