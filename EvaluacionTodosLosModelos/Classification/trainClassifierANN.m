function [trainedANN, validationAccuracy] = trainANN(trainingData)
% --------------------------------------------------------------------
% ANN Model for Hand Gesture Recognition using EMG Signals
% Based on "Real-Time Hand Gesture Recognition Based on 
% Artificial Feed-Forward Neural Networks and EMG".
% --------------------------------------------------------------------

% Extract predictors and response
inputTable = trainingData;
predictorNames = {'WMoos_F1_Ms1', 'WMoos_F1_Ms2', 'WMoos_F1_Ms3', 'WMoos_F1_Ms4', 'WMoos_F1_Ms5', 'WMoos_F1_Ms6', 'WMoos_F1_Ms7', 'WMoos_F1_Ms8', 'WMoos_F2_Ms1', 'WMoos_F2_Ms2', 'WMoos_F2_Ms3', 'WMoos_F2_Ms4', 'WMoos_F2_Ms5', 'WMoos_F2_Ms6', 'WMoos_F2_Ms7', 'WMoos_F2_Ms8', 'WMoos_F3_Ms1', 'WMoos_F3_Ms2', 'WMoos_F3_Ms3', 'WMoos_F3_Ms4', 'WMoos_F3_Ms5', 'WMoos_F3_Ms6', 'WMoos_F3_Ms7', 'WMoos_F3_Ms8', 'WMoos_F4_Ms1', 'WMoos_F4_Ms2', 'WMoos_F4_Ms3', 'WMoos_F4_Ms4', 'WMoos_F4_Ms5', 'WMoos_F4_Ms6', 'WMoos_F4_Ms7', 'WMoos_F4_Ms8', 'WMoos_F5_Ms1', 'WMoos_F5_Ms2', 'WMoos_F5_Ms3', 'WMoos_F5_Ms4', 'WMoos_F5_Ms5', 'WMoos_F5_Ms6', 'WMoos_F5_Ms7', 'WMoos_F5_Ms8'};
predictors = inputTable{:, predictorNames};
response = inputTable.activity;

% Convert categorical response to numeric
categories = {'waveOut', 'waveIn', 'fist', 'open', 'pinch', 'noGesture'};
responseNumeric = grp2idx(categorical(response, categories));

% Normalize the predictors
[predictors, mu, sigma] = zscore(predictors);

% Split data into training and validation sets
cvp = cvpartition(responseNumeric, 'Holdout', 0.15);
trainingPredictors = predictors(cvp.training, :);
trainingResponse = responseNumeric(cvp.training, :);
validationPredictors = predictors(cvp.test, :);
validationResponse = responseNumeric(cvp.test, :);

% Define ANN Architecture
numFeatures = size(trainingPredictors, 2);
numHiddenUnits = 6;  % As defined in the paper
numClasses = numel(categories);

% Create ANN
layers = [ 
    featureInputLayer(numFeatures, 'Normalization', 'none')
    fullyConnectedLayer(numHiddenUnits)
    tanhLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
];

% Training options
options = trainingOptions('sgdm', ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 32, ...
    'InitialLearnRate', 0.01, ...
    'Shuffle', 'every-epoch', ...
    'Plots', 'training-progress', ...
    'Verbose', false);

% Train the ANN
trainedANN = trainNetwork(trainingPredictors, categorical(trainingResponse, 1:numClasses), layers, options);

% Validate the model
predictions = classify(trainedANN, validationPredictors);
validationAccuracy = sum(predictions == categorical(validationResponse, 1:numClasses)) / numel(validationResponse);

end
