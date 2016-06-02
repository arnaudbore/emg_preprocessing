figure
for i=1:10
subplot(5,5,i)
plot(components(i,:))
hold on
end
components_ratio = [];
for i=1:size(components,1)

%     Hs=spectrum.welch;
%     Spect = psd(Hs,components(i,:), 'Fs',param.samplingRate,'ConfLevel',0.95);

    subplot(size(components,1),2,2*i-1)
    spect2 = pwelch(components(i,:),[],[],[],param.samplingRate);
plot(spect2)
%     plot(Spect.Frequencies, 10*log10(abs(Spect.Data)), 'b', Spect.Frequencies, 10*log10(abs(Spect.ConfInterval(:,1))), 'b:', Spect.Frequencies, 10*log10(abs(Spect.ConfInterval(:,2))), 'b:')  
%     plot(Spect)
    subplot(size(components,1),2,2*i)
    plot(components(i,:))
    
    
    components_low = spect2(1:300);
    components_high = spect2(301:end);

    components_ratio(i) = sum(components_high) ./ sum(components_low);
    
end

components_ratio


fprintf('SNR(task, rest) with all components is %f\n',snr.all)
% 

help subplot

tmpComponents = components;
tmpComponents(1:3,:) = [];

[tmpResiduals.all, i_components] = ld_getResiduals(curSignal, ...
                                                     param.icaAnalysis(nICA), ...
                                                     false, ...
                                                     tmpComponents);
tmpResiduals = ld_splitTRs(tmpResiduals, kinInfo);
tmpResiduals = ld_filterResiduals(tmpResiduals, param);
snr.tmp = ld_computeSNR(tmpResiduals.taskAbsFilt, tmpResiduals.restAbsFilt, param);

[specttask, f] = pwelch(residuals.task,[],[],[],param.samplingRate);
[spectrest, f] = pwelch(residuals.rest,[],[],[],param.samplingRate);


Hs=spectrum.welch;
Spect = psd(Hs,residuals.task, 'Fs',param.samplingRate,'ConfLevel',0.95);
plot(Spect.Frequencies, 10*log10(abs(Spect.Data)), 'b', Spect.Frequencies, 10*log10(abs(Spect.ConfInterval(:,1))), 'b:', Spect.Frequencies, 10*log10(abs(Spect.ConfInterval(:,2))), 'b:')  

components_low = specttask(1:300);
components_high = specttask(301:end);

specttask_ratio = sum(components_high) ./ sum(components_low);

components_ratio = [];
for i=1:size(tmpComponents,1)

%     Hs=spectrum.welch;
%     Spect = psd(Hs,components(i,:), 'Fs',param.samplingRate,'ConfLevel',0.95);

    subplot(size(tmpComponents,1),2,2*i-1)
    [spect2,f] = pwelch(tmpComponents(i,:),[],[],[],param.samplingRate);
plot(f,spect2)
%     plot(Spect.Frequencies, 10*log10(abs(Spect.Data)), 'b', Spect.Frequencies, 10*log10(abs(Spect.ConfInterval(:,1))), 'b:', Spect.Frequencies, 10*log10(abs(Spect.ConfInterval(:,2))), 'b:')  
%     plot(Spect)
    subplot(size(tmpComponents,1),2,2*i)
    plot(tmpComponents(i,:))
    
    
    components_low = spect2(1:300);
    components_high = spect2(301:end);

    components_ratio(i) = sum(components_high) ./ sum(components_low);
    
end

components_ratio
