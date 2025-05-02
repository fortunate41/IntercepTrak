function Teststat =Fct_FPD_TestStat(rx_signal)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                %
%                       Frequency Time Detector (FPD)                            %
%                                                                                %
%   This method measures the received signal energy over N samples in the        %
%   frequency domain. The power values can be compared with a certain threshold. %
%   In case the jammer is present the measured power will be higher than in      %
%   the no jamming case.                                                         %                                                         
%                                                                                %
%   Reference: [fad2016] N. Fadaei, “Detection, characterization, and            %
%   mitigation of GNSS jamming using pre-correlation methods”,                   % 
%   Msc thesis, Univ. of Calgary, Apr 2016                                       %  
%                                                                                %
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
N  =  10;%Ns*prod(N_BOC_vec)*SF;

%fft to convert to frequency domain and determine power
fft_rx = fftshift(abs(fft(rx_signal)/length(rx_signal)));
%fft_rx = fftshift(abs(fft(rx_signal)));
Test_stat = 1/N*movsum(abs(fft_rx).^2, N);
%Test_stat = Test_stat(N:end-N);
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