%
% This code is based on the paper entitled
% "An Energy-based Method for Orientation Correction
% of EMG Bracelet Sensors in Hand Gesture Recognition Systems"
% by Victor Hugo Vimos T.
%
% Before using this code, please read the file README
%
% *Victor Hugo Vimos T / victor.vimos@epn.edu.ec
%  Escuela Politecnica Nacional
%  (C) Copyright Victor Hugo Vimos T.
%  2020

%-----------------------------------------
% Set Path folders if the code does not run
%------------------------------------------


exitLoop      = false;
syncro        = 0;
energy_umbral = 0.17;
control       = true;

addpath('Data');
addpath('PreProcessing');
addpath('FeatureExtraction');
addpath('Classification');
addpath('PostProcessing');
rng('default');
warning off all;

while exitLoop~=true
    clc
    disp('Gesture Recognition');
    disp(' [1] Experiment 1');
    disp(' [2] Experiment 2');
    disp(' [3] Experiment 3');
    disp(' [4] Experiment 4');
    disp(' [5] Testing');
    disp(' [6] Evaluation...');
    disp(' [7] Exit');
    option=input('Select an option to run:  ');
    switch option

        case 1
            model  = selectModel();
            if model ~= false
                control=experiment_1(model,syncro,energy_umbral);
                if control==false
                    exitLoop=true;
                elseif control==true
                    exitLoop=true;
                end
            else
                disp('No model selected...')
                pause(1)
                beep;
                clear option
            end

        case 2
            model  = selectModel();
            if model ~= false
                control= experiment_2(model,syncro,energy_umbral);
                if control==false
                    exitLoop=true;
                elseif control==true
                    exitLoop=true;
                end
            else
                disp('No model selected...')
                pause(1)
                beep;
                clear option
            end

        case 3
            model  = selectModel();
            if model ~= false
                control= experiment_3(model,syncro,energy_umbral);
                if control==false
                    exitLoop=true;
                elseif control==true
                    exitLoop=true;
                end
            else
                disp('No model selected...')
                pause(1)
                beep;
                clear option
            end

        case 4
            model  = selectModel();
            if model ~= false
                control= experiment_4(model,syncro,energy_umbral);
                if control==false
                    exitLoop=true;
                elseif control==true
                    exitLoop=true;
                end
            else
                disp('No model selected...')
                pause(1)
                beep;
                clear option
            end
        case 5
            disp("Testeando...");

            
            % Ruta base
            basePath = fullfile(pwd, 'Data', 'General', 'testing');
            userFolders = dir(basePath);

            % Filtrar carpetas válidas (usuarios)
            userFolders = userFolders([userFolders.isdir] & ~startsWith({userFolders.name}, '.'));

            % === 1. Intercambiar training <-> testing ===
            for i = 1:length(userFolders)
                userName = userFolders(i).name;
                userPath = fullfile(basePath, userName, 'userData.mat');

                if isfile(userPath)
                    loaded = load(userPath, 'userData');
                    userData = loaded.userData;

                    % Intercambiar training y testing
                    temp = userData.training;
                    userData.training = userData.testing;
                    userData.testing = temp;

                    save(userPath, 'userData');
                else
                    warning("Archivo no encontrado para %s", userName);
                end
            end

            % === 2. Ejecutar testModels con datos de training usados como testing ===
            disp('>> Ejecutando testModels con datos de TRAINING...');
            testModels(syncro, energy_umbral, "training");

            % === 3. Restaurar datos originales ===
            for i = 1:length(userFolders)
                userName = userFolders(i).name;
                userPath = fullfile(basePath, userName, 'userData.mat');

                if isfile(userPath)
                    loaded = load(userPath, 'userData');
                    userData = loaded.userData;

                    % Restaurar original (intercambiar de nuevo)
                    temp = userData.training;
                    userData.training = userData.testing;
                    userData.testing = temp;

                    save(userPath, 'userData');
                end
            end

            % === 4. Ejecutar testModels con datos reales de testing ===
            disp('>> Ejecutando testModels con datos de TESTING reales...');
            testModels(syncro, energy_umbral, "testing");

            disp('>> Proceso completo. Los datos fueron restaurados correctamente.');
            
            
        case 6
            disp("Evaluando...")
            directory = 'Data\General\testing';
            
            numRepGestureTesting = 25;
            disp("numero de repeticiones por Gesto");
            disp(numRepGestureTesting);

            model = "knn";
            if model =="ann"
                %%%%%% Para ANN
                % Cargar archivo original
                load('ResponsesANN.mat');  % contiene la variable 'responses'
                %%%%% Responses%%%%%%% es el resultado del ANN
                % Inicializar nueva estructura
                response.training = struct();  % si no hay datos de entrenamiento, queda vacío
                response.testing = struct();
                userNames = fieldnames(responses.testing);
                
                for i = 1:length(userNames)
                    user = userNames{i};
                    sizeOfTestedSamples = size(responses.testing.(user).vectorOfLabels);
                    response.testing.(user).vectorOfLabels = struct2cell(responses.testing.(user).vectorOfLabels);
                    response.testing.(user).class = struct2cell(responses.testing.(user).class);
                    response.testing.(user).vectorOfTimePoints = struct2cell(responses.testing.(user).vectorOfTimePoints);
                    response.testing.(user).vectorOfProcessingTime = struct2cell(responses.testing.(user).vectorOfProcessingTime);

                end
                save('responseANNFormated.mat', 'response');
                responseValues = 'responseANNFormated.mat';
            elseif model == "knn"
                responseValues = 'responsesKNN150Train.mat';
            elseif model =="svm"
                %%%%%%  Para svm
                responseValues = 'responseExp1G.mat';
            end
            %%Cambiar para evaluar los segmentos
            type = 'testing';
            %%%%%% Cambiar el mes
            mesSeleccionado = input('¿Qué mes desea evaluar? (Ingrese un número: 1, 2, 3, etc.): ');

            Evaluation(directory, responseValues, type, mesSeleccionado);

            break;

        case 7
            exitLoop = true;


        otherwise
            disp(' Please, select a valid option... ');
            pause(2)
    end

end

if control==true
    delete(pwd,'\','userData.mat')
    %clc
    disp('Experiment has finished ... ')
end


%clearvars -except usersLowIndex response
close all
