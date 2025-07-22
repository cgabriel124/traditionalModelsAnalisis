%%Sirve para unir gestos de N usuarios con N idx seleccionados en un solo
%%elemento con el fin de usarlo para entrenar un modelo general

function UnirDatosKNN(usuarios, idx_seleccionados, version, nombre_salida)
    % Orden fijo de gestos estandarizados
    ordenGestos = {'noGesture', 'fist', 'open', 'pinch', 'waveIn', 'waveOut'};
    %%%%                1-25.....26-50..51-75...76-100...101-125...126-150
    %idx_seleccionados = [108:114, 133:139, 33:39, 58:64, 83:89, 8:14];
    %idx_seleccionados=[1:5,26:30,51:55,76:80,101:105,126:130];

    
    allSamplesList = {}; % Celda vacía
    
    idx_counter=1;
    %version = "testingSamples";
    version = "trainingSamples";
    newUserDataUnion = struct();
    
    
    for x = 1:length(ordenGestos)
        gestoActual = ordenGestos{x};  % ← Usa llaves para obtener el string
        disp(["Procesando gesto:", gestoActual])
    
        for u = 1:length(usuarios)
            usuario = usuarios(u);
            load(sprintf('resultadosFormatoMat/user%d/newUserData.mat', usuario));
    
            samples = newUserData.(version);
            campos = fieldnames(samples);
    
            % Filtrar campos válidos (idx_XXX existentes)
            campos_seleccionados = {};
            for i = 1:length(idx_seleccionados)
                campoNombre = sprintf('idx_%d', idx_seleccionados(i));
                if ismember(campoNombre, campos)
                    campos_seleccionados{end+1} = campoNombre;
                end
            end
    
            % Recorrer campos válidos y extraer los que coincidan con el gesto actual
            for i = 1:length(campos_seleccionados)
                sample = samples.(campos_seleccionados{i});
                nombreGesto = string(sample.gestureName);
    
                if nombreGesto == gestoActual
                    idx_actual = sprintf('idx_%d', idx_counter);
                    newUserDataUnion.(version).(idx_actual) = sample;
                    idx_counter = idx_counter + 1;
                end
            end
        end
    end
    newUserData = newUserDataUnion;
    
    %disp(newUserDataUnion.samples)
    save([nombre_salida '.mat'], 'newUserData');

end
