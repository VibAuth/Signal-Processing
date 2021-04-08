close all;
clearvars;
%% Vibration parameter setting
rate = 1500;
vibLength = 1.44;
vibSectionLength = vibLength + 0.25;
coarseInterval = rate * vibSectionLength;

%% File parameter setting
path = '../../VibData/Vib-Data/0405data_widegap/';
signalfile = './chirp.csv'; 
signal = csvread(signalfile);
filename = 'db12.csv';

axisSetting = 3;  % xรเ:1 / yรเ:2 / zรเ:3

[p_data(1:3,:), p_fft(1:3,:)] = func_signalcut_by_xcorr(path, filename, signal, axisSetting, coarseInterval);
