function [output] = vibFFT(data)
    [~, idx] = max(abs(data));
    data = circshift(data, ceil(length(data) / 2) - idx);
    
    win = hamming(length(data));    
    temp = abs(fft(data .* win')); 
    temp = temp(2:ceil(length(temp)/2) + 1);
    output = temp;
end
