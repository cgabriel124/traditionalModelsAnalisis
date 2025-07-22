clc
clear all
close all
warning off all;

addpath('ReadDataset');
addpath('Preprocessing');
addpath('Segmentation');
addpath('DTW distance');
addpath('TrainingModel');
addpath('Feature extraction');

addpath('libs'); % libreria de Jonathan
gestures = {'noGesture', 'open', 'fist', 'waveIn', 'waveOut', 'pinch'};



%% ======================= Model Configuration ===========================

load options.mat

% This command makes possible the reproducibility of the results
rng('default'); 

%%
userFolder = 'training';
folderData = [userFolder 'JSON'];
filesInFolder = dir(folderData);
numFiles = length(filesInFolder);
userProcessed = 0;
% responses.userGroup = userFolder; 
gestures = {'noGesture', 'open', 'fist', 'waveIn', 'waveOut', 'pinch'};


%%Para un modelo general agrupare la data X e Y de todos los usuarios
totalX = [];
totalY = [];

for user_i = 1:numFiles
    
  if ~(strcmpi(filesInFolder(user_i).name, '.') || strcmpi(filesInFolder(user_i).name, '..') || strcmpi(filesInFolder(user_i).name, '.DS_Store'))

 %% Adquisition     
      
     userProcessed = userProcessed + 1;
     file = [folderData '/' filesInFolder(user_i).name '/' filesInFolder(user_i).name '.json'];
     text = fileread(file);
     user = jsondecode(text);
     fprintf('Processing data from user: %d / %d\n', userProcessed, numFiles-2);
     close all;
    
    % Reading the training samples
     version = 'testing'; 
     currentUserTrain = recognitionModel(user, version, gestures, options);
     [train_RawX_temp, train_Y_temp] = currentUserTrain.getTotalXnYByUser(); 
    
   %% Preprocessing   
       % Filter applied  
     train_FilteredX_temp = currentUserTrain.preProcessEMG(train_RawX_temp);
       % Making a single set with the training samples of all the classes
     [filteredDataX, dataY] = currentUserTrain.makeSingleSet(train_FilteredX_temp, train_Y_temp);
      % Finding the EMG that is the center of each class
      bestCenters = currentUserTrain.findCentersOfEachClass(filteredDataX, dataY);
    %% Feature Extraction      
      % Feature extraction by computing the DTW distanc
      dataX = currentUserTrain.featureExtraction(filteredDataX, bestCenters);
      % Preprocessing the feature vectors
      nnModel = currentUserTrain.preProcessFeatureVectors(dataX);
    %%Guardar variables para un modelo general.
    totalX = [totalX; filteredDataX];
    totalY = [totalY; dataY];
    
    % % Training 
    %   % Training the feed-forward NN
    %   nnModel.model = currentUserTrain.trainSoftmaxNN(nnModel.dataX, dataY);
    %   nnModel.numNeuronsLayers = currentUserTrain.numNeuronsLayers;
    %   nnModel.transferFunctions = currentUserTrain.transferFunctions;
    %   nnModel.centers = bestCenters;
    % 
    %  %% Testing  
    %   % Reading the testing samples
    %   version = 'testing';
    %   currentUserTest = recognitionModel(user, version, gestures, options);  %%gestures 2 6
    %   test_RawX = currentUserTest.getTotalXnYByUser();
    % 
    %   % Classification
    %   [predictedSeq,  timeClassif, vectorTime] = currentUserTest.classifyEMG_SegmentationNN(test_RawX, nnModel);
    % 
    %   % Pos-processing labels
    %   [predictedLabels, timePos] = currentUserTest.posProcessLabels(predictedSeq);
    % 
    %   % Computing the time of processing
    %   estimateTime = currentUserTest.computeTime(timeClassif, timePos);
    %   % Concatenating the predictions of all the users for computing the
    %   % errors
    % 
    %   responses.(version).(user.userInfo.name) = currentUserTest.recognitionResults(predictedLabels,predictedSeq,timeClassif,vectorTime,'testing');   

     
  end
  
  %clc
end

%currentUserTest.generateResultsJSON(responses);

%clear;

%%General

userGeneral = "ModeloGeneral";
version = 'training';
load options.mat
gestures = {'noGesture', 'open', 'fist', 'waveIn', 'waveOut', 'pinch'};
currentUserTrain = recognitionModel(userGeneral, version, gestures, options);

bestCenters = currentUserTrain.findCentersOfEachClass(totalX, totalY);

dataX = currentUserTrain.featureExtraction(totalX, bestCenters);

nnModel = currentUserTrain.preProcessFeatureVectors(dataX);

nnModel.model = currentUserTrain.trainSoftmaxNN(nnModel.dataX, totalY);
nnModel.numNeuronsLayers   = currentUserTrain.numNeuronsLayers;
nnModel.transferFunctions = currentUserTrain.transferFunctions;
nnModel.centers = bestCenters;


%% ========================= Testing con Modelo General =========================

userFolder = 'testing';
folderData = [userFolder 'JSON'];
filesInFolder = dir(folderData);
numFiles = length(filesInFolder);
userProcessed = 0;

responses.testing = struct(); % Estructura para almacenar resultados

for user_i = 1:numFiles
    
    if ~(strcmpi(filesInFolder(user_i).name, '.') || strcmpi(filesInFolder(user_i).name, '..') || strcmpi(filesInFolder(user_i).name, '.DS_Store'))
        
        %% Adquisición de datos de prueba
        userProcessed = userProcessed + 1;
        file = [folderData '/' filesInFolder(user_i).name '/' filesInFolder(user_i).name '.json'];
        text = fileread(file);
        user = jsondecode(text);
        fprintf('Testing data from user: %d / %d\n', userProcessed, numFiles-2);
        
        version = 'training';
        currentUserTest = recognitionModel(user, version, gestures, options);

        % Obtener los datos de prueba
        test_RawX = currentUserTest.getTotalXnYByUser();

        % Clasificación con el modelo general
        [predictedSeq, timeClassif, vectorTime] = currentUserTest.classifyEMG_SegmentationNN(test_RawX, nnModel);

        % Post-procesamiento de etiquetas
        [predictedLabels, timePos] = currentUserTest.posProcessLabels(predictedSeq);

        % Cálculo del tiempo total de clasificación
        estimateTime = currentUserTest.computeTime(timeClassif, timePos);

        % Guardar resultados en la estructura de respuestas
        responses.testing.(user.userInfo.name) = currentUserTest.recognitionResults(predictedLabels, predictedSeq, timeClassif, vectorTime, 'testing');   
    end
end

% Guardar resultados en un JSON
save("responses.mat", "responses");
currentUserTest.generateResultsJSON(responses);

