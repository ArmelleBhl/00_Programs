function [profile1_idx,profile2_idx] = Separate2profiles(nom_file,depth,seldate)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%% Find the 2 profiles

image_idx = 1:length(nom_file);
underwater = depth(find(depth>=1,1,'first'):find(depth>=1,1,'last'));      % remove the images above water level at the beginning and the end of the raw data
underwater_idx = image_idx(find(depth>=1,1,'first'):find(depth>=1,1,'last'));

profile1 = underwater(1:find(underwater<1,1,'first')-1);
profile1_idx = underwater_idx(1:find(underwater<1,1,'first')-1);

profile2 = underwater(find(underwater<1,1,'last') +1 : end);
profile2_idx = underwater_idx(find(underwater<1,1,'last') +1 : end);

% Plot the depth profile

figure(2)
hold on
% plot(depth,'Color',"#D95319",'LineWidth', 2);
plot(depth,'Marker',".",'MarkerEdgeColor',"#D95319","LineStyle","--","Color","#D95319")
set(gca, 'YDir', 'reverse'); % Invert y-axis
yline(0,'Color', "#0072BD")
plot(profile1_idx,profile1,'Marker',".",'MarkerEdgeColor',"#7E2F8E","LineStyle","--",'Color',"#7E2F8E")
plot(profile2_idx,profile2,'Marker',".",'MarkerEdgeColor',"#77AC30","LineStyle","--",'Color',"#77AC30")
grid on;
grid minor
xlabel('Image index');
ylabel('Depth (meter)');
title(['Depth Profile of LISST-Holo2 holograms on the ', string(seldate)]);
legend('LISST depth profile', 'Water level','Profile 1','Profile 2','Location','best')


% % Copy the 2 profiles in new folders 
% 
% profile1_filenames = nom_file(profile1_idx);
% profile2_filenames = nom_file(profile2_idx);

% opts.Interpreter = 'tex';
% % Include the desired Default answer
% opts.Default = 'Yes';
% % Use the TeX interpreter to format the question
% quest = 'Do you want to copy the images from the 2 profiles and save them in separate new folders?';
% answer = questdlg(quest,'Save the 2 profiles?',...
%                   'Yes','No',opts);
% 
% if strcmp(answer,'No')
%     return
% end   
% 
% 
% [~,msg] = mkdir(cleaneddataFolder,date_meas);
% 
% if strcmp(msg,'Directory already exists.')
%     waitfor(msgbox(["The directory for cleaned data already exists.";"The program will stop."],"Error","error"));
%     return
% end    
% 
% [~,~] = mkdir(fullfile(cleaneddataFolder,date_meas),'Profile1');
% [~,~] = mkdir(fullfile(cleaneddataFolder,date_meas),'Profile2');
% 
% 
% for k=1:length(profile1_filenames)
%     copyfile(strcat(selpath,"\",profile1_filenames(k)),fullfile(cleaneddataFolder,num2str(date_meas),'Profile1'))
% end
% 
% for k=1:length(profile2_filenames)
%     copyfile(strcat(selpath,"\",profile2_filenames(k)),fullfile(cleaneddataFolder,num2str(date_meas),'Profile2'))
% end
% 
% % Save the plot showing the separation of the 2 profiles
% 
% saveas(gcf,fullfile(cleaneddataFolder, num2str(date_meas), strcat(date_meas,' Profiles separation.png')))
% 
% 
% %% PRINT MESSAGE THAT ALL WENT WELL
% 
% end