function ld_plotCompareMRIDetrendFiltered(i_emgSignal, i_param)
% 
% 
% 
% 
% 
% 
    figure
    subplot(3,1,1)
    plot(i_emgSignal.MRI)
    ylabel('MRI RAW')
    subplot(3,1,2)
    plot(i_emgSignal.MRIDetrend)
    ylabel('MRI Detrend')
    subplot(3,1,3)
    plot(i_emgSignal.MRIDetrendFiltered)
    ylabel('MRI Detrend Filtered')
    
    annotation('textbox', [0 0.9 1 0.1], ...
        'String', ['Analysis: ' i_emgSignal.name], ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center')
    
    screen_size = get(0, 'ScreenSize');
    set(gcf, 'Position', [0 0 screen_size(3) screen_size(4) ] ); %set to scren size
    set(gcf,'PaperPositionMode','auto') %set paper pos for printing    
    
    saveas(gcf,[i_param.subject , '_', ...
                i_param.day, '_', ...
                i_param.condition, '_', ...
                i_emgSignal.name '_AllSignalComparaison.png'])
    close(gcf)