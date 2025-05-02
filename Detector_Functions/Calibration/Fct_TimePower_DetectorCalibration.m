function Teststat = Fct_TimePower_DetectorCalibration(rx_signal, fs, Ns)

%Power-law parameter (v=1 square law)
v = 1;
%Window length (in samples)
time_window_length_mseconds = 1;
time_window_length_samples = (time_window_length_mseconds*1e-3)*fs;%length(rx_fading_fin_H0);%Ns*prod(N_BOC_vec)*SF; %1 code epoch
N  =  time_window_length_samples/Ns;%
%Determine the power With NO normalization over N
%data padding to take N samples
n = uint32(length(rx_signal));
m=uint32(n/N);

z=floor(n/m);
%The chosen test statistic takes the mean, it has the best performance
Test_stat = mean(abs(reshape(rx_signal(1:z*m), m, [])).^(2*v),2);

Teststat = mean(Test_stat);


% %total ms in the signal
% time_tot_ms = length(rx_signal)/fs*1e3;%[ms]
% time_tot_samples = uint32(length(rx_signal));
% %Window length (in samples)
% desired_windwLength_ms = 1;
% desired_windwLength_samples = (desired_windwLength_ms*1e-3)*fs;%length(rx_fading_fin_H0);%Ns*prod(N_BOC_vec)*SF; %1 code epoch
% N  =  desired_windwLength_samples;%
% %divide the signal in pieces of N=desired_windwLength_samples.
% m=uint32(time_tot_samples/N);%Total number of pieces
% z=floor(time_tot_samples/m);%Number of samples in each piece
% %The chosen test statistic takes the mean, it has the best performance
% Test_stat = mean(abs(reshape(rx_signal(1:z*m), m, [])).^(2*v),2);

%area under the curve --> cumkdensity(xi,pdf), 1-cumkdensity(xi,pdf) is pfa

% --- Plot Signal Power vs Time --------------------------------------------------------------------   
%     figure
%     plot(linspace(1/fs*1e3, (length(TimeDetector)/(fs*1e-3)), length(TimeDetector)), 10*log10(TimeDetector)+30)
%     title(['Time Power Detector (window=' num2str(N/fs*1e3) 'ms)'])
%     xlabel('Time (ms)')
%     ylabel('Power (dBm)')
%     set(0,'defaultaxesfontsize',40);