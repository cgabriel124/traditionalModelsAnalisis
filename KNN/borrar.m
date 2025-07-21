numRepTest = 50;
if numRepTest == 50
    users = fieldnames(response.training);
    blockSize = 25;
    totalElements = 6 * numRepTest; % 6 gestos * 50 repeticiones = 300

    for u = 1:numel(users)
        userName = users{u};
        if isfield(response, "testing") && isfield(response.testing, userName) ...
                && isfield(response.testing.(userName), "class")
            fprintf("Usuario %s ya tiene datos en testing. Se omite.\n", userName);
            continue;
        end

        % Vectores originales
        labels = response.training.(userName).vectorOfLabels;
        classes = response.training.(userName).class;
        procTimes = response.training.(userName).vectorOfProcessingTime;
        timePoints = response.training.(userName).vectorOfTimePoints;

        % Inicializar los vectores de training y testing vacíos
        trainLabels = {};
        trainClasses = {};
        trainProcTimes = {};
        trainTimePoints = {};

        testLabels = {};
        testClasses = {};
        testProcTimes = {};
        testTimePoints = {};

        % Recorrer por bloques de 25 y distribuir alternadamente
        numBlocks = totalElements / blockSize; % 300/25 = 12 bloques
        for b = 1:numBlocks
            idxStart = (b-1)*blockSize + 1;
            idxEnd = b*blockSize;

            % Extraer bloque actual
            blkLabels = labels(idxStart:idxEnd);
            blkClasses = classes(idxStart:idxEnd);
            blkProcTimes = procTimes(idxStart:idxEnd);
            blkTimePoints = timePoints(idxStart:idxEnd);

            if mod(b,2) == 1
                % Bloques impares van a training
                trainLabels = [trainLabels; blkLabels];
                trainClasses = [trainClasses; blkClasses];
                trainProcTimes = [trainProcTimes; blkProcTimes];
                trainTimePoints = [trainTimePoints; blkTimePoints];
            else
                % Bloques pares van a testing
                testLabels = [testLabels; blkLabels];
                testClasses = [testClasses; blkClasses];
                testProcTimes = [testProcTimes; blkProcTimes];
                testTimePoints = [testTimePoints; blkTimePoints];
            end
        end

        % Asignar datos reagrupados a response.training y response.testing
        response.training.(userName).vectorOfLabels = trainLabels;
        response.training.(userName).class = trainClasses;
        response.training.(userName).vectorOfProcessingTime = trainProcTimes;
        response.training.(userName).vectorOfTimePoints = trainTimePoints;

        response.testing.(userName).vectorOfLabels = testLabels;
        response.testing.(userName).class = testClasses;
        response.testing.(userName).vectorOfProcessingTime = testProcTimes;
        response.testing.(userName).vectorOfTimePoints = testTimePoints;
    end
end
save('responsesKNN.mat', 'response');