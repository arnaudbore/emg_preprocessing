function o_SNR = ld_computeSNR(signal1, signal2, param)
% 
% Compute SNR
% 
% 
% 
% 
% arnaud.bore@gmail.com 02/06/2016
% 

if strcmp(param.powerMethod,'RMS')
    o_SNR = sqrt(mean((signal1).^2)) / sqrt(mean((signal2).^2));
end

