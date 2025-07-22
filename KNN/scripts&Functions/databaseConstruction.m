function [database,umbralMax]=databaseConstruction(nameUser,defaultFlag,Fb,Fa,numTry,numGestures,nameGestures)
% databaseConstruction(nameUser,defaultFlag,Fb,Fa,numTry,numGestures,nameGestures)

% Builds a matrix with the filtered EMG signal containing all the gestures
% recorded. The gestures are load from usersData folder. The filter is a
% fourth orden butterworth filter over the absolute value of the signal (5
% Hz). This database is recorded as a .mat file in usersData folder.
% When defaultFlag is 1, F, numTry, numGestures and nameGesture is
% predefined, so are not inputs required. Whereas, when defaultFlag is 0,
% numTry, numGestures Fa, Fb and nameGesture are inputs requiered.
% Example:
% databaseConstruction('juan',1)
0
% Also, returns the max values, as a vector, for gesture detection 

%% Predefined values
if defaultFlag==1
    numTry=5;
    numGestures=6;
    nameGestures={'WaveIn';'WaveOut';'Fist';'Open';'Pinch';'noGesto'}; % defaultFlag
    [Fb, Fa] = butter(4, (0.05), 'low'); % filter values
end
database=cell(numGestures*numTry,8);

% Variables for limit calculation
umbralMax=zeros(numTry*numGestures,1);
timeShift=40; % so it can be simulated the shift window. (0.2 sec)

for i=1:numGestures
    % Loop per gesture
    nameGestureI=char(nameGestures(i));
    load([nameUser nameGestureI '.mat']);
    disp(nameGestureI)
    for j=1:numTry



        % Loop per number of repetitions
        signal=dataGesture.emg{j};
        [samples,~]=size(signal);
        
        %% Algorithm for gesture detection
        diffSignal=abs([zeros(1,8);diff(signal)])/8; % derivation
        
        % Mean values per window
        for w=1:timeShift:samples-timeShift
            signalf(w:w+timeShift,:)= mean(sum(diffSignal(w:w+timeShift,:),2)); % mean values
        end        
        signalf(w:w+timeShift,:)= mean(sum(diffSignal(w:w+timeShift,:),2)); % mean values last vector part         
        
        % Getting max values
        umbralMax((i-1)*numTry+j)=max(signalf);
        
        %% building database
        for k=1:8
            % Loop per channel
            unknownGesture = filtfilt(Fb, Fa,abs(signal(:,k)) ); % filtered absolute value
            database{(i-1)*numTry+j,k}=unknownGesture;
        end
    end
end
%save (['usersData\' nameUser  'Database.mat'],'database')
save (['userDataNueva\' nameUser  'Database.mat'],'database')
beep
end