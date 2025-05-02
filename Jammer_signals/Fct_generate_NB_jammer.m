function [jammer_signal]= Fct_generate_NB_jammer(fsampling_Hz, signal_length_samples, BW_NB_Hz) 
%generate a narrowband jammer by filtering an AWGN with a rectangular pulse
%shape; the narrowband jammer will have a bandwidth BW_NB


%filter an additive white Gaussian noise generated on time axis tax 
tax=[0 : round(signal_length_samples/1000): signal_length_samples-1]/ fsampling_Hz; %time axis in seconds
white_noise=randn(1,signal_length_samples);
white_noise=(white_noise-mean(white_noise))/std(white_noise);

%here the cutoff and stopband frequencies are equal; therefore,
%take them equal with the positive receiver bandwidth, i.e., B_T/2
fcutoff=BW_NB_Hz/2;
%define the sinc function; this will be the denominator of the
%time impulse response
B_sinc=sinc(tax*fcutoff);
jammer_signal=filter(B_sinc,1,white_noise);
jammer_signal=jammer_signal/mean(abs(jammer_signal).^2);
stepi=fsampling_Hz/signal_length_samples;
% fax=[-fsampling_Hz/2: stepi:fsampling_Hz/2-stepi];
% figure; plot(fax/1e3, 10*log10(abs(fftshift(fft(jammer_signal))))); 
% xlabel('Frequency [kHz]')
% 
  
