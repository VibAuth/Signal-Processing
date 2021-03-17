
rate = 1000;
duration_in_sec = 1.44;
duration = rate * duration_in_sec;

t = (0:duration - 1) / rate;

fL = 152;
fH = 190;

signal = chirp(t, fL, t(end), fH);