%% Link the 2 csv files

%% Workspace initialization

close all;                                                                 % close all figure
clear;                                                                     % remove all variables from the current workspace
clc;                                                                       % delete the command window


%% Initialisation

% Paths of the different folders

currentFolder = pwd;
rawdataFolder = fullfile(extractBefore(currentFolder,'\00_Programs'),'01_Raw data');
% cleaneddataFolder = fullfile(extractBefore(currentFolder,'\00_Programs'),'02_Cleaned raw data');
processeddataFolder = fullfile(extractBefore(currentFolder,'\00_Programs'),'03_Processed data');


%% Selection of the acqusition date

% Get a list of the dates of the LISST-Holo2 acquisition campaigns

% Get a list of all files and folders in this folder.
Listfiles = dir(processeddataFolder);
% Get a logical vector that tells which is a directory.
dirFlags = [Listfiles.isdir];
% Extract only those that are directories.
subFolders = Listfiles(dirFlags); % A structure with extra info.
% Get only the folder names into a cell array.
subFolderNames = string({subFolders(3:end).name}); % Start at 3 to skip . and ..


% Make user choose the campaign date

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

%  Determine the path where the 'ALL' and the 'pstat' files are stored
selpath = fullfile(processeddataFolder,subFolderNames(indx),'Size distributions');
% Print an error message if the folder containing the raw data is not named
% correctly, saved in the correct folder or does not exist
if isfolder(selpath) ~= 1 
    waitfor(msgbox(["The folder 'Size distributions' containing the 'ALL' csv at the date selected does not exist, is not named correctly or is not saved in the folder E:\03_Processed data\yyyymmdd.";"The program will stop.";"Please check the raw data folder and start again."],"Error","error"))
    return
end    


%% Read the 'All' csv file

ALLfilename = dir(fullfile(selpath,'*_All.csv'));
ALLtable = readtable(fullfile(selpath,ALLfilename.name));  


%% Reading of the Pstat csv files

cd(selpath)
ListPstatfiles = dir('*-pstat.csv');
cd(currentFolder)

% vérifier qu'il y a le bon nombre de fichier pstat
if length(ListPstatfiles) ~= size(ALLtable(5:end,:),1)
    waitfor(msgbox(["The folder 'Size distributions' of the selected campaign does not contain the expected number of '-pstat.csv' files.";"The program will stop.";"Please check the processed data and start again."],"Error","error"))
    return
end    

% vérifier que le fichier pstat correspond à la bonne ligne du ALL csv

for k=4:length(ListPstatfiles)

    % Read the Pstat file
    filePstat = ListPstatfiles(k).name;
    Pstat= readtable(fullfile(selpath,filePstat));

    % Check that the name of the csv file and the line of the ALL file
    % correspond
    PstatImageNumber = extractBefore(filePstat,'-pstat');
    PstatImageNumber = extractAfter(PstatImageNumber,4);
    PstatImageNumber = str2num(PstatImageNumber);
    if PstatImageNumber ~= table2array(ALLtable(4+k,"ImageNumber"))
       waitfor(msgbox(["Probelm with the images number' files.";"The program will stop."],"Error","error"))
       return
    end

    % Creation of the columns to add to the 'pstat.csv' file

    % Initialisation of the columns
    variables = [];
    variables = ["Year_YYYY_", "Month_MM_","Day_DD_","Hour_HH_",...
    "Minute_MM_","Second_SS_","Depth_m_",...
    "DeploymentID","ImageNumber","TotalNumberOfParticles"];     % list of the variables names
    variables(2:size(Pstat,1)+1,:)=NaN;                                          % add NaN to the end of the list so that its size matches the number of columns of the csv
    variables = array2table(variables);                                        % transform the array into a table for a concatenation later
    variables.Properties.VariableNames = table2array(variables(1,:));          % change the variables'names for a concatenation later
    variables(1,:)=[];

    % Fill the columns with the correct data
    variables.("Year_YYYY_")=repmat(ALLtable.Year_YYYY_(4+k),size(variables,1),1);
    variables.("Month_MM_")=repmat(ALLtable.Month_MM_(4+k),size(variables,1),1);
    variables.("Day_DD_")=repmat(ALLtable.Day_DD_(4+k),size(variables,1),1);
    variables.("Hour_HH_")=repmat(ALLtable.Hour_HH_(4+k),size(variables,1),1);
    variables.("Minute_MM_")=repmat(ALLtable.Minute_MM_(4+k),size(variables,1),1);
    variables.("Second_SS_")=repmat(ALLtable.Second_SS_(4+k),size(variables,1),1);
    variables.("Depth_m_")=repmat(ALLtable.Depth(4+k),size(variables,1),1);
    variables.("DeploymentID")=repmat(ALLtable.DeploymentID(4+k),size(variables,1),1);
    variables.("ImageNumber")=repmat(ALLtable.ImageNumber(4+k),size(variables,1),1);
    variables.("TotalNumberOfParticles")=repmat(ALLtable.NumberOfParticles(4+k),size(variables,1),1);

    % Addition of the columns to the Pstat table

    Pstat = [variables Pstat];

    writetable(Pstat,fullfile(selpath,filePstat),"WriteVariableNames",true);        % overwrite the 'pstat' csv file selected by the user to save the changes made using this program

end




