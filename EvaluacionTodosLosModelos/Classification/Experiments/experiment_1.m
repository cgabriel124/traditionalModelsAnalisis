function control = experiment_1(model,syncro,energy_umbral)

if model==1
    modelSelected='general';
else
    modelSelected='specific';
end

assignin('base','modelSelected',modelSelected);

fprintf('Experiment selected : %d\n',1);
fprintf('Model selected      : %s\n',modelSelected);

if modelSelected=="general"
    dataPacket      = orderfields(dir('Data\General\Training'));
    pathOrigin      = 'Data\General\Training';
elseif modelSelected=="specific"
    dataPacket      = orderfields(dir('Data\Specific'));
    pathOrigin      = 'Data\Specific';
end

dataPacketSize  = length(dataPacket);
pathUser        = pwd;
userCounter     = 1;
% ================================ MAD & Energy ==================================
orientation  = cell(dataPacketSize-2,2);
for k=1:dataPacketSize

    if ~(strcmpi(dataPacket(k).name, '.') || strcmpi(dataPacket(k).name, '..'))
        usuario     = dataPacket(k).name;
        userFolder  = horzcat(pathUser,'\',pathOrigin,'\',dataPacket(k).name,'\','userData.mat');
        load(userFolder);

        if syncro>0
            for x=1:150
                gesto_=userData.training{x,1}.gestureName;
                assignin('base','gesto_',gesto_);
                if gesto_=="waveOut"
                    location_=x;
                    break;
                end
            end
            elec_=zeros(1,syncro);
            aux=1;
            energy_order=zeros(syncro,8);
            % =======================================================
            %                     NO ROTATION
            % =======================================================
            for goto_=location_:location_+syncro-1
                emgData             = userData.training{goto_,1}.emg;
                Index_              = userData.training{goto_,1}.groundTruthIndex;
                Index_high_         = Index_(1,2);
                emgData             = emgData(Index_high_ - 255:Index_high_,:);
                energy_wm           = WMoos_F5(emgData');
                energy_order(aux,:) = energy_wm;
                [~,max_energy]      = max((energy_wm));
                elec_(1,aux)        = max_energy;
                aux = aux+1;
            end
            ref_partial         = histcounts(elec_(1,:),1:(8+1));
            [~,ref]             = max(ref_partial);
            xyz                 = ref;
        else
            xyz                 = 1 ;
        end
        % ================== Umbral =========================

        calibration_umbral=zeros(8,5);
        save("userDataErrror.mat", "userData");
        for o=1:5
            waveout_pure=userData.sync{o,1}.emg;
            umbral_envelope_wm=WMoos_F5(waveout_pure');
            calibration_umbral(:,o)=umbral_envelope_wm;
        end
        sequence_=WM_X(xyz);
        calibration_umbral=calibration_umbral';
        calibration_umbral=calibration_umbral(:,sequence_);
        mean_umbral=calibration_umbral;
        mean_umbral=mean(mean_umbral);
        val_umbral_high = energy_umbral*sum(mean_umbral(1:4))/4;
        val_umbral_low  = energy_umbral*sum(mean_umbral(5:8))/4;

        % ==================================================
        orientation{userCounter,1} = usuario;
        orientation{userCounter,2} = xyz;
        orientation{userCounter,3} = val_umbral_low;
        orientation{userCounter,4} = val_umbral_high;
        userCounter = userCounter+1;
    end
end
assignin('base','orientation',orientation);
% ================= Index & locations ================
[Location,indices,gestureLocation,low_bajo]=getIndex(modelSelected);
% ======================================================

low_bajo            = rmfield(low_bajo,'NaN');
low_bajoPacket      = fieldnames(low_bajo);

if length(fields(low_bajo)) >=1
    exitCheck=false;
else
    fprintf('All users can be used for training .... \n');
    pause(4)
    exitCheck=true;
end


if exitCheck==true

    % ==================================================================================
    % =========================    TRAINING MODELS    ==================================
    % ==================================================================================

    if  modelSelected =="general"

        % ============================== GENERAL ====================================
        name_indices='indicesTodosExp1G.mat';
        save('indicesTodosExp1G.mat','Location','indices','gestureLocation')
        % ============================== Check sensor placement =====================
        [~,users_good_checked,~] = Wmoos_check_sensor_placement(name_indices,'NR',1);
        assignin('base','users_good_checked',users_good_checked);
        % ============================== Packing EMG Data ===========================
        fprintf('\nPacking all EMG Data ...\n');
        ventana=180;
        [trainActivity,Ms1,Ms2,Ms3,Ms4,Ms5,Ms6,Ms7,Ms8]=Wmoos_data_union(ventana,name_indices,'NC','NR');
        trainActivity=trainActivity';
        CellEMGDataTrain= [Ms1,Ms2,Ms3,Ms4,Ms5,Ms6,Ms7,Ms8];
        assignin('base','trainActivity',trainActivity);
        assignin('base','CellEMGDataTrain',CellEMGDataTrain);
        % ============================== Featuring EMG Data =========================
        fprintf('\nFeatures, EMG Data ...\n');
        fprintf('Please wait ... \n');
        sEMGActivityData=Wmoos_features_selection_mod_5();
        clear CellEMGDataTrain Ms1 Ms2 Ms3 Ms4 Ms5 Ms6 Ms7 Ms8
        % ================================= Training ================================
        fprintf('\nTraining General Model Exp1 ...\n');
        fprintf('Please wait ... \n');
        %----------SVM
        [trainedClassifier, ~] = trainClassifier(sEMGActivityData);

        assignin('base','trainedClassifier',trainedClassifier);

        save('trainedClassifier.mat', 'trainedClassifier');

        beep
        pause(6)
        clc

        % ====================================
        % ======= READY TO TEST EXP 1 ========
        % ====================================
    end

    % ==================================================================================
    % ==========================    TESTING MODELS    ==================================
    % ==================================================================================

    if  modelSelected =="general"
        % ============================== GENERAL ====================================
        dataPacket      = orderfields(dir('Data\General\Testing'));
        dataPacketSize  = length(dataPacket);
        pathUser        = pwd;
        pathOrigin      = 'Data\General\Testing';

        assignin('base','dataPacket',     dataPacket);
        assignin('base','dataPacketSize', dataPacketSize);
        assignin('base','pathUser',       pathUser);
        assignin('base','pathOrigin',     pathOrigin);

        userCounter     = 1;
        % ================================ MAD & Energy ==================================
        orientation  = cell(dataPacketSize-2,2);
        for k=1:dataPacketSize

            if ~(strcmpi(dataPacket(k).name, '.') || strcmpi(dataPacket(k).name, '..'))
                usuario     = dataPacket(k).name;
                userFolder  = horzcat(pathUser,'\',pathOrigin,'\',dataPacket(k).name,'\','userData.mat');
                load(userFolder);

                if syncro>0
                    for x=1:150
                        gesto_=userData.training{x,1}.gestureName;
                        if gesto_=="waveOut"
                            location_=x;
                            break;
                        end
                    end
                    elec_=zeros(1,syncro);
                    aux=1;
                    energy_order=zeros(syncro,8);

                    % =======================================================
                    %                     NO ROTATION
                    % =======================================================
                    for goto_=location_:location_+syncro-1
                        emgData             = userData.training{goto_,1}.emg;
                        Index_              = userData.training{goto_,1}.groundTruthIndex;
                        Index_high_         = Index_(1,2);
                        emgData             = emgData(Index_high_ - 255:Index_high_,:);
                        energy_wm           = WMoos_F5(emgData');
                        energy_order(aux,:) = energy_wm;
                        [~,max_energy]      = max((energy_wm));
                        elec_(1,aux)        = max_energy;
                        aux = aux+1;
                    end
                    ref_partial         = histcounts(elec_(1,:),1:(8+1));
                    [~,ref]             = max(ref_partial);
                    xyz                 = ref;
                else
                    xyz                 = 1 ;
                end
                % ================== Umbral =========================

                calibration_umbral=zeros(8,5);
                for o=1:5
                    waveout_pure=userData.sync{o,1}.emg;
                    umbral_envelope_wm=WMoos_F5(waveout_pure');
                    calibration_umbral(:,o)=umbral_envelope_wm;
                end
                sequence_=WM_X(xyz);
                calibration_umbral=calibration_umbral';
                calibration_umbral=calibration_umbral(:,sequence_);
                mean_umbral=calibration_umbral;
                mean_umbral=mean(mean_umbral);
                val_umbral_high = energy_umbral*sum(mean_umbral(1:4))/4;
                val_umbral_low  = energy_umbral*sum(mean_umbral(5:8))/4;

                % ==================================================

                orientation{userCounter,1} = usuario;
                orientation{userCounter,2} = xyz;
                orientation{userCounter,3} = val_umbral_low;
                orientation{userCounter,4} = val_umbral_high;
                userCounter = userCounter+1;
            end
        end
        assignin('base','orientation',orientation);


        % ============================ Initialization =============================

        userIndex       = 1;            % Start reading from first user
        %emgRepetition   = 151;          % Start getting the first gesture repetition
        emgRepetition = 1;
        stepControl     = 1;            % Set the first windows index(steps) to 1
        responseIndex   = 1;            % First response goes to the location 1
        responseBuffer  = 'noGesture';  % First gesture located the buffer is "noGesture"

        start_at        = emgRepetition;

        assignin('base','userIndex',     userIndex);
        assignin('base','emgRepetition', emgRepetition);
        assignin('base','stepControl',   stepControl);
        assignin('base','responseIndex', responseIndex);
        assignin('base','responseBuffer',responseBuffer);

        assignin('base','low_umbral', 0);
        assignin('base','high_umbral',0);
        assignin('base','matrix',0);

        % Buffers

        conditionBuffer       = false;
        conditionBuffer_one   = false;
        conditionBuffer_two   = false;

        responseBuffer      = 'noGesture';  % First  buffer gesture located the buffer is "noGesture"
        responseBuffer_one  = 'noGesture';  % Second  buffer gesture located the buffer is "noGesture"
        responseBuffer_two  = 'noGesture';  % Third  buffer gesture located the buffer is "noGesture"

        assignin('base','conditionBuffer',     conditionBuffer);
        assignin('base','conditionBuffer_one', conditionBuffer_one);
        assignin('base','conditionBuffer_two', conditionBuffer_two);

        assignin('base','responseBuffer',     responseBuffer);
        assignin('base','responseBuffer_one', responseBuffer_one);
        assignin('base','responseBuffer_two', responseBuffer_two);
        assignin('base','counter_target', 0);

        % Creatting variable "response" to locate all responses

        response.NaN.class{1,1}{1,1}                  = "NaN";
        response.NaN.vectorOfLabels{1,1}{1,1}         = "NaN";
        response.NaN.vectorOfTimePoints{1,1}{1,1}     = 0;
        response.NaN.vectorOfProcessingTime{1,1}{1,1} = 0;
        assignin('base','response',response);

        % Variables to select classifier model sequence
        assignin('base','sequence_mad', true);

        % Postprocessing variables

        for i=1:4
            buffer_compact{1,i}='noGesture';
        end

        assignin('base','buffer_compact', buffer_compact);
        assignin('base','emgCounterCompact', 1);

        TargetPrediction{1,1}='noGesture';
        assignin('base','TargetPrediction', TargetPrediction);
        TargetPredictionHorzcat{1,1}='';
        assignin('base','TargetPredictionHorzcat', TargetPredictionHorzcat);

        % =======================================================================

        testControl=true;
        assignin('base','testControl', testControl);

        while testControl==true

            emgDataTested           = OfflineDataExp1G(1,20,"off");
            emgFeatured             = getFeatures(emgDataTested);
            emgTarget               = getClassification(emgFeatured,"offline");
            emgTargetPostprocessed  = getTargetPostprocessed(emgTarget,"offline");

            controlExit       = evalin('base','controlExit');
            usuario           = evalin('base','usuario');
            emgRepetition     = evalin('base','emgRepetition');


            if controlExit==false && usuario~="NaN"

                TargetPrediction   = evalin('base', 'TargetPrediction');
                responseIndex      = evalin('base', 'responseIndex');
                [TargetPrediction_actual,TargetPrediction_fixed]=emgCompacted(emgTargetPostprocessed,4);
                TargetPrediction{1,responseIndex-1} = TargetPrediction_actual;
                assignin('base','TargetPrediction', TargetPrediction);
                emgCounterCompact  =  evalin('base', 'emgCounterCompact');
                check_compact      = emgCounterCompact-1;

                if check_compact==0
                    TargetPrediction_fixed_up  =  TargetPrediction_fixed;
                    TargetPredictionHorzcat    =  evalin('base', 'TargetPredictionHorzcat');
                    TargetPredictionHorzcat    = horzcat(TargetPredictionHorzcat,TargetPrediction_fixed_up);
                    assignin('base','TargetPredictionHorzcat', TargetPredictionHorzcat);
                end

            elseif controlExit==true && usuario~="NaN"
                TargetPrediction=evalin('base', 'TargetPrediction');
                usuario          =  evalin('base','usuario');
                response         =  evalin('base','response');

                resp=summaryClass(TargetPrediction);
                response.(usuario).classNew{emgRepetition-1,1}=resp;
                TargetPrediction{1,1}='noGesture';
                assignin('base','TargetPrediction', TargetPrediction);

                TargetPredictionHorzcat  =  evalin('base', 'TargetPredictionHorzcat');
                TargetPredictionHorzcat  =  TargetPredictionHorzcat(1,2:end);
                TargetPredictionUnion= emgCompactedTotal(TargetPredictionHorzcat,length (TargetPredictionHorzcat));

                resp2=summaryClass(TargetPredictionUnion)
                response.(usuario).classNew2{emgRepetition-1,1}=resp2;

                response.(usuario).vectorOfLabelsNew{emgRepetition-1,1}=TargetPredictionUnion;
                clear TargetPredictionHorzcat
                TargetPredictionHorzcat{1,1}='';
                assignin('base','TargetPredictionHorzcat', TargetPredictionHorzcat);
                assignin('base','response',response);
            end

            testControl   = evalin('base','testControl');
        end


        response        =  evalin('base','response');
        orientation     =  evalin('base','orientation');

        clearvars -except usersLowIndex response orientation start_at

        for i=1:size(orientation)*([1;0])
            if i == 1
                response                                          = rmfield(response,'NaN');
            end
            response.(char(orientation(i,1))).vectorOfLabels  = response.(char(orientation(i,1))).vectorOfLabelsNew;
            response.(char(orientation(i,1))).class           = response.(char(orientation(i,1))).classNew2;
            response.(char(orientation(i,1)))                 = rmfield(response.(char(orientation(i,1))),'vectorOfLabelsNew');
            response.(char(orientation(i,1)))                 = rmfield(response.(char(orientation(i,1))),'classNew');
            response.(char(orientation(i,1)))                 = rmfield(response.(char(orientation(i,1))),'classNew2');
        end

        assignin('base','response',response);
        fileName='responseExp1G.mat';
        save(fileName,'response');
        %zero_analysis = start_at-150;
        zero_analysis = 1;
        disp("start---at")
        disp(start_at)
        disp("finStart--at")
        
        WM_conversion_newFormat(fileName,zero_analysis)

        jsonName='responseExp1G.json';
        jsonFormat(fileName,jsonName);


        exitCheck=true;
        delete(pwd,'\','indicesTodosExp1G.mat')



        % ====================================
        % ======  TEST EXP 1 HAS DONE ========
        % ====================================
    end

else
    for i=1:length(fields(low_bajo))
        fprintf('User error due to training steps: %s \n',char(low_bajoPacket(i,1)));
    end
    assignin('base','usersLowIndex',low_bajo);
    beep
    pause(1)
    beep
    pause(1)
    fprintf('Please check those users...\n');
end
control=exitCheck;
end



