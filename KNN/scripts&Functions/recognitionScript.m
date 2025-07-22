% VERSION FINAL
% recognitionScript(timeSeries,database,windowTime,Fb,Fa,numTry,numGestures,timeShiftWindow,kNN,probabilidadkNNUmbral,nameGestures)
% Is a function to the real time recognition.
% Where timeSeries is the time to run the script
% database is a cell nRowsx8 with the filtered emg signals corresponding
% with the trained gestures.
% windowTime is the time of the shift window
% Fb and Fa are the values for the filter, those have to be the same as in
% the databaseConstruction
% numTry is the number a gesture was repeted in the training routine
% num gestures is the number of gestures included in the training routine
% kNN is the number of nearest neightboor to be considered.
% probabilidadkNNUmbral is the probability from 0 to 1.
% Los resultados de la clasificación pueden ser accedidos como una variable
% global "gesto".
% La función devuelve 4 resultados.  
%[resultadosFiltrados,tClassificationVector,histogramaGestos,resultadosCrudos] 
% resultadosFiltrados es una matriz mExecutionsx2 que inclute los resultados
% de la clasificación y su probabilidad por cada ejecución del timer.
% resultadosFiltrados =
% 1 0.8
% 1 1
% 0 1
% 0 1
% tClassificationVector es un vector con los tiempos de cada lazo para la
% clasificación
% histogramaGestos es un histograma de los gestos obtenidos. La primera
% columna representa los gestos, la segunda, el número de veces que fue
% detectado dicho gesto. El cero representa no gesto, desde ahí, del 1 al 5
% es WI,WO,F,O,P
% histogramaGestos = 
% 0 18
% 1 0
% 2 2
% 3 0
% 4 0
% 5 0
% 6 0
% En este caso, de las 20 execuciones por rotar la ventana, se obtuvieron
% 18 no gestos y 2 wave out.

function [resultadosFiltrados, tClassificationVector,histogramaGestos,resultadosCrudos]=...
    recognitionScript(timeSeries,database,windowTime,Fb,Fa,numTry,numGestures,timeShiftWindow,kNN,probabilidadkNNUmbral,nameGestures,nameUser)
global emg leido flagStop myoObject kAux gesto
% Default values
freq=200; %Hz
nameSeries='secuencia';
parallelFlag=1; % 0 for not parfor, 1 for parfor in DTW database


% Dependent variables
samplesWindow=round(windowTime*freq);
numExecutionsTimer=ceil(timeSeries/timeShiftWindow);


%% Starting parpool
if parallelFlag==1
    fprintf('Por favor espere.\n')

    if isempty(gcp)
        fprintf('Por favor espere.\n')
        parpool;
        fprintf('Por favor espere.\n')
        beep
    end
    
    fprintf('Listo.\n')
end


%% Initializing variables
DTWUnknownGesture=zeros(numTry*numGestures,8);
[sizeDatabase,~]=size(database);
tClassificationVector=zeros(numExecutionsTimer,1);
tLeisureVector=zeros(numExecutionsTimer,1);
unknownGesture=zeros(samplesWindow,8);
completeUnknownGesture=zeros(timeSeries*freq,8);

% Gesto resultante del DTW y KNN, no aplica filtro ni umbral
gestosKNNVector=zeros(numExecutionsTimer,1);
probGestoKNNVector=zeros(numExecutionsTimer,1);

% Gesto resultante finales, al aplicar filtro y umbral.
resultadosGestoVector=zeros(numExecutionsTimer,1);
probabilidadVector=zeros(numExecutionsTimer,1);

kExecutions=1;
flagFilterGesture=0;
samplesObtained=0; 



%% Recognition loop
leido=0;    % flag to know when new data is ready
kAux=0;     % timer loops counter

drawnow
uiwait(msgbox('PLEASE, PRESS THE BUTTON TO START.','Instructions','modal'));

% setting timer
timeShiftWindow=timeShiftWindow;
tmr = timer('ExecutionMode','fixedRate','TasksToExecute',numExecutionsTimer,...
    'TimerFcn',@(~,~)myoTimerFunction,'StartDelay',timeShiftWindow,'Period',timeShiftWindow);
%%myoObject.myoData.clearLogs();

start(tmr)

disp("xxxxx")
while kAux<numExecutionsTimer
disp("yyyyy")
    % Bandera para detener lazo
    if flagStop==1
disp("zzzz")
        stop(tmr)
disp("kkkkk")
        break
    end
   disp("mmmm") 
    %% Loading signal    
    tLeisure = tic;
       
    % Wainting for data
    
    while  leido==0
        drawnow;
         
    end
    leido=0;
    
    disp("ooo") 
    tLeisureVector(kExecutions) = toc(tLeisure);
    disp("ppp") 
    tClassification=tic;        
    
    disp("qqq") 
    % loading and filtering the gesture to be analyzed
    [shiftSamples,~]=size(emg);
    samplesObtained=samplesObtained+shiftSamples;
    
    unknownGesture = circshift(unknownGesture,-shiftSamples);
    unknownGesture(end-shiftSamples+1:end,:) = emg;
        
    completeUnknownGesture(samplesObtained-shiftSamples+1:samplesObtained,:)=emg;

    unknownGesture = filtfilt(Fb, Fa,abs(unknownGesture) ); % filtered absolute value
    
    
    
    
    %% DTW
    % El algoritmo DTW es calculado entre la señal a clasificar
    % unknownGesture y todas las señales del database por canal. El
    % resultado de estas operaciones se almacena como una matriz 30x8
    % DTWUnknownGesture.
    
    if parallelFlag==0
        for kDatabase=1:sizeDatabase
            for kChannel=1:8
                DTWUnknownGesture(kDatabase,kChannel)=...
                    dtw_c(database{kDatabase,kChannel},unknownGesture(:,kChannel),50);
            end
        end
    else
        parfor kDatabase=1:sizeDatabase
            for kChannel=1:8
                DTWUnknownGesture(kDatabase,kChannel)=...
                    dtw_c(database{kDatabase,kChannel},unknownGesture(:,kChannel),50);
            end
        end
    end
    
    
    
    
    
    
    %% kNN
    % Se suma el resultado DTW de los ocho canales. 
    % DTWsumChannel es un vector columna que contiene la suma de las
    % distancias DTW entre la señal a clasificar (unknownGesture) y las
    % señales del database.     
    DTWsumChannel=sum(DTWUnknownGesture,2);

    
    %     [DTWValuesSortedKNN,kNNresults]=sort(DTWsumChannel); % se ignoran los valores del DTW
    [~,kNNresults]=sort(DTWsumChannel);    
    % kNNresults contiene la posición de los resultados con menor suma de
    % distancias DTWs.
    
    
    
    kNNresults=ceil(kNNresults/numTry); 
    % esta división cambia el significado de kNNresults.
    % Ahora contiene el número de gesto correspondiente a los menores DTW
    
    
    % Escogiendo los k más cercanos
    kNNresults=kNNresults(1:kNN,:);
%     DTWValuesSortedKNN=DTWValuesSortedKNN(1:kNN,:);
    

    % Encontrando el más común entre los vecinos más cercanos
    [gestoResultKNN,probGestureKNN]=mode(kNNresults); 
    
    % probabilidad por unidad
    probGestureKNN=probGestureKNN/kNN; 
    
    % Asignando nombre al gesto resultante
    gestoString=char(nameGestures{gestoResultKNN});
    
    % Resultados únicamente de KNN, antes de filtrado y umbralKNN
    probGestoKNNVector(kExecutions)=probGestureKNN;
    gestosKNNVector(kExecutions)=gestoResultKNN;
   
    
    

    
    %% Umbral y Filtro
        gesto=0;
        % Comparando que se supere el umbral de probabilidad
        if probGestureKNN>probabilidadkNNUmbral
            
            
            if kExecutions>1                
                
                % filtro a la salida. Compara que el gesto sea igual al
                % resultante anterior. El gesto resultante anterior es
                % aquel sin cosiderar el umbral. 
                if gestosKNNVector(kExecutions-1)==gestoResultKNN
                    gesto=gestoResultKNN;
                end
                
                
                % cambio de estado
                if resultadosGestoVector(kExecutions-1)==gesto % resultado debe ser igual al gesto KNN anterior
                    flagFilterGesture=gesto;
                    gesto=0; % filtro
                elseif flagFilterGesture==gestoResultKNN % si el gesto de KNN es respuesta del filtro
%                     elseif flagFilterGesture==gesto % si el gesto resultante es el valor del filtro
                gesto=0;                
                end 
                
                
                
            end            
        end        
        
        
        
        %% Fprintf
        if gesto==0 || strcmp(gestoString,'noGesto')
            
            % Cuando el gesto resultante no supera el umbral o cuando el
            % resultado del KNN devuelve no gesto
            fprintf('%d.\n',kExecutions);
                                                
            
        else
            
            % Cuando existe resultado
            fprintf('%d. %s,          %4.2f %%...\n',kExecutions,gestoString ,probGestureKNN)
            resultadosGestoVector(kExecutions)=gesto;
            probabilidadVector(kExecutions)=probGestureKNN;
            
                                    
        end
                                          

    %% Final de lazo
    tClassificationVector(kExecutions) = toc(tClassification);
    
    if tClassificationVector(kExecutions)>timeShiftWindow
        
        % cuando el tiempo del lazo actual supera el tiempo de la ventana.
        % Time problems.
        fprintf('!!!!'); 
                
    end
    
    
    
    kExecutions=kExecutions+1;
end



%% Al finalizar lazo. Construcción de histograma.
beep
save (['usersData\' nameUser nameSeries '.mat'],'completeUnknownGesture')


% El histograma es una matriz de 6x2 donde la primera columna muestra los
% gestos y la segunda el número de veces que fue reconocido tal gesto
histogramaGestos=[(0:5)',zeros(6,1)];

for d=0:5
    % Número de veces que el gesto resultante fue igual a cierto gesto (d)
    histogramaGestos(d+1,2)=sum(resultadosGestoVector==d);    
end


resultadosFiltrados=[resultadosGestoVector,probabilidadVector];
resultadosCrudos=[gestosKNNVector,probGestoKNNVector];
end