function plotFreqSpectrum(sig, fs_Hz, Nfft, titleMsg)


if ~exist('Nfft', 'var')
    Nfft = 2^18;
end
if ~exist('titleMsg', 'var')
    titleMsg('Frequency Spectrum');
end

fax = -fs_Hz/2 : fs_Hz/Nfft :(fs_Hz)/2 - fs_Hz/Nfft;
SIG = fft(sig, Nfft);

plot(fax*1e-6, 10*log10(fftshift(abs(SIG/Nfft))))
xlim([-60, 60]);
title(titleMsg)
xlabel('frequency (MHz)')
ylabel('magnitude (dB)');