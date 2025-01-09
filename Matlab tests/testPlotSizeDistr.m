%% Workspace initialization

close all;                                                                 % close all figure
clear;                                                                     % remove all variables from the current workspace
clc;                                                                       % delete the command window


%% Selection and reading of the Excel file

% User selection of the Excel file
[filePstat,locationPstat] = uigetfile('*.xlsx',...
    'Select an Excel file',...
    fullfile(extractBefore(pwd,'\00_Programs'),'03_Processed data'));      % user selects the 'ALL' csv file to which variable names and units will be added

if isequal(filePstat,0)                                                         % a message is diplayed showing the selection made by the user
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(locationPstat,filePstat)]);
end

% Reading of the selected csv file
Table = readtable(fullfile(locationPstat,filePstat));                                  % read the csv file selected and save it as a table


%% Extraction of the data

% Depth
depth = Table.Var1(5:end);
% Size class
size_class = Table(3,3:end);
size_class = table2array(size_class);
% Size distribution
size_distr = Table(5:end,3:end);
size_distr = table2array(size_distr);

% Depth limits of the turbidity peak
upperLimTP = 5;
TP = 18;
lowerLimTP = 38;


idx_aboveTP = find((depth<=upperLimTP) & (depth>upperLimTP-10));
idx_TP = find((depth>TP-2) & (depth<TP+2));
idx_belowTP = find((depth>=lowerLimTP) & (depth<lowerLimTP+10));



%% Plot

% Set color vector
color = turbo(111);

figure (1)
hold on
for k=1:size(size_distr,1)
    plot(size_class,size_distr(k,:),'Color',color(depth(k)+1,:))
end    
xscale log
xlim([10 1000])
xlabel('Diameter')
ylabel('%SPMVC')
title('Particle size distribution for all the images of the campaign')
colormap(turbo(110))
cb = colorbar('Ticks',linspace(0,1,12),...
         'TickLabels',{'0','10','20','30','40','50','60','70','80','90','100','110'});
cb.Label.String = 'Depth (m)';


figure (2)
color = cool(50);
hold on
for k=1:length(idx_belowTP)
    idx= idx_belowTP(k);
    plot(size_class,size_distr(idx,:),'Color',color(depth(idx)+1,:))
end 
for k=1:length(idx_TP)
    idx=idx_TP(k);
    plot(size_class,size_distr(idx,:),'Color',color(depth(idx)+1,:))
end  
for k=1:length(idx_aboveTP)
    idx=idx_aboveTP(k);
    plot(size_class,size_distr(idx,:),'Color',color(depth(idx)+1,:))
end  
xscale log
xlim([10 1000])
xlabel('Diameter')
ylabel('%SPMVC')
title('Particle size distribution for a selection of the campaign')
colormap(cool(50))
cb = colorbar('Ticks',linspace(0,1,6),...
         'TickLabels',{'0','10','20','30','40','50'});
cb.Label.String = 'Depth (m)';

