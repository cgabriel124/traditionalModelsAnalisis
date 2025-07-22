% FINAL VERSION
% Routine for saving all user gestures. Can include or exclude any
% predefined gestures as well as include more. It is based on recordGesture
% (which just record one gesture). If a gesture is predefined an image of
% the gesture will appear.
% Example:
% numTry=2;
% timeGesture=0.5;
% nameUser='jona';
% testingFlag=0;
% training(numTry,timeGesture,nameUser,testingFlag)

function training(numTry,timeGesture,nameUser,testingFlag)
nameGestures={'WaveIn';'WaveOut';'Fist';'Open';'Pinch';'noGesto'}; % predefined gestures
numGestures=0;
showMessageFlag=1; % allows to record the gestures after pressing okap button

%% Training for all five predefined gestures
for codeGesture=1:5
    % Showing gesture's figure
    figGesture=figure('ToolBar','none','NumberTitle','off',...
        'MenuBar','none','Visible','off');
    movegui(figGesture,'south');
    figGesture.Visible='on';
    
    % Reading image
    imageGesture = imread(['images\' nameGestures{codeGesture} '.png']); % % PC
    image(imageGesture);
    figGesture=gcf;
    axis off
    title(nameGestures{codeGesture});
    
    % Including gesture
    option=questdlg(['Would you like to include the gesture ' nameGestures{codeGesture} '?']...
        ,'Including gestures','Yes','No','Yes');
    
    switch option
        case 'Yes'
            % Recording gesture
            recordGesture(numTry,timeGesture,nameUser,codeGesture,'',showMessageFlag);
            numGestures=numGestures+1;
    end
    close(figGesture);
end

if testingFlag==0
    % Traditional training
    %% Training noGesto
    codeGesture=6;
    option=questdlg(['Would you like to include the gesture ' nameGestures{codeGesture} '?']...
        ,'Including gestures','Yes','No','Yes');
    
    switch option
        case 'Yes'
            % Recording gesture
            recordGesture(numTry,timeGesture,nameUser,codeGesture,'',showMessageFlag);
            numGestures=numGestures+1;
    end
    
    
    
    %% Training for extra gestures.
    option='Yes';
    while strcmp(option,'Yes')
        option=questdlg('Would you like to include more gestures?','Excluding gestures','Yes','No, finish','No, finish');
        
        switch option
            case 'Yes'
                % Including extra gestures
                nuevo=inputdlg('Name Gesture','New gesture');
                if isempty(nuevo)==0
                    nameGesture=char(nuevo);
                    codeGesture=codeGesture+1;
                    recordGesture(numTry,timeGesture,nameUser,codeGesture,nameGesture,showMessageFlag);
                    numGestures=numGestures+1;
                end
        end
    end
else
    %% Training a test routine
    uiwait(msgbox('Please, after pressing the OKAP button, write in the keyboard "Hola mundo" until the beep','Instructions','modal'));
    nameGesture='escribiendoPrueba';
    codeGesture=100;
    numTry=1;
    showMessageFlag=0;
    drawnow
    recordGesture(numTry,timeGesture,nameUser,codeGesture,nameGesture,showMessageFlag);
end
end

