function [chirp_wave]=Fct_generate_dualchirp_jammer( fs, SweepRange_Hz, SweepPeriod_s,Time_window_s, phi0,f_IF_Hz)
%generate an up or down chirp signal in baseband
% fs           = sampling frequency
%SweepRange_Hz =sweep range (difference between max and min freq of jammer)
%SweepPeriod_s   =sweep period in seconds, i.e. the time 
%               it takes to sweep from fmin to fmax  is (fmax-fmin=SweepRange_Hz).
%upchirp_true  = a 0,1 flag showing if we generate an uo chirp or a down
%                chirp
%Time_window_s  =time window over which we generate the jammer
%phi0           = initial phase of the jammer
%f_IF_Hz        = IF frequency in Hz; in baseband modeling we take it 0


time_ax=[0:1/fs:Time_window_s];  %pay attention, to see changes, time_ax 
                                    %need to be much higher than T defined
                                    %below (T=time to sweep from fmin to
                                    %fmax)
%we assume symetrical sweeping range, from f0-fmin to
%f0+fmax, where abs(fmin)=abs(fmax)
fmin=-SweepRange_Hz/2;
fmax=fmin+SweepRange_Hz;

if fmax >fs/2
    error(['fmin, fmax, and fs are not well chosen: choose fs higher than:',num2str(fmax*2/1e6),' MHz'])
end

mu_chirp=(fmax-fmin)/SweepPeriod_s;
time_ax1=rem(time_ax, SweepPeriod_s)-SweepPeriod_s/2;%-fix(time_ax/Tsym);  %this has a saw shape, see 
%figure; plot(time_ax*1e6,time_ax1*1e6); hold on; 
%title('Output of saw function')
%xlabel('Input time [\mu s]');ylabel('Output time [\mu s]');

chirp_freq_up=f_IF_Hz+mu_chirp/2*time_ax1 +phi0./(2*pi*time_ax1);  %go from fmin to fmax in Tsym

chirp_freq_down=f_IF_Hz- mu_chirp/2*time_ax1 +phi0./(2*pi*time_ax1);%go from fmax to fmin in Tsym


chirp_wave=4*exp(1j*2*pi*chirp_freq_up.*time_ax1)-2*exp(1j*2*pi*chirp_freq_down.*time_ax1);

