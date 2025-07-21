
global  emg  myoObject



figGesture=figure('ToolBar','none','NumberTitle','off',...
    'MenuBar','none','Visible','off');
movegui(figGesture,'south');
figGesture.Visible='on';

% Reading image
imageGesture = imread(['images\phrase.png']);
image(imageGesture);
figGesture=gcf;
axis off

drawnow
tic
myoObject.myoData.clearLogs();
(inputdlg({'Ingrese el texto de la foto'},'pueba combinada',4))
emg= myoObject.myoData.emg_log;
timeGesture=toc
close all

nameGesture='pruebaFrase';
dataGesture.emg=emg;
dataGesture.code=100;
dataGesture.name=nameGesture;
dataGesture.date=date;
dataGesture.numTry=1;
dataGesture.time=timeGesture;
    
   
%% Saving data
try    
    save (['usersData\' nameUser nameGesture '.mat'],'dataGesture');
    fprintf('Alright, recording finished\n=D\n');
catch
    fprintf('Problems saving the files!\nPlease, save manually dataGesture!!!!!\n');
end