% FUNCION MODIFICADA: PreparacionDeDatosKNN_Unificada.m
% Descripcion: Carga datos de training y testing, los combina por bloques de 25 (training + testing),
% extrae señales EMG (usando groundTruth solo si tipo == "training"), y guarda cada gesto por separado.

function PreparacionDeDatosKNN_Unificada(usuario, carpetaDatos, tipo)

    % Validar tipo
    if ~(tipo == "training" || tipo == "testing")
        error('El tipo debe ser "training" o "testing"');
    end

    fprintf("Procesando usuario: %s\n", usuario);

    % Cargar datos según usuario
    if usuario ~= "userDataUnion"
        ruta = fullfile(carpetaDatos, sprintf('%s/newUserData.mat', usuario));
    else
        ruta = fullfile(carpetaDatos, 'newUserDataUnion.mat');
    end

    warning('off', 'all');
    if exist(ruta, 'file')
        datos = load(ruta);
    else
        return;
    end
    warning('on', 'all');

    newUserData = datos.newUserData;

    camposTrain = fieldnames(newUserData.trainingSamples);
    camposTest  = fieldnames(newUserData.testingSamples);

    if length(camposTrain) ~= 150 || length(camposTest) ~= 150
        error('Se esperan 150 muestras en training y 150 en testing');
    end

    mapaGestos = containers.Map();

    for bloque = 0:5  % 6 gestos
        fprintf("Procesando bloque de gesto #%d (índices %d al %d)", bloque+1, bloque*25+1, bloque*25+25);
        idxBase = bloque * 25;

        % Procesar los primeros 25 de training
        for offset = 1:25
            idx = idxBase + offset;
            campo = sprintf('idx_%d', idx);
            fprintf('idx_%d', idx);
            muestra = newUserData.trainingSamples.(campo);
            origen = "training";
            gesture = char(muestra.gestureName);
            fprintf("  Gesto: %s (fuente: %s)\n", gesture, origen);

            if ~isKey(mapaGestos, gesture)
                mapaGestos(gesture) = {};
            end

            signal = muestra.emg;

            if tipo == "training" && isfield(muestra, 'groundTruthIndex')
                rango = muestra.groundTruthIndex(2) - muestra.groundTruthIndex(1) + 1;
                agregar = floor((400 - rango) / 2);
                ini = muestra.groundTruthIndex(1) - agregar;
                fin = muestra.groundTruthIndex(2) + agregar;
                groundTruthIndex = [ini, fin];
            else
                groundTruthIndex = [1, length(signal.ch1)];
            end

            if gesture == "noGesture" && tipo == "training"
                groundTruthIndex = [1, 400];
            end

            ini = max(1, groundTruthIndex(1));
            fin = min(groundTruthIndex(2), length(signal.ch1));
            N = fin - ini + 1;
            data = zeros(N, 8);

            for canal = 1:8
                ch = sprintf('ch%d', canal);
                data(:, canal) = signal.(ch)(ini:fin) / 128;
            end

            lista = mapaGestos(gesture);
            lista{end+1} = data;
            mapaGestos(gesture) = lista;
        end

        % Procesar los siguientes 25 de testing
        for offset = 1:25
            idx = idxBase + offset;
            campo = sprintf('idx_%d', idx);
            muestra = newUserData.testingSamples.(campo);
            origen = "testing";
            gesture = char(muestra.gestureName);
            fprintf("  Gesto: %s (fuente: %s)\n", gesture, origen);

            if ~isKey(mapaGestos, gesture)
                mapaGestos(gesture) = {};
            end

            signal = muestra.emg;

            if tipo == "training" && isfield(muestra, 'groundTruthIndex')
                rango = muestra.groundTruthIndex(2) - muestra.groundTruthIndex(1) + 1;
                agregar = floor((400 - rango) / 2);
                ini = muestra.groundTruthIndex(1) - agregar;
                fin = muestra.groundTruthIndex(2) + agregar;
                groundTruthIndex = [ini, fin];
            else
                groundTruthIndex = [1, length(signal.ch1)];
            end

            if gesture == "noGesture" && tipo == "training"
                groundTruthIndex = [1, 400];
            end

            ini = max(1, groundTruthIndex(1));
            fin = min(groundTruthIndex(2), length(signal.ch1));
            N = fin - ini + 1;
            data = zeros(N, 8);

            for canal = 1:8
                ch = sprintf('ch%d', canal);
                data(:, canal) = signal.(ch)(ini:fin) / 128;
            end

            lista = mapaGestos(gesture);
            lista{end+1} = data;
            mapaGestos(gesture) = lista;
        end
    end

    claves = keys(mapaGestos);
    for i = 1:length(claves)
        gesto = claves{i};
        dataGesture.name = gesto;
        dataGesture.emg = mapaGestos(gesto).';

        fprintf("  Total de muestras para gesto '%s': %d\n", gesto, length(dataGesture.emg));

        if tipo == "training"
            if gesto == "noGesture"
                filename = sprintf('%snoGesto.mat', usuario);
            else
                filename = sprintf('%s%s.mat', usuario, gesto);
            end
        else
            if strcmp(gesto, "noGesture")
                filename = sprintf('%sPaperPruebasnoGesto.mat', usuario);
            else
                filename = sprintf('%sPaperPruebas%s.mat', usuario, gesto);
            end
        end

        partes = strsplit(carpetaDatos, filesep);
        carpetaMes = partes{end};
        rutaActual = pwd;
        carpetaKNN = fullfile(rutaActual, 'KNN', carpetaMes);
        if ~exist(carpetaKNN, 'dir')
            mkdir(carpetaKNN);
        end
        save(fullfile(carpetaKNN, filename), 'dataGesture');
    end

end
