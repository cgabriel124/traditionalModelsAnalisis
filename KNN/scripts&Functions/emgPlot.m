function emgPlot(timeRun)
% function that plots raw EMG data during timeRun seconds. The chart is
% divided in 4 subplots, each one contains 2 EMG signals.
% Emg signals are sampled at 200Hz, but the data plot is set with a lower
% freq.
% It uses a timer that reads the EMG data periodically. The timer uses a
% function for reading.
% a no data message will be displayed for each loop that missed data

global myoObject emg leido
freqApprox=10; % Freq for plotting, freq for reading timer
timeWindow=2; % time width that is draw in the plot
numberSamplesOnScreen = 400; % Number points in screen


% variables initialization
emgVector = zeros(numberSamplesOnScreen,8); % vector with the emg signal
xValuesVector = linspace(0,timeWindow,numberSamplesOnScreen)'; % vector with the time values.
timeDrawVector=zeros(ceil(freqApprox*timeRun),1); % vector time with times per loop for drawing
tLoopVector=zeros(ceil(freqApprox*timeRun),1); % vector with the elapsed time per loop
samplesLoop=zeros(ceil(freqApprox*timeRun),1); % samples read in each loop
numExecutionsTimer=ceil(timeRun*freqApprox);
periodTimer=1/freqApprox;

elapsedTime = 0;
i = 0; % loop counter
k = 0; % counter for number of loops where data missed

%% Initial plot
ax1=subplot(4,1,1);
ax2=subplot(4,1,2);
ax3=subplot(4,1,3);
ax4=subplot(4,1,4);
drawnow;


%% Timer setup
tmr = timer('ExecutionMode','fixedRate','TasksToExecute',numExecutionsTimer,...
    'TimerFcn',@(~,~)myoTimerFunction,'StartDelay',periodTimer,'Period',periodTimer);
myoObject.myoData.clearLogs();
start(tmr)

% Loop
while elapsedTime<timeRun
    tLoop=tic;
    i = i + 1;
    
    %% Waiting for EMG data
    while  leido == 0 % leido is a global variable that changes its state when data is ready.
        drawnow;
    end
    leido=0;
    samplesLoop(i)=length(emg); % emg contains EMG data read
    emgVector = circshift(emgVector,-samplesLoop(i));
    
    %% including read data
    try
        emgVector(end-samplesLoop(i)+1:end,:) = emg;
    catch
        k=k+1; % k is a counter for data missed
        emgVector(end,:) = zeros(1,8);
        fprintf('%d. no data.\n',i);
    end
    
    %% ploting
    timeDraw=tic; % measure time for drawing
    % Plotting values
    plot(ax1,[xValuesVector xValuesVector],emgVector(:,1:2));...
        ylim(ax1,[-1 1]);
    
    plot(ax2,[xValuesVector xValuesVector],emgVector(:,3:4));...
        ylim(ax2,[-1 1]);
    
    plot(ax3,[xValuesVector xValuesVector],emgVector(:,5:6));...
        ylim(ax3,[-1 1]);
    
    plot(ax4,[xValuesVector xValuesVector],emgVector(:,7:8));...
        ylim(ax4,[-1 1]);
    
    % changing the time values so it resembles a real time simulation
    xValuesVector = linspace(elapsedTime-timeWindow,elapsedTime,numberSamplesOnScreen)';
    
    % Excluded for speed
    % ax1.Title.String = 'EMG signals';
    % ax4.XLabel.String = 'Time [sec]';
    
    % Ticks
    ax1.XTick = [elapsedTime-timeWindow  elapsedTime];
    ax2.XTick = [elapsedTime-timeWindow  elapsedTime];
    ax3.XTick = [elapsedTime-timeWindow  elapsedTime];
    ax4.XTick = [elapsedTime-timeWindow  elapsedTime];
    
    % Lims
    xlim(ax1,[elapsedTime-timeWindow elapsedTime]);
    xlim(ax2,[elapsedTime-timeWindow elapsedTime]);
    xlim(ax3,[elapsedTime-timeWindow elapsedTime]);
    xlim(ax4,[elapsedTime-timeWindow elapsedTime]);            
    
    timeDrawVector(i)=toc(timeDraw);
    
    % time simulation
    tiempoLazoI=toc(tLoop); % time per loop
    tLoopVector(i)=tiempoLazoI;
    elapsedTime = elapsedTime + tLoopVector(i); % total elapsed time
end
beep
%% results
freqRead=sum(samplesLoop)/elapsedTime

i=i % number of loop executions

elapsedTime=elapsedTime % total elapsed time

k % number of loops where data missed

stop(tmr)
delete(tmr)
end
