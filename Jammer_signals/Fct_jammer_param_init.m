function jam_param=Fct_jammer_param_init(jam_type, Jam_type_Vec, Max_Doppler_jammer, gnssband)  
%create jammer with predefined parameters
switch jam_type
        case 1
            jam_param{1}=NaN;  % no jamming
        case 2  %AM jammer
            %vector of jamming frequencies, given in Hz 
            jam_param{1}=[1.023] *1e6;
            %vector of jamming amplitudes (linear scale)
            jam_param{2}=[1];
            if length(jam_param{1})~=length(jam_param{2})
                error ('The jam_param cells should have equal length')
            end

        case 3  %single chirp 10 MHz
           %SweepRange_Hz;
           jam_param{1}= 5.6*1e6;  %BW
           %Sweepperiod_s
           jam_param{2}= 5*1e-6;
           %upchirp_true
           jam_param{3}=1;
           %phi0
           jam_param{4}=0;
           %f_IF_Hz
           jam_param{5}=Max_Doppler_jammer(gnssband);
		   
        case 4  %single chirp 20 MHz
           %SweepRange_Hz;
           jam_param{1}= 10.6*1e6;  %BW
           %Sweepperiod_s
           jam_param{2}= 10*1e-6;
           %upchirp_true
           jam_param{3}=1;
           %phi0
           jam_param{4}=0;
           %f_IF_Hz
           jam_param{5}=Max_Doppler_jammer;
		   
        case 5  %single or multi-tone FM jammer
          %vector of jamming frequencies, given in Hz 
           jam_param{1}=[1] *1e6;
           %vector of jamming amplitudes (linear scale)
           jam_param{2}=[1];
           %jamming modulation indeces
           jam_param{3}= [0.3];
           if length(jam_param{1})~=length(jam_param{2}) || length(jam_param{1})~=length(jam_param{3})
               error ('The jam_param cells should have equal length')
           end
            
       case 6  %dual chirp  (doesn't seem  to work yet)
            %SweepRange_Hz;
           jam_param{1}= 10.6*1e6;  
           %Sweepperiod_s
           jam_param{2}=10.6*1e-6;
           %upchirp_true
           jam_param{3}=1;
           %phi0
           jam_param{4}=0;
           %f_IF_Hz
           jam_param{5}=Max_Doppler_jammer;
           
       case 7  %generic multichipr
           %SweepRange_Hz;
           %jam_param{1}= [10.6*1e6 23.2*1e6 56*1e6] ;  
           jam_param{1}= [1*1e6 5.6*1e6 10.2*1e6] ;  
           %Sweepperiod_s
           %jam_param{2}=[8.64*1e-6 5.24*1e-6 6.83*1e-6];
           jam_param{2}=[5.24*1e-6 8.64*1e-6 6.83*1e-6];
           %upchirp_true
           %jam_param{3}=[1 -1 1];
           jam_param{3}=[1 -0.8 0.5];
            if length(jam_param{1})~=length(jam_param{2}) || length(jam_param{1})~=length(jam_param{3})
                error ('The jam_param cells should have equal length')
            end
           %phi0
           jam_param{4}=0*ones(1,length(jam_param{2}));
           %f_IF_Hz
           jam_param{5}=Max_Doppler_jammer*ones(1,length(jam_param{2}));
           %vector of jamming amplitudes (linear scale)
           jam_param{6}=[1 1 1];
           if length(jam_param{6})~=length(jam_param{1}) 
                error ('The jam_param cells should have equal length')
           end
           
      case 8  %another single chirp like in https://www.researchgate.net/profile/Ciro_Gioia/publication/308968144_From_Agnostic_to_Model-Based_GNSS_Jamming_Detection/links/57fb674a08ae91deaa684f74/From-Agnostic-to-Model-Based-GNSS-Jamming-Detection.pdf
           %SweepRange_Hz;
           jam_param{1}= 8*1e6;  
           
           %Sweepperiod_s
           jam_param{2}=0.1*1e-6;
           %jam_param{2}=1*1e-6;
          
           %upchirp_true
           jam_param{3}=1;
           %phi0
           jam_param{4}=0;
           %f_IF_Hz
           jam_param{5}=Max_Doppler_jammer;
           
    case 9
        %DME jammer
        jam_param{1} = 4.5e11; %Separation between pulses , alpha
        jam_param{2} = 12e-6; %Pulse time, dt
        
    case 10 %1 kHz NB jammer
        jam_param{1} = 1*1e3; %BW_NB_Hz
        
    case 11  %Double tone AM jammer
        %vector of jamming frequencies, given in Hz 
        jam_param{1}=[1.023 3*1.023] *1e6;
        %vector of jamming amplitudes (linear scale)
        jam_param{2}=[1 1];
        if length(jam_param{1})~=length(jam_param{2})
            error ('The jam_param cells should have equal length')
        end
        
    case 12  %Double FM jammer
       %vector of jamming frequencies, given in Hz 
        jam_param{1}=[1 2] *1e6;
        %vector of jamming amplitudes (linear scale)
        jam_param{2}=[1 0.9];
        %jamming modulation indeces
        jam_param{3}= [0.3 0.5];
        if length(jam_param{1})~=length(jam_param{2}) || length(jam_param{1})~=length(jam_param{3})
            error ('The jam_param cells should have equal length')
        end
        
    case 13 %1MHz NB jammer
        jam_param{1} = 1*1e6; %BW_NB_Hz
        
end