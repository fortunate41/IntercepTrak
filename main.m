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


%Selects simulated signal or In-lab data
%  FLAG = false;
%  while ~FLAG
%     prompt = 'Select and option: \n \n 1. Synthetic signal. \n 2. Recorded signal. \n \n Option: ';
%     Option = input(prompt);
%     if Option == 1 || Option == 2
%        FLAG = true;
%     end
%  end
 
Option = 1;  %! Synthetic signal, 2= inlab signal

 if Option==1 %Synthetic signal
     
    %Ensure That No Parallel Pool Is Running
    %delete(gcp('nocreate'))%deletes Parpool
%     if isempty(gcp)
%         myCluster = parcluster;
%         pool = parpool(myCluster);%generates a parpool with the maximum number of workers
%     end
     
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
    
    %% For loops beginning
    for nrand = 1:Total_Iterations
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
                        
                        %% Generate spectrogram and and save figures
                        Fct_generateImage(GNSS_plus_Jammer_awgn, ParamSim.Fs)
                        
                    end %end jam_type
                end %end JSR_dB
            end %end cnr
        end%end gnssband
        p = parfor_progress;
        showTimeToCompletion( p/100, [], [], startTime );
    end %end nrand
    
 elseif Option==2
  
     %% Initialize parameters
    ParamGNSS    = Fct_GNSS_parameters(Option);
    ParamJam     = Fct_Jammer_parameters(ParamGNSS);
    ParamSim     = Fct_Sim_parameters(ParamGNSS, Option);
    ParamChannel = Fct_Channel_parameters(ParamGNSS,ParamJam);

    %% Local variables from struct
    Total_Iterations             = ParamSim.Nrandompoints;
    Total_Iterations_Calibration = ParamSim.Nrandompoints_Calibration;
    JSR_dB_length                = ParamJam.JSR_dB_Length;
    JSR_dB_Vec                   = [ParamJam.JSR_dB_Vec];
    CNR_dBHz_length              = ParamGNSS.CNR_dBHz_Length;
    CNR_dBHz_Vec                 = [ParamGNSS.CNR_dBHz];
    Det_type_length              = ParamJam.Detectors_type_Length;
    Det_type_Vec                 = [ParamJam.Det_type_Vec];
    GNSS_Band_Length             = length(ParamGNSS.GNSS_Band);
    GNSS_Band_Vec                = ParamGNSS.GNSS_Band;
    ScenarioVec_length           = length(ParamGNSS.ScenarioVec);
    cenarioVec                   = [ParamGNSS.ScenarioVec];
    PdfBased_true                = ParamSim.PdfBasedMethod_true;
    CFAMethod_true               = ParamSim.CFAMethod_true;
    StatisticalMethod_true       = ParamSim.StatisticalMethod_true;
    Load_threhold_true           = ParamSim.Load_threhold_true;
    EstimatedCNR_true            = ParamSim.EstimatedCNR_true;
    PlotCheckfiles_true          = ParamSim.PlotCheckfiles_true;
    
    %% Initialize arrays for preallocating
    CN0_effH1              = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length, JSR_dB_length);
    TeststatH0             = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length, Det_type_length);
    TeststatH1             = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length, JSR_dB_length, Det_type_length);
    Pd_PDFBased            = zeros(GNSS_Band_Length, CNR_dBHz_length, JSR_dB_length, Det_type_length);
    thresh_gamma_PDFBased  = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length, JSR_dB_length, Det_type_length);
    DetectorSta_FlagH1     = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length, JSR_dB_length, Det_type_length);
    DetectorSta_FlagH0     = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length, Det_type_length);
    DetectorCFA_FlagH1     = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length, JSR_dB_length, Det_type_length);
    DetectorCFA_FlagH0     = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length, Det_type_length); EstimatedCNR_true==1
    CNR_estimateH0         = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length);
    CN0_spilker_estH0      = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length);
    CNR_estimateH1         = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length, JSR_dB_length);
    CN0_spilker_estH1      = NaN*ones(Total_Iterations, GNSS_Band_Length, CNR_dBHz_length, JSR_dB_length);
    
    %% To show % of simulatuion, remaining time, etc in Command Window and save % in an external file called "parfor_progress" 
    fprintf('\t Completion: ');
    showTimeToCompletion; startTime=tic;
    Itermax=Total_Iterations*ScenarioVec_length;
    p = parfor_progress( Itermax );
    
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
        
        for nrand = 1:Total_Iterations  
            %% Generate channel for N_max satellites and jammers
            Channel = Fct_Channel_Gen(ParamChannel, ParamGNSS, ParamJam, ParamSim, gnssband, Option);
            
            %% Read GNSS Signal from file
            GNSS_sign = Fct_ReadData(ParamSim, FileId_GNSS, gnssband);
            
            %% Add channel effect to GNSS signal and normalize
            [GNSS_sign_withch] = Fct_add_ch_to_inputsig(GNSS_sign, Channel.Alpha_chS2A, Channel.DelS2A, ParamChannel.Max_Doppler_S2A(gnssband), ParamSim.Nc);
            
            %% Read Jamming Signal from file
            Interf_sign = Fct_ReadData(ParamSim, FileId_Jammer, gnssband);
            
            %% Add channel effect to Jammer signal and normalize
            [Interf_sign_withch] = Fct_add_ch_to_inputsig(Interf_sign, Channel.Alpha_chS2A, Channel.DelS2A, ParamChannel.Max_Doppler_S2A(gnssband), ParamSim.Nc);
            
            for cnr = 1:CNR_dBHz_length
                %% Add AWGN noise to GNSS signal
                [GNSS_sign_withch_awgn, ~] = Fct_add_awgn(GNSS_sign_withch, ParamGNSS, ParamSim, CNR_dBHz_Vec(cnr), gnssband);
                
                %% Despread GNSS signal and compute CNR
                if EstimatedCNR_true==1
                    [CNR_estimateH0(nrand, gnssband, cnr), CN0_spilker_estH0(nrand, gnssband, cnr)] = Fct_Compute_CNR(GNSS_sign_withch_awgn, ParamSim, ParamChannel, ParamGNSS, gnssband, nrand, Option);
                    CNR_estimate = CNR_estimateH0(nrand, gnssband, cnr);
                else
                %% Estimated CNR is real CNR
                    CNR_estimate = CNR_dBHz_Vec(cnr);
                end

                %% H0 detectors simulation (Method1:PDF-based)
                if PdfBased_true==1
                    [~, ~, TeststatH0(nrand, gnssband, cnr, :)] = Fct_Detection(GNSS_sign_withch_awgn, ...
                    ParamSim, Det_type_Vec, CNR_estimate, cnr, CNR_dBHz_Vec, GNSS_Band_Vec(gnssband), 1);
                end
                %% H0 detectors simulation (Method2:CFA threholding)
                if CFAMethod_true==1 
                    [DetectorCFA_FlagH0(nrand, gnssband, cnr, :), ~, ~] = Fct_Detection(GNSS_sign_withch_awgn, ...
                    ParamSim, Det_type_Vec, CNR_estimate, cnr, CNR_dBHz_Vec, GNSS_Band_Vec(gnssband), 1);
                end
                
                 %% H0 detectors simulation (Method3:Statistical threholding)
                 if StatisticalMethod_true==1
                    [DetectorSta_FlagH0(nrand, gnssband, cnr, :), ~, ~] = Fct_Detection(GNSS_sign_withch_awgn, ...
                    ParamSim, Det_type_Vec, CNR_estimate, cnr, CNR_dBHz_Vec, GNSS_Band_Vec(gnssband), 0);
                 end
             
                for jJSR = 1:JSR_dB_length%Signal to Interference ratio
                    %% Apply JSR to Jammer signal
                    jam_ampl = sqrt(10.^(JSR_dB_Vec(jJSR)/10));
                    Interf_sign_withch_JSR = jam_ampl*Interf_sign_withch;
                    
                    %% Add jammer and GNSS signals
                    GNSS_plus_Jammer_withch = Interf_sign_withch_JSR + GNSS_sign_withch;
                    
                    %% Add AWGN noise to jammer+GNSS signal
                    [GNSS_plus_Jammer_withch_awgn, ~] = Fct_add_awgn(GNSS_plus_Jammer_withch, ParamGNSS, ParamSim, CNR_dBHz_Vec(cnr), gnssband);
                    
                    %% COMPUTE EFFECTIVE CN0 (H1 hypothesis)
                    CN0_effH1(nrand, gnssband, cnr, jJSR) = Fct_EffCNR(GNSS_sign_withch, Interf_sign_withch_JSR, JSR_dB_Vec(jJSR), CNR_dBHz_Vec(cnr));

                    %% Despread GNSS signal and compute CNR (H1 hypothesis)
                    if EstimatedCNR_true==1 
                        [CNR_estimateH1(nrand, gnssband, cnr, jJSR), CN0_spilker_estH1(nrand, gnssband, cnr, jJSR)] = Fct_Compute_CNR(GNSS_plus_Jammer_withch_awgn,...
                        ParamSim, ParamChannel, ParamGNSS, gnssband, nrand, Option);
                        CNR_estimate = CNR_estimateH1(nrand, gnssband, cnr, jJSR);%It can be changed by spilker
                    end
                    
                    %% H1 detectors simulation (Method1:PDF-based)
                    if PdfBased_true==1
                        [~, ~, TeststatH1(nrand, gnssband, cnr, jJSR, :)] = Fct_Detection(GNSS_plus_Jammer_withch_awgn, ...
                        ParamSim, Det_type_Vec, CNR_estimate, cnr, CNR_dBHz_Vec, GNSS_Band_Vec(gnssband), 0);
                    end

                    %% H1 detectors simulation (Method2:CFA threholding)
                    if CFAMethod_true==1 || StatisticalMethod_true==1
                        [DetectorCFA_FlagH1(nrand, gnssband, cnr, jJSR, :), ~, ~] = Fct_Detection(GNSS_plus_Jammer_withch_awgn, ...
                        ParamSim, Det_type_Vec, CNR_estimate, cnr, CNR_dBHz_Vec, GNSS_Band_Vec(gnssband), 1);
                    end

                    %% H1 detectors simulation (Method3:Statistical threholding)
                    if PdfBased_true==1
                        [DetectorSta_FlagH1(nrand, gnssband, cnr, jJSR, :), ~, ~] = Fct_Detection(GNSS_plus_Jammer_withch_awgn, ...
                        ParamSim, Det_type_Vec, CNR_estimate, cnr, CNR_dBHz_Vec, GNSS_Band_Vec(gnssband), 0);
                    end
                
                end% end cnr
            end% end JSR_dB
            %        progressbar(nrand/Total_Iterations) % Update figure ;
            p = parfor_progress;
            showTimeToCompletion( p/100, [], [], startTime );
        end% end nrand
    end
    
    %% Compute Pd and Pfa for both approaches 
    %PDF-based
    fixedPfa=1e-3;
    if PdfBased_true ==1
        for gnssband=1:ScenarioVec_length
            for cnr = 1:CNR_dBHz_length
                for jJSR = 1:JSR_dB_length%Signal to Interference ratio
                    for det_type = 1:Det_type_length
                        [ thresh_gamma_PDFBased(gnssband,cnr,jJSR,det_type), Pd_PDFBased(gnssband,cnr,jJSR,det_type), ~, ~, ~, ~ ] = ...
                            Fct_find_thresh_at_fixPfa_sim_pdfH0H1_interpPDForCDF( TeststatH1(:,gnssband,cnr,jJSR,det_type), ...
                            TeststatH0(:,gnssband,cnr,det_type),fixedPfa, 0);
                    end
                end
            end
        end
    end

    %CFA and statistical thrsholding Pd and Pfa                
    NumberOfDetections = sum(DetectorCFA_FlagH1==1);%sum how many falgs=1 we have for all the simulations under H1
    NumberOfFalseAlarms  = sum(DetectorCFA_FlagH0==1);%sum how many falgs=1 we have for all the simulations under H0
    Pd_CFA  = NumberOfDetections./Total_Iterations;%divides by total number of iterations
    Pfa_CFA = NumberOfFalseAlarms./Total_Iterations;
    Pmd_CFA = 1-Pd_CFA;
    
    NumberOfDetections = sum(DetectorSta_FlagH1==1);%sum how many falgs=1 we have for all the simulations under H1
    NumberOfFalseAlarms  = sum(DetectorSta_FlagH0==1);%sum how many falgs=1 we have for all the simulations under H0
    Pd_Sta  = NumberOfDetections./Total_Iterations;%divides by total number of iterations
    Pfa_Sta = NumberOfFalseAlarms./Total_Iterations;
    Pmd_Sta = 1-Pd_Sta;
    
    save('SimulationResults_InLabdB')
    
    %% Plotting
    Fct_plotting_results_Inlab(ParamJam, ParamSim, ParamGNSS, Pd_CFA, Pfa_CFA, Pd_Sta, Pfa_Sta, Pd_PDFBased, CNR_estimateH0, CN0_spilker_estH0, CNR_estimateH1, CN0_spilker_estH1, CN0_effH1, TeststatH0, TeststatH1)

 end