%% Clean LISST-Holo2 raw data

% This program takes as an input

% Armelle BOUHALI, 01.10.2024


%% Workspace initialization

close all;                                                                 % close all figure
clear;                                                                     % remove all variables from the current workspace
clc;                                                                       % delete the command window


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

if isfolder(selpath) ~= 1 
    waitfor(msgbox(["The folder containing the raw data at the date selected does not exist, is not named correctly yyyymmdd_measures or is not saved in the folder E:\01_Raw data\yyyymmdd.";"The program will stop.";"Please check the raw data folder and start again."],"Error","error"))
    return
end    


%% Extraction of images metadata

% Initialisation

files = dir(fullfile(selpath, '*.pgm'));                                   % return attributes (name, folder, date, bytes, isdir, datenum) about each of the pgm files contained in the raw data folder selected by the user
nom_file = {files.name};

depth = zeros(1,length(files));

% Extraction of the depth

for k = 1:length(files)                                                    % for each pgm file, the metadata are extracted
    file_name = files(k).name;                                             % temporary variable with the name of the file currently studied
    
    file_path = fullfile(selpath, file_name);                              % temporary save of the path of the current file
    fid = fopen(file_path, 'rb');
    copie = fread(fid, '*char')';                                          % read the current file as characters
    fclose(fid);
    
    depth(1,k) = str2double(sortie_recherche('Depth', 'meter', copie));  % store the depth of current file
end


%% Plotting the depth profile of LISST during image capture

% Plot the depth profile

figure(1)
hold on
plot(depth,'Color',"#D95319",'LineWidth', 2);
set(gca, 'YDir', 'reverse'); % Invert y-axis
yline(0,'Color', "#0072BD")
grid on;
grid minor
xlabel('Image index');
ylabel('Depth (meter)');
title(['Depth Profile of LISST-Holo2 holograms on the ', string(seldate)]);
legend('LISST depth profile', 'Water level','Location','best')

date_meas = extractAfter(selpath,"01_Raw data\");
date_meas = extractBefore(date_meas,9);


%% Only keep the data from the downwards part of the 2nd profile

image_idx = 1:length(nom_file);
underwater = depth(find(depth>=1,1,'first'):find(depth>=1,1,'last'));      % remove the images above water level at the beginning and the end of the raw data
underwater_idx = image_idx(find(depth>=1,1,'first'):find(depth>=1,1,'last'));

profile1 = underwater(1:find(underwater<1,1,'first')-1);
profile1_idx = underwater_idx(1:find(underwater<1,1,'first')-1);

profile2 = underwater(find(underwater<1,1,'last') +1 : end);
profile2_idx = underwater_idx(find(underwater<1,1,'last') +1 : end);

% Plot the depth profile

figure(1)
hold on
plot(depth,'Color',"#D95319",'LineWidth', 2);
set(gca, 'YDir', 'reverse'); % Invert y-axis
yline(0,'Color', "#0072BD")
plot(profile1_idx,profile1,'Color',	"#7E2F8E",'LineWidth', 2)
plot(profile2_idx,profile2,'Color',"#77AC30",'LineWidth', 2)
grid on;
grid minor
xlabel('Image index');
ylabel('Depth (meter)');
title(['Depth Profile of LISST-Holo2 holograms on the ', string(seldate)]);
legend('LISST depth profile', 'Water level','Profile 1','Profile 2','Location','best')


% Copy the 2 profiles in new folders 

profile1_filenames = nom_file(profile1_idx);
profile2_filenames = nom_file(profile2_idx);

opts.Interpreter = 'tex';
% Include the desired Default answer
opts.Default = 'Yes';
% Use the TeX interpreter to format the question
quest = 'Do you want to copy the images from the 2 profiles and save them in separate new folders?';
answer = questdlg(quest,'Save the 2 profiles?',...
                  'Yes','No',opts);

if strcmp(answer,'No')
    return
end   


[status,msg] = mkdir(cleaneddataFolder,date_meas);

if strcmp(msg,'Directory already exists.')
    waitfor(msgbox(["The directory for cleaned data already exists.";"The program will stop."],"Error","error"));
    return
end    

[status1,msg1] = mkdir(fullfile(cleaneddataFolder,date_meas),'Profile1');
[status2,msg2] = mkdir(fullfile(cleaneddataFolder,date_meas),'Profile2');


for k=1:length(profile1_filenames)
    copyfile(strcat(selpath,"\",profile1_filenames(k)),fullfile(cleaneddataFolder,num2str(date_meas),'Profile1'))
end

for k=1:length(profile2_filenames)
    copyfile(strcat(selpath,"\",profile2_filenames(k)),fullfile(cleaneddataFolder,num2str(date_meas),'Profile2'))
end

% Save the plot showing the separation of the 2 profiles

saveas(gcf,fullfile(cleaneddataFolder, num2str(date_meas), strcat(date_meas,' Profiles separation.png')))