load('user7Database.mat'); % Cargar la variable database
N = size(database, 1);
numChannels = 8;

% Matriz de distancias DTW
D = zeros(N);
disp("Calculando distancias DTW...");
for i = 1:N
    for j = i+1:N
        D(i,j) = multiChannelDTW(database(i,:), database(j,:));
        D(j,i) = D(i,j);
    end
end

% t-SNE no funciona con matriz precomputada, usamos MDS en su lugar
Y = cmdscale(D, 2);  % Reducción a 2 dimensiones

% Etiquetas
labels = repelem(1:6, N/6)';
nameGestures = {'noGesto'; 'WaveIn'; 'WaveOut'; 'Fist'; 'Open'; 'Pinch'};

nameGestures={'WaveIn';'WaveOut';'Fist';'Open';'Pinch';'noGesto'};
% Graficar
figure;
gscatter(Y(:,1), Y(:,2), labels);

title('Visualización con MDS y DTW user 3 nuevo');
xlabel('Dim 1');
ylabel('Dim 2');
legend(nameGestures, 'Location', 'best');
grid on;


function dist = multiChannelDTW(sig1, sig2)
    dist = 0;
    for ch = 1:8
        dist = dist + dtw(sig1{ch}, sig2{ch});
    end
end