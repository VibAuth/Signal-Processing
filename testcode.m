rate = 1000;
vibLength = 1.44;
vibSectionLength = vibLength + 0.5;
coarseInterval = rate * vibSectionLength;

path = './';
filename = 'hs_chirp_p0_1.csv';
[hs_p0(1:3,:), hs_p0_f(1:3,:)] = func_signalcut(path, filename);
figure('Name','hs_chirp_p0_1','NumberTitle','off')
for cnt = 1:3
    subplot(2,3,cnt)
    plot(hs_p0(cnt,:))
    subplot(2,3,cnt+3)
    plot(rate/coarseInterval:rate / coarseInterval:rate / 2, hs_p0_f(cnt,:))
end

figure()
plot(xcorr(signal, hs_p0(1,:)))
figure()
spectrogram(hs_p0(1, :), 128, 127, 128, 'Yaxis')