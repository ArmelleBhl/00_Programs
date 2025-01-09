function CleanRawData(depth,seldate,nom_file,date_meas,answeNBprofiles,profile_filenames, cleaneddataFolder, selpath)
% This function cleans the raw data and only keeps the data that was taken
% when the LISS-Holo2 was underwater and going downwards

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%% Find the index of the 'cleaned' data
% 'Cleaned' data refers to holograms taken when the LISST-Holo2 was:
% - underwater (i.e. depth >1m)
% - going downwards (i.e. first part of the profile, until the LISST
% reaches the maximum depth)
% - acquired when the LISST was stopped at a depth level (the LISST was not
% moving)

% Find the index of the last image taken at the maximum depth
max_depth = max(depth);
idx_max_depth = find(depth==max_depth,1,'last');

% Find the index of the first image taken at a depth >1m
idx_underwater = find(depth>1,1,'first');

% % Define a threshold for considering the depth as constant
% threshold = 0.11;
% 
% % Find the indices where the depth is constant
% constant_depth_indices = find(abs(diff(depth(idx_underwater:idx_max_depth))) < threshold) + idx_underwater;
% 
% % Create an array to hold the indices of the constant depth segments
% constant_segments = [];
% 
% % Loop through the constant indices and find contiguous segments
% for i = 1:length(constant_depth_indices)-1
%     if constant_depth_indices(i+1) - constant_depth_indices(i) == 1        % if the indices are successive
%         if isempty(constant_segments) || constant_segments(end, 2) + 1 < constant_depth_indices(i) 
%             constant_segments(end+1, :) = [constant_depth_indices(i), constant_depth_indices(i)];
%         else
%             constant_segments(end, 2) = constant_depth_indices(i);
%         end
%     end
% end
% 
% % constant_segments(:,1) = constant_segments(:,1)-1;
% % constant_segments(:,2) = constant_segments(:,2)+1;

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

for k = 1:size(constant_segments,1)
    if constant_segments(k,2)- constant_segments(k,1) <10
         keep_rows(k) = false;  % Mark this row for removal
    end
end

% Filter the constant_segments based on the logical index
constant_segments = constant_segments(keep_rows, :);

% File names of the data taken when the LISST-Holo2 was underwater and
% going downwards
cleaned_data_idx = [];
for i= 1:size(constant_segments,1)
    a= constant_segments(i,1):constant_segments(i,2);
    cleaned_data_idx= [cleaned_data_idx a];
end    

cleaned_data_file_names = nom_file(cleaned_data_idx);


%% Plot the clean raw data depth profile

figure(4)
hold on
% plot(depth,'Color',"#D95319",'LineWidth', 2);
% plot(depth,'Marker',".",'MarkerEdgeColor',"#D95319","LineStyle","--","Color","#D95319");
plot(depth,'Marker',".",'MarkerEdgeColor',"k","LineStyle","none","Color","k");
% plot(idx_underwater:idx_max_depth,depth(idx_underwater:idx_max_depth),'Color',"#77AC30",'LineWidth', 2)
% plot(idx_underwater:idx_max_depth,depth(idx_underwater:idx_max_depth),'Marker',".",'MarkerEdgeColor',"#77AC30","LineStyle","--",'Color',"#77AC30")
% plot(ipt + idx_underwater, depth(ipt),'k','MarkerSize',3)
% for i=1:size(constant_segments,1)
%     plot(constant_segments(i,1):constant_segments(i,2),depth(constant_segments(i,1):constant_segments(i,2)))
% end
% plot(cleaned_data_idx,depth(cleaned_data_idx),'Marker',".",'MarkerEdgeColor',"#77AC30",'MarkerSize',6,"LineStyle","none")
plot(cleaned_data_idx,depth(cleaned_data_idx),'Marker',".",'MarkerEdgeColor',"#D95319",'MarkerSize',8,"LineStyle","none")
set(gca, 'YDir', 'reverse'); % Invert y-axis
yline(0,'Color', "#4DBEEE")
grid on;
grid minor
xlabel('Image index');
ylabel('Depth (meter)');
title(['Depth Profile of LISST-Holo2 holograms on the ', string(seldate)]);
legend('LISST depth profile','Cleaned raw data', 'Water level','Location','best')


%% Make the user choose if he wants the cleaned data to be saved

opts.Interpreter = 'tex';
% Include the desired Default answer
opts.Default = 'Yes';
% Use the TeX interpreter to format the question
quest = ['There are ', num2str(length(cleaned_data_file_names)), ' .pgm files in the cleaned raw data (on ', num2str(length(nom_file)), ' raw holograms).', 'Do you want to copy the cleaned data and save them in a new folder?'];
answerSaveCleanedData = questdlg(quest,'Save the cleaned raw data?',...
                  'Yes','No',opts);
% Stop the function CleanRawData if the user don't want to save the cleaned
% data
if strcmp(answerSaveCleanedData,'No')
    return
end 


%% Copy the cleaned raw data in a new folder 

if strcmp(answeNBprofiles,'2 profiles')
    % Delete the raw data that is not underwater and going downwards
    for k=1:length(profile_filenames)
        if sum(strcmp(profile_filenames(k),cleaned_data_file_names))==0
            delete(profile_filenames(k))
        end
    end    

elseif strcmp(answeNBprofiles,'1 profile')
    % Create a directory to save the cleaned data
    [~,msg] = mkdir(cleaneddataFolder,date_meas);

    if strcmp(msg,'Directory already exists.')
        waitfor(msgbox(["The directory for cleaned data already exists.";"The program will stop."],"Error","error"));
        return
    end  

    % Save the cleaned data in the folder created just before
    for k=1:length(cleaned_data_file_names)
        copyfile(strcat(selpath,"\",cleaned_data_file_names(k)),fullfile(cleaneddataFolder,num2str(date_meas)))
    end

    % Save the depth profile in the folder '02_Cleaned raw data'
    saveas(gcf,fullfile(cleaneddataFolder, num2str(date_meas), strcat(date_meas,' Cleaned raw data depth profile.png')))

end


end