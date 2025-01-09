% LISST-Holo2 holograms sorting before processing

%% Workspace initialization

clear all;
close all;
clc;

%% Initialisation

% Paths of the different folders

currentFolder = pwd;
rawdataFolder = fullfile(extractBefore(currentFolder,'\00_Programs'),'01_Raw data');
cleaneddataFolder = fullfile(extractBefore(currentFolder,'\00_Programs'),'02_Cleaned raw data');


%% LISST-Holo2 acqusition dates

% Get a list of all files and folders in this folder.
Listfiles = dir(rawdataFolder);
% Get a logical vector that tells which is a directory.
dirFlags = [Listfiles.isdir];
% Extract only those that are directories.
subFolders = Listfiles(dirFlags); % A structure with extra info.
% Get only the folder names into a cell array.
subFolderNames = string({subFolders(3:end).name}); % Start at 3 to skip . and ..

date_campaigns = datetime(subFolderNames,'InputFormat','yyyyMMdd');
[indx,tf] = listdlg('Name','Date Selection','PromptString','Select the acquisition date for which you want to clean the raw data:','SelectionMode','single','ListSize',[400,250],'ListString',date_campaigns);

while tf==0
    waitfor(msgbox("No acquisiton date has been selected.","Error","warn"));

    % Get a list of all files and folders in this folder.
    Listfiles = dir(rawdataFolder);
    % Get a logical vector that tells which is a directory.
    dirFlags = [Listfiles.isdir];
    % Extract only those that are directories.
    subFolders = Listfiles(dirFlags); % A structure with extra info.
    % Get only the folder names into a cell array.
    subFolderNames = string({subFolders(3:end).name}); % Start at 3 to skip . and ..

    date_campaigns = datetime(subFolderNames,'InputFormat','yyyyMMdd');
    [indx,tf] = listdlg('Name','Date Selection','PromptString','Select the acquisition date for which you want to clean the raw data:','SelectionMode','single','ListSize',[400,250],'ListString',date_campaigns);
end

seldate = date_campaigns(indx);

selpath = fullfile(rawdataFolder,subFolderNames(indx),strcat(subFolderNames(indx),'_measures'));


%%

% fig = uifigure('Position',[500 500 320 280]);
% d = uidatepicker(fig,'Position',[18 235 150 22]);
% d.DisplayFormat = 'dd-MM-yyyy';

%%

% %% Selection of the raw data (.pgm files produced by the LISST-Holo2)
% 
% % User selection of the folder containing the raw data to clean
% 
% selpath = uigetdir(rawdataFolder,...
%     'Select a folder containing raw data');                                % user selects a folder containing the LISST-Holo2 raw data to be cleaned
% 
% if isequal(selpath,0)                                                      % a message is diplayed showing the selection made by the user
%    disp('The user did not select the raw data folder');
%    return
% else
%    disp(['The user selected the folder ', selpath]);
% end


%% Determine if the data only contains 1 LISST-Holo profile or 2

cleaned_depth = depth(idx_underwater:idx_max_depth);
min_depths = ~ischange(cleaned_depth,'mean','Threshold',0.0001);
cleaned_image_idx = (1:length(cleaned_depth)) + idx_underwater;

plot(cleaned_image_idx(min_depths),cleaned_depth(min_depths),'k*')

