% Script to measure accuracy of the classification system based on the
% testing routine. Setting parameters can be changed so a new clasificator
% can be tested.


addpath(genpath(pwd));

clear all
clc
load('usuarios.mat'); 
% load('resultadosTodos.mat'); 



% Variables in the training routine
numTry=5;
nameGestures={'WaveIn';'WaveOut';'Fist';'Open';'Pinch';'noGesto'};
numGestures=6;
numRepTest=30;




% Setting classification parameters
probabilidadkNNUmbral=0.7;
ordenFiltro=4;
freqFiltro=0.05;
[Fb, Fa] = butter(ordenFiltro, freqFiltro, 'low'); % creating filter
windowTime=1;
kNN=5;
timeShiftWindow=0.2;


% Gesture detection method
relaxedDetectionUmbral=0.1;  % percentage
gestureDetectionMethodFlag=0; % 1 for use this method, 0 for ignoring



% inicializando variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
valorRealTotal=[]; % vector de valores reales de todas las pruebas.
resultadosTotal=[];% vector de resultados obtenidos de todas las pruebas.
tClassificationTotal=[]; % vector con los tiempos de clasificación.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

logResultadosCrudosCelda=cell(numGestures,numRepTest,length(usuarios.nombres)); % celda obteniendo los resultados crudos de todos los usuarios.
logResultadosFiltradosCelda=cell(numGestures,numRepTest,length(usuarios.nombres)); % celda obteniendo los resultados finales de todos los usuarios.
histogramaNoGesto=[(0:5)' zeros(6,1)]; % variable para la prueba del no gesto


% for kUsuarios=length(usuarios.nombres)-5:length(usuarios.nombres)
for kUsuarios=1

    % Loop per user0
    nameUser=usuarios.nombres{kUsuarios};
    [database,dMax]= databaseConstruction(nameUser,0,Fb,Fa,numTry,numGestures,nameGestures);
    
    
    resultadosPruebaPerUser=[];
    valorRealPruebaPerUser=[];
    
    
    
    %% Prueba de los gestos
    
%     for kGesture= 1:numGestures-1
        
        % Loop por gesto
        load([nameUser 'pruebaFrase'  '.mat']);
        histogramaGestosPerUser=[(0:5)' zeros(6,1)];
        
        
        
        
        
%         for kRutina=1:numRepTest
            % Loop por repetición del test.
%             disp(kRutina)
            
            %% Clasificación
            completeUnknownSignal=dataGesture.emg;
            [logResultadosFiltrados,tClassificationVector,histogramaGestos,logResultadosCrudos]...
                = recognitionPruebasPaper(completeUnknownSignal,database,windowTime,Fb,Fa,timeShiftWindow,kNN,probabilidadkNNUmbral);
            
end            
            
%             % Log results
%             logResultadosCrudosCelda{kGesture,kRutina,kUsuarios}=logResultadosCrudos;
%             logResultadosFiltradosCelda{kGesture,kRutina,kUsuarios}=logResultadosFiltrados;
%             tClassificationTotal=[tClassificationTotal;tClassificationVector];
%             
%             % Obteninedo histograma general
%             histogramaGestos(1,2) = 0; % exclutendo todas los resultados nulos
%             
%             
%             
%             
%             % Análisis del histograma resultante
%             if sum(histogramaGestos(2:end,2))==1 && histogramaGestos(kGesture+1,2)==1 % (condición 1: un solo resultado obtenido) y (condición dos: resultado obtenido es el correcto)
%                 % Detección correcta, pasa el valor histogramaGestos=histogramaGestos
%                 
%                 
%             elseif histogramaGestos(:,2:end)==0 % sistema de clasificación no detectó ni un solo gesto
%                 
%                 histogramaGestos(1,2)=1;
%                 
%                 
%             elseif sum(histogramaGestos((histogramaGestos(:,1)~=kGesture),:))~=0 % Detección de otros elementos
%                 % se pasa el resultado tal cual, es posible que devuelva
%                 % más de un resultado
%                 histogramaGestos(kGesture+1,2)=0;
%             else
%             end
%             
%             
%             
%             
%             
%             % Resultado para la matriz de confusión
%             resultadosPruebaPerUser=[resultadosPruebaPerUser,histogramaGestos(:,2)];
%             
%             % Valor esperado de la clasificación
%             valorReal=(zeros(6,1));
%             valorReal(kGesture+1,1) = 1;
%             valorRealPruebaPerUser=[valorRealPruebaPerUser,valorReal];
%             
%             % Histograma completo por gesto
%             histogramaGestosPerUser(:,2)=(histogramaGestosPerUser(:,2)+histogramaGestos(:,2));
% %         end
% %     end
%     
%     
%     
%     % Matriz de confusión por usuario
% %     figure
% %     plotconfusion(valorRealPruebaPerUser,resultadosPruebaPerUser,[nameUser, '. Freq: ',num2str(freqFiltro),' orden: ',num2str(ordenFiltro)])
% %     save (['usersData\' nameUser  'Histograma.mat'],'histogramaGestosPerUser');
% %     save (['resultados\ventana1seg\' nameUser  '.mat'],'valorRealPruebaPerUser','resultadosPruebaPerUser');
%     
%     
%     
%     % Joining total results
% %     valorRealTotal=[valorRealTotal,valorRealPruebaPerUser];
% %     resultadosTotal=[resultadosTotal,resultadosPruebaPerUser];
% %     
%     
%     
    %% no gesto
%     load([nameUser 'PaperPruebasescribiendoPrueba.mat']);
%     histogramaGestosPerUser=[(0:5)' zeros(6,2)];
%     completeUnknownSignal=dataGesture.emg{1};
%     [~,~,histogramaGestos,~]...
%         = recognitionPruebasPaper(completeUnknownSignal,database,windowTime,Fb,Fa,timeShiftWindow,kNN,probabilidadkNNUmbral);
%     
%     if sum(histogramaGestos(2:end,2))==0
%         histogramaGestos(1,2)=1;
%     else
%         histogramaGestos(1,2)=0;
%     end
%     histogramaNoGesto(:,2)=histogramaGestos(:,2)+histogramaNoGesto(:,2);
%     
%     
% end
% histogramaNoGesto
% %% Al finalizar
% beep
% 
% % Resultados totales
% figure
% % freqFiltro=0.4;
% % ordenFiltro=2;
% plotconfusion(valorRealTotal,resultadosTotal,['TODOS. Freq: ',num2str(freqFiltro),' orden: ',num2str(ordenFiltro)])
% % save (['resultados\ventana1seg\todos.mat'],'valorRealTotal','resultadosTotal');
% 
% figure
% histogram(tClassificationTotal)
% % save ('usersData\resultadosTodos.mat','valorRealTotal','resultadosTotal','tClassificationTotal');
% 



