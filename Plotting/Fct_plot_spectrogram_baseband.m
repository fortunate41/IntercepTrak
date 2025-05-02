function [SY, FY, TY ]=Fct_plot_spectrogram_baseband(input_signal, fs, xlabel_name)
%plot a spectrogram on the input_signal
%fs= sampling frequency
%obs_window_microsec = observation window over which the spectrogram is
%computed

%Chirp -->( input_signal, 32, 20, 1024*4, fs )
%AM/FM -->( input_signal, 32*8, 20, 1024*4, fs )

[SY, FY, TY ] = spectrogram( input_signal, 32, 20, 1024*4, fs );
FY = FY - fs/2;
SY = fftshift( SY, 1 );
imagesc( TY * 1e6, FY / 1e6, real( SY .*conj(SY) ) )
%contourf( TY * 1e6, FY / 1e6, real( SY .*conj(SY) ) )
set(gca, 'YDir', 'Normal')
%xlabel('Time [\mu s]')
%ylim([-10 10])
xlabel(xlabel_name)
ylabel('Frequency [MHz]')
% title('Spectrogram before despreading')

