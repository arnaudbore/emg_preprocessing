function o_icaComponents = ld_run_ICA_GLM(i_emgSignal, i_icaOrder)
% 
% function o_snr = ld_runICA(i_emgSignal)
% 
% i_emgSignal:
% 
% o_snr:
% 
% 
% Creation: May 5th 2016
% Author: Arnaud Bore

% Run ICA Analysis
[o_icaComponents, ~, ~] = fastica(i_emgSignal, ...
                        'lastEig', i_icaOrder, ...
                        'numOfIC', i_icaOrder, ...
                        'g', 'tanh');                    

[~, ~, stats] = glmfit(icasig', i_emgSignal);
residuals = stats.resid;


                    