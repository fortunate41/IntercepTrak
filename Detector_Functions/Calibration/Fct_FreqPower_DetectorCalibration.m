function Teststat = Fct_FreqPower_DetectorCalibration(rx_signal)

%Power-law parameter (v=1 square law)
v = 1;
%Window length (in samples)
N  =  1000;%Ns*prod(N_BOC_vec)*SF;

%fft to convert to frequency domain and determine power
fft_rx = fftshift(abs(fft(rx_signal)/length(rx_signal)));
%fft_rx = fftshift(abs(fft(rx_signal)));
Test_stat = 1/N*movsum(abs(fft_rx).^2, N);

Test_stat = Test_stat(N:end-N);
Teststat = mean(Test_stat);%We remove the transition at the begining and end of the window

%% --- Plot Signal Power vs Frequency --------------------------------------------------------------------       
% Precision = fs/length(rx_fading_fin);
% f = linspace((-fs/2-Precision/2), (fs/2-Precision/2), length(rx_fading_fin)); % Create the frequency axis and put the measure in the middle of the bin.
% F = f/1e6;%MHz
% 
% figure
% plot(F, 10*log10(FreqDetector)+30)%In dBm
% title(['Frequency Power Detector (window = ' num2str(N/fs*1e3) ' ms)'])
% xlabel('Frequency (MHz)')
% ylabel('Power (dBm)')
% set(0,'defaultaxesfontsize',40);