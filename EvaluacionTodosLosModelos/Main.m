
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

    disp(' [6] Evaluation...');
    disp(' [7] Exit');
    option=input('Select an option to run:  ');

    switch option
        case 6
            disp("Evaluando...")
            directory = 'Data\General\testing';

            disp('     Elija la carpeta que evaluara.');
            disp('1. Mes 1 ');
            disp('2. Mes 2 ');
            disp('3. Mes 3 ');
            option=input('ingrese la opcion ');
            switch option
                case 1
                    directory = 'Data\General\Mes 1\testing';
                case 2
                    directory = 'Data\General\Mes 2\testing';
                case 3
                    directory = 'Data\General\Mes 3\testing';
            end

            
            numRepGestureTesting = 25;
            disp("numero de repeticiones por Gesto");
            disp(numRepGestureTesting);

            disp("");
            disp("Seleccione el modelo que evaluara")
            disp('1. ANN ');
            disp('2. kNN ');
            disp('3. SVM ');
            modelOption = input('ingrese la opcion ');
            switch modelOption
                case 1
                    model = "ann";
                case 2
                    model = "knn";
                case 3
                    model = "svm";
            end

            % cambiar manualmente "load()" y "responseValues" al mes y modelo que se quiere
            % evaluar, en "Model-Responses/" estan algunos resultados.

            
            if model =="ann"
                %%%%%% Para ANN
                % Cargar archivo original
                load('responsesMes3ANN.mat');  % contiene la variable 'responses'
                %%%%% Responses%%%%%%% es el resultado del ANN

                response.training = struct(); 
                response.testing = struct();
                userNames = fieldnames(responses.testing);
                disp(userNames)
                for i = 1:length(userNames)
                    user = userNames{i};
                    sizeOfTestedSamples = size(responses.testing.(user).vectorOfLabels);
                    response.testing.(user).vectorOfLabels = struct2cell(responses.testing.(user).vectorOfLabels);
                    response.testing.(user).class = struct2cell(responses.testing.(user).class);
                    response.testing.(user).vectorOfTimePoints = struct2cell(responses.testing.(user).vectorOfTimePoints);
                    response.testing.(user).vectorOfProcessingTime = struct2cell(responses.testing.(user).vectorOfProcessingTime);

                end
                userNamesTraining = fieldnames(responses.training);
                for i = 1:length(userNamesTraining)
                    user = userNamesTraining{i};
                    if ~isempty(responses.training.(user))  % Verificar si hay datos para este usuario
                        response.training.(user).vectorOfLabels = struct2cell(responses.training.(user).vectorOfLabels);
                        response.training.(user).class = struct2cell(responses.training.(user).class);
                        response.training.(user).vectorOfTimePoints = struct2cell(responses.training.(user).vectorOfTimePoints);
                        response.training.(user).vectorOfProcessingTime = struct2cell(responses.training.(user).vectorOfProcessingTime);
                    end
                end


                save('responseANNFormated.mat', 'response');
                responseValues = 'responseANNFormated.mat';
            elseif model == "knn"
                responseValues = 'responsesKNNMes3.mat';
            elseif model =="svm"
                %%%%%%  Para svm
                %load('responseExp1GMes2.mat'); 
                responseValues = 'responseExp1GMes3.mat';
            end
            %%Cambiar para evaluar los segmentos
            type = 'testing';
            %%%%%% Cambiar el mes
            mesSeleccionado = input('¿Qué mes desea evaluar? (Ingrese un número: 1, 2 o 3): ');

            Evaluation(directory, responseValues, type, mesSeleccionado,model);

            type = 'training';
            [nombreArchivo, carpetaResultados] = Evaluation(directory, responseValues, type, mesSeleccionado,model);
            
            borrar= unifyResults(nombreArchivo,carpetaResultados, mesSeleccionado);
            
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

function resultados = unifyResults(nombreArchivo,carpetaResultados,mesSeleccionado)
    resultados = load(fullfile(carpetaResultados, nombreArchivo));
    mes = ['Mes_' num2str(mesSeleccionado)];

    usuarios = fieldnames(resultados.resultadosEstructurados.(mes));

    for i = 1:length(usuarios)
        classification = 0;
        recognition = 0;
        overlapping = 0;
        meanTimeWindow = 0;
        meanTimeGesture = 0;
        usuarioActual = usuarios{i};
        % Accedes a la estructura del usuario actual
        classification = classification + resultados.resultadosEstructurados.(mes).(usuarioActual).training.classification;
        recognition = recognition + resultados.resultadosEstructurados.(mes).(usuarioActual).training.recognition;
        overlapping = overlapping + resultados.resultadosEstructurados.(mes).(usuarioActual).training.overlapping;
        meanTimeWindow = meanTimeWindow + resultados.resultadosEstructurados.(mes).(usuarioActual).training.meanTimeWindow;
        meanTimeGesture = meanTimeGesture + resultados.resultadosEstructurados.(mes).(usuarioActual).training.meanTimeGesture;
        
        classification = classification + resultados.resultadosEstructurados.(mes).(usuarioActual).testing.classification;
        recognition = recognition + resultados.resultadosEstructurados.(mes).(usuarioActual).testing.recognition;
        overlapping = overlapping + resultados.resultadosEstructurados.(mes).(usuarioActual).testing.overlapping;
        meanTimeWindow = meanTimeWindow + resultados.resultadosEstructurados.(mes).(usuarioActual).testing.meanTimeWindow;
        meanTimeGesture = meanTimeGesture + resultados.resultadosEstructurados.(mes).(usuarioActual).testing.meanTimeGesture;

        % Calcular promedios
        general.classification = classification / 2;
        general.recognition = recognition / 2;
        general.overlapping = overlapping / 2;
        general.meanTimeWindow = meanTimeWindow / 2;
        general.meanTimeGesture = meanTimeGesture / 2;
        resultados.resultadosEstructurados.(mes).(usuarioActual).general = general;

    end
    % Construye la ruta completa del archivo
    rutaArchivo = fullfile(carpetaResultados, nombreArchivo);
    
    % Guarda el archivo
    resultadosEstructurados = resultados.resultadosEstructurados;
    save(rutaArchivo, 'resultadosEstructurados');

    
end