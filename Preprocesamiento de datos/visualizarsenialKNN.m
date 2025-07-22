% Cargar el archivo .mat
load('user4pinch.mat');  % Asegúrate de que el archivo esté en el path

% Seleccionar el gesto que deseas visualizar
gestureIndex = 1;

% Extraer la señal EMG del gesto seleccionado (Nx8)
signal = dataGesture.emg{gestureIndex};  % N muestras x 8 canales

% Crear una figura con 8 subplots (uno por canal)
figure;
for k = 1:8
    subplot(8, 1, k);
    plot(signal(:,k) / 128);  % Normalización opcional
    title(['Canal ', num2str(k)]);
    xlabel('Muestras');
    ylabel('Amplitud');
end

% Ajustar tamaño de la figura para mejor visualización
set(gcf, 'Position', [100 100 800 800]);
