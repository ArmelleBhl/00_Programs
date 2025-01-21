%% Workspace initialization

close all;                                                                 % close all figure
clear;                                                                     % remove all variables from the current workspace
clc;  


%% Read table

ModesTable = readtable(fullfile(extractBefore(pwd,'\00_Programs'),'Armelle','Results modes size distribution.xlsx'),"VariableNamingRule","modify");  


%% Plot

figure(1)
hold on
set(gca, 'YDir', 'reverse'); % Invert y-axis
xscale log
xlim([10 1000])
% ylim([datetime("2024-01-01") datetime("2024-12-31")])
ylim("padded")
grid minor
xlabel('Mode diameter size class (um)')
ylabel('Date')
p1 = plot([ModesTable.Epilimion1 ModesTable.Epilimion2].',[ModesTable.AcquisitionDate ModesTable.AcquisitionDate].','LineStyle','-','Color',"#4DBEEE",'LineWidth',2);
p2 = plot([ModesTable.TP1 ModesTable.TP2].',[ModesTable.AcquisitionDate ModesTable.AcquisitionDate].','LineStyle','-','Color',"#0072BD",'LineWidth',2);
p3 = plot([ModesTable.BelowTP1 ModesTable.BelowTP2].',[ModesTable.AcquisitionDate ModesTable.AcquisitionDate].','LineStyle','-','Color',"#D95319",'LineWidth',2);
p4 = plot([ModesTable.Hypolimnion1 ModesTable.Hypolimnion2].',[ModesTable.AcquisitionDate ModesTable.AcquisitionDate].','LineStyle','-','Color',"#EDB120",'LineWidth',2);

legend([p1(1),p2(2),p3(3),p4(4)],'Epilimnion','Turbidity peak','Below turbidity peak','Hypolimnion','Location','best')
