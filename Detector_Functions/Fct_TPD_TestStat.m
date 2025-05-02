function Teststat = Fct_TPD_TestStat(rx_signal, fs, Ns)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                               %
%                        Time Power Detector (TPD)                              %
%                                                                               %
%   This method measures the energy of the received signal over N samples.      %
%   v is a positive integer to determine the power low detection order (v=1     %
%   for square-law). The power values can be compared with a certain threshold. %
%   In case the jammer is present the measured power will be higher than in     %
%   the no jamming case.                                                        %
%                                                                               %    
%   Reference: [fad2016] N. Fadaei, “Detection, characterization, and           %
%   mitigation of GNSS jamming using pre-correlation methods”,                  % 
%   Msc thesis, Univ. of Calgary, Apr 2016                                      %  
%                                                                               %
%   Inputs:                                                                      %
%                                                                                %
%       - rx_fading_fin -> Signal in the receiver antenna that contains          %
%       both the GNSS signals and jammer (in case it is present) mixed.          %
%       Both signals have propagated through a fading channel.                   %
%                                                                                %
%       - fs -> Sampling Frequency. Only needed to convert samples to            %
%       time in the plot.                                                        %
%                                                                                %
%       - Ns -> Oversampling Factor. Only needed for adaptable window length.    %
%                                                                                %
%       - SF -> Spreading Factor. Only needed for adaptable window length.       %
%                                                                                %
%       - N_BOC_vec -> BOC modulation order. Only needed for adaptable           %
%       window length.                                                           %
%                                                                                %
%   Outputs:                                                                     %
%                                                                                %
%       - Result -> Contains the Result of the test statistic. In this case      %
%       it contains the mean power of the received signal rx_fading_fin.         %
%                                                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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