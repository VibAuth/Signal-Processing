close all;
clearvars;
% Vibration parameter setting
rate = 1500;
vibLength = 1.44;
vibSectionLength = vibLength + 0.3;
coarseInterval = rate * vibSectionLength;
numVib = 3;

% File parameter setting
path = './../Vib-Data/0416data_long_interval/';

%% Dabin data
filename_list = {'db1.csv','db2.csv','db3.csv','db4.csv','db5.csv', ...
    'db6.csv','db7.csv','db8.csv','db9.csv','db10.csv', ...
    'db11.csv','db12.csv','db13.csv','db14.csv','db15.csv'};

cnt = 1;
for i = 1:length(filename_list)
    filename = filename_list{i};
    [db_x(cnt:cnt+2,:), db_y(cnt:cnt+2,:),db_z(cnt:cnt+2,:)] ...
    = func_signalcut_time_domain (path, filename, coarseInterval, numVib);

    for j = 0:2
       db_x_c(:,:,cnt+j) = abs(cwt(db_x(cnt+j, :)));
       db_y_c(:,:,cnt+j) = abs(cwt(db_y(cnt+j, :)));
       db_z_c(:,:,cnt+j) = abs(cwt(db_z(cnt+j, :)));
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
    [hs_x(cnt:cnt+2,:), hs_y(cnt:cnt+2,:),hs_z(cnt:cnt+2,:)] ...
    = func_signalcut_time_domain (path, filename, coarseInterval, numVib);
    
    for j = 0:2
       hs_x_c(:,:,cnt+j) = abs(cwt(hs_x(cnt+j, :)));
       hs_y_c(:,:,cnt+j) = abs(cwt(hs_y(cnt+j, :)));
       hs_z_c(:,:,cnt+j) = abs(cwt(hs_z(cnt+j, :)));
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
    [js_x(cnt:cnt+2,:), js_y(cnt:cnt+2,:),js_z(cnt:cnt+2,:)] ...
    = func_signalcut_time_domain (path, filename, coarseInterval, numVib);

    for j = 0:2
       js_x_c(:,:,cnt+j) = abs(cwt(js_x(cnt+j, :)));
       js_y_c(:,:,cnt+j) = abs(cwt(js_y(cnt+j, :)));
       js_z_c(:,:,cnt+j) = abs(cwt(js_z(cnt+j, :)));
    end
    
    cnt = cnt+3;
end

%% Correlation

cwt_x(:,:,1:45) = db_x_c;
cwt_x(:,:,46:90) = hs_x_c;
cwt_x(:,:,91:135) = js_x_c;

cwt_y(:,:,1:45) = db_y_c;
cwt_y(:,:,46:90) = hs_y_c;
cwt_y(:,:,91:135) = js_y_c;

cwt_z(:,:,1:45) = db_z_c;
cwt_z(:,:,46:90) = hs_z_c;
cwt_z(:,:,91:135) = js_z_c;

for r=1:135
    for c=1:135
        corr_cwt_x(r,c) = corr2(cwt_x(:,:,r),cwt_x(:,:,c));
        corr_cwt_y(r,c) = corr2(cwt_y(:,:,r),cwt_y(:,:,c));
        corr_cwt_z(r,c) = corr2(cwt_z(:,:,r),cwt_z(:,:,c));
    end
end

figure()
subplot(1,3,1)
imagesc(corr_cwt_x)
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('xaxis cwt corr')
% caxis([0.8 1]);

subplot(1,3,2)
imagesc(corr_cwt_y)
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('yaxis cwt corr')
% caxis([0.8 1]);

subplot(1,3,3)
imagesc(corr_cwt_z)
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('zaxis cwt corr')
% caxis([0.8 1]);

cwt_all = (cwt_x + cwt_y + cwt_z)/3;

for r=1:135
    for c=1:135
        corr_cwt_all(r,c) = corr2(cwt_all(:,:,r),cwt_all(:,:,c));
    end
end
figure()
imagesc(corr_cwt_all)
daspect([1 1 1])
xticks(0:45:135);
yticks(0:45:135);
title('cwt value avg corr')

