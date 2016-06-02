function o_emgSignal = ld_preprocessSignal(i_emgSignal, param)
% function o_emgSignal = ld_preprocessSignal
% i_emgSignal:
% i_listElectrodes:
% i_lowFreq:
% i_HighFreq:
% param.trSmp:
% i_nbVolMRI:
% 
% o_emgSignal:
% 
% 
% Creation: May the 4th be with you 2016
% Author: Arnaud Bore, arnaud.bore@gmail.com
% 

o_emgSignal = i_emgSignal;

for nElec=1:length(param.electrodes2Check) % loop over electrodes of Interest
        
    % Get current signal depending on the list of Electrodes
    curSignal = i_emgSignal.(param.electrodes2Check{nElec}).MRI;
    sigDetrend = detrend(curSignal);
    o_emgSignal.(param.electrodes2Check{nElec}).MRIDetrend = sigDetrend;
    
    % Low pass filter: 500 to 1000Hz
    [B_low,A_low] = butter(5, 2* (param.highFreq / param.samplingRate));
    sigFilt = filtfilt(B_low, A_low, sigDetrend);
    
    % High pass filter: 10 to 40 Hz
    [B_high,A_high] = butter(5,2* (param.lowFreq / param.samplingRate),'high'); %
    sigFilt = filtfilt(B_high, A_high, sigFilt);
    
    o_emgSignal.(param.electrodes2Check{nElec}).MRIDetrendFiltered = sigFilt;
    
    sigTr = zeros(param.trSmp, param.nbVolMRI); % Init signal TR
    sigDetrendTr = zeros(param.trSmp, param.nbVolMRI); % Init signal TR Detrend
    sigDetrendFilteredTr = zeros(param.trSmp, param.nbVolMRI); % Init signal TR Detrend Filtered

    for nTr = 1:param.nbVolMRI % Loop over TRs
        sigTr(:,nTr) = curSignal(round([1:param.trSmp]+(nTr-1)*param.trSmp)); % To check
        sigDetrendTr(:,nTr) = sigDetrend(round([1:param.trSmp]+(nTr-1)*param.trSmp)); % To check
        sigDetrendFilteredTr(:,nTr) = sigFilt(round([1:param.trSmp]+(nTr-1)*param.trSmp)); % To check
    end
    
    % Save Signal split into TRs
    o_emgSignal.(param.electrodes2Check{nElec}).mriTR = sigTr;
    
    % Save Signal Detrend split into TRs 
    o_emgSignal.(param.electrodes2Check{nElec}).mriTRDetrend = sigDetrendTr;
    
    % Save Signal Detrend, Filtered split into TRs 
    o_emgSignal.(param.electrodes2Check{nElec}).mriTRDetrendFiltered = sigDetrendFilteredTr;
    
    % Save Avereage and standard deviation: Signal Detrend, Filtered split into TRs 
    o_emgSignal.(param.electrodes2Check{nElec}).mriTRDetrendFilteredAvg = mean(sigDetrendFilteredTr,2);
    o_emgSignal.(param.electrodes2Check{nElec}).mriTRDetrendFilteredStd = std(sigDetrendFilteredTr')';
end

