function [SY, FY, TY ] = plotSpectrogramBaseband(input_signal,fs)
%   Plot spectrogram on the input_signal.
%
% Input:
%   fs          sampling frequency
%   obs_window  length of window
%   xlabel_name name of xlabel
%
% Ouput:
%   SY          power per frequency and time bin
%   FY          frequency bins in MHz
%   TY          time bins in s


% wlen = 16;
% window = kaiser(wlen,5);
%overlap = floor(0.99*wlen);%wlen/2;


%wlen = 128;%16;
%window = kaiser(wlen,120);
% overlap = floor(0.5*wlen);%wlen/2;


%[SY, FY, TY ] = spectrogram( input_signal, window, overlap, 1024, fs);

[SY, FY, TY ] =spectrogram( input_signal,128,120,128,fs);

FY = FY - fs/2;
SY = fftshift( SY, 1 );

imagesc( TY * 1e6, FY / 1e6, real( SY .*conj(SY) ) )
%xlim([1 1e-6/(1/fs)])
set(gca, 'YDir', 'Normal')
% ylabel('frequency (MHz)')
