function [result] = CutFreqandCorr(fdataArr, startidx, endidx)
    [rowSize, ~] = size(fdataArr);
    
    for cnt = 1:rowSize
       frac(cnt,:) = fdataArr(cnt, startidx:endidx);
    end
    
    result = corr(frac');
    figure()
    imagesc(result)
    
end