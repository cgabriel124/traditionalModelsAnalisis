% FINAL VERSION
% Script that runs the user interface for the hand gesture recognition
% system. It runs the training routine as well as the recognition routine.
% Myo data is streamed  using MYOMEX library. The myoObject variable
% contains all data from the MYO; it has to be defined as a global variable.

% The interface shows the following options, when new user selected, the
% training routine will start.
% When recognition is selected the recognition starts.+
% when plot EMG is selected a real time plotting will appear.


%% Valores predefinidos
timeSeries=30; % tiempo de reconocimiento
windowTime=1;
ordenFiltro=4;
freqFiltro=0.05;
[Fb, Fa] = butter(ordenFiltro, freqFiltro, 'low'); % creating filter
timeShiftWindow=0.2;
kNN=5;
probabilidadkNNUmbral=0.7;
nameGestures={'WaveIn';'WaveOut';'Fist';'Open';'Pinch';'noGesto'};
numTry=5;
numGestures=6;

%% Conection and initial settings
% Including all subfolders and files
addpath(genpath(pwd));


% Connecting MYO
%//////////////********//////////
global myoObject
%%isConnected =  connectMyo; % isConnected is a flag, connectMyo is a function that connects the MYO
%%drawnow
%//////////////********//////////
isConnected = 1;

%% Main loop
if isConnected == 1
    
    option = 1;
    while option~=5
        option=menu('Gesture Recognition','New user','Recognition','plot EMG','Testing','Exit'); % options menu
        close all
        drawnow
        
        switch option
            
            case 1
                %% Training
                % setting training values, name User, Time Gesture, number of repetitions.
                newUser=inputdlg({'Name User','Time Gesture','number of repetitions'},...
                    'New User',1,{'jona','2','5'});
                
                if isempty(newUser)==0 % checking no empty values
                    nameUser=char(newUser{1});
                    timeGesture=str2double(newUser{2});
                    numTry=str2double(newUser{3});
                    testingFlag=0; % 0 for normal training
                    training(numTry,timeGesture,nameUser,testingFlag) % training routine for the given values
                    
                    %                 database=databaseConstruction(nameUser,1);
                    %                 fprintf('Database obtained successfully.\nThanks!\n')
                    
                    
                else
                    fprintf('Information not valid.\n')
                end
                
                
            case 2
                %% Recognition
                try
                    user=inputdlg({'Name User'},'Loading User',1,{nameUser}); % when a nameUser is defined
                catch
                    user=inputdlg({'Name User'},'Loading User',1,{'jona'}); % default
                end
                
                try
                nameUser=char(user{1});
                default=0;
                database=databaseConstruction(nameUser,default,Fb,Fa,numTry,numGestures,nameGestures);
                [resultadosFiltrados, tClassificationVector,histogramaGestos,resultadosCrudos]=...
                recognitionScript(timeSeries,database,windowTime,Fb,Fa,numTry,numGestures,timeShiftWindow,kNN,probabilidadkNNUmbral,nameGestures,nameUser)
                catch ME
                    disp('Se produjo un error.');
                    disp(['Mensaje de error: ', ME]);
                end
            case 3
                %% Plotting
                timeRun=inputdlg({'time for EMG plot'},'Time',1,{'30'});
                timeRun=str2double(timeRun{1});
                emgPlot(timeRun)
                
            case 4
                %% Testing
                try
                    user=inputdlg({'Name User'},'Loading User',1,{nameUser}); % when a nameUser is defined
                catch
                    user=inputdlg({'Name User'},'Loading User',1,{'jona'}); % default
                end
                
                nameUser=char(user{1});
                numTry=30;
                timeGesture=5;
                nameUserTesting=[nameUser 'PaperPruebas'];
                testingFlag=1; % 0 for normal training
                training(numTry,timeGesture,nameUserTesting,testingFlag)

                try
                    load('usuarios.mat'); % reading for previous data
                    [~,numberUsuarios]=size(usuarios.nombres);
                    usuarios.nombres{numberUsuarios+1}=nameUser;
                catch
                    usuarios.nombres{2}=nameUser; % when is the first data
                end
                
                save ('usersData\usuarios.mat','usuarios'); % saving users that have done the testing
                                               
        end
    end
end

isConnected=terminateMyo;


