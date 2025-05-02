function [SY, FY, TY ]=Fct_generateImage(signal, fs, method)


if method ==1
    %% Plot Spectrogram (Jammer + GNSS)
    [SY, FY, TY ]= plotSpectrogramBaseband(signal, fs);
elseif method==2
    %% Plot WVD (Jammer + GNSS)
    FreqPoints = ceil(length(signal)/4);
    TimePoints = ceil(length(signal)/2);
    [SY,FY,TY] = wvd(signal,fs,'smoothedPseudo','NumFrequencyPoints',FreqPoints,'NumTimePoints',TimePoints,kaiser(65,3));  
    FY = FY - fs/2;
    SY = fftshift( SY, 1 );
elseif method==3
    %% Plot Fourier synchrosqueezed transform (Jammer + GNSS)
    [SY,FY,TY] = fsst(signal,fs,kaiser(65,3),'yaxis');
%     FY = FY - ParamSim.fs/2;
%     SY = fftshift( SY, 1 );
end