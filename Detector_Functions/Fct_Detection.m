function [Flag, Threshold, Teststat] = Fct_Detection(rx_signal, ParamSim, Det_type_Vec, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true)

%% Local variables
Ns        = ParamSim.Ns;
Fs        = ParamSim.Fs;
agc_filter = comm.AGC('MaxPowerGain', 40);%AGC filter used in AGC detector

if all(ismember(Det_type_Vec,1))
    
    Teststat(1)  = Fct_TPD_TestStat(rx_signal, Fs, Ns);
    Threshold(1) = Fct_SetThreshold(1, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(1)      = Fct_Detector(Teststat(1), Threshold(1));
    
elseif all(ismember(Det_type_Vec,2))
    
    Teststat(1) = Fct_FPD_TestStat(rx_signal);
    Threshold(1) = Fct_SetThreshold(2, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(1)      = Fct_Detector(Teststat(1), Threshold(1));
    
elseif all(ismember(Det_type_Vec,3))
    
    Teststat(1) = Fct_AGC_Teststat(rx_signal, agc_filter);
    Threshold(1) = Fct_SetThreshold(3, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(1)      = Fct_Detector(Teststat(1), Threshold(1));
            
elseif all(ismember(Det_type_Vec,[1 2]))
    
    Teststat(1) = Fct_TPD_TestStat(rx_signal, Fs, Ns);
    Threshold(1) = Fct_SetThreshold(1, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(1)      = Fct_Detector(Teststat(1), Threshold(1));
    
    Teststat(2) = Fct_FPD_TestStat(rx_signal);
    Threshold(2) = Fct_SetThreshold(2, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(2)      = Fct_Detector(Teststat(1), Threshold(1));
    
elseif all(ismember(Det_type_Vec,[1 3]))
    
    Teststat(1) = Fct_TPD_TestStat(rx_signal, Fs, Ns);
    Threshold(1) = Fct_SetThreshold(1, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(1)      = Fct_Detector(Teststat(1), Threshold(1));
    
    Teststat(2) = Fct_AGC_TestStat(rx_signal, agc_filter);
    Threshold(2) = Fct_SetThreshold(3, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(2)      = Fct_Detector(Teststat(1), Threshold(1));
    
elseif all(ismember(Det_type_Vec,[2 3]))
    
    Teststat(1) = Fct_FPD_TestStat(rx_signal);
    Threshold(1) = Fct_SetThreshold(2, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(1)      = Fct_Detector(Teststat(1), Threshold(1));
    
    Teststat(2) = Fct_AGC_TestStat(rx_signal, agc_filter);
    Threshold(2) = Fct_SetThreshold(3, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(2)      = Fct_Detector(Teststat(1), Threshold(1));
    
elseif all(ismember(Det_type_Vec,[1 2 3]))
    
    Teststat(1) = Fct_TPD_TestStat(rx_signal, Fs, Ns);
    Threshold(1) = Fct_SetThreshold(1, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(1)      = Fct_Detector(Teststat(1), Threshold(1));
    
    Teststat(2) = Fct_FPD_TestStat(rx_signal);
    Threshold(2) = Fct_SetThreshold(2, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(2)      = Fct_Detector(Teststat(1), Threshold(1));
    
    Teststat(3) = Fct_AGC_TestStat(rx_signal, agc_filter);
    Threshold(3) = Fct_SetThreshold(3, CNR, cnr, CNR_dBHz_Vec, gnssband, LoadThreshold_true);
    Flag(3)      = Fct_Detector(Teststat(1), Threshold(1));
    
end