close all;
clearvars;
% Vibration parameter setting
rate = 1500;
vibLength = 1.44;
vibSectionLength = vibLength + 0.3;
coarseInterval = rate * vibSectionLength;

% File parameter setting
path = './../Vib-Data/0416data_long_interval/';
signalfile = './chirp.csv'; 
signal = csvread(signalfile);

%% Dabin data
filename_list = {'db1.csv','db2.csv','db3.csv','db4.csv','db5.csv', ...
    'db6.csv','db7.csv','db8.csv','db9.csv','db10.csv', ...
    'db11.csv','db12.csv','db13.csv','db14.csv','db15.csv'};

cnt = 1;
for i = 1:length(filename_list)
    filename = filename_list{i};
    [db_x(cnt:cnt+2,:), db_y(cnt:cnt+2,:),db_z(cnt:cnt+2,:), db_xf(cnt:cnt+2,:),db_yf(cnt:cnt+2,:), db_zf(cnt:cnt+2,:)] ...
    = func_signalcut_by_conv(path, filename, signal, coarseInterval);
    cnt = cnt+3;
end

%% Heesu data
filename_list = {'hs1.csv','hs2.csv','hs3.csv','hs4.csv','hs5.csv', ...
    'hs6.csv','hs7.csv','hs8.csv','hs9.csv','hs10.csv', ...
    'hs11.csv','hs12.csv','hs13.csv','hs14.csv','hs15.csv'};

cnt = 1;
for i = 1:length(filename_list)
    filename = filename_list{i};
    [hs_x(cnt:cnt+2,:), hs_y(cnt:cnt+2,:),hs_z(cnt:cnt+2,:), hs_xf(cnt:cnt+2,:),hs_yf(cnt:cnt+2,:), hs_zf(cnt:cnt+2,:)] ...
    = func_signalcut_by_conv(path, filename, signal, coarseInterval);
    cnt = cnt+3;
end

%% Jinseon Data
filename_list = {'js1.csv','js2.csv','js3.csv','js4.csv','js5.csv', ...
    'js6.csv','js7.csv','js8.csv','js9.csv','js10.csv', ...
    'js11.csv','js12.csv','js13.csv','js14.csv','js15.csv'};

cnt = 1;
for i = 1:length(filename_list)
    filename = filename_list{i};
    [js_x(cnt:cnt+2,:), js_y(cnt:cnt+2,:),js_z(cnt:cnt+2,:), js_xf(cnt:cnt+2,:),js_yf(cnt:cnt+2,:), js_zf(cnt:cnt+2,:)] ...
    = func_signalcut_by_conv(path, filename, signal, coarseInterval);
    cnt = cnt+3;
end

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
title('zaxis fft corr')

all_xf(1:45,:) = db_xf;
all_xf(46:90,:) = hs_xf;
all_xf(91:135,:) = js_xf;
figure()
imagesc(corr(all_xf'))
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('xaxis fft corr')

all_yf(1:45,:) = db_yf;
all_yf(46:90,:) = hs_yf;
all_yf(91:135,:) = js_yf;
figure()
imagesc(corr(all_yf'))
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('yaxis fft corr')

avg_all_axis = (all_xf + all_yf + all_zf)/3;
figure()
imagesc(corr(avg_all_axis'))
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('fft value avg corr')

avg_all_axis_corr = (corr(all_zf') + corr(all_xf') + corr(all_yf'))/3;
figure()
imagesc(avg_all_axis_corr)
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('fft corr value avg corr')