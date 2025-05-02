function ParamJam = Fct_Jammer_parameters(ParamGNSS)

%random JSR between 40 and 80 dB
ParamJam.JSR_dB_Vec    = rand(1,1)*40+40;%[-15 -10 -7 -5 -3 0 3 5 7 10 15 20];%Jammer to Signal ratios considered during the simulations
ParamJam.JSR_dB_Length = [length(ParamJam.JSR_dB_Vec)];
ParamJam.Jam_type_Vec  = [1 2 3 5 9 10];%Jammers Types considered: 
                                 %[1= no jammer, 2= AM jammer, 3= 10MHz chirp
                                 %jammer, 3= 20MHz chirp jammer,
                                 %5= FM jammer, 6= double chirp; 
                                 %7= multichirp (it requires a very high Ns)
                                 %8= another single chirp , see Borio paper "From Agnostic to Model-Based GNSS Jamming Detection"
                                 %9= DME-like jammer, 10= NB jammer 1kHz, 11= Double AM
                                 %12= Double FM, 13= NB jammer 1MHz
ParamJam.Jammers_Length   = length([ParamJam.Jam_type_Vec]);
ParamJam.Det_type_Vec     = [1 2 3];%Detectors used 1=TPD, 2=FPD, 3=AGC
ParamJam.Detectors_type_Length = length(ParamJam.Det_type_Vec);
ParamJam.Jammers_ON = 1;%Number of jammers ON at the same timne
for gnssband=1:length(ParamGNSS.GNSS_Band)
    ParamJam.JammerCarrierFreq_Hz(gnssband) = ParamGNSS.CarrierFrequencyGNSS_Hz(gnssband);%same carrier frequency in each band;
end