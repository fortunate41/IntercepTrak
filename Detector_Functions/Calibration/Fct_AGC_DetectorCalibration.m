function Test_stat = Fct_AGC_DetectorCalibration(rx_signal, agc_filter)

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
