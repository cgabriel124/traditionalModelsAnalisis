% Cargar el archivo .mat
load('resultadosFormatoMat/user1/newUserData.mat');

% Seleccionar la señal EMG
signal = newUserData.trainingSamples.idx_77.emg;

% Crear una figura con 8 subplots
figure;

% Iterar sobre cada canal y graficar la señal
for k = 1:8
    campo = sprintf('ch%d', k);
    subplot(8,1,k);
    plot(signal.(campo) / 128);
    title(['Canal ', num2str(k)]);
    xlabel('Muestras');
    ylabel('Amplitud Normalizada');
end

% Ajustar el tamaño de la figura
set(gcf, 'Position', [100 100 800 600]);