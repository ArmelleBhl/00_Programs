% Clear the workspace
clear; clc;


%%% Directory where the raw PGM data of LISST is located

directory_name = 'D:\LISST-HOLO\LouiseNoelDuPayrat_LakeSnow\Sources';
dossier = input('Dossier brut à étudier: ', 's');

%%% Extracting LISST data

depth = [];
depth_str = {};
temperature = {};
voltage = {};
size = {};   
exposure = {};
delay = {};
shutter = {};
gain = {};
power = {};
version = {};

nom_file = {};
indexs = [];
timing = [];
i = 0;

raw_data_path = fullfile(directory_name, dossier, '00_raw_data');

files = dir(fullfile(raw_data_path, '*.pgm')); % Adjust file extension as needed

for k = 1:length(files)
    file_name = files(k).name;
    nom_file{end+1} = file_name; % Append file name
    i = i + 1;
    indexs(end+1) = i; % Append index
    timing(end+1) = i / 60; % Timing in minutes
    
    file_path = fullfile(raw_data_path, file_name);
    fid = fopen(file_path, 'rb');
    copie = fread(fid, '*char')'; % Read the file as characters
    fclose(fid);
    
    depth(end+1) = str2double(sortie_recherche('Depth', 'meter', copie));
    
    depth_str{end+1} = sortie_recherche('Depth', 'meter', copie);
    temperature{end+1} = sortie_recherche('Temperature', '&deg', copie);
    voltage{end+1} = sortie_recherche('Input voltage', 'volts', copie);
    size{end+1} = sortie_recherche('Image size', '.', copie);
    exposure{end+1} = sortie_recherche('Exposure \(laser on time\)', 'us', copie);
    delay{end+1} = sortie_recherche('Delay from camera strobe \(start of exposure\)', 'us', copie);
    shutter{end+1} = sortie_recherche('Camera shutter \(exposure\)', '.', copie);
    gain{end+1} = sortie_recherche('Camera gain', '.', copie);
    power{end+1} = sortie_recherche('Laser power', '.', copie);
    version{end+1} = sortie_recherche('Imager code version Mar 17 2022', '.', copie);
end

%%% Plotting the depth profile of LISST during image capture

figure('Position', [100, 100, 1200, 800]);
plot(indexs, depth, 'LineWidth', 2);
set(gca, 'YDir', 'reverse'); % Invert y-axis
grid on;
xlabel('Index');
ylabel('Depth (meter)');
title('Depth Profile of LISST');

%%% Dictionary of images by depths:
% For easy extraction of images at the same depths and processing them together
% To perform statistics on the levels

dictionnaire = containers.Map('KeyType', 'char', 'ValueType', 'any');

for i = 1:length(depth_str)
    if isKey(dictionnaire, depth_str{i})
        ancien = dictionnaire(depth_str{i});
    else
        ancien = {};
    end
    ancien{end+1} = nom_file{i}; % Append file name
    dictionnaire(depth_str{i}) = ancien; % Update the dictionary
end

%%% Functions

function result = sortie_recherche(born_dep, borne_fin, copie)
    rechercher = strcat(born_dep, '(.*)', borne_fin);
    result = regexp(copie, rechercher, 'tokens');
    if isempty(result)
        result = '';
    else
        result = strtrim(result{1}{1}); % Get the first captured group and trim spaces
    end
end
