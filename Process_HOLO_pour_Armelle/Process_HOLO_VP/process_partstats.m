clear; close all;clc

%% LOAD GENERAL FILE FROM HOLOBATCH
holo_files = dir(fullfile(extractBefore(pwd,'\00_Programs'),'03_Processed data','20230927','Size distributions','*_All.csv'));
holo_file = fullfile(holo_files.folder,holo_files.name);
holo_mat = importfile_holo(holo_file, 1); 

%% PROCESS PSD FROM HOLOBATCH
nb_particles=holo_mat(6:end,19);
tot_vol=nanmean(holo_mat(6:end,25));

diam=holo_mat(4,26:end);                               % median diameter
sizebin=diff(diam(1:50));

psd_all=holo_mat(6:end,26:end);
psd_all(psd_all==0)=NaN;
psd=nanmean(psd_all);

vd_median=psd(1:end-1)./sizebin;                        %normalized by size class
vd_rel=(vd_median./nansum(vd_median)).*100;             %relativ in % from the volume total

tot_vol=nanmean(holo_mat(6:end,25)); 

%% PROCESS INDIVIDUAL PARTICLES FROM PSTATS
rep0=dir(fullfile(extractBefore(pwd,'\00_Programs'),'03_Processed data','20230927','Size distributions','*pstat.csv'));
indmax=length(rep0);

%% PRE-ALLOCATE FOR SPEED =================================================
ECD=NaN(length(rep0),2000);             %ECD provided by holobatch
axmin=NaN(length(rep0),2000);
axmaj=NaN(length(rep0),2000);
AR=NaN(length(rep0),2000);
area=NaN(length(rep0),2000);            % area
perim=NaN(length(rep0),2000);           % perimeter 
vol=NaN(length(rep0),2000);             % volume
DFpf=NaN(length(rep0),2000);            % Perimeter Based Fractal Dim. (Vahedi (2007))
DF3D=NaN(length(rep0),2000);            % 3D Fractal Dim. (Lee and Kramer, 2004)
ws=NaN(length(rep0),2000);              % Settling velocotiy from Winterwep (1998) equation // included AR and DF3D
wst=NaN(length(rep0),2000);             % Settling velocotiy from Stoke law

h = waitbar(0,'Image Processing - Please wait...');
    
%% LOOP ON IMAGE NUMBER
for i =1:indmax
waitbar(i / indmax)

load([rep0(i).name])% LOAD PSTATS

%% LOOP ON INDIIDUAL PARTICLES
for j=1:length(PartStats)   
      
  ECD(i,j)=PartStats(j).EquivDiameter;                      %ECD
  vol(i,j)=PartStats(j).Volume;                             %VOLUME
  perim(i,j)=PartStats(j).Perimeter;                        %PERIMETER
  area(i,j)=PartStats(j).Area;                              %AREA
 
  axmin(i,j)= PartStats(j).MinorAxisLength;                 %MINI AXIS
  axmaj(i,j)= PartStats(j).MajorAxisLength;                 %MAJOR AXIS

  AR(i,j)=axmin(i,j)/axmaj(i,j);                            %ASPECT RATIO
  
  DFpf(i,j)=2*log(perim(i,j))/log(area(i,j));               %DF2D          % Vahedi et Gorczyca (2011) 
  
  DF3D(i,j)=(-1.628*DFpf(i,j))+4.6;                         %DF3D          % Lee and Kramer (2004)
 
  %ESTIMATE WS
  %CONSTANT
  rhow=1000;
  rhos=2650;
  nukin=1.3*10^-6;                                          %kinematic viscosity of water at 10°C in m2/s
  nu=1.3*10^-3;                                             %dynamic viscosity of water at 10°C in Pa (kg/m/s)
  VS = 0.001;                                               %vitesse fluide relative à l'object
  RE=(VS*(ECD(i,j)*10^-6))/nukin;                           %reynolds number (1 to 3, generally 1)
  d=1;                                                      %PRIMARY PARTICLE SIZE
  tetha=AR(i,j);                                            %aspect ratio parameter 

ws(i,j)=(tetha/18)*(((rhos-rhow)*9.81)/nu)*((d*10^-6)^(3-DF3D(i,j)))*((ECD(i,j)*10^-6)^(DF3D(i,j)-1)/(1+(0.15*(RE^0.687))));
ws(i,j)=ws(i,j)*1000;

%spherical particles
tetha=1;     
wss(i,j)=(tetha/18)*(((rhos-rhow)*9.81)/nu)*((d*10^-6)^(3-DF3D(i,j)))*((ECD(i,j)*10^-6)^(DF3D(i,j)-1)/(1+(0.15*(RE^0.687))));
wss(i,j)=wss(i,j)*1000;
 
%stokes
wst(i,j)= (2/9)*((rhos-rhow)./nu)*9.81*((ECD(i,j)*10^-6./2).^2);
wst(i,j)=wst(i,j)*1000;

% Chakraborti 
wsc(i,j)=1.86*((ECD(i,j)*10^-6).^2);
wsc(i,j)=wsc(i,j)*1000000;

end

end
close(h)

%% PLOT PART
%MEAN OF VOLUME (FROM HOLOBATCH)
figure
subplot 211
plot(diam(1:end-1),abs(vd_rel),'linewidth',2)
set(gca, 'Xscale', 'log')
ylabel('% SPMVC')
xlabel('ECD (μm)')
%text(max(ECD(:))-100,10,['Tot. vol.=' num2str(tot_vol) ' μl l^-^1'],'fontsize',12,'fontweight','b')
%xlim([10^0 10^3])
%ylim([0 30])
set(gca,'fontsize',12,'fontweight','b')
grid on
xlimit=get(gca,'Xlim');

% NUMBER OF PARTICLES (FROM PSTATS FILES)
subplot 212
bin=20:10:2000;
%bins = 10.^(0:5);
occur=histc(ECD(:),bin);
bar(bin,occur,'FaceColor',[0 .45 .74])
xlabel('ECD (µm)')
ylabel('Nb of part.')
grid on
xlim([xlimit])
%ylimit=get(gca,'Ylim');
ylim([10^-1 10^3])
yticks([10^0 10^1 10^2 10^3])
set(gca,'fontsize',12,'fontweight','b')
set(gca,'Yscale','log')
set(gca,'Xscale','log')
currentfolder=pwd; 
%print('-dpng','-r300',[currentfolder,'PSD_HOLO.png'])
%save([currentfolder, 'PSD_HOLO'],'vd_rel','diam')

 

%% MAKE DENSITY PLOT FOR AR / DF3D 
%% figure;
%ASPECT RATION
subplot 121
x = AR(:)'; %x(x==0)=NaN;
y = ECD(:)';

bins=[0,1,11;0,300,13];
h=histogram2(x,y,bins);

X=0:.1:1;X=repmat(X',1,bins(2,3)); 
Y=0:25:300;Y=repmat(Y,bins(1,3),1);

pcolor(Y,X,log10(h));
colormap jet
myscale=[.1 1000];
hi=colorbar;
caxis(myscale)
ticks_wanted=[.1 1 10 100 1000];
caxis(log10(myscale))
hi.Title.String = {'nb. of', 'particles'};
set(hi,'YTick',log10(ticks_wanted));
set(hi,'YTickLabel',ticks_wanted); 
set(gca,'fontsize',17,'fontweight','b')
xlabel('ECD (µm)')
ylabel('AR')
set(gcf,'Color','w')

% DF3D
subplot 122
x = DF3D(:)'; %x(x==0)=NaN;
y = ECD(:)';

%bins=[1.8,2.6,17;0,400,9]; %[lowerx,upperx,ncellx;lowery,uppery,ncelly]
bins=[2.0,2.6,25;0,300,13];
h=histogram2(x,y,bins);

%X=1.8:0.05:2.6;X=repmat(X',1,bins(2,3)); 
%X=2.0:0.05:2.6;X=repmat(X',1,bins(2,3)); 
X=2.0:0.025:2.6;X=repmat(X',1,bins(2,3)); 
Y=0:25:300;Y=repmat(Y,bins(1,3),1);

% PLOT
pcolor(Y,X,log10(h)); hold on 
myscale=[.1 1000];
mycolormap = customcolormap([0 0.5 0.8 1], [0.1 0.1 0.3; 0.1 0.6 0.5; 1 1 1; 1 1 1]);
colorbar;
colormap(mycolormap);
hi=colorbar;
caxis(myscale)
ticks_wanted=[.1 1 10 100 1000];
caxis(log10(myscale))
hi.Title.String = {'nb. of', 'particles'};
set(hi,'YTick',log10(ticks_wanted));
set(hi,'YTickLabel',ticks_wanted); 
set(gcf,'Color','w')
set(gca,'fontsize',17,'fontweight','b')
ylabel('DF_3_D')
xlabel('ECD (µm)')
set(gcf, 'PaperPosition', [0 0 25 15])

print('-dpng','-r300',[currentfolder,'density_plots.png'])

%% PLOT SCATTER
figure

% total number of particles
nb=~isnan(ECD);
nbpart=nansum(nansum(nb));

% variables into vectors
y = ws(:)'; 
x = ECD(:)';
z = AR(:)'; z(z==0)=NaN;

%plot
subplot 121
scatter(x,y,2,z,'filled'); hold on ; 
h=colorbar; colormap(gca,cmocean('thermal')) ; caxis([0 1])
xlim([10 300])
ylim([0.005 10])
set(gca, 'Xscale', 'log')
set(gca, 'Yscale', 'log')
xlabel('ECD (µm)')
ylabel('Ws (mm s^-^1)')
h.Title.String = 'AR';
set(gca,'tickdir','out'); set(gca,'fontsize',13,'fontweight','b')
grid on
ref=[30:10:150];
[binnedws,n_points,std_bin]=bindata(ECD,ws,ref);
scatter(ref,binnedws,10,'filled','k'); hold on
errorbar(ref,binnedws,std_bin,'k','linestyle','none','handlevisibility','off');hold on 
errorbar(ref,binnedws,-std_bin,'k','linestyle','none','handlevisibility','off'); hold on 
iok=~isnan(binnedws);
[p1, s1]=polyfit(log10(ref(iok)),log10(binnedws(iok)),1);
y1=10^(p1(1,2))*(ref(iok).^p1(1,1));
plot(ref(iok),y1,'color','k','linewidth',1,'handlevisibility','off');hold on
set(gcf, 'PaperPosition', [0 0 25 15])
text(15,8,['N_i_m_a_g_e_s = ' num2str(i)],'fontsize',13,'fontweight','b'); 
text(15,5,['N_p_a_r_t_i_c_l_e_s = ' num2str(nbpart)],'fontsize',13,'fontweight','b');
text(15,3,['y = ' num2str(round(p1(1)*100)/100) ' x + ' num2str(abs(round(p1(2)*100)/100))],'color','k','fontsize',12,'fontweight','b')

% variables into vectors
y = ws(:)'; % change to WS of interest here 
x = ECD(:)';
z = DF3D(:)'; z(z==0)=NaN;

%plot
subplot 122
scatter(x,y,2,z,'filled'); hold on ; 
h=colorbar; colormap(gca,cmocean('thermal')) ; caxis([1.9 2.5])
xlim([10 300])
ylim([0.005 10])
set(gca, 'Xscale', 'log')
set(gca, 'Yscale', 'log')
xlabel('ECD (µm)')
ylabel('Ws (mm s^-^1)')
h.Title.String = 'DF_3_D';
set(gca,'tickdir','out'); set(gca,'fontsize',13,'fontweight','b')
grid on
if key==1;
ref=[30:10:300];
elseif key==0;
ref=[30:10:150];
end 
[binnedws,n_points,std_bin]=bindata(ECD,ws,ref);
scatter(ref,binnedws,10,'filled','k'); hold on
errorbar(ref,binnedws,std_bin,'k','linestyle','none','handlevisibility','off');hold on 
errorbar(ref,binnedws,-std_bin,'k','linestyle','none','handlevisibility','off'); hold on 
iok=~isnan(binnedws);
[p1, s1]=polyfit(log10(ref(iok)),log10(binnedws(iok)),1);
y1=10^(p1(1,2))*(ref(iok).^p1(1,1));
plot(ref(iok),y1,'color','k','linewidth',1,'handlevisibility','off');hold on
text(15,8,['N_i_m_a_g_e_s = ' num2str(i)],'fontsize',13,'fontweight','b'); 
text(15,5,['N_p_a_r_t_i_c_l_e_s = ' num2str(nbpart)],'fontsize',13,'fontweight','b'); 
text(15,3,['y = ' num2str(round(p1(1)*100)/100) ' x + ' num2str(abs(round(p1(2)*100)/100))],'color','k','fontsize',12,'fontweight','b')

print('-dpng','-r300',[currentfolder,'Ws_plot.png'])

%% Save 
save([currentfolder,'_matrices.mat'],'ECD','axmaj','axmin','perim','area','AR','DFpf','DF3D','ws','bin','diam','psd','psd_all');

