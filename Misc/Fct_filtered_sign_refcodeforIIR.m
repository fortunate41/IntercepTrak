function [rx_filtered,Hz,ht,Rcorr_filt,PSD_sim,delay_filter,filter_order,fax]= ...
    Fct_filtered_sign_refcodeforIIR(rx_signal,filt_type,filter_parameters,N_BOC_vec, ...
			   fc, B_T, Ns, bt_calc, xBOC) 
%filter the received signal rx_signal with a filter 'filter_type'
%('rect', 'no_filter', 'cheb',  'butterworth', 'fir'), 
%here we compute differently the
%delay for IIR and FIR filters: instead of taking the maximum value of the
%impulse response, we filter a reference code (without noise or Doppler,
%and we correlate this filtered reference code with the unfiltered ref
%code, and we find the position of the maximum peak (this will correspond
%to the delay introduced by the filter)
%INPUTS:
%rx_signal = received signal at sub-sample level (i.e., both BOC
%            modulation and oversampling are included)
%filt_type =type of the filter (so far: 'rect', 'no_filter', 'cheb', 
%           'butterworth', 'fir')
%filter_parameters  = the parameters of the filter:
%[width_of_transition_band(in MHz)
%                     passband_ripple_in_dB or loss in passband [in
%                     dB]
%                     and attenuation in stopband [in dB]
%                     or stopband_ripple_in_dB]
%fc           =chip rate (in MHz)
%B_T       =receiver bandwidth (double sided=> positive bandwidth
%           is B_T/2)
%Ns = oversampling factor considered for simulations
%      this should be choosen sufficiently high,
%      such that we cover all the possible tested
%      bandwidths; i.e., fsampling=Ns*N_BOC1*N_BOC2*fc > 2*B_T/2,
%      in order to fulfill Nyquist condition; fsampling is in
%      MHz ;
%bt_calc = a string equal either to 'passband', or to 'stopband', or to 'threedB',
%          which tells us whether B_T is taken to be equal to the
%          passband, to the stopband or to the 3-dB (or cutoff) bandwidth; default is 'passband'
%xBOC   = the reference signal (at sub-sample level), no noise, no channel;
%it is needed to compute the filter delay
%OUTPUTS:
%rx_filtered = filtered signal
%Hz  = filter transfer function
%ht = filter impulse response
%Rcorr_filt  =ACF of the filtered signal (needed to compute the
%             PSD)
%PSD_Sim  =PSD of the filtered signal (computed as Fourier
%          transform of Rcorr_filt)
%delay_filter= delay introduced by the filter
%filter_order =the minimum filter order (used in the design)
%fax  =frequency axis (for reference)
if nargin<8,
  bt_calc='passband';
end;


%FFT length for computing the PSD and transfer functions of the
%filters; it should be sufficiently high
fft_length=2^14;
fsampling=Ns*N_BOC_vec(1)*N_BOC_vec(2)*fc;
fax=[-fsampling/2+fsampling/fft_length:fsampling/fft_length:fsampling/2]+1e-5;

%signal power, BOC level:
%p1=mean(abs(rx_signal).^2);
%normalization factor: maximum of the PSD without filter
p1=max(abs(fft(xcorr(rx_signal), fft_length)));


%filter parameters:
%width of the transition band (in MHz)
tr_width=filter_parameters(1); 
rp=filter_parameters(2); %loss in passband
rs=filter_parameters(3); %attenuation in stopband
if strcmp(bt_calc, 'passband')
  fp=B_T/2;
  fs=fp+tr_width;
else
  if strcmp(bt_calc, 'stopband')
    fs=B_T/2;
    fp=fs-tr_width;
  else %3dB bandwidth (not very clear if it should be taken like this)
    fp=B_T/2-tr_width/2;
    fs=B_T/2+tr_width/2;
  end
end


if strcmp(filt_type,'rect') %windowed-sinc in time domain; rect
                            %with ripples in freq domain
  %ACF via simulations with bandwidth limited via  rectangular
  %filter;  %time pulse = windowed-sinc time pulse
  nr_coeff=10; %sinc number of coefficients (or half number); take
               %it sufficiently high; e.g., around 10.
  time_ax=[-nr_coeff:1/Ns:nr_coeff];
  %here the cutoff and stopband frequencies are equal; therefore,
  %take them equal with the positive receiver bandwidth, i.e., B_T/2
  fcutoff=B_T/2;
  %define the sinc function; this will be the denominator of the
  %time impulse response
  B_sinc=sinc(time_ax*fcutoff);
  %find impulse response
  ht=impz(B_sinc,1); 
  %find the frequency response via Fourier
  Hz=ifftshift(fft(ht,fft_length));
  
  %[x1 delay]=max(abs(ht));    %estimate the filter delay (old approach)
  %filter the reference code and correlate it with unfiltered code, in
  %order to find the delay introduced by the filter
  ref_filtered=filter(B_sinc,1,xBOC);
  acf_ref=xcorr(ref_filtered,xBOC);
  [~, pos_max]=max(abs(acf_ref));
  delay=abs(length(xBOC)-pos_max)+1;
  rx_filtered_init=filter(B_sinc,1,rx_signal); %filter in
                                               %time-domain
  %normalization to keep power unchanged					       
  p2_sinc=max(abs(fft(xcorr(rx_filtered_init), fft_length)));%mean(abs(rx_filtered_init).^2);   
  rx_filt_sinc=rx_filtered_init*sqrt(p1/p2_sinc);
  %received filtered signal, we need to remove the filter delay and
  %padd with zeros in  order to have the same length! 
  %The padding with zeros might affect the ACF
  rx_filtered=[rx_filt_sinc(delay:end-1) zeros(1,delay)]; 
  %ACF from simulations with limited BW via 'rect' filter
  Rcorr_filt_nn=xcorr(rx_filtered);
  Rcorr_filt=abs(Rcorr_filt_nn)/max(abs(Rcorr_filt_nn));
  PSD_sim=fftshift(fft(Rcorr_filt_nn,fft_length)); 
  filter_order='NaN';
else 
  if strcmp(filt_type,'cheb') %chebyshev type 1 filter
  
    [N_cheb,W_cheb]=cheb1ord(fp/(fsampling/2),fs/(fsampling/2),rp,rs);
    [B_cheb,A_cheb]=cheby1(N_cheb,rp,W_cheb);
    [ht]=impz(B_cheb,A_cheb);
    Hz=ifftshift(fft(ht,fft_length));
    %[x2 delay]=max(abs(ht)); %old method
    %[tg_cheb, f_cheb]=grpdelay(B_cheb, A_cheb, length(rx_signal), fsampling);
    %delay=round(tg_cheb(1))+2
    %find also the group delay and compute the final filter delay;
    %remove filter delay and padd with zeros to keep the same signal
    %length'
    %delay=round(mean([tg_cheb(1) delay]));
    %new method to compute the filter delay:
    ref_filtered=filter(B_cheb,A_cheb,xBOC);
    acf_ref=xcorr(ref_filtered,xBOC); 
    [~, pos_max]=max(abs(acf_ref));
    delay=abs(length(xBOC)-pos_max)+1;
  
    rx_cheb_nd=filter(B_cheb,A_cheb,rx_signal);
    p2_cheb=max(abs(fft(xcorr(rx_cheb_nd), fft_length)));%mean(abs(rx_cheb_nd).^2);
    rx_cheb_nd=rx_cheb_nd*sqrt(p1/p2_cheb);
    %remove filter delay and padd with zeros to keep the same signal length'
    rx_filtered=[rx_cheb_nd(delay:end-1) zeros(1,delay)];
    %ACF from simulations with limited BW and 'Cheb1' LPF 
    Rcorr_filt_nn=xcorr(rx_filtered);
    Rcorr_filt=abs(Rcorr_filt_nn)/max(abs(Rcorr_filt_nn));
    PSD_sim=fftshift(fft(Rcorr_filt_nn,fft_length)); 
    filter_order=N_cheb;
  else
    if strcmp(filt_type,'butterworth')
      [N_butt, W_butt]=buttord(fp/(fsampling/2),fs/(fsampling/2),rp,rs);
      filter_order=N_butt;
      [B_butt,A_butt]=butter(N_butt,W_butt);
      ht=impz(B_butt,A_butt);
      Hz=ifftshift(fft(ht,fft_length));
      %[x3 delay]=max(abs(ht));
      %[tg_butt, f_butt]=grpdelay(B_butt, A_butt, length(rx_signal), fsampling);
      %delay=round(tg_butt(1))+1
      %plot(ht); drawnow;
      %find also the group delay and compute the final filter delay;
      %remove filter delay and padd with zeros to keep the same
      %signal length'(not working properly)
     % [delay tg_butt(1)]
     % delay=round(mean([tg_butt(1) delay]));
      ref_filtered=filter(B_butt,A_butt,xBOC);
      acf_ref=xcorr(ref_filtered,xBOC); 
      %plot(abs(acf_ref)); hold on; plot(abs(xcorr(xBOC)),'r--'); drawnow; 
      [~, pos_max]=max(abs(acf_ref));
      delay=abs(length(xBOC)-pos_max)+1;
      rx_butt_nd=filter(B_butt,A_butt,rx_signal);
      p2_butt=max(abs(fft(xcorr(rx_butt_nd), fft_length)));%mean(abs(rx_butt_nd).^2);
      rx_butt_nd=rx_butt_nd*sqrt(p1/p2_butt);
      %remove filter delay and padd with zeros to keep the same signal length'
      rx_filtered=[rx_butt_nd(delay:end-1) zeros(1,delay)];
      %ACF from simulations with limited BW and 'Butter' LPF 
      Rcorr_filt_nn=xcorr(rx_filtered);
      Rcorr_filt=abs(Rcorr_filt_nn)/max(abs(Rcorr_filt_nn));
      PSD_sim=fftshift(fft(Rcorr_filt_nn,fft_length)); 
    else
      if strcmp(filt_type,'fir') 
        A_filter=[1 0]; %the desired amplitude in the bands A_filter
        %In Matlab 7 only:
        %[N_fir,F0,A0,W_fir]=firpmord([fp/(fsampling/2) fs/(fsampling/2)],A_filter,[rp rs]);
        %[B_fir,err]=firpm(N_fir,F0,A0,W_fir);

        %compute deviations, in linear scale, according to stpband
            %and passband ripples (according to Matlab help on web: 
        %http://www.mathworks.com/access/helpdesk/help/toolbox/signal/firpmord.html
        dev = [(10^(rp/20)-1)/(10^(rp/20)+1)  10^(-rs/20)];

        [N_fir,F0,A0,W_fir]=remezord([fp fs],A_filter,dev, fsampling);
        [B_fir,err]=remez(N_fir,F0,A0,W_fir);
        %err
        while err>0.039
          N_fir=N_fir+1;  
          [B_fir,err]=remez(N_fir,F0,A0,W_fir);
        end
        filter_order=N_fir;

        [ht]=impz(B_fir,1);
        %transfer fct of the filter:
        Hz=ifftshift(fft(ht, fft_length));
        %[x4 delay_old]=max(abs(ht));
        ref_filtered=filter(B_fir,1,xBOC);
        acf_ref=xcorr(ref_filtered,xBOC); 
        [~, pos_max]=max(abs(acf_ref));
        delay=abs(length(xBOC)-pos_max)+1;
        %[delay_old delay]
        rx_fir_nd=filter(B_fir,1,rx_signal);
        p2_fir=max(abs(fft(xcorr(rx_fir_nd), fft_length)));%mean(abs(rx_fir_nd).^2);
        rx_fir_nd=rx_fir_nd*sqrt(p1/p2_fir);
        %remove filter delay and padd with zeros to keep the same signal length'
        rx_filtered=[rx_fir_nd(delay:end-1) zeros(1,delay)];
        %ACF from simulations with limited BW and 'firpm' LPF 
        Rcorr_filt_nn=xcorr(rx_filtered);
        Rcorr_filt=abs(Rcorr_filt_nn)/max(abs(Rcorr_filt_nn));
        PSD_sim=fftshift(fft(Rcorr_filt_nn,fft_length)); 
      else
          if strcmp(filt_type,'no_filter')
              rx_filtered=rx_signal;
              Hz=NaN;
              ht=NaN;
              Rcorr_filt=NaN;
              PSD_sim=NaN;
              delay=NaN;
              filter_order=NaN;
          else
              error('Undefined filter type')
          end
      end
    end
  end
end

delay_filter=delay;

%%%2. normalize signal after filtering  to unit power in infinite BW; so that C/N0 is with
%%respect to unit power signal in infinite BW
%rx_filtered=rx_filtered/sqrt(mean(abs(rx_signal).^2));
%mean(abs(rx_filtered).^2)
