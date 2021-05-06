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

    for j = 0:2
       db_x_s(:,:,cnt+j) = real(spectrogram(db_x(cnt+j, :), 128, 127, 128));
       db_y_s(:,:,cnt+j) = real(spectrogram(db_y(cnt+j, :), 128, 127, 128));
       db_z_s(:,:,cnt+j) = real(spectrogram(db_z(cnt+j, :), 128, 127, 128));
    end
    
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
    
    for j = 0:2
       hs_x_s(:,:,cnt+j) = real(spectrogram(hs_x(cnt+j, :), 128, 127, 128));
       hs_y_s(:,:,cnt+j) = real(spectrogram(hs_y(cnt+j, :), 128, 127, 128));
       hs_z_s(:,:,cnt+j) = real(spectrogram(hs_z(cnt+j, :), 128, 127, 128));
    end
    
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

    for j = 0:2
       js_x_s(:,:,cnt+j) = real(spectrogram(js_x(cnt+j, :), 128, 127, 128));
       js_y_s(:,:,cnt+j) = real(spectrogram(js_y(cnt+j, :), 128, 127, 128));
       js_z_s(:,:,cnt+j) = real(spectrogram(js_z(cnt+j, :), 128, 127, 128));
    end
    
    cnt = cnt+3;
end

%% Correlation

stft_x(:,:,1:45) = db_x_s;
stft_x(:,:,46:90) = hs_x_s;
stft_x(:,:,91:135) = js_x_s;

stft_y(:,:,1:45) = db_y_s;
stft_y(:,:,46:90) = hs_y_s;
stft_y(:,:,91:135) = js_y_s;

stft_z(:,:,1:45) = db_z_s;
stft_z(:,:,46:90) = hs_z_s;
stft_z(:,:,91:135) = js_z_s;

for r=1:135
    for c=1:135
        corr_stft_x(r,c) = corr2(stft_x(:,:,r),stft_x(:,:,c));
        corr_stft_y(r,c) = corr2(stft_y(:,:,r),stft_y(:,:,c));
        corr_stft_z(r,c) = corr2(stft_z(:,:,r),stft_z(:,:,c));
    end
end

figure()
subplot(1,3,1)
imagesc(corr_stft_x)
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);

subplot(1,3,2)
imagesc(corr_stft_y)
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);

subplot(1,3,3)
imagesc(corr_stft_z)
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);

stft_all = (stft_x + stft_y + stft_z)/3;

for r=1:135
    for c=1:135
        corr_stft_all(r,c) = corr2(stft_all(:,:,r),stft_all(:,:,c));
    end
end
figure()
imagesc(corr_stft_all)
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);

