function [Interf_sign_withch] = Fct_jammer_withch(ParamJam, ParamSim, ParamChannel, Channel, jam_param, jJSR, jam_type, gnssband)

%% Variables allocation    
TotalSamples       = ParamSim.TotalSamples(gnssband);
JSR_dB             = ParamJam.JSR_dB_Vec(jJSR);
fs                 = ParamSim.Fs;
alpha_chG2A        = Channel.Alpha_chG2A;
delG2A             = Channel.DelG2A;
% SJR_dB         = -1*JSR_dB;
% SJR_dB_samples = SJR_dB; 

%Generate different types of jammers with its own fading channel to add later to the GNSS signal

%step 1: generate jammer without fading channel; SJR_dB is computed based on
%rx_fading energy
switch jam_type
    case 1 % no jamming
        Interf_sign = zeros(1, TotalSamples);
    case {2, 11} %single (2) or multiple-tone AM (11)
        %jam_param{1} is the vector of jamming freq
        %jam_param{2} is the vector of jamming amplitues in linear
        %scale with respect to the first one; the first one is
        %always 1
        jam_param{2} = jam_param{2}./jam_param{2}(1);
        cwi_freq     = jam_param{1};
        cwi_ampl     = jam_param{2};% vector of the ampl of the CWIs
        tax1         = [0 : 1: TotalSamples-1]/ fs; %time axis in seconds
        Interf_sign  = zeros(1, TotalSamples);
        for i=1:length(cwi_ampl)
            Interf_sign = Interf_sign+cwi_ampl(i) .* exp(1j*2*pi*cwi_freq(i)*tax1);
        end
        
    case 3 %Single chirp jammer
        cwi_ampl = 1;%
        SweepRange_Hz = jam_param{1};
        SweepPeriod_s = jam_param{2};
        upchirp_true  = jam_param{3};
        phi0          = jam_param{4};
        f_IF_Hz       = jam_param{5};
        Time_window_s = TotalSamples/fs;  
        [chirp_wave]  = Fct_generatechirp_jammer( fs, SweepRange_Hz, SweepPeriod_s, upchirp_true, Time_window_s, phi0, f_IF_Hz);
        Interf_sign   = cwi_ampl* chirp_wave(1:TotalSamples);
       

 case {5,12}  %single (4) or multi-tone FM jammer (11)
        jam_param{2} = jam_param{2}./jam_param{2}(1);
        cwi_freq     = jam_param{1};
        cwi_ampl     = jam_param{2};% vector of the ampl of the CWIs
        beta_jam     = jam_param{3};
        tax1         = [0 : 1: TotalSamples-1]/ fs; %time axis in seconds
        Interf_sign  = zeros(1, TotalSamples);
        for i = 1:length(cwi_ampl)
            Interf_sign = Interf_sign+cwi_ampl(i) .* exp(1j*(2*pi*cwi_freq(i)*tax1+beta_jam(i)*sin(2*pi*cwi_freq(i)*tax1)));
        end
          
  case 6 %dual chirp signal
       cwi_ampl         = 1;%
       SweepRange_Hz    = jam_param{1};
       SweepPeriod_s    = jam_param{2};
       phi0             = jam_param{4};
       f_IF_Hz          = jam_param{5};
       Time_window_s    = TotalSamples/fs;  
       [dualchirp_wave] = Fct_generate_dualchirp_jammer( fs, SweepRange_Hz, SweepPeriod_s, Time_window_s, phi0, f_IF_Hz);
       Interf_sign      = cwi_ampl * dualchirp_wave(1:TotalSamples);
       
     case 7  %generic multi-chirp

        SweepRange_Hz = jam_param{1};
        SweepPeriod_s = jam_param{2};
        upchirp_true  = jam_param{3};
        phi0          = jam_param{4};
        f_IF_Hz       = jam_param{5};
        %6th jam_param is cwi_ampl
        jam_param{6} = jam_param{6}./jam_param{6}(1);

        cwi_ampl      = jam_param{6};% vector of the ampl of the CWIs
        Time_window_s = TotalSamples/fs;  
        Interf_sign   = zeros(1, TotalSamples);
        for i=1:length(cwi_ampl)
            [chirp_wave] = Fct_generatechirp_jammer( fs, SweepRange_Hz(i), SweepPeriod_s(i), upchirp_true(i), Time_window_s, phi0(i),f_IF_Hz(i));
            Interf_sign  = Interf_sign+cwi_ampl(i) .* chirp_wave(1:TotalSamples);
        end
    case 8 %another chirp jammer (Borio), like in https://www.researchgate.net/profile/Ciro_Gioia/publication/308968144_From_Agnostic_to_Model-Based_GNSS_Jamming_Detection/links/57fb674a08ae91deaa684f74/From-Agnostic-to-Model-Based-GNSS-Jamming-Detection.pdf
        cwi_ampl      = 1;%
        SweepRange_Hz = jam_param{1};
        SweepPeriod_s = jam_param{2};
        upchirp_true  = jam_param{3};
        phi0          = jam_param{4};
        f_IF_Hz       = jam_param{5};
        Time_window_s = TotalSamples/fs;  
        [chirp_wave]  = Fct_generatechirp_jammer( fs, SweepRange_Hz, SweepPeriod_s, upchirp_true, Time_window_s, phi0, f_IF_Hz);
        Interf_sign   = cwi_ampl* chirp_wave(1:TotalSamples);
        
    case 9 %DME jammer
        alfa        = jam_param{1};
        dt          = jam_param{2} ;
        tax1        = [0 : 1: TotalSamples-1]/ fs; %time axis in seconds
        Interf_sign = exp(-alfa*0.5*(tax1-dt*0.5).^2) + exp(-alfa*0.5*(tax1-3*dt*0.5).^2);
        Interf_sign = Interf_sign/mean(abs(Interf_sign).^2) ;
    case {10}  %narrowband jammer 1kHz (9) and 1 MHz
        BW_NB_Hz    = jam_param{1};
        Interf_sign = Fct_generate_NB_jammer(fs, TotalSamples, BW_NB_Hz) ;    
end

if jam_type == 1
    Interf_sign_withch = Interf_sign; %No jammer
else
    %Add channel to jammer signal and normalizes
    [Interf_sign_withch] = Fct_add_ch_to_inputsig(Interf_sign, alpha_chG2A, delG2A, ParamChannel.Max_Doppler_G2A(gnssband), ParamSim.Nc);
    %applying specific JSR to increase the power of the jammer signal
    jam_ampl  = sqrt(10.^(JSR_dB/10));
    Interf_sign_withch = jam_ampl*Interf_sign_withch;

end        