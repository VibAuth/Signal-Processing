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

filename = 'db_s1_1.csv';
[db_x(1:3,:), db_y(1:3,:),db_z(1:3,:), db_xf(1:3,:),db_yf(1:3,:), db_zf(1:3,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'db_s1_2.csv';
[db_x(4:6,:), db_y(4:6,:),db_z(4:6,:), db_xf(4:6,:),db_yf(4:6,:), db_zf(4:6,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'db_s1_3.csv';
[db_x(7:9,:), db_y(7:9,:),db_z(7:9,:), db_xf(7:9,:),db_yf(7:9,:), db_zf(7:9,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'db_s1_4.csv';
[db_x(10:12,:), db_y(10:12,:),db_z(10:12,:), db_xf(10:12,:),db_yf(10:12,:), db_zf(10:12,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'db_s1_5.csv';
[db_x(13:15,:), db_y(13:15,:),db_z(13:15,:), db_xf(13:15,:),db_yf(13:15,:), db_zf(13:15,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);

figure('Name','Dabin Data','NumberTitle','off');
for cnt = 1:15
    subplot(5,3,cnt)
    plot(db_z(cnt,:))
end

filename = 'hs_s1_1.csv';
[hs_x(1:3,:), hs_y(1:3,:),hs_z(1:3,:), hs_xf(1:3,:),hs_yf(1:3,:), hs_zf(1:3,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'hs_s1_2.csv';
[hs_x(4:6,:), hs_y(4:6,:),hs_z(4:6,:), hs_xf(4:6,:),hs_yf(4:6,:), hs_zf(4:6,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'hs_s1_3.csv';
[hs_x(7:9,:), hs_y(7:9,:),hs_z(7:9,:), hs_xf(7:9,:),hs_yf(7:9,:), hs_zf(7:9,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'hs_s1_4.csv';
[hs_x(10:12,:), hs_y(10:12,:),hs_z(10:12,:), hs_xf(10:12,:),hs_yf(10:12,:), hs_zf(10:12,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'hs_s1_5.csv';
[hs_x(13:15,:), hs_y(13:15,:),hs_z(13:15,:), hs_xf(13:15,:),hs_yf(13:15,:), hs_zf(13:15,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);

figure('Name','Heesu Data','NumberTitle','off');
for cnt = 1:15
    subplot(5,3,cnt)
    plot(hs_z(cnt,:))
end

filename = 'js_s1_1.csv';
[js_x(1:3,:), js_y(1:3,:),js_z(1:3,:), js_xf(1:3,:),js_yf(1:3,:), js_zf(1:3,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'js_s1_2.csv';
[js_x(4:6,:), js_y(4:6,:),js_z(4:6,:), js_xf(4:6,:),js_yf(4:6,:), js_zf(4:6,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'js_s1_3.csv';
[js_x(7:9,:), js_y(7:9,:),js_z(7:9,:), js_xf(7:9,:),js_yf(7:9,:), js_zf(7:9,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'js_s1_4.csv';
[js_x(10:12,:), js_y(10:12,:),js_z(10:12,:), js_xf(10:12,:),js_yf(10:12,:), js_zf(10:12,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);
filename = 'js_s1_5.csv';
[js_x(13:15,:), js_y(13:15,:),js_z(13:15,:), js_xf(13:15,:),js_yf(13:15,:), js_zf(13:15,:)] = func_signalcut_by_xcorr(path, filename, signal, coarseInterval);

figure('Name','Jinseon Data','NumberTitle','off');
for cnt = 1:15
    subplot(5,3,cnt)
    plot(js_z(cnt,:))
end

% gather all data
all_zf(1:15,:) = db_zf;
all_zf(16:30,:) = hs_zf;
all_zf(31:45,:) = js_zf;
figure()
imagesc(corr(all_zf'))
title('zaxis fft corr')

all_xf(1:15,:) = db_xf;
all_xf(16:30,:) = hs_xf;
all_xf(31:45,:) = js_xf;
figure()
imagesc(corr(all_xf'))
title('xaxis fft corr')

all_yf(1:15,:) = db_yf;
all_yf(16:30,:) = hs_yf;
all_yf(31:45,:) = js_yf;
figure()
imagesc(corr(all_yf'))
title('yaxis fft corr')

avg_all_axis = (all_xf + all_yf + all_zf)/3;
figure()
imagesc(corr(avg_all_axis'))
title('fft value avg corr')

avg_all_axis_corr = (corr(all_zf') + corr(all_xf') + corr(all_yf'))/3;
figure()
imagesc(avg_all_axis_corr)
title('fft corr value avg corr')
