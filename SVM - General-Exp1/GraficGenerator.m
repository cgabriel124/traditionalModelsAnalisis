function mainGraficarResultados()
type = "testing";


%% Buscar archivos y combinarlos
currentFolder = pwd;
archivos = dir(fullfile(currentFolder, 'ResultadosEstructurados_*.mat'));

if isempty(archivos)
    error('No se encontraron archivos con el nombre "ResultadosEstructurados_*.mat"');
end

estructuraFinal.meses = struct();  % Inicializamos el campo "meses"

for i = 1:length(archivos)
    nombreArchivo = archivos(i).name;
    data = load(nombreArchivo);

    if ~isfield(data, 'resultadosEstructurados')
        error('El archivo %s no contiene la variable "resultadosEstructurados"', nombreArchivo);
    end

    disp(['Cargando: ', nombreArchivo]);
    tokens = regexp(nombreArchivo, 'ResultadosEstructurados_Mes_(\d+)\.mat', 'tokens');

    if ~isempty(tokens)
        numMes = str2double(tokens{1}{1});
        nombreMes = sprintf('Mes_%d', numMes);

        % Extraemos directamente la estructura de datos del mes
        estructuraFinal.meses.(nombreMes) = data.resultadosEstructurados.(nombreMes);
    else
        warning('El archivo %s no coincide con el patrón esperado.', nombreArchivo);
    end
end

% Guardamos la estructura final en un archivo .mat
save('monthlyResults.mat', '-struct', 'estructuraFinal');
disp('Archivo monthlyResults.mat guardado correctamente.');



% Cargar archivo
load('monthlyResults.mat'); % Carga variable "meses"

% Obtener nombres de los meses
monthNames = fieldnames(meses);
numMonths = length(monthNames);

% Inicializar estructura para guardar resultados
metricTypes = {'classification', 'recognition', 'overlapping'};
userData = struct();

for m = 1:numMonths
    monthField = monthNames{m};
    currentMonth = meses.(monthField);
    userNames = fieldnames(currentMonth);

    for u = 1:length(userNames)
        user = userNames{u};
        if isfield(currentMonth.(user), type)  % Asegura que tenga datos del tipo solicitado (training/testing)

            for mt = 1:length(metricTypes)
                metric = metricTypes{mt};

                if isfield(currentMonth.(user).(type), metric)
                    value = currentMonth.(user).(type).(metric);
                else
                    value = NaN;
                end

                if ~isfield(userData, user)
                    userData.(user) = struct();
                end
                if ~isfield(userData.(user), metric)
                    userData.(user).(metric) = nan(1, numMonths);
                end
                userData.(user).(metric)(m) = value;
            end
        end
    end
end

%%%%%%%GRAFICAR
metricTypes = {'classification', 'recognition', 'overlapping'};

for mt = 1:length(metricTypes)
    metric = metricTypes{mt};
    figure;
    hold on;

    users = fieldnames(userData);
    allValues = [];

    % Dibujar líneas de usuarios con transparencia
    for u = 1:length(users)
        user = users{u};
        values = userData.(user).(metric);
        allValues = [allValues; values]; % Guardar para calcular el promedio

        p = plot(1:numMonths, values, '-o', 'LineWidth', 1.5);
        p.Color(4) = 0.3; % Alpha para transparencia (valor entre 0 y 1)
    end

    % Calcular y graficar el promedio
    avgValues = mean(allValues, 1, 'omitnan');
    plot(1:numMonths, avgValues, '-o', 'Color', [0 0 0], 'LineWidth', 2.5); % Negro, sin transparencia

    % Ajustes del gráfico
    title(['Promedio y Evolución Individual - ', metric]);
    xlabel('Mes');
    ylabel('Porcentaje (%)');
    xticks(1:numMonths);
    xticklabels(monthNames);
    legend({'Promedio'}, 'Location', 'best');
    grid on;
    hold off;
end

%%Graficas interactivas
for mt = 1:length(metricTypes)
    metric = metricTypes{mt};
    figure('Name', ['Interactivo - ', metric], 'NumberTitle', 'off');
    hold on;

    users = fieldnames(userData);
    allValues = [];
    colors = lines(length(users));  % Colores únicos

    % Dibujar líneas con transparencia
    for u = 1:length(users)
        user = users{u};
        values = userData.(user).(metric);
        allValues = [allValues; values];

        % Línea individual con transparencia
        p = plot(1:numMonths, values, '-o', ...
            'Color', [colors(u,:) 0.3], 'LineWidth', 1.5);

        % Etiquetas invisibles para cada punto (para usar con datatip)
        for i = 1:numMonths
            t = text(i, values(i), '', 'Visible', 'off');
            set(t, 'UserData', user);  % Guardar nombre de usuario
        end
    end

    % Línea de promedio
    avgValues = mean(allValues, 1, 'omitnan');
    plot(1:numMonths, avgValues, '-o', 'Color', [0 0 0], 'LineWidth', 2.5);

    % Estética
    title(['Gráfica Interactiva - ', metric]);
    xlabel('Mes');
    ylabel('Porcentaje (%)');
    xticks(1:numMonths);
    xticklabels(monthNames);
    legend({'Promedio'}, 'Location', 'best');
    grid on;
    hold off;

    % Activar datacursormode con función personalizada
    dcm = datacursormode(gcf);
    set(dcm, 'UpdateFcn', @(~, event_obj) customDataTip(event_obj, userData, metric, monthNames));
end

end

% Función personalizada para datatip
function output_txt = customDataTip(event_obj, userData, metric, monthNames)
    pos = get(event_obj, 'Position');
    idx = pos(1);
    val = pos(2);
    users = fieldnames(userData);
    userName = 'Desconocido';

    for i = 1:length(users)
        datos = userData.(users{i}).(metric);
        if idx <= length(datos) && abs(datos(idx) - val) < 0.001
            userName = users{i};
            break;
        end
    end

    output_txt = {
        ['Mes: ', monthNames{idx}], 
        ['Valor: ', num2str(val, '%.2f'), '%'], 
        ['Usuario: ', userName]
    };
end








%%%Estructura
%% archivo: "monthlyResults.mat"
%meses
%-Mes_1
%--Mes_1
%---user1
%------classification
%------recognition
%------overlapping
%---user2
%------classification
%------recognition
%------overlapping
%---user3
%------classification
%------recognition
%------overlapping
%...
%-Mes_2
%--Mes_2
%---user1
%------classification
%------recognition
%------overlapping
%---user2
%------classification
%------recognition
%------overlapping
%---user3
%...
%-Mes_n

%archivo: ResultadosEstructurados_Mes_1.mat
%resultadosEstructurados
%-Mes_1
%---user1
%------classification
%------recognition
%------overlapping
%---user2
%------classification
%------recognition
%------overlapping
%---user3
%------classification
%------recognition
%------overlapping
%...



