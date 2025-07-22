% Ruta base donde están los resultados
resultBasePath = '.\resultadosFormatoMat\';

% Listar todas las carpetas de usuarios
userFolders = dir(fullfile(resultBasePath, 'user*'));

% Inicializar la estructura para guardar los rangos
Rangos = struct();

% Recorrer cada carpeta de usuario
for userIdx = 1:length(userFolders)
    userFolder = userFolders(userIdx).name;
    userPath = fullfile(resultBasePath, userFolder);
    
    % Cargar el archivo userData.mat
    matFilePath = fullfile(userPath, 'userData.mat');
    if ~exist(matFilePath, 'file')
        fprintf('Archivo no encontrado: %s\n', matFilePath);
        continue;
    end
    loadedData = load(matFilePath);

    % Obtener los testing
    if isfield(loadedData.userData, 'testing')
        testingSamples = loadedData.userData.testing; % 150x1 cell
    else
        fprintf('No se encontraron datos "testing" en: %s\n', matFilePath);
        continue;
    end

    % Inicializar estructura para este usuario
    userField = sprintf('user%d', userIdx);
    Rangos.(userField) = struct();

    % Recorrer cada celda dentro de testingSamples
    for sampleIdx = 1:length(testingSamples)
        sampleData = testingSamples{sampleIdx};

        % Verificar si tiene el campo emg
        if isfield(sampleData, 'emg')
            emgData = sampleData.emg; % nx8 matriz

            % Inicializar estructuras para mínimos y máximos
            minStruct = struct();
            maxStruct = struct();

            % Calcular mínimos y máximos por cada columna (canal)
            for ch = 1:size(emgData, 2) % Recorrer columnas
                channelData = emgData(:, ch);
                minStruct.(sprintf('ch%d', ch)) = min(channelData);
                maxStruct.(sprintf('ch%d', ch)) = max(channelData);
            end

            % Guardar los rangos en la estructura
            sampleField = sprintf('sample%d', sampleIdx);
            Rangos.(userField).(sampleField).min = minStruct;
            Rangos.(userField).(sampleField).max = maxStruct;
        else
            fprintf('Campo "emg" no encontrado en sample %d de %s\n', sampleIdx, userFolder);
        end
    end
end

% Guardar la estructura Rangos en un archivo .mat
outputFilePath = fullfile(resultBasePath, 'Rangos.mat');
save(outputFilePath, 'Rangos');

fprintf('Rangos guardados en: %s\n', outputFilePath);
