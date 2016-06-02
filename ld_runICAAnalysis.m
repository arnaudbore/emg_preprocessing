function o_emgSignal = ld_runICAAnalysis(i_emgSignal, i_icaOrder, i_param)
%   function o_emgSignal = ld_runICAAnalysis(i_emgSignal, icaOrder)
% 
%   i_emgSignal: Structure
%   i_icaOrder: Number of components extracted
% 
% 
% 
% 
%   Creation: May 5th 2016
%   Author: Arnaud Bore, arnaud.bore@gmail.com

    o_emgSignal = i_emgSignal;
    
    %% Run ICA on split signal (every TR)
    % Should think about changing this to specific TRs
    [icasig, A, W] = fastica(o_emgSignal.mriTRDetrendFiltered', ...
                             'lastEig', i_icaOrder, ...
                             'numOfIC', i_icaOrder, ...
                             'g', 'tanh');
    
    %  Save ICAs Components
    mriICAComponents = strcat('mriICAComponents', num2str(i_icaOrder));
    o_emgSignal.mriGLM.(mriICAComponents) = icasig;
    
    %% Plot Components
    if i_param.verbose
        figure
        for iComponent = 1:i_icaOrder
            if i_icaOrder > 6
                subplot(3,3,iComponent)
            else
                subplot(4,3,iComponent)
            end
            plot(icasig(iComponent,:));
        end
        annotation('textbox', [0 0.9 1 0.1], ...
            'String', ['ICAs Components order ' num2str(i_icaOrder)], ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center')
        screen_size = get(0, 'ScreenSize');
        set(gcf, 'Position', [0 0 screen_size(3) screen_size(4) ] ); %set to scren size
        set(gcf,'PaperPositionMode','auto') %set paper pos for printing           

        saveas(gcf,[i_param.subject , '_', ...
            i_param.day, '_', ...
            i_param.condition, '_', ...
            'ICA_', num2str(i_icaOrder), '_', ... 
            i_emgSignal.name '_ICAsComponents.png'])
        close(gcf)
    end
    %% @TODO: Need to check which component to use !!!!!

    
    %% Glm fit using ICA components
    %  Check if all components improve SNR 
    %  If True save components and GLM results
    %     
%     icasig = [icasig ; o_emgSignal.mriTRDetrendFilteredAvg'];                         
    for iComponents=1:size(icasig,1)
        tICAsig = [icasig(iComponents,:) ; o_emgSignal.mriTRDetrendFilteredAvg'];
        for nVol=1:size(o_emgSignal.mriTRDetrendFiltered,2)
            curSignal = o_emgSignal.mriTRDetrendFiltered(:,nVol);
            
            [~, ~, stats] = glmfit(icasig', curSignal);
            
            % Compute SNR %             
            curSNR = snr(stats.resid, curSignal);
            if ~exist('oldSNR','var')
                % Compare SNRs
            else
               oldSNR = curSNR; 
            end
            
            mriTRRes(:,nVol) = stats.resid;
        end
    end
    mriRes = reshape(mriTRRes', [], 1);
    
    mriResField = strcat('mriResICA', num2str(i_icaOrder));
    mriTRResField = strcat('mriTRResICA', num2str(i_icaOrder));
    
    
    
    o_emgSignal.mriGLM.(mriTRResField) = mriTRRes; % Save residuals per TR
    o_emgSignal.mriGLM.(mriResField) = mriRes; % Save residuals
    
    
