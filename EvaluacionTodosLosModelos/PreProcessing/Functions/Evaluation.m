function [nombreArchivo, carpetaResultados]  = Evaluation(directory,responseValues,type,numeroMes,model)
% --------------------------------------------------------------------
% This code is based on the paper entitled                     
% "An Energy-based Method for Orientation Correction
% of EMG Bracelet Sensors in Hand Gesture Recognition Systems"
% by Victor Hugo Vimos T.
%
% *Victor Hugo Vimos T / victor.vimos@epn.edu.ec
% --------------------------------------------------------------------

%%Calculo del valor de overlaping general
overlappingFactors = [];
%%

DataDir=[pwd,'\',directory];
addpath(pwd,'\','Postprocessing\libs');
addpath(DataDir);


%dataPacket = orderfields(dir('Data\General\testing\'));
dataPacket      = orderfields(dir(DataDir));
dataPacketSize  = length(dataPacket);
pathUser        = pwd;
pathOrigin      = directory;

assignin('base','dataPacket',    dataPacket);
assignin('base','dataPacketSize',dataPacketSize);
assignin('base','pathUser',      pathUser);
assignin('base','pathOrigin',    pathOrigin);

if model ~= "ann"
    response_  = load([pwd,'\Models-Responses\',responseValues]);
else
    response_  = load([pwd,'\',responseValues]);
end
response   = response_.response;
%response = response

fprintf('Archivos encontrados en el directorio "%s":\n', DataDir)
fprintf('direct user "%s":\n', pathUser);
fprintf('direct origin "%s":\n', pathOrigin);

control=true;


if type=="training"
    names_responses=fields(response.training);
    field = 'training';
elseif type=="testing"
    names_responses=fields(response.testing);
    field = 'testing';
else
    disp('Error, no valid name...')
    control=false;
end

assignin('base', 'names_responses', names_responses);
save('names_responses.mat', 'names_responses');

summary = [];
aux=1;

%%////////////////////////////////////////////%%
mesNombre = ['Mes_' num2str(numeroMes)];
filenameResultados = ['ResultadosEstructurados_' mesNombre '.mat'];

if isfile(filenameResultados)
    % Si el archivo existe, lo cargamos para no perder datos previos
    aux_ = load(filenameResultados);
    resultadosEstructurados = aux_.resultadosEstructurados;
    fprintf('Archivo "%s" cargado. Resultados anteriores serán preservados.\n', filenameResultados);
else
    resultadosEstructurados = struct();
end

% Aseguramos que el campo del mes exista
if ~isfield(resultadosEstructurados, mesNombre)
    resultadosEstructurados.(mesNombre) = struct();
end
%%////////////////////////////////////////////%%


if control==true
    %try

        for k=1:dataPacketSize

            
            if ~(strcmpi(dataPacket(k).name, '.') || strcmpi(dataPacket(k).name, '..'))
                usuario     = dataPacket(k).name;
                assignin('base', "usuario", usuario)
                userFolder  = horzcat(pathUser,'\',pathOrigin,'\',dataPacket(k).name,'\','userData.mat');
                load(userFolder);


                

                
                for u=1:length(names_responses)
                    
                    if string(names_responses(u,1)) == string(usuario)
                        
                        user_=char(names_responses(u,1));
                        %%////////////////////////////////////////////%%
                        resumenUser = zeros(125,2);
                        overlappingUser = [];
                        contadorUser = 1;
                        %%////////////////////////////////////////////%%

                        %%
                        totalTimeWindowsPerUser = [];
                        totalTimeGesturesPerUser = [];
                        disp(user_);
                        disp(type);
                        for i=26:150
                            %clc
                            %usuario
                            %pause(0.1)
                            
                            groundTruth                       = userData.testing{i,1}.groundTruth;
                            repOrgInfo.gestureName            = categorical(userData.(field){i,1}.gestureName);
                            repOrgInfo.groundTruth            = groundTruth;
                            
                            response_.class                   = response.(field).(user_).class{i,1};
                            response_.vectorOfLabels          = response.(field).(user_).vectorOfLabels{i,1};
                            response_.vectorOfTimePoints      = response.(field).(user_).vectorOfTimePoints{i,1};
                            response_.vectorOfProcessingTimes = response.(field).(user_).vectorOfProcessingTime{i,1};
                            
                            %% para el tiempo
                            % Acumulación para tiempo por ventana
                            totalTimeWindowsPerUser = [totalTimeWindowsPerUser; response_.vectorOfProcessingTimes(:)];
                            
                            % Acumulación para tiempo por gesto completo
                            timePerGesture = sum(response_.vectorOfProcessingTimes);
                            totalTimeGesturesPerUser = [totalTimeGesturesPerUser; timePerGesture];


                            r1 = evalRecognition(repOrgInfo,response_);

                            overlappingFactors(end+1) = r1.overlappingFactor;
                            
                            %%////////////////////////////////////////////%%
                            overlappingUser(end+1) = r1.overlappingFactor;

                            %%////////////////////////////////////////////%%
                            
                            %=========================================
                            
                            % Your code here!  
                            
                            if r1.classResult==true
                                
                                summary(aux,1)=1;
                                resumenUser(contadorUser,1)=1;
                            else
                                summary(aux,1)=0;
                                resumenUser(contadorUser,1)=0;
                            end
                            
                            if r1.recogResult==true
                                summary(aux,2)=1;
                                resumenUser(contadorUser,2)=1;
                            else
                                summary(aux,2)=0;
                                resumenUser(contadorUser,2)=0;
                            end
                            
                            %=========================================                            
                            aux=aux+1;
                            contadorUser=contadorUser+1;
                        end

                        %%////////////////////////////////////////////%%
                        resultadosEstructurados.(mesNombre).(user_).(type).classification = ...
                            sum(resumenUser(:,1)) / length(resumenUser);
                        resultadosEstructurados.(mesNombre).(user_).(type).recognition = ...
                            sum(resumenUser(:,2)) / length(resumenUser);
                        resultadosEstructurados.(mesNombre).(user_).(type).overlapping = ...
                            mean(overlappingUser, 'omitnan');
                        resultadosEstructurados.(mesNombre).(user_).(type).meanTimeWindow = ...
                            mean(totalTimeWindowsPerUser, 'omitnan');

                        resultadosEstructurados.(mesNombre).(user_).(type).meanTimeGesture = ...
                            mean(totalTimeGesturesPerUser, 'omitnan');
                        %%////////////////////////////////////////////%%
                        
                    end
                    
                end
                
            end
            
        end        
    % catch ME
    %     fprintf('No data to evaluate in folder: %s\n',field);
    %     fprintf('Ocurrió un error:');
    %     disp(ME)
    % end   
end

save("summary.mat", 'summary');

classification = sum(summary(:,1))/length(summary)
recognition    = sum(summary(:,2))/length(summary)
promedioOverlapping = mean(overlappingFactors, 'omitnan');

save("todosLosOverLap", "overlappingFactors");
save("FactorOverlapingGeneral", "promedioOverlapping");

save('REsultadosEvaluClas.mat', 'classification');
save('REsultadosEvaluRecog.mat', 'recognition');

%%////////////////////////////////////////////%%
carpetaResultados = fullfile('results', model);
if ~exist(carpetaResultados, 'dir')
    mkdir(carpetaResultados);
end


nombreArchivo = ['ResultadosEstructurados_' mesNombre '.mat'];
nombreArchivoFull = fullfile(carpetaResultados, nombreArchivo);

% Si ya existe, cargamos el archivo previo y fusionamos resultados
if isfile(nombreArchivoFull)
    prevData = load(nombreArchivoFull);
    resultadosPrevios = prevData.resultadosEstructurados;

    % Fusionamos resultados nuevos con previos (por cada usuario del mes)
    usuariosMes = fieldnames(resultadosEstructurados.(mesNombre));
    for i = 1:numel(usuariosMes)
        usuarioActual = usuariosMes{i};
        resultadosPrevios.(mesNombre).(usuarioActual).(type) = ...
            resultadosEstructurados.(mesNombre).(usuarioActual).(type);
    end

    resultadosEstructurados = resultadosPrevios;
end

% Guardamos la versión fusionada
save(nombreArchivoFull, 'resultadosEstructurados');

%%////////////////////////////////////////////%%

end


