clear all; close all; 
addpath(genpath('Channel'))
addpath(genpath('Classifier'))
addpath(genpath('GNSS_signals'))
addpath(genpath('Init'))
addpath(genpath('Jammer_signals'))
addpath(genpath('Misc'))
addpath(genpath('Plotting'))
addpath(genpath('Progress_Bar'))
addpath(genpath('Recorded_data'))
addpath(genpath('Sim'))
addpath(genpath('Test_statistic'))

%test only for the Synthetic signal, i.e., Option=1
Option=1;
training_true=input('0 for test data and 1 for training data: ')
datasetpathTrain='\\intra.tut.fi\home\moralesf\My Documents\GATEMAN\Matlab Code\Jamming_Classifier';
datasetpathTest='\\intra.tut.fi\home\moralesf\My Documents\GATEMAN\Matlab Code\Jamming_Classifier';
 
 
%% Initialize parameters
ParamGNSS    = Fct_GNSS_parameters(Option);
ParamJam     = Fct_Jammer_parameters(ParamGNSS);
ParamSim     = Fct_Sim_parameters(ParamGNSS, Option);
ParamChannel = Fct_Channel_parameters(ParamGNSS,ParamJam);

%% Local variables allocation from struct
Total_Iterations             = ParamSim.Nrandompoints;
Total_Iterations_Calibration = ParamSim.Nrandompoints_Calibration;
JSR_dB_length                = ParamJam.JSR_dB_Length;
JSR_dB_Vec                   = [ParamJam.JSR_dB_Vec];
JammerType_length            = ParamJam.Jammers_Length;
JammerType_Vec               = [ParamJam.Jam_type_Vec];
CNR_dBHz_length              = ParamGNSS.CNR_dBHz_Length;
CNR_dBHz_Vec                 = [ParamGNSS.CNR_dBHz];
Det_type_length              = ParamJam.Detectors_type_Length;
Det_type_Vec                 = [ParamJam.Det_type_Vec];
GNSS_Band_Length             = length(ParamGNSS.GNSS_Band);
GNSS_Band_Vec                = ParamGNSS.GNSS_Band;
PdfBased_true                = ParamSim.PdfBasedMethod_true;
CFAMethod_true               = ParamSim.CFAMethod_true;
StatisticalMethod_true       = ParamSim.StatisticalMethod_true;
Load_threhold_true           = ParamSim.Load_threhold_true;
EstimatedCNR_true            = ParamSim.EstimatedCNR_true;


%% To show % of simulatuion, remaining time, etc in Command Window and save % in an external file called "parfor_progress" 
fprintf('\t Completion: ');
showTimeToCompletion; startTime=tic;
p = parfor_progress( Total_Iterations );


kk=1;
store_image=cell(Total_Iterations*GNSS_Band_Length*CNR_dBHz_length*JSR_dB_length*JammerType_length, 4);
%% For loops beginning
for nrand = 1:Total_Iterations
JSR_dB_Vec   = rand(1,1)*40+40;
    CNR_dBHz_Vec  =rand(1,1)*25+25;

    for gnssband=1:GNSS_Band_Length
        %% Generate channel for N_max satellites and jammers
        Channel = Fct_Channel_Gen(ParamChannel, ParamGNSS, ParamJam, ParamSim, gnssband, Option);

        %% Generate GNSS signal for SV_length satellites
        [I, Q] = GNSSsignalgen(ParamGNSS.SV_Number, ParamGNSS.GNSS_Band{gnssband}, ParamSim.Fs, ParamSim.Nc);
        GNSS_sign = (I+1j*Q).';

        %% Apply channel to GNSS signal and normalize
        GNSS_sign_withch = Fct_add_ch_to_inputsig(GNSS_sign, Channel.Alpha_chS2A, Channel.DelS2A, ParamChannel.Max_Doppler_S2A(gnssband), ParamSim.Nc);

        for cnr = 1:CNR_dBHz_length
            %% Add AWGN to normalize GNSS signal
            [GNSS_sign_withch_awgn, ~] = Fct_add_awgn(GNSS_sign_withch, ParamGNSS, ParamSim, CNR_dBHz_Vec(cnr), gnssband);

            %% Jammer signals simulation
            for jJSR = 1:JSR_dB_length%Signal to Interference ratio
                for jam_type = 1:JammerType_length%Selects type of jammer
                    %% Generate normalized jammer signal and adds channel
                    [Interf_sign_withch] = Fct_Jammer_gen(ParamJam, ParamChannel, ParamSim, Channel, jJSR, JammerType_Vec(jam_type), gnssband);

                    %% Adds GNSS signal plus jammer
                    GNSS_plus_Jammer_nonoise = GNSS_sign_withch + Interf_sign_withch;

                    %% Add AWGN to GNSS plus jammer signal
                    [GNSS_plus_Jammer_awgn, ~] = Fct_add_awgn(GNSS_plus_Jammer_nonoise, ParamGNSS, ParamSim, CNR_dBHz_Vec(cnr), gnssband);

                    %% Classifier
                    %waveletAnalysis(real(GNSS_plus_Jammer_awgn), ParamSim.Fs)

                    %% Generate spectrogram and save figures
%method=1-->Spectrogram
%method=3-->WVD
%method=3-->FSST
method=1;
                     [SY, FY, TY ]=Fct_generateImage(GNSS_plus_Jammer_awgn, ParamSim.Fs,method);
                     
                imagesc( TY * 1e6, FY / 1e6, real( SY .*conj(SY) ) )
                set(gca, 'YDir', 'Normal')

                [xax,yax]=meshgrid(TY, FY);

                    store_image{1}=real( SY .*conj(SY) );
                    store_image{2}=JammerType_Vec(jam_type);
                    store_image{3}=xax;
                    store_image{4}=yax;
                    
                    %imwrite(uint16(store_image{kk,1}), jet, ['Image_training_database/Training_image_',num2str(kk),'.jpg'], 'jpg');
                    imagesc(FY,TY, store_image{1});
                    set(gca, 'Visible', 'off')
                    output_size = [512 512];%Size in pixels [width height]
                    resolution = 600;%Resolution in DPI
                    set(gcf,'paperunits','inches','paperposition',[0 0 output_size/resolution]);
                    % use 600 DPI

                    if training_true==1
                        switch JammerType_Vec(jam_type)
                            case 1  %nojam
                                print(['Image_training_database/NoJam/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                            case 2  %singleAM
                                print(['Image_training_database/SingleAM/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                            case 3   %singlechirp
                                print(['Image_training_database/SingleChirp/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                            case 5   %singleFM
                                print(['Image_training_database/SingleFM/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                            case 9  %DME
                                print(['Image_training_database/DME/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                            case 10  %NB
                                print(['Image_training_database/NB/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                        end
                    else
                        switch JammerType_Vec(jam_type)
                            case 1  %nojam
                                print(['Image_testing_database/NoJam/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                            case 2  %singleAM
                                print(['Image_testing_database/SingleAM/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                            case 3   %singlechirp
                                print(['Image_testing_database/SingleChirp/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                            case 5   %singleFM
                                print(['Image_testing_database/SingleFM/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                            case 9  %DME
                                print(['Image_testing_database/DME/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                            case 10  %NB
                                print(['Image_testing_database/NB/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono', ['-r' num2str(resolution)]);
                        end
                        % print(['Image_testing_database/Training_image_',num2str(kk),'.bmp'],  '-dbmpmono',['-r' num2str(resolution)]);
                    end
                    kk=kk+1;
                end %end jam_type
            end %end JSR_dB
        end %end cnr
    end%end gnssband
    p = parfor_progress;
    showTimeToCompletion( p/100, [], [], startTime );
end %end nrand
   
% for kk=1:10
%  
%     figure; contourf(store_image{kk,3},store_image{kk,4}, store_image{kk,1});
%     title(['Jammer type=', num2str(store_image{kk,2})])
% end
if training_true
    return
end



imdsTrain = imageDatastore(datasetpathTrain, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

imdsTest = imageDatastore(datasetpathTest, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

%Split train dataset in order to take less images to speed-up
ReadSizeTrain = 2000;
[imdsTrain, imds_extra] = splitEachLabel(imdsTrain,ReadSizeTrain);

%-Using SURF
bag = bagOfFeatures(imdsTrain, 'StrongestFeatures', 0.7, 'GridStep', [64 64], 'BlockWidth', [64 96],'UseParallel', true);

opts = templateSVM('BoxConstraint',4,'KernelFunction','gaussian', 'KernelScale', 'auto', 'Standardize',1,'Solver', 'L1QP');
%Evaluate classifier with training data, to obtain "perfect results" and
%check that everything is OK
categoryClassifier = trainImageCategoryClassifier(imdsTrain, bag, 'LearnerOptions', opts, 'UseParallel', true);
confMatrixTrain = evaluate(categoryClassifier, imdsTrain);

%Now evaluate it with the test data
categoryClassifier = trainImageCategoryClassifier(imdsTrain,bag, 'LearnerOptions', opts, 'UseParallel', true);
%confusion matrix
[confMat,knownLabelIdx,predictedLabelIdx,score] = evaluate(categoryClassifier,imdsTest);

confMat2 = confusionmat(knownLabelIdx,predictedLabelIdx);

plotConfMat(confMat2)


%% Deep Learning

labelCountTrain = countEachLabel(imdsTrain);
labelCountTest = countEachLabel(imdsTest);

%Check size images
img = readimage(imdsTrain,1);
imdsTrainSize = size(img);

layers = [
    imageInputLayer([imdsTrainSize 1])
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(6)
    softmaxLayer
    classificationLayer];


options = trainingOptions('adam', ...
    'InitialLearnRate',0.0001,...
    'MaxEpochs',20, ...
    'MiniBatchSize',64,...
    'SquaredGradientDecayFactor',0.99, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsTest, ...
    'ValidationFrequency',20, ...
    'Verbose',false, ...
    'Plots','training-progress', 'ExecutionEnvironment', 'parallel');

net = trainNetwork(imdsTrain,layers,options);

YPred = classify(net,imdsTest);
YValidation = imdsTest.Labels;

confMatDL = confusionmat(YValidation,YPred);

plotConfMat(confMatDL)

accuracy = sum(YPred == YValidation)/numel(YValidation)

% Nclasses=10;
% numHiddenUnits=3;
% Depth=4;
% 
% %lgraph = segnetLayers(size(image_for_im_size),Nclasses,Depth)
% 
% %sgdm =stochastic gradient descent with momentum.
% options = trainingOptions('sgdm', ...
%     'InitialLearnRate',0.01, ...
%     'MaxEpochs',4, ...
%     'Shuffle','every-epoch', ...
%     'ValidationFrequency',30, ...
%     'Verbose',false, ...
%     'Plots','training-progress');
% %net = trainNetwork(imdsTrain,lgraph,options);
% 
%    layers = [...
%     imageInputLayer([1080 1920 6])
%     convolution2dLayer(5,16,'Stride',4)
%     reluLayer
%     maxPooling2dLayer(2,'Stride',4)
%     fullyConnectedLayer(1)
%     softmaxLayer
%     classificationLayer
%     ];
% 
% net = trainNetwork(imdsTrain,layers,options);
% 
% YTest = classify(net,imdsTest);