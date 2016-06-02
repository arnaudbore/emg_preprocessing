function o_residuals = ld_filterResiduals(i_residuals, param)
% 
% function o_residuals = ld_filterResiduals(i_residuals, param)
% 
% Filter residuals.task and residuals.rest:
%   - Low pass filter using param.lowFreq
%   - Check absolute value
% 
% arnaud.bore@gmail.com 02/06/2016
% 

    o_residuals = i_residuals;

    % Low pass filter
    [B_low,A_low] = butter(5,2* (param.lowFreq / param.samplingRate)); %
    
    o_residuals.taskAbsFilt = abs(o_residuals.task);
    o_residuals.taskAbsFilt = filtfilt(B_low, A_low, o_residuals.taskAbsFilt);
    o_residuals.taskAbsFilt(o_residuals.taskAbsFilt < 0) = 0;
    
    o_residuals.restAbsFilt = abs(o_residuals.rest);
    o_residuals.restAbsFilt = filtfilt(B_low, A_low, o_residuals.restAbsFilt);
    o_residuals.restAbsFilt(o_residuals.restAbsFilt < 0) = 0;