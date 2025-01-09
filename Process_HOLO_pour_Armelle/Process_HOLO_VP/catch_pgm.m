%% read pgm files and catch infos!
 a=dir('*.PGM');
 dpth=NaN(size(a));
 temp=NaN(size(a));
 volt=NaN(size(a));
 LaserPwr=NaN(size(a));
 LaserPhoto=NaN(size(a));
 TotVol=NaN(size(a));
 for i =1:length(a);
     data=imfinfo(a(i).name);
%     %imnumber(i)=data.Filename(1:8);
     time(i)=datenum(data.FileModDate);
% end
%
%%
%% Open the Text File for Reading
fid = fopen(a(i).name,'r'); 
%F = fread(fid);
%extradata=F(end-1023:end);
%
%% Read Introduction Lines
%InputText=textscan(fid,'%s',25,'delimiter','\n','bufsize',10000000);  % Read strings delimited
                                                  % by a carriage return
%Intro=InputText{1};
    LHinfo.PressureCounts=fread(fid,1,'uint64');
    LHinfo.TemperatureCounts=fread(fid,1,'uint16');
    LHinfo.BatteryCounts=fread(fid,1,'uint16');
    LHinfo.ExposureMicroSecond=0.6*fread(fid,1,'uint16');
    LHinfo.LaserPowerCounts=fread(fid,1,'uint16');
    LHinfo.LaserDiodeCounts=fread(fid,1,'uint16');
    LHinfo.CameraBrightness=fread(fid,1,'uint16');
    TemperatureCounts(i)=LHinfo.TemperatureCounts;
while 1
            tline = fgetl(fid);
            if ~isempty(strfind(tline,'Depth'));
                ss=regexp(tline,'\s+','split');
                dpth(i)=str2num(ss{2});
            end
            if ~isempty(strfind(tline,'Temperature'));
                ss=regexp(tline,'\s+','split');
                temp(i)=str2num(ss{2});
            end
            if ~isempty(strfind(tline,'Input voltage'));
                ss=regexp(tline,'\s+','split');
                volt(i)=str2num(ss{3});
            end
            if ~isempty(strfind(tline,'Laser power'));
                ss=regexp(tline,'\s+','split');
                LaserPwr(i)=str2num(ss{3});
            end
            if ~isempty(strfind(tline,'Laser photo'));
                ss=regexp(tline,'\s+','split');
                LaserPhoto(i)=str2num(ss{4});
            end
            if ~isempty(strfind(tline,'Total'));
                ss=regexp(tline,'\s+','split');
                TotVol(i)=str2num(ss{4});
            end
            if ~ischar(tline), break, end
            %disp(tline); 
            %pause

end
fclose(fid);
%pause
 end

 subplot 221, plot(dpth)
 legend('dpth')
 subplot 222, plot(temp)
 legend('temp')
 subplot 223, plot(volt)
 legend('volt')
 subplot 224, plot(LaserPhoto)
 legend('LaserPhoto')
%  saveas(gcf,'Lisst-Holo','jpeg')
