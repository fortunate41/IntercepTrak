function [Threshold, fixed_Pfa] =Fct_calibrateThreshold(ParamSim, ParamGNSS, ParamJam, ParamChannel, Option)


if Option==1
    
    %% Local variables allocation from struct
    Total_Iterations_Calibration = ParamSim.Nrandompoints_Calibration;
    CNR_dBHz_length              = ParamGNSS.CNR_dBHz_Length;
    CNR_dBHz_Vec                 = [ParamGNSS.CNR_dBHz];
    Det_type_length              = ParamJam.Detectors_type_Length;
    Det_type_Vec                 = [ParamJam.Det_type_Vec];
    GNSS_Band_Length             = length(ParamGNSS.GNSS_Band);
    
    %% Initialize arrays for preallocating results
    TeststatH0_Calibration = NaN*ones(Total_Iterations_Calibration, GNSS_Band_Length, CNR_dBHz_length, Det_type_length);
    Threshold = NaN*ones(GNSS_Band_Length, CNR_dBHz_length, Det_type_length);
    
    %% Calibration stage to determine the threshold based on fixed Pfa (PDf under H0)
    fprintf('\t Completion of Calibration: ');
    showTimeToCompletion; startTime=tic;
    p = parfor_progress( Total_Iterations_Calibration );
    parfor nrand = 1:Total_Iterations_Calibration
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
                
                %% H0 detectors simulation
                TeststatH0_Calibration(nrand, gnssband, cnr, :) = Fct_DetectionCalibration(GNSS_sign_withch_awgn, ParamSim, Det_type_Vec);
                
            end
        end
        p = parfor_progress;
        showTimeToCompletion( p/100, [], [], startTime );
    end
   
else
    %% Local variables allocation from struct
    Total_Iterations_Calibration = ParamSim.Nrandompoints_Calibration;
    CNR_dBHz_length              = ParamGNSS.CNR_dBHz_Length;
    CNR_dBHz_Vec                 = [ParamGNSS.CNR_dBHz];
    Det_type_length              = ParamJam.Detectors_type_Length;
    Det_type_Vec                 = [ParamJam.Det_type_Vec];
    GNSS_Band_Length             = length(ParamGNSS.GNSS_Band);
    ScenarioVec_length  = ParamGNSS.ScenarioVec_Length;
    PlotCheckfiles_true = 0;
    
    %% Initialize arrays for preallocating results
    TeststatH0_Calibration = NaN*ones(Total_Iterations_Calibration, GNSS_Band_Length, CNR_dBHz_length, Det_type_length);
    Threshold = NaN*ones(GNSS_Band_Length, CNR_dBHz_length, Det_type_length);
    
    for gnssband=1:ScenarioVec_length
        
        FileNameJammer = ParamSim.FileNameJammer{gnssband};
        FileNameGNSS   = ParamSim.FileNameGNSS{gnssband};
        PathName       = ParamSim.PathName{gnssband};
        
        %% Check the binary file and the signal (plotting PSD and spectrogram)
        fct_checkfiles_and_signal(ParamSim, FileNameGNSS, FileNameJammer, PathName, gnssband, PlotCheckfiles_true) 
        
        %% Open files
        FileId_GNSS   = fopen([PathName FileNameGNSS], 'r');
        if FileId_GNSS <= 0
            error(['File ' FileNameGNSS ' not found']);
        end
        FileId_Jammer = fopen([PathName FileNameJammer], 'r');
        if FileId_Jammer <= 0
            error(['File ' FileNameJammer ' not found']);
        end
        
        %move the reading starting point according to the number of discarded samples
        fseek( FileId_GNSS, ParamSim.SamplesToDiscard, 'bof');
        fseek( FileId_Jammer, ParamSim.SamplesToDiscard, 'bof');
        
        fprintf('\t Completion of Calibration: ');
        showTimeToCompletion; startTime=tic;
        iterTot = Total_Iterations_Calibration*ScenarioVec_length;
        p = parfor_progress( Total_Iterations_Calibration );
        
        for nrand = 1:Total_Iterations_Calibration
            %% Generate channel for N_max satellites and jammers
            Channel = Fct_Channel_Gen(ParamChannel, ParamGNSS, ParamJam, ParamSim, gnssband, Option);
            
            %% Read GNSS Signal from file
            GNSS_sign = Fct_ReadData(ParamSim, FileId_GNSS, gnssband);
            
            %% Add channel effect to GNSS signal and normalize
            [GNSS_sign_withch] = Fct_add_ch_to_inputsig(GNSS_sign, Channel.Alpha_chS2A, Channel.DelS2A, ParamChannel.Max_Doppler_S2A(gnssband), ParamSim.Nc);
            for cnr = 1:CNR_dBHz_length
                %% Add AWGN noise to GNSS signal
                [GNSS_sign_withch_awgn, ~] = Fct_add_awgn(GNSS_sign_withch, ParamGNSS, ParamSim, CNR_dBHz_Vec(cnr), gnssband);
                
                %% H0 detectors simulation
                TeststatH0_Calibration(nrand, gnssband, cnr, :) = Fct_DetectionCalibration(GNSS_sign_withch_awgn, ParamSim, Det_type_Vec);
            end
                p = parfor_progress;
                showTimeToCompletion( p/100, [], [], startTime );
        end
    end  
end

% Compute Threshold based on fixed Pfa
fixed_Pfa=1e-3;
for gnssband=1:GNSS_Band_Length
    for cnr = 1:CNR_dBHz_length
        for det_type = 1:Det_type_length
            Threshold(gnssband,cnr,det_type) =  Fct_find_thresh_at_fixPfa( TeststatH0_Calibration(:,gnssband,cnr,det_type), fixed_Pfa, 0);
        end
    end
end
