function o_nbVolumes = ld_getNbVolumes(i_param)
%  
%  function o_nbVolumes = ld_getNbVolumes(i_subject, i_rawDCM, i_day, i_Cond)
% 
%  i_subjects:  
%  i_raWDCM:
%  i_day
%  i_cond


subjectFolder = fullfile(i_param.rawDCM, i_param.subject, i_param.day);
modalities = dir(subjectFolder);

modFound = [];

for nMod=1:length(modalities)
    if strfind(modalities(nMod).name,i_param.condition)
        modFound(end+1) = nMod;
    end
end

if length(modFound) > 1
    disp('TO DO')
end

% Add modality to the subjectFolder name
subjectFolder = fullfile(subjectFolder, modalities(modFound).name);



tDay = [i_param.day(1) , '0', i_param.day(2)];
listFiles = dir([subjectFolder, filesep, '*', i_param.subject, '_', ...
                                      tDay, '*.dcm*']);

if isempty(listFiles)
    listFiles = dir([subjectFolder, filesep, '*', i_param.subject, '_', ...
                                      i_param.day, '*.dcm*']);
end
                                  
% We divide by 2 because there are spine and brain images
o_nbVolumes = length(listFiles(not([listFiles.isdir]))) / 2 ; 
