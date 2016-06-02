function ld_plotDemeanedSignalComparaison_RandomTR(i_emgSignal, i_param)
% 
% function ld_plotDemeanedSignalComparaison(i_emgSignal, i_param)
% 
% i_emgSignal:
% i_param:
% 
% 

figure

for sub=1:3
    r = randi([1 size(i_emgSignal.mriTRDetrendFiltered,2)],1);
    subplot(3,3,sub)
    plot(i_emgSignal.mriTR(:,r),'b')
    title(['TR number: ' num2str(r)])        
    if sub == 1
        ylabel('MRI RAW')
    end
    subplot(3,3,sub+3)
    plot(i_emgSignal.mriTRDemeaned(:,r),'r')
    if sub == 1
        ylabel('MRI Demeaned')
    end
    subplot(3,3,sub+6)
    plot(i_emgSignal.mriTRDetrendFiltered(:,r), 'b')
    hold on
    plot(i_emgSignal.mriTRDemeaned(:,r), 'r')
    if sub == 1
        ylabel('Comparaison')
    end
end

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
            i_emgSignal.name '_DemeanedTRComparaison.png'])
close(gcf)