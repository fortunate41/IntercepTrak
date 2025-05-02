function Test_stat = Fct_AGC_TestStat(rx_signal, agc_filter)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                    %
%                               AGC Detector                                         %
%                                                                                    %
%   This detector takes into account the Automatic Gain control (AGC) of the         %
%   front-end. The AGC is in charge of adjusting the incoming signal power           %
%   such that the quantization losses are kept as minimum as possible.In             %
%   jamming-free scenario, the GNSS signal is kept below the thermal noise           %
%   floor, and in consecuence the AGC is mostly driven by the thermal noise          %
%   floor rather than the signal power. In this case the AGC values will be          %
%   much lower than in case some interference is present.                            %
%                                                                                    %
%   Reference: [BKS+2014] M.Z.H. Bhuiyan, H.Kuusniemi, S. Söderholm, E. Airos,       % 
%   “The impact of interference on GNSS receiver observables -  a running´           %
%   digital sum based jammer detector”, Radioengineering, vol. 23(3), Sep 2014.      %
%                                                                                    %
%   Inputs:                                                                          %
%                                                                                    %
%       - rx_fading_fin -> Signal in the receiver antenna that contains              %
%       both the GNSS signals and jammer (in case it is present) mixed.              %
%       Both signals have propagated through a fading channel.                       %
%                                                                                    %
%       - agc_filter -> Contains the AGC filter object generated in the main file    %              
%                                                                                    %
%   Outputs:                                                                         %
%                                                                                    %
%       - Result -> Contains the Result of the test statistic. In this case          %
%       it contains the AGC output of the received signal rx_fading_fin after        % 
%       passing thrpugh the AGC filter.                                              %
%                                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Apply automatic gain conversion according to the agc_filter taken as input
AGC_output = real(agc_filter(rx_signal.'));%Transition in the first samples, we do it twice
AGC_output = real(agc_filter(rx_signal.'));

%Gain(dB) = Input - Output. In case of Jammer, the input will be much more
%higher than the output, and in consequence this gain will be high as well.
AGC_gain   = real(rx_signal.') ./ AGC_output;

%We take the mean value of the AGC as a test statistic
Test_stat = mean(AGC_gain);

%% --- Plot ---------------------
% figure
% plot(linspace(1/fs*1e3, (length(AGC_gain)/(fs*1e-3)), length(AGC_gain)), 1./(AGC_gain))
% xlabel('Time (ms)')
% ylabel('AGC Gain')
% title('AGC Detector')
