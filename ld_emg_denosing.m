% ld_emg_denoising
% Creation: May the 4th be with you 2016
% Author: Arnaud Bore, arnaud.bore@gmail.com
% Creator: Arnaud Boré
% Purpose:
% 
% 
% arnaud.bore@gmail.com 02/06/2016


ld_import_data
    
addpath('./fstica');

fprintf('Run Analysis\n');
fprintf('############\n');

for nSub = 1:length(subjects) % Loop over subjects

    param.trSmp = param.samplingRate * subjects(nSub).tr; % tr sampled

    for nDay = 1:length(days) % Loop over days

        for nCond = 1:length(msl_rnd) % msl:1, rnd:2
            
            param.subject = subjects(nSub).index;
            param.name = subjects(nSub).name;
            param.tr = subjects(nSub).tr;
            param.day = days{nDay};
            param.condition = msl_rnd{nCond};
            param.verbose = false;

            fprintf('Subject %s, %s, %s\n',subjects(nSub).index, ...
                                           days{nDay}, ...    
                                           msl_rnd{nCond});
            
            % Get number of volumes during MRI session
            param.nbVolMRI = ld_getNbVolumes(param);
            
            % Max Real Time MRI
            param.maxMRITime = param.trSmp * param.nbVolMRI; 
                                    
            emgFileName = [param.name '_' ...
                           param.condition '_' ...
                           param.day '.txt']; % EEG filename
            
            param.emgFileName = fullfile(param.rawEMG, param.subject, ...
                                    emgFileName); % EEG filename
                                
            kinFileName = ['timing_', ...
                           param.subject '_' ...
                           param.condition '_' ...
                           param.day '.txt']; % EEG filename
            
            param.kinFileName = fullfile(param.resultsKIN, param.subject, ...
                                    kinFileName); % EEG filename                               
            
            [kinInfo, param] = ld_readKin(param);
                                
            emgSignal = ld_readEMG(param);
            
            %%
            % Compute signal
            % 1 - detrend signal
            % 2 - Filter
            % 3 - Split into TRs
           
            emgSignal = ld_preprocessSignal(emgSignal, param);
            if param.verbose
                for nElec = param.electrodes2Check
                    nElec = nElec{1};
                    curSignal = emgSignal.(nElec);
                    % Plot raw MRI, Detrend, Filtered
%                     ld_plotCompareMRIDetrendFiltered(curSignal, param)
%                   ld_plotCompareMRIDetrendFiltered_RandomTR(curSignal, param)
                end
            end
                                        
            %% Dummy analysis (per electrodes)
            % 1 - Compute Signal - Avg(Signal) -> mriTRDemeaned
            % 2 - Reshape into one single vector
            
            for nElec = param.electrodes2Check
                nElec = nElec{1}; %#ok<FXSET>
                
                fprintf('Compute demeaned signal from %s\n', nElec);
                emgSignal.(nElec).mriTRDemeaned = ...
                  emgSignal.(nElec).mriTRDetrendFiltered - ...
                  repmat(emgSignal.(nElec).mriTRDetrendFilteredAvg, ...
                  1, param.nbVolMRI);
              
                % Concatenate rows into vector: mriDemeaned
                emgSignal.(nElec).mriDemeaned = ...
                reshape(emgSignal.(nElec).mriTRDemeaned.', 1,[]);
            end
            
%             for nElec = electrodes2Check
%                 nElec = nElec{1};
%                 curSignal = emgSignal.(nElec);
%                 % Plot raw and Demeaned Signal
%                 ld_plotDemeanedSignalComparaison_RandomTR(curSignal, param)
%             end
            
            %% ICA and then GLM to get residuals
            % 
            %
            for nElec = 1:length(param.electrodes2Check)
                
                curSignal.signalICA = emgSignal.(param.electrodes2Check{nElec}).mriTRDetrendFiltered';
                curSignal.signalICA = curSignal.signalICA(kinInfo.restTRs, :); % Rest Period only
                curSignal.signalGLM = emgSignal.(param.electrodes2Check{nElec}).mriTRDetrendFiltered';
                curSignal.average = mean(curSignal.signalICA,1);
                
                higherOrder = true;
                nICA = 1;
                while higherOrder || nICA < length(param.icaAnalysis)
                    fprintf('Run ICA and GLM analysis on %s with ICA order: %d\n',param.electrodes2Check{nElec}, param.icaAnalysis(nICA));                
                    [residuals.all, components] = ld_getResiduals(curSignal, param.icaAnalysis(nICA), true);
                    
                    residuals = ld_splitTRs(residuals, kinInfo);
                    
                    residuals = ld_filterResiduals(residuals, param);
                    
                    snr.all = ld_computeSNR(residuals.taskAbsFilt, residuals.restAbsFilt, param);
                    
                    fprintf('SNR(task, rest) with all components is %f\n',snr.all)
                    for iComponents=1:size(components,1)
                        tmpComponents = components;
                        tmpComponents(iComponents,:) = [];
                        fprintf('Run GLM analysis on %s without component %d\n', param.electrodes2Check{nElec}, iComponents);                
                        [tmpResiduals.all, i_components] = ld_getResiduals(curSignal, ...
                                                     param.icaAnalysis(nICA), ...
                                                     false, ...
                                                     tmpComponents);
                                                 
                        tmpResiduals = ld_splitTRs(tmpResiduals, kinInfo);
                        tmpResiduals = ld_filterResiduals(tmpResiduals, param);
                        snr.tmp = ld_computeSNR(tmpResiduals.taskAbsFilt, tmpResiduals.restAbsFilt, param);
                        fprintf('SNR(task, rest) from ICA and GLM wo component %d is %f\n',iComponents, snr.tmp)
                        if snr.tmp < snr.all % Good Component 
                            continue
                        else % Bad Component
                            fprintf('Component %d is signal on %s\n', iComponents, param.electrodes2Check{nElec});  
                            fprintf('Remove component %d\n', iComponents, param.electrodes2Check{nElec});
                            fprintf('Star over\n');
                            higherOrder = false;
                            components(iComponents,:) = [];
                            % Start over without this Components 
                            fprintf('Run GLM analysis on %s without component %d\n', param.electrodes2Check{nElec}, iComponents);                
                            [residuals.all, components] = ld_getResiduals(curSignal, param.icaAnalysis(nICA), true);
                    
                            residuals = ld_splitTRs(residuals, kinInfo);
                    
                            residuals = ld_filterResiduals(residuals, param);
                    
                            snr.all = ld_computeSNR(residuals.taskAbsFilt, residuals.restAbsFilt, param);
                            fprintf('SNR(task, rest) with all components is %f\n',snr.all)
                            iComponents = 1;
                        end      
                        
                         
                    end
                    
                    nICA = nICA + 1;
                end 
            end
            t = 1
            %% Spectral analysis
%             Hs = spectrum.welch; % used to see the EMG spectrum (quality check)
%             figure;
%             for i=1:4
%                 emg_psd = psd(Hs, sig_TR_resamp(:,q(i)), 'Fs', f_resamp);
%                 subplot(4,1,i), plot(emg_psd);
%             end
%             
%             figure;
%             for i=1:4
%                 emg_psd = psd(Hs, sig_TR_resamp_demean(:,q(i)), 'Fs', f_resamp);
%                 subplot(4,1,i), plot(emg_psd);
%             end
%             
%             figure;
%             for i=1:4
%                 emg_psd = psd(Hs, clean_sig_TR_resamp(:,q(i)), 'Fs', f_resamp);
%                 subplot(4,1,i), plot(emg_psd);
%             end
            
            %% Envelope
            
%             sig_resamp_demean_abs = abs(sig_resamp_demean);
%             [B,A] = butter(5,2* (10 / samp_fr));
%             sig_resamp_demean_env = filtfilt(B,A,sig_resamp_demean_abs);
%             
%             
%             sig_resamp = resample(sig_filt, f_resamp, samp_fr);
%             figure;
%             plot(sig_resamp, 'b')
%             hold on; plot(sig_resamp_demean,'r')
%             plot(sig_resamp_demean_env,'g','Linewidth',5)
%             
%             
%             
%             clean_sig_resamp_abs = abs(clean_sig_resamp);
%             [B,A] = butter(5,2* (10 / samp_fr));
%             clean_sig_resamp_env = filtfilt(B,A,clean_sig_resamp_abs);
%             
%             figure;
%             plot(sig_resamp, 'b')
%             hold on; plot(clean_sig_resamp,'r')
%             plot(clean_sig_resamp_env,'g','Linewidth',5)
            
        end
    end
end
