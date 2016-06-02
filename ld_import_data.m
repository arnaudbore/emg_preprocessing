% Import_data
% Creation: May the 4th be with you 2016
% Author: Arnaud Bore, arnaud.bore@gmail.com
% Purpose: 
%       - create raw variables
%       - set up analysis
% 
% arnaud.bore@gmail.com 02/06/2016
% 

clear all  %#ok<CLALL>
clc

%% Create subjects structure
% 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


sub =      {'S06' 'S16' 'S26'};
% sub =      {'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09' 'S10' ...
%             'S11' 'S12' 'S13' 'S15' 'S16' 'S17' 'S18' 'S19' 'S20' ...
%             'S21' 'S22' 'S23' 'S24' 'S25' 'S26' 'S27' 'S28' 'S29' 'S30'};
        
sub_name = {'ROL' 'JES' 'SIM'};

% sub_name = {'JUL' 'EMM' 'ADO' 'YAC' 'ROL' 'BRI' 'ERI' 'DAM' 'ALE' ...
%             'DAI' 'DAN' 'ANA' 'LIS' 'JES' 'DAV' 'AND' 'ABD' 'MIC' ...
%             'GAT' 'LUC' 'AMI' 'CAR' 'FRE' 'SIM' 'PHI' 'DEW' 'NAD' 'KAR'};
        
% sub_tr = [3.14, 3.14, ...
%           3.20, 3.20, 3.20, 3.20];
% sub_tr = [sub_tr, ones(1, length(sub)-length(sub_tr))* 3.05];

sub_tr = [3.20 ,ones(1, length(sub)-1)* 3.05];

% Loop over subjects to create structure: subjects
for nSub=1:length(sub) 
    subjects(nSub).index = sub{nSub};
    subjects(nSub).name = sub_name{nSub};
    subjects(nSub).tr = sub_tr(nSub);
end

param.rawDCM = '/home/bore/projects/SP_MSL/raw/dicom';
param.rawKIN = '/home/bore/projects/SP_MSL/raw/kin';
param.rawEMG = '/home/bore/projects/SP_MSL/raw/emg';

param.resultsKIN = '/home/bore/projects/SP_MSL/results/kin';

param.powerMethod = 'RMS';

clear sub sub_name sub_tr nSub

%% Variables Task
% 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

msl_rnd = {'MSL' 'RND'};
days = {'D1', 'D7'}; % Days when recording
param.samplingRate = 2500; % EEG recording Hz

param.restDur = 20; % Duration of Rest Period


numBloc = 15; % number of blocks
numMvt = 80; % number of movements per block
numSeq = 8;  % number of movements in the sequence
numRep = numMvt / numSeq; % number of sequence repetition in each block

param.lowFreq = 20; % 20 -> 40
param.highFreq = 500; % 500 -> 1000 Hz

param.electrodes2Check = {'ECR', 'FCR', 'FCU', 'ECU'};

param.icaAnalysis = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
