% FINAL VERSION
% Function to record 1 emg data from a gesture using MYO MEX library!
% Myo must be connected. A gesture is recorded after pressing the okap
% button when showMessageFlag is 1.
% The data is stored in a .mat file with the name 'nameUserNameGesture'. It
% assumes that data is desired to be included in previous ones.
% Data is recorded in usersData folder.
% input arguments (numREP,timeGesture,nameUser,codeGesture,nameGesture)
% numREP represents number of repetitions desired per gesture.
% timeGesture is the time in seconds to record the gesture.
% nameUser is the name of the user. This value is important as it will be
% used later for finding it.
% codeGesture is a number for identifing a gesture.
% nameGesture is the name of a gesture. It is requiered for new gestures.
% It can be ommited only when codeGestures is less than 6. If
% codeGestures is less than 6 it assumes it is a predefined gestures.
% Predefined gestures: {Wave In, Wave Out, Fist, Open, Pinch, noGesto}.
% Example:
% recordGesture(2,2,'prueba',6,'west')
% The format of the output is:
% dataGesture.emg=emgSignal(1x8)
% dataGesture.code=codeGesture
% dataGesture.name=nameGesture
% dataGesture.date=date
% dataGesture.numTry=numTry
% dataGesture.time=timeGesture

%%
function dataGesture=recordGesture(numTry,timeGesture,nameUser,codeGesture,nameGesture,showMessageFlag)

%% Predefined values
nameGestures={'WaveIn';'WaveOut';'Fist';'Open';'Pinch';'noGesto'};

if codeGesture<7
    nameGesture=nameGestures{codeGesture};
end

startRow=0;

%% reading and icluding previous data
try
    load([nameUser nameGesture '.mat']); % reading for previous data
    fprintf('Data found, the record data will be added to the previous.\n')
    
    % including data at the last rows
    [startRow,~]=size(dataGesture.emg);
    dataGesture.emg=[dataGesture.emg;cell(numTry,1)];
catch
    dataGesture.emg=cell(numTry,1);
    fprintf('data no found, a new file will be created.\n')
end

%% Reading
global leido emg myoObject
emg=zeros(1,8);
drawnow

% Loop for the number of repetitions requiered
for kNumTry=1:numTry
    
    % Message, after the clic the recording starts
    if showMessageFlag==1
    uiwait(msgbox(['Please, press the button and perform the gesture ' nameGesture ...
        ' until the beep'],'Instructions','modal'));
    end
    % Timer configuration
    leido=0;
    tmr = timer('ExecutionMode','fixedRate','TasksToExecute',1,...
        'TimerFcn',@(~,~)myoTimerFunction,'StartDelay',timeGesture,'Period',timeGesture);
    myoObject.myoData.clearLogs();
    
    % Starting timer
    tic
    start(tmr)
    
    % Waiting bar
    h = waitbar(0,'Please wait...');
    
    % Waiting for available data
    while  leido==0
%         pause(0.1);        
        clc
        percentage=(toc)/timeGesture;
        waitbar(toc/timeGesture,h);       
        percentage = percentage *100;
        fprintf('Please wait: %4.2f%%',percentage)
        drawnow
    end
    close(h);
    clc
    beep
    fprintf('Gesture recorded\nThanks!\n');
    disp(kNumTry);
    
    % Stopping timer for next execution
    stop(tmr);
    delete(tmr);
    
    % Creating dataGesture structure.
    dataGesture.emg{kNumTry+startRow,1}=emg;
    dataGesture.code=codeGesture;
    dataGesture.name=nameGesture;
    dataGesture.date=date;
    dataGesture.numTry=numTry;
    dataGesture.time=timeGesture;
    
    emg=zeros(1,8); % Clearing variable emg for new data
end

%% Saving data
try    
    save (['usersData\' nameUser nameGesture '.mat'],'dataGesture');
    fprintf('Alright, recording finished\n=D\n');
catch
    fprintf('Problems saving the files!\nPlease, save manually dataGesture!!!!!\n');
end
end