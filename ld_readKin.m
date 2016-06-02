function [o_kinInfo, o_param] = ld_readKin(param)
% 
% 
% 
% 
% 

    o_param = param;

    fprintf('Read Kinematic information from: %s\n',param.kinFileName)
    fid = fopen(param.kinFileName, 'r');
    
    formatSpec = '%f	%f	%d\n';
    sizeA = [3 Inf];
    o_kinInfo.taskSeconds = fscanf(fid,formatSpec,sizeA);

    % Change third line to end of task (line 1 + line 2)
    o_kinInfo.taskSeconds(3,:) = o_kinInfo.taskSeconds(1,:) + ...
                                 o_kinInfo.taskSeconds(2,:);
                             
    % Reshape
    o_kinInfo.taskSeconds = o_kinInfo.taskSeconds';
    
    o_kinInfo.endKinematicSeconds = o_kinInfo.taskSeconds(end,1) + ...
                                    o_kinInfo.taskSeconds(end,2) + ...
                                    param.restDur;
    
    o_param.nbBlocks = size(o_kinInfo.endKinematicSeconds,1);
                                
    % Check if length of kinematic file is lower than MRI volumes
    if o_kinInfo.endKinematicSeconds > param.nbVolMRI * param.tr;
        fprintf('Error: there are more Kinematic time points than MRI volumes');
        return
    end
     
    o_kinInfo.taskTRs = [];
    o_kinInfo.restTRs = [];
    
    for iVol=1:param.nbVolMRI
        volStart = (iVol-1) * param.tr;
        volEnd = iVol * param.tr;
        
        taskBlocks = zeros(length(o_param.nbBlocks), 1);
        
        for iBlock=1:length(o_kinInfo.taskSeconds)
            taskStart = o_kinInfo.taskSeconds(iBlock, 1);
            taskEnd = o_kinInfo.taskSeconds(iBlock, 3);
            if taskStart < volStart && taskEnd > volEnd
                taskBlocks(iBlock) = 1;
            elseif (taskStart > volStart && taskStart < volEnd) || (taskEnd > volStart && taskEnd < volEnd)
                taskBlocks(iBlock) = 0.1;
            end
        end
        
        if sum(taskBlocks) == 1
            o_kinInfo.taskTRs(end+1) = iVol;
        elseif sum(taskBlocks) == 0
            o_kinInfo.restTRs(end+1) = iVol;
        end
    end
