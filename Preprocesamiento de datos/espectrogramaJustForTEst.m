% Ruta base donde están los resultados
resultBasePath = '.\resultadosFormatoMat\';
ruta_actual = pwd;
fprintf('La ruta actual es: %s\n', ruta_actual);
% Listar todas las carpetas de usuarios
userFolders = dir(fullfile(resultBasePath, 'user*'));

% Inicializar la estructura para guardar los rangos
Rangos = struct();

% Recorrer cada carpeta de usuario
for userIdx = 1:length(userFolders)
    userFolder = userFolders(userIdx).name;
    userPath = fullfile(resultBasePath, userFolder);
    
    % Cargar el archivo newUserData.mat
    matFilePath = fullfile(userPath, 'newUserData.mat');
    if ~exist(matFilePath, 'file')
        fprintf('Archivo no encontrado: %s\n', matFilePath);
        continue;
    end
    loadedData = load(matFilePath);

    % Obtener los testingSamples
    if isfield(loadedData.newUserData, 'testingSamples')
        testingSamples = loadedData.newUserData.testingSamples;
    else
        fprintf('No se encontraron testingSamples en: %s\n', matFilePath);
        continue;
    end

    % Inicializar estructura para este usuario
    userField = sprintf('user%d', userIdx);
    Rangos.(userField) = struct();

    % Recorrer cada índice dentro de testingSamples
    idxFields = fieldnames(testingSamples);
    for idx = 1:length(idxFields)
        idxField = idxFields{idx};
        idxData = testingSamples.(idxField);

        % Verificar si tiene el campo emg
        if isfield(idxData, 'emg')
            emgData = idxData.emg;

            % Obtener valores mínimos y máximos de todos los canales
            minVals = zeros(1, 8);
            maxVals = zeros(1, 8);
            for ch = 1:8
                channelData = emgData.(['ch', num2str(ch)]);
                minVals(ch) = min(channelData);
                maxVals(ch) = max(channelData);
            end

            % Guardar los rangos en la estructura
            Rangos.(userField).(idxField).min = min(minVals);
            Rangos.(userField).(idxField).max = max(maxVals);
        else
            fprintf('Campo "emg" no encontrado en %s de %s\n', idxField, userFolder);
        end
    end
end

% Guardar la estructura Rangos en un archivo .mat
outputFilePath = fullfile(resultBasePath, 'Rangos.mat');
save(outputFilePath, 'Rangos');

fprintf('Rangos guardados en: %s\n', outputFilePath);
