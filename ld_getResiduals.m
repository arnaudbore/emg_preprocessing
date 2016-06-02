function [o_residuals, o_components] = ld_getResiduals(i_emgSignal, i_icaOrder, ...
                                       i_computeComponents, ...
                                       i_components)
%   function ld_getResiduals(i_emgSignal, i_icaOrder, i_components)
% 
%   i_emgSignal: structure -> signal and average
%   i_icaOrder: order of the ICA if i_computeComponents == true
%   i_computeComponents: If you want to run ICA analysis
%   
% 
%   Arnaud Bore 01 Juin 2016
    
    if nargin <= 3
        i_computeComponents = true; % Compute ICA
    end 

        
    %% Run ICA on split signal (every TR)
    if i_computeComponents
        disp('Run ICA Analysis')
        [i_components, A, W] = fastica(i_emgSignal.signalICA, ...
                                 'lastEig', i_icaOrder, ...
                                 'numOfIC', i_icaOrder, ...
                                 'g', 'tanh');
    end
    
    
    icasig = [i_components ; i_emgSignal.average];

    disp('Run GLM Analysis')
    for nVol=1:size(i_emgSignal.signalGLM, 1)
            curSignal = i_emgSignal.signalGLM(nVol, :);
            [~, ~, stats] = glmfit(icasig', curSignal);
            
            o_residuals(nVol, :) = stats.resid;
    end
    
    o_components = i_components;
    