%% Clean LISST-Holo2 raw data

% DESCRIPTION TO BE DONE

% Armelle BOUHALI, 01.10.2024


%% TO DO

% Position of the figure windows


%% Workspace initialization

close all;                                                                 % close all figure
clear;                                                                     % remove all variables from the current workspace
clc;                                                                       % delete the command window


%% Initialisation

% Paths of the different folders

currentFolder = pwd;
rawdataFolder = fullfile(extractBefore(currentFolder,'\00_Programs'),'01_Raw data');
cleaneddataFolder = fullfile(extractBefore(currentFolder,'\00_Programs'),'02_Cleaned raw data');


%% Selection of the acqusition date

% Get a list of the dates of the LISST-Holo2 acquisition campaigns

% Get a list of all files and folders in this folder.
Listfiles = dir(rawdataFolder);
% Get a logical vector that tells which is a directory.
dirFlags = [Listfiles.isdir];
% Extract only those that are directories.
subFolders = Listfiles(dirFlags); % A structure with extra info.
% Get only the folder names into a cell array.
subFolderNames = string({subFolders(3:end).name}); % Start at 3 to skip . and ..


% Make user choose the campaign date he wants to clean

date_campaigns = datetime(subFolderNames,'InputFormat','yyyyMMdd');
[indx,tf] = listdlg('Name','Date Selection','PromptString','Select the acquisition date for which you want to clean the raw data:','SelectionMode','single','ListSize',[400,250],'ListString',date_campaigns);

% Print an error message if no date have been selected
while tf==0
    waitfor(msgbox("No acquisiton date has been selected.","Error","warn"));

    date_campaigns = datetime(subFolderNames,'InputFormat','yyyyMMdd');
    [indx,tf] = listdlg('Name','Date Selection','PromptString','Select the acquisition date for which you want to clean the raw data:','SelectionMode','single','ListSize',[400,250],'ListString',date_campaigns);
end
% Save the date selected
seldate = date_campaigns(indx);
%  Determine the path where the corresponding raw data are supposed to be stored
selpath = fullfile(rawdataFolder,subFolderNames(indx),strcat(subFolderNames(indx),'_measures'));
% Print an error message if the folder containing the raw data is not named
% correctly, saved in the correct folder or does not exist
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
    
    depth(1,k) = str2double(sortie_recherche('Depth', 'meter', copie));    % store the depth of current file
end


%% Plotting the depth profile of LISST during image capture

% Plot the depth profile

figure(1)
hold on
plot(depth,'Marker',".",'MarkerEdgeColor',"#D95319","LineStyle","--","Color","#D95319");
yline(0,'Color', "#0072BD")
set(gca, 'YDir', 'reverse'); % Invert y-axis
grid on;
grid minor
xlabel('Image index');
ylabel('Depth (meter)');
title(['Depth Profile of LISST-Holo2 holograms on the ', string(seldate)]);
legend('LISST depth profile', 'Water level','Location','best')

% Save the depth profile in the folder '01_Raw data'

date_meas = extractAfter(selpath,"01_Raw data\");
date_meas = extractBefore(date_meas,9);

saveas(gcf,fullfile(selpath, strcat(date_meas,' Raw data depth profile.png')))


%%


% Make the user decide if he wants the raw data to be cleaned

opts.Interpreter = 'tex';
% Include the desired Default answer
opts.Default = 'Yes';
% Use the TeX interpreter to format the question
quest = ['The folder selected contains ', num2str(length(nom_file)), ' .pgm files.', 'Do you want to clean the raw data to select only the holograms taken when the LISST-Holo2 was underwater and going downwards?'];
answer = questdlg(quest,'Clean the raw data?',...
                  'Yes','No',opts);

if strcmp(answer,'No')
    return
end    

% Find the index of the last image taken at the maximum depth

max_depth = max(depth);
idx_max_depth = find(depth==max_depth,1,'last');

% Find the index of the first image taken at a depth >1m

idx_underwater = find(depth>1,1,'first');


% Plot the cleaned raw data depth profile

figure(2)
hold on
% plot(depth,'Color',"#D95319",'LineWidth', 2);
plot(depth,'Marker',".",'MarkerEdgeColor',"#D95319","LineStyle","--","Color","#D95319");
% plot(idx_underwater:idx_max_depth,depth(idx_underwater:idx_max_depth),'Color',"#77AC30",'LineWidth', 2)
plot(idx_underwater:idx_max_depth,depth(idx_underwater:idx_max_depth),'Marker',".",'MarkerEdgeColor',"#77AC30","LineStyle","--",'Color',"#77AC30")
set(gca, 'YDir', 'reverse'); % Invert y-axis
yline(0,'Color', "#0072BD")
grid on;
grid minor
xlabel('Image index');
ylabel('Depth (meter)');
title(['Depth Profile of LISST-Holo2 holograms on the ', string(seldate)]);
legend('LISST depth profile','Cleaned raw data', 'Water level','Location','best')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define a threshold for considering the depth as constant
threshold = 0.11;

% Find the indices where the depth is constant
constant_depth_indices = find(abs(diff(depth(idx_underwater:idx_max_depth))) < threshold) + idx_underwater -1; % indices des plateaux (mais il manque l'indice de la dernière mesure du plateau!!!)

% Create an array to hold the indices of the constant depth segments
constant_segments = [];

% Loop through the constant indices and find contiguous segments
for i = 1:length(constant_depth_indices)-1
    if constant_depth_indices(i+1) - constant_depth_indices(i) == 1        % if the indices are successive
        if isempty(constant_segments) || constant_segments(end, 2) < constant_depth_indices(i) 
            constant_segments(end+1, :) = [constant_depth_indices(i), constant_depth_indices(i+1)];
        else
            constant_segments(end, 2) = constant_depth_indices(i+1);
        end
    end
end

constant_segments(:,2) = constant_segments(:,2)+1;

% Remove the moments when the Lisst holo was going slowly but was not
% stopped on purpose

% Create a logical index for rows to keep
keep_rows = true(size(constant_segments, 1), 1);

% for k = 1:size(constant_segments,1)
%     if constant_segments(k,2)- constant_segments(k,1) <10
%          keep_rows(k) = false;  % Mark this row for removal
%     end
% end

% Filter the constant_segments based on the logical index
constant_segments = constant_segments(keep_rows, :);

figure (3)
hold on
plot(depth,'k')
for i=1:size(constant_segments,1)
    plot(constant_segments(i,1):constant_segments(i,2),depth(constant_segments(i,1):constant_segments(i,2)))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Copy the cleaned raw data in a new folder 

cleaned_data = nom_file(idx_underwater:idx_max_depth);

opts.Interpreter = 'tex';
% Include the desired Default answer
opts.Default = 'Yes';
% Use the TeX interpreter to format the question
quest = ['There are ', num2str(length(cleaned_data)), ' .pgm files in the cleaned raw data (on ', num2str(length(nom_file)), ' raw holograms).', 'Do you want to copy the cleaned data and save them in a new folder?'];
answer = questdlg(quest,'Save the cleaned raw data?',...
                  'Yes','No',opts);

if strcmp(answer,'No')
    return
end   

[status,msg] = mkdir(cleaneddataFolder,date_meas);


if strcmp(msg,'Directory already exists.')
    waitfor(msgbox(["The directory for cleaned data already exists.";"The program will stop."],"Error","error"));
    return
end    

for k=1:length(cleaned_data)
    copyfile(strcat(selpath,"\",cleaned_data(k)),fullfile(cleaneddataFolder,num2str(date_meas)))
end

% Save the depth profile in the folder '02_Cleaned raw data'

saveas(gcf,fullfile(cleaneddataFolder, num2str(date_meas), strcat(date_meas,' Cleaned raw data depth profile.png')))

