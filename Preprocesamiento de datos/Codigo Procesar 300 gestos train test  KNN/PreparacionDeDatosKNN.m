function PreparacionDeDatosKNN(usuario,idx_seleccionados,version,modoEntrenamiento)
    
    if usuario ~= "userDataUnion"
        load(sprintf('resultadosFormatoMat/%s/newUserData.mat', usuario));
    else
        load("newUserDataUnion.mat")
    end
    if modoEntrenamiento
    %if version == "trainingSamples"
        use_ground_truth = true;
    else
        use_ground_truth = false;
    end

    
    %%La data tiene la siguiente estructura {"noGesture", "fist", "open", "pinch", "waveIn", "waveOut"}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   1-25.....26-50..51-75...76-100...101-125...126-150
    %% por eso se debe escoger los indices corrrectos para obtener "{'WaveIn';'WaveOut';'Fist';'Open';'Pinch';'noGesto'};"

    % Seleccionar las señales EMG

    if use_ground_truth
        trainingSamples = newUserData.trainingSamples;
        testingSamples = newUserData.testingSamples;

        allData = struct();  % Aquí se guardará la combinación completa
        samplesPerGesture = 25;  % Siempre hay 25 repeticiones por gesto
        numGestos = 6;

        contador = 1;
        for g = 0:(numGestos-1)
            % Índices para este gesto en training y testing
            train_idx = (g * samplesPerGesture) + (1:samplesPerGesture);
            test_idx  = (g * samplesPerGesture) + (1:samplesPerGesture);

            % Añadir 25 de training
            for i = train_idx
                field = sprintf('idx_%d', i);
                allData.(sprintf('idx_%d', contador)) = trainingSamples.(field);
                contador = contador + 1;
            end

            % Añadir 25 de testing
            for i = test_idx
                field = sprintf('idx_%d', i);
                allData.(sprintf('idx_%d', contador)) = testingSamples.(field);
                contador = contador + 1;
            end
        end
        trainingSamples = allData;
        % Índices que se van a seleccionar
        %% 5 repeticiones por gesto
        %idx_seleccionados = [101, 102, 103, 104, 105, 126, 127, 128, 129, 130, 26, 27, 28, 29, 30, 51, 52, 53, 54, 55, 76, 77, 78, 79, 80, 1 ,2 ,3 ,4 ,5]; % Si está vacío, se seleccionan todos
        %% 7 repeticiones por gesto
        %idx_seleccionados = [101, 102, 103, 104, 105, 106, 107, 126, 127, 128, 129, 130, 131, 132, 26, 27, 28, 29, 30, 31, 32, 51, 52, 53, 54, 55, 56, 57, 76, 77, 78, 79, 80, 81, 82, 1 ,2 ,3 ,4 ,5, 6, 7]; % Si está vacío, se seleccionan todos
        %idx_seleccionados = [108:114, 133:139, 33:39, 58:64, 83:89, 8:14];
    else
        if version == "training"
            trainingSamples = newUserData.trainingSamples;
        elseif version == "testing"
            trainingSamples = newUserData.testingSamples;
        end
        %idx_seleccionados = [108:114, 133:139, 33:39, 58:64, 83:89, 8:14];
        %idx_seleccionados = [1:150];
    end


    % Obtener los campos de trainingSamples
    campos = fieldnames(trainingSamples);
    
    % Bandera para controlar el uso de groundTruthIndex
    
    
    % Si idx_seleccionados está vacío, seleccionar todos los campos
    if isempty(idx_seleccionados)
        idx_seleccionados = 1:length(campos);
    else
        campos_seleccionados = cell(length(idx_seleccionados), 1);
        for i = 1:length(idx_seleccionados)
            campos_seleccionados{i} = sprintf('idx_%d', idx_seleccionados(i));
    
        end
        % Verificar si los campos seleccionados existen
        campos_seleccionados = campos_seleccionados(ismember(campos_seleccionados, campos));
    
    end
    
    % Inicializar un mapa para agrupar por gesto
    mapaGestos = containers.Map();
    
    % Recorrer los campos seleccionados
    for i = 1:length(campos_seleccionados)
        campo = campos_seleccionados{i};
        sample = trainingSamples.(campo);
        gesture = sample.gestureName;
        
        % % Normalizar nombres de gestos
        % if strcmpi(gesture, 'relax')
        %     gesture = 'noGesto';
        % elseif strcmpi(gesture, 'wavein')
        %     gesture = 'WaveIn';
        % elseif strcmpi(gesture, 'waveout')
        %     gesture = 'WaveOut';
        % else
        %     disp(gesture);
        %     gesture = capitalizeFirst(gesture); % Fist, Open, Pinch
        % end

    gesture = char(sample.gestureName);
        % Verificar si ya existe este gesto en el mapa
    if ~isKey(mapaGestos, gesture)
        mapaGestos(gesture) = {};
    end
    
    signal = sample.emg;
    
    if use_ground_truth && isfield(sample, 'groundTruthIndex')
        rango_actual = sample.groundTruthIndex(2) - sample.groundTruthIndex(1) + 1;
        valores_a_agregar = floor((400 - rango_actual) / 2);
        nuevo_inicio = sample.groundTruthIndex(1) - valores_a_agregar;
        nuevo_fin = sample.groundTruthIndex(2) + valores_a_agregar;
        groundTruthIndex = [nuevo_inicio, nuevo_fin];
    else
        groundTruthIndex = [1, length(signal.ch1)];
    end
    
    if gesture == "noGesture" && use_ground_truth
        groundTruthIndex = [1,400];
    
    end
    
    start_idx = max(1, groundTruthIndex(1));
    end_idx = min(groundTruthIndex(2), length(signal.ch1));
    N = end_idx - start_idx + 1;
    data = zeros(N, 8);
    
    for k = 1:8
        campo_ch = sprintf('ch%d', k);
        data(:, k) = signal.(campo_ch)(start_idx:end_idx) / 128;
    end
    
    % Añadir la señal al mapa correctamente
    listaActual = mapaGestos(gesture);
    listaActual{end+1} = data;
    mapaGestos(gesture) = listaActual;
    end
    
    % Guardar cada gesto en su propio archivo .mat
    claves = keys(mapaGestos);
    for i = 1:length(claves)
        gesto = claves{i};
    dataGesture.name = gesto;
    dataGesture.emg = mapaGestos(gesto).';
        
        if use_ground_truth
            if gesto == "noGesture"
                filename = sprintf('%s%s.mat',usuario, "noGesto");
            else
                filename = sprintf('%s%s.mat',usuario, gesto);
            end
    
        else
            if strcmp(gesto, "noGesture")
                filename = sprintf('%s%sPaperPruebasnoGesto.mat', usuario, version);
            else
                filename = sprintf('%s%sPaperPruebas%s.mat',usuario,version, gesto);
            end
        end
    
        % Determinar carpeta de salida
        if modoEntrenamiento
            outputFolder = "TrainData";
        else
            outputFolder = "TestData";
        end

        % Crear carpeta si no existe
        if ~exist(outputFolder, 'dir')
            mkdir(outputFolder);
        end

        % Construir ruta completa al archivo
        fullPath = fullfile(outputFolder, filename);

        % Guardar archivo
        save(fullPath, 'dataGesture');

    end
    
end