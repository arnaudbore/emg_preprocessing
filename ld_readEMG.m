function o_emgSignal = ld_readEMG(param)
% 
% 
% 
% 
% 

    fprintf('Read EMG from: %s\n', param.emgFileName);
            
    fileID = fopen(param.emgFileName,'r');
    header = fgetl(fileID); % Get header from emg file

    % Get headerColumns
    headerColumns = regexp(strsplit(header,'"\t"'),'([A-Z#a-z ]+)','match');
    headerColumns = [headerColumns{:}];

    clear header

    o_emgSignal.total = dlmread(param.emgFileName , '\t', 1 , 0);

    % limit the recorded signals to the scan time
    o_emgSignal.MRI = o_emgSignal.total(1:param.maxMRITime, :); 

    % limit the recorded signals to the scan time
    o_emgSignal.nonMRI = o_emgSignal.total(param.maxMRITime+1:end, :); 

    for nCol=1:length(headerColumns) % Loop over columns
        columnName = strrep(headerColumns(nCol),' ', '');
        headerColumns{nCol} = char(columnName);
        fprintf('Extract MRI and non MRI signal from %s\n', headerColumns{nCol});
        o_emgSignal.(headerColumns{nCol}).MRI = o_emgSignal.MRI(:, nCol);
        o_emgSignal.(headerColumns{nCol}).nonMRI = o_emgSignal.nonMRI(:, nCol);
        o_emgSignal.(headerColumns{nCol}).name = headerColumns{nCol};
    end

    % Save columns into emgSignal variable
    o_emgSignal.header = headerColumns;