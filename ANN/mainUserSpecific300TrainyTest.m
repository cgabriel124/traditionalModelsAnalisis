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
folderTrainData = 'trainingJSON';
folderTestData  = 'testingJSON';
filesInTrainFolder = dir(folderTrainData);
filesInTestFolder  = dir(folderTestData);
numFiles = length(filesInTrainFolder);
userProcessed = 0;
responses.training = struct();
responses.testing = struct();

for user_i = 1:numFiles
  
  if ~(strcmpi(filesInTrainFolder(user_i).name, '.') || strcmpi(filesInTrainFolder(user_i).name, '..') || strcmpi(filesInTrainFolder(user_i).name, '.DS_Store'))

    %% Adquisition del usuario de entrenamiento
    userProcessed = userProcessed + 1;
    file = [folderTrainData '/' filesInTrainFolder(user_i).name '/' filesInTrainFolder(user_i).name '.json'];
    text = fileread(file);
    user = jsondecode(text);
    fprintf('Processing data from user: %d / %d\n', userProcessed, numFiles-2);
    close all;

    %% === ACCUMULATE TRAINING DATA (from both trainingSamples and testingSamples) ===
    totalX = [];
    totalY = [];

    % Get trainingSamples
    version = 'training'; 
    currentUserTrain = recognitionModel(user, version, gestures, options);
    [trainX1, trainY1] = currentUserTrain.getTotalXnYByUser();
    trainX1 = currentUserTrain.preProcessEMG(trainX1);
    [trainX1, trainY1] = currentUserTrain.makeSingleSet(trainX1, trainY1);
    totalX = [totalX; trainX1];
    totalY = [totalY; trainY1];

    % Get testingSamples para entrenamiento
    version = 'testing';
    currentUserTrainTest = recognitionModel(user, version, gestures, options);
    [trainX2, trainY2] = currentUserTrainTest.getTotalXnYByUser();
    trainX2 = currentUserTrainTest.preProcessEMG(trainX2);
    [trainX2, trainY2] = currentUserTrainTest.makeSingleSet(trainX2, trainY2);
    totalX = [totalX; trainX2];
    totalY = [totalY; trainY2];

    %% === TESTING ===
    % Verifica si existe archivo de test correspondiente antes de entrenar
    testUserName = filesInTrainFolder(user_i).name;
    testFile = fullfile(folderTestData, testUserName, [testUserName, '.json']);
    if ~exist(testFile, 'file')
        fprintf('Archivo de testing no encontrado para %s. No se entrena ni evalúa este usuario.\n', testUserName);
        continue;
    end

    %% ENTRENAMIENTO
    bestCenters = currentUserTrain.findCentersOfEachClass(totalX, totalY);
    dataX = currentUserTrain.featureExtraction(totalX, bestCenters);
    nnModel = currentUserTrain.preProcessFeatureVectors(dataX);
    nnModel.model = currentUserTrain.trainSoftmaxNN(nnModel.dataX, totalY);
    nnModel.numNeuronsLayers = currentUserTrain.numNeuronsLayers;
    nnModel.transferFunctions = currentUserTrain.transferFunctions;
    nnModel.centers = bestCenters;

    %% Cargar datos del archivo testing para evaluar
    testText = fileread(testFile);
    testUser = jsondecode(testText);
    userName = user.userInfo.name;

    % 1) Test with testingSamples (archivo distinto)
    version = 'testing';
    currentUserTest = recognitionModel(testUser, version, gestures, options);
    [testX, ~] = currentUserTest.getTotalXnYByUser();
    [predictedSeq, timeClassif, vectorTime] = currentUserTest.classifyEMG_SegmentationNN(testX, nnModel);
    [predictedLabels, timePos] = currentUserTest.posProcessLabels(predictedSeq);
    estimateTime = currentUserTest.computeTime(timeClassif, timePos);
    responses.testing.(userName) = currentUserTest.recognitionResults(predictedLabels, predictedSeq, timeClassif, vectorTime, 'testing');

    % 2) Test with trainingSamples (mismo archivo original)
    version = 'training';
    currentUserTest = recognitionModel(user, version, gestures, options);
    [testX, ~] = currentUserTest.getTotalXnYByUser();
    [predictedSeq, timeClassif, vectorTime] = currentUserTest.classifyEMG_SegmentationNN(testX, nnModel);
    [predictedLabels, timePos] = currentUserTest.posProcessLabels(predictedSeq);
    estimateTime = currentUserTest.computeTime(timeClassif, timePos);
    responses.training.(userName) = currentUserTest.recognitionResults(predictedLabels, predictedSeq, timeClassif, vectorTime, 'training');

  end
end

save("responses.mat", "responses");
currentUserTest.generateResultsJSON(responses);
