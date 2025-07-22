% Cargar el archivo .mat
load alejandronoGesto.mat

% Seleccionar la señal EMG
signal = dataGesture.emg{1};

% Crear una figura con 8 subplots
figure;

% Iterar sobre cada canal y graficar la señal
for k = 1:8
    subplot(8,1,k);
    plot(signal(:,k));
    title(['Canal ', num2str(k)]);
    xlabel('Muestras');
    ylabel('Amplitud');
end

% Ajustar el tamaño de la figura
set(gcf, 'Position', [100 100 800 600]);