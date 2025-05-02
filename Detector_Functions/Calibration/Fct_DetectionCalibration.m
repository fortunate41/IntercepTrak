function Teststat = Fct_DetectionCalibration(rx_signal, ParamSim, Det_type_Vec)

%% Local variables
Ns        = ParamSim.Ns;
Fs        = ParamSim.Fs;
agc_filter = comm.AGC('MaxPowerGain', 40);%AGC filter used in AGC detector

if all(ismember(Det_type_Vec,1))
    
    Teststat = Fct_TimePower_DetectorCalibration(rx_signal, Fs, Ns);
    
elseif all(ismember(Det_type_Vec,2))
    
    Teststat = Fct_FreqPower_DetectorCalibration(rx_signal);
    
elseif all(ismember(Det_type_Vec,3))
    
    Teststat = Fct_AGC_DetectorCalibration(rx_signal, agc_filter);
            
elseif all(ismember(Det_type_Vec,[1 2]))
    
    Teststat(1) = Fct_TimePower_DetectorCalibration(rx_signal, Fs, Ns);
    Teststat(2) = Fct_FreqPower_DetectorCalibration(rx_signal);
    
elseif all(ismember(Det_type_Vec,[1 3]))
    
    Teststat(1) = Fct_TimePower_DetectorCalibration(rx_signal, Fs, Ns);
    Teststat(2) = Fct_AGC_DetectorCalibration(rx_signal, agc_filter);
    
elseif all(ismember(Det_type_Vec,[2 3]))
    
    Teststat(1) = Fct_FreqPower_DetectorCalibration(rx_signal);
    Teststat(2) = Fct_FreqPower_DetectorCalibration(rx_signal);
    
elseif all(ismember(Det_type_Vec,[1 2 3]))
    
    Teststat(1) = Fct_TimePower_DetectorCalibration(rx_signal, Fs, Ns);
    Teststat(2) = Fct_FreqPower_DetectorCalibration(rx_signal);
    Teststat(3) = Fct_AGC_DetectorCalibration(rx_signal, agc_filter);
    
end