function [output] = vibFFT(data)
    temp = abs(fft(data)); 
    temp = temp(2:length(temp)/2 + 1);
    output = temp;
end