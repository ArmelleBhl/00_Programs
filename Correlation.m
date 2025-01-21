%% Workspace initialization

close all;                                                                 % close all figure
clear;                                                                     % remove all variables from the current workspace
clc; 


CTDturbidity_mean_depth_level_ALL= [];
NBparticles_mean_ALL = [];


%%

CTDturbidity_mean_depth_level_ALL = [CTDturbidity_mean_depth_level_ALL; CTDturbidity_mean_depth_level];
NBparticles_mean_ALL = [NBparticles_mean_ALL; NBparticles_mean];
%%
save('TurbidityParticlesALL.mat',"NBparticles_mean_ALL","CTDturbidity_mean_depth_level_ALL")

%%
% b = CTDturbidity_mean_depth_level_ALL./NBparticles_mean_ALL;
% yCalc = CTDturbidity_mean_depth_level_ALL.*b;

mdl = fitlm(CTDturbidity_mean_depth_level_ALL.',NBparticles_mean_ALL.','linear');
% mdl = fitlm(CTDturbidity_mean_depth_level_ALL(NBparticles_mean_ALL<=600).',NBparticles_mean_ALL(NBparticles_mean_ALL<=600).','linear','Intercept',false);
Rsquared = mdl.Rsquared.Ordinary;

figure(1)
hold on
plot(CTDturbidity_mean_depth_level_ALL,NBparticles_mean_ALL,'LineStyle','none','Marker','.','MarkerSize',8)
p= plot(mdl);
delete(p(1))
% p(end-1,1).Visible='off';
% p(end,1).Visible='off';
% plot(linspace(1,15,100),vq)
% plot(CTDturbidity_mean_depth_level_ALL,yCalc,'LineStyle','--')
xlabel('Median turbidity measured with the CTD')
ylabel('Median number of particles detected by the LISST')
xlim([0 15])
ylim([0 2000])
title('Measured turbidity VS Number of particles')
str=[    'N = ',sprintf('%d',mdl.NumObservations),...  
', R^2 = ',sprintf('%.2f',mdl.Rsquared.Ordinary),...
%'y = ',sprintf('%.2f',table2array(mdl.Coefficients(2,1))),'x + ',sprintf('%.2f',table2array(mdl.Coefficients(1,1)))
]
annotation('textbox',[.15 0.9 0 0],'string',str,'FitBoxToText','on','EdgeColor','black') 
% saveas(gcf,fullfile(analysisFolder, 'Number of particules VS Turbidity','Median', 'All Dates',' MeanCorrelationTurbidityNBparts.png'))
