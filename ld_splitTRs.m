function o_residuals = ld_splitTRs(i_residuals, i_kinInfo)
% 
% function o_residuals = ld_splitTRs(i_residuals, i_kinInfo)
% 
% Split between TRs 
% 
% 
% arnaud.bore@gmail.com 02/06/2016
% 

o_residuals = i_residuals;

o_residuals.restTRs = i_residuals.all(i_kinInfo.restTRs, :);
o_residuals.taskTRs = i_residuals.all(i_kinInfo.taskTRs, :);

o_residuals.rest = reshape(o_residuals.restTRs',1,numel(o_residuals.restTRs));
o_residuals.task = reshape(o_residuals.taskTRs',1,numel(o_residuals.taskTRs));
