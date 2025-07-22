%%La data tiene la siguiente estructura {"noGesture", "fist", "open", "pinch", "waveIn", "waveOut"}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   1-25.....26-50..51-75...76-100...101-125...126-150
clc
clear
idx_seleccionados = [1:150];
%idx_seleccionados = [ 1:10,26:35,51:60,76:85,101:110,126:135 ];
%idx_seleccionados = [108:114, 133:139, 33:39, 58:64, 83:89, 8:14];
% usuario = "user6";
% version = "testingSamples";
% PreparacionDeDatosKNN(usuario,idx_seleccionados,version);
% version = "trainingSamples";
% PreparacionDeDatosKNN(usuario,idx_seleccionados,version);
% for i = 3:5
%     usuario = strcat('user', num2str(i));
%     version = "testingSamples";
%     PreparacionDeDatosKNN(usuario,idx_seleccionados,version);
%     version = "trainingSamples";
%     PreparacionDeDatosKNN(usuario,idx_seleccionados,version);
% end
% 
% 
%% Para el trainingn
idx_seleccionados = 1:300; %% todos los datos

%idx_seleccionados = [1:25; 51:75; 101:125; 151:175; 201:225; 251:275];
idx_seleccionados = [1:25, 51:75, 101:125, 151:175,201:225, 251:275] ;
modoEntrenamientoCompleto = true; %% obtener la data para entrenamiento total
for i = 4:4
    usuario = strcat('user', num2str(i));
    PreparacionDeDatosKNN(usuario, idx_seleccionados, version, modoEntrenamientoCompleto);
end


%% para el testing
version = "testing";  % obtiene los usuarios de testeo de la parte de testing
%version = "training";  % obtiene los usuarios de testeo de la parte de training
idx_seleccionados = 1:150;
modoEntrenamientoCompleto = false;

for i = 4:4
    usuario = strcat('user', num2str(i));
    PreparacionDeDatosKNN(usuario, idx_seleccionados, version, modoEntrenamientoCompleto);
end




% clear
% clc
% idx_seleccionados = [ 1:150 ];
% usuarios = [3,5,7,9];
% n = length(idx_seleccionados)*length(usuarios);
% 
% %% Testing Part General
% version = "testingSamples";
% nombre_salida = "userUnion";
% UnirDatosKNN(usuarios, idx_seleccionados, version, nombre_salida);
% 
% idx_seleccionados = [1:n];
% usuario = "userDataUnion";
% PreparacionDeDatosKNN(usuario,idx_seleccionados,version);
% 
% %% Training Part General
% version = "trainingSamples";
% nombre_salida = "userUnion";
% UnirDatosKNN(usuarios, idx_seleccionados, version, nombre_salida);
% 
% idx_seleccionados = [1:n];
% usuario = "userDataUnion";
% PreparacionDeDatosKNN(usuario,idx_seleccionados,version);
% 
% clear
% clc