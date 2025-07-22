% VERSION FINAL
% Recognition for testing based on default parameters (numTry,numGestures)
% This is a function that runs the classification algorithm given an unkown
% signal.
% recognitionPruebasPaper(completeUnknownSignal,database,windowTime,Fb,Fa,timeShiftWindow,kNN,probabilidadkNNUmbral)
% Where completeUnknownSignal is a matrix mRowsx8 with the emg signal.
% database is a cell nRowsx8 with the filtered emg signals corresponding
% with the trained gestures.
% windowTime is the time of the shift window
% Fb and Fa are the values for the filter, those have to be the same as in
% the databaseConstruction
% kNN is the number of nearest neightboor to be considered.
% probabilidadkNNUmbral is the probability from 0 to 1.
% Se devuelven 4 resultados.  
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
% es WI,WO,F,O,PwindowTime
% histogramaGestos = 
% 0 18
% 1 0
% 2 2
% 3 0
% 4 0
% 5 0
% 6 0a
% En este caso, de las 20 execuciones por rotar la ventana, se obtuvieron
% 18 no gestos y 2 wave out.

function [resultadosFiltrados, tClassificationVector,histogramaGestos,resultadosCrudos]=...
    recognitionPruebasPaperSinModificarAntes(completeUnknownSignal,database,windowTime,Fb,Fa,timeShiftWindow,kNN,probabilidadkNNUmbral)
% Default values
freq=200; %Hz
numGestures=6;
numTry=50;
%nameGestures={'WaveIn';'WaveOut';'Fist';'Open';'Pinch';'noGesto'};
nameGestures={'Fist';'Open';'Pinch';'WaveIn';'WaveOut';'noGesto'};
parallelFlag=1; % 0 for not parfor, 1 for parfor in DTW database

[timeSeries,~]=size(completeUnknownSignal);
timeSeries=timeSeries/freq; % tiempo duración de la señal

shiftSamples = ceil(freq*timeShiftWindow); % samples to shift per loop

% Dependent variables
samplesWindow=round(windowTime*freq);
numExecutionsTimer=ceil(timeSeries/timeShiftWindow);


%% Starting parpool
if parallelFlag==1
    %fprintf('Por favor espere.\n')
    
    if isempty(gcp)
        parpool;
        beep
    end
    
    %fprintf('Listo.\n')
end


%% Recognition routine
DTWUnknownGesture=zeros(numTry*numGestures,8);
[sizeDatabase,~]=size(database);
tClassificationVector=zeros(numExecutionsTimer,1);

% Gesto resultante del DTW y KNN, no aplica filtro ni umbral
gestosKNNVector=zeros(numExecutionsTimer,1);
probGestoKNNVector=zeros(numExecutionsTimer,1);

% Gesto resultante finales, al aplicar filtro y umbral.
resultadosGestoVector=zeros(numExecutionsTimer,1);
probabilidadVector=zeros(numExecutionsTimer,1);

kExecutions=1;
flagFilterGesture=0; % variable para auxiliar para el gesto filtrado






%% Recognition loop
while kExecutions-1<numExecutionsTimer
    
    
    tClassification=tic;
    
    
    
    %% Loading signal    
    % loading and filtering the gesture to be analyzed
    unknownGesture = completeUnknownSignal(1:samplesWindow,:);
    unknownGesture = filtfilt(Fb, Fa,abs(unknownGesture) ); % filtered absolute value
    completeUnknownSignal = circshift(completeUnknownSignal,-shiftSamples);
    completeUnknownSignal(end-shiftSamples+1:end,:)=zeros(shiftSamples,8);
    
    
    
    
    
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
            %fprintf('%d.\n',kExecutions);
                                                
            
        else
            
            % Cuando existe resultado
            %fprintf('%d. %s,          %4.2f %%...\n',kExecutions,gestoString ,probGestureKNN)
            resultadosGestoVector(kExecutions)=gesto;
            probabilidadVector(kExecutions)=probGestureKNN;
            
                                    
        end
                                          

    %% Final de lazo
    tClassificationVector(kExecutions) = toc(tClassification);
    
    if tClassificationVector(kExecutions)>timeShiftWindow
        
        % cuando el tiempo del lazo actual supera el tiempo de la ventana.
        % Time problems.
        %fprintf('!!!!Excedio el tiempo'); 
                
    end
    
    
    
    kExecutions=kExecutions+1;
end



%% Al finalizar lazo. Construcción de histograma.
beep


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