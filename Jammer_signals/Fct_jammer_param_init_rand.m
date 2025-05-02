function jam_param=Fct_jammer_param_init_rand(jam_type, Max_Doppler_jammer, gnssband)  
%create jammer with predefined parameters
switch jam_type
        case 1
            jam_param{1}=NaN;  % no jamming
        case 2  %single-tone AM jammer
            %vector of jamming frequencies, given in Hz 
            jam_freq_MHz=rand(1,1)*(10-0.1)+0.1;   %unif distributed between 0.1 and 10]
            jam_param{1}=[jam_freq_MHz] *1e6;
            %vector of jamming amplitudes (linear scale)
            jam_param{2}=[1];
            if length(jam_param{1})~=length(jam_param{2})
                error ('The jam_param cells should have equal length')
            end

        case 3  %single chirp random BW
           %SweepRange_Hz; %unif distributed between 5 and 20 MHz
           jam_param{1}= (rand(1,1)*20+5)*1e6;  %BW
           %Sweepperiod_s; unif distributed between 5 and 20 mus
           jam_param{2}= (rand(1,1)*20+5)*1e-6;
           %upchirp_true  %random 0 or 1
           jam_param{3}=randi([0 1]);
           %phi0
           jam_param{4}=0;
           %f_IF_Hz
           jam_param{5}=Max_Doppler_jammer(gnssband);

        case 5  %single-tone random FM jammer
          %vector of jamming frequencies, given in Hz 
           jam_freq_MHz=rand(1,1)*(10-0.1)+0.1;   %unif distributed between 0.1 and 10]
           jam_param{1}=[jam_freq_MHz] *1e6;
           %vector of jamming amplitudes (linear scale)
           jam_param{2}=[1];
           %jamming modulation indecesm random between 0.1 and 0.9
           jam_param{3}= rand(1,1)*0.8+0.1;
           if length(jam_param{1})~=length(jam_param{2}) || length(jam_param{1})~=length(jam_param{3})
               error ('The jam_param cells should have equal length')
           end
            
       case 6  %dual chirp  Random BW
           MaxChirps=2;
           %SweepRange_Hz; %unif distributed between 1 and 10 MHz
           jam_param{1}= (rand(1,MaxChirps)*9+1)*1e6;  %BW
           %Sweepperiod_s; unif distributed between 1 and 10 mus
           jam_param{2}= (rand(1,MaxChirps)*9+1)*1e-6;
           %upchirp_true  %random 0 or 1
           jam_param{3}=randi([0 1],1,MaxChirps);
           %phi0
           jam_param{4}=zeros(1,MaxChirps);
           %f_IF_Hz
           jam_param{5}=Max_Doppler_jammer;
           
       case 7  %generic multichirp
           %SweepRange_Hz; 
           jam_param{1}= [1 5.6 10.2]*1e6 ;  
           %Sweepperiod_s
           jam_param{2}=[5.24 8.64 6.83]*1e-6;
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
        %DME jammer, random 
        jam_param{1} = (rand(1,1)*9+1)*1e11; %Separation between pulses , alpha
        jam_param{2} = (rand(1,1)*19+1)*1e-6; %Pulse time, dt
        
    case 10 % NB jammer, random BW between 20 kHz and 2000 kHz
        jam_param{1} = (rand(1,1)*(2000-20)+20)*1e3; %BW_NB_Hz
        
    case 11  %Multi tone AM jammer (up to 5 tones)
        %vector of jamming frequencies, given in Hz
        MaxTones = 5;
        jam_freq_MHz=rand(1,randi([1 MaxTones],1))*(10-0.1)+0.1; %unif distributed between 0.1 and 10]
        jam_param{1}=[jam_freq_MHz] *1e6;
        %vector of jamming amplitudes (linear scale)
        jam_param{2}=[ones(length(jam_freq_MHz))];
        if length(jam_param{1})~=length(jam_param{2})
            error ('The jam_param cells should have equal length')
        end
        
    case 12  %Multi FM jammer
       %vector of jamming frequencies, given in Hz 
        MaxTones = 5;
        jam_freq_MHz=rand(1,MaxTones)*(10-0.1)+0.1;   %unif distributed between 0.1 and 10]
        jam_param{1}=[jam_freq_MHz] *1e6;
        %vector of jamming amplitudes (linear scale)
        jam_param{2}=[ones(length(jam_freq_MHz))];
        %jamming modulation indecesm random between 0.1 and 0.9
        jam_param{3}= rand(1,MaxTones)*0.8+0.1;
        if length(jam_param{1})~=length(jam_param{2}) || length(jam_param{1})~=length(jam_param{3})
            error ('The jam_param cells should have equal length')
        end
        
end