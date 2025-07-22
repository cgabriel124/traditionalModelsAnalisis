% MATLAB Code to generate sliding windows for EMG signals
% and corresponding gesture labels and indices

% Load user data
%load('userData.mat');

% Extract training samples
trainingSamples = userData.trainingSamples;
numGestures = numel(fieldnames(trainingSamples));

% Parameters for sliding window
windowSize = 200; % Window size
stepSize = 20;    % Step size (overlap)

% Initialize variables
CellEMGDataTrain = cell(0, 8); % Cell array for EMG windows (8 channels)
gestureLabels = [];            % Array for gesture labels
gestureIndices = [];           % Array for gesture indices

% Iterate through all gestures
for g = 1:numGestures
    % Access each gesture sample
    gestureField = sprintf('idx_%d', g);
    gestureData = trainingSamples.(gestureField);

    % Extract gesture name, EMG data, and ground truth
    gestureName = string(gestureData.gestureName);
    emgData = gestureData.emg; % Cell array for 8 channels

    % Handle ground truth
    if isfield(gestureData, 'groundTruth')
        groundTruth = gestureData.groundTruth;
    else
        n = size(emgData.ch1, 1);
        groundTruth = zeros(n, 1);
    end

    % Ensure groundTruth and one EMG channel match in size
    %assert(size(emgData{1}, 1) == size(groundTruth, 1), 'EMG and groundTruth size mismatch');

    % Create sliding windows
    numSamples = size(emgData{1}, 1);
    for startIdx = 1:stepSize:(numSamples - windowSize + 1)
        endIdx = startIdx + windowSize - 1;

        % Extract EMG window for all 8 channels
        emgWindow = zeros(windowSize, 8);
        for ch = 1:8
            emgWindow(:, ch) = emgData{ch}(startIdx:endIdx);
        end

        % Determine if the window contains a gesture
        groundTruthWindow = groundTruth(startIdx:endIdx);
        if any(groundTruthWindow)
            % Assign label and index for gesture windows
            gestureLabels = [gestureLabels; gestureName];
            gestureIndices = [gestureIndices; g];
        else
            % Label as 'noGesture'
            gestureLabels = [gestureLabels; "noGesture"];
            gestureIndices = [gestureIndices; 0];
        end

        % Store EMG window in cell array
        CellEMGDataTrain = [CellEMGDataTrain; {emgWindow}];
    end
end

% Save the results
save('ProcessedEMGData.mat', 'CellEMGDataTrain', 'gestureLabels', 'gestureIndices');
