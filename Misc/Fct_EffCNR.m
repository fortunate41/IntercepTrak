function EffCNR = Fct_EffCNR(rx_fading, Interf_sign_withch, JSR_dB, CNR_dBHz)

    %COMPUTE EFFECTIVE CNR
    PSD_sig=abs(fftshift(fft(rx_fading))).^2; 
    PSD_jam=abs(fftshift(fft(Interf_sign_withch))).^2;
    [SSC, SSC1, SSC2]=Fct_interf_SSC_between2_simbased_PSDs( PSD_sig, PSD_jam);
    CNR_lin=10.^(CNR_dBHz/10);
    JSR_lin=10^(JSR_dB/10);                      
    EffCNR=10*log10(CNR_lin/(1+JSR_lin/CNR_lin*SSC));
end