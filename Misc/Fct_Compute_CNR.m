function [CNR, CN0_spilker] = Fct_Compute_CNR(signal, ParamSim, ParamChannel, ParamGNSS, gnssband, nrand, Option)


%% Local variables
Integration_blocks= ParamSim.Nc;%# of integration blocks

%% Doppler correction
fD = ParamChannel.FDest(gnssband);%Doppler frequency correction needed

if Option == 2 %Find doppler shift (if any)
	fD_Vec=0:100:10e3;
    t=linspace((nrand-1)*1e-3*(ParamGNSS.SF(gnssband)/1023), nrand*1e-3*(ParamGNSS.SF(gnssband)/1023), ParamSim.SamplesPerms(gnssband));
    i=1;
    %% Obtain PRN code and resample it for 1 ms data
    [I, Q] = GNSSsignalgen(ParamGNSS.SV_Number(gnssband), ParamGNSS.GNSS_Band{gnssband}, ParamSim.Fs, 1);
    % IQ in the same vector
    code = (I+1j*Q).';
    code = code(1:length(signal(1:ParamSim.SamplesPerms(gnssband))));
    for fD=fD_Vec
        signal_corr = signal(1:ParamSim.SamplesPerms(gnssband)) .* exp(2*pi*1i*fD*t);
        corr(i,:) = xcorr(signal_corr(1:ParamSim.SamplesPerms(gnssband)), code);
        i=i+1;
    end
    [Y X] = max(max(corr(:,:),[],2));%find the maximums for each analised fD
    fD=fD_Vec(X);%doppler estimate
end
t=linspace((nrand-1)*ParamSim.Nc*1e-3*(ParamGNSS.SF(gnssband)/1023), nrand*ParamSim.Nc*1e-3*(ParamGNSS.SF(gnssband)/1023), ParamSim.TotalSamples(gnssband));
Dopplercorrection = exp(2*pi*1i*fD*t);

%% Remove Doppler
signal = signal .* Dopplercorrection;

%% Obtain PRN code and resample it
[I, Q] = GNSSsignalgen(ParamGNSS.SV_Number(gnssband), ParamGNSS.GNSS_Band{gnssband}, ParamSim.Fs, ParamSim.Nc);
% IQ in the same vector
code = (I+1j*Q).';
code = code(1:length(signal));

for prn=1:ParamGNSS.SV_Length
    %% Divide in 1 block per ms blocks
    signal_corr_blocks = reshape(signal,[],Integration_blocks).';
    code_blocks    = reshape(code(prn,:),[],Integration_blocks).';
    %% Convert to frequency domain (complex)
    signal_blocks_fft = fft(signal_corr_blocks,size(signal_corr_blocks,2) ,2);
    code_blocks_fft = fft(code_blocks,size(code_blocks,2) ,2);

    % Multiplication in the frequency domain (complex) 
    % Convolution in the time domain is equivalent to
    % multiplication in the frequency domain.
    convFreqDomain = signal_blocks_fft .* conj( code_blocks_fft );

    % Perform inverse FFT to return to the time domain (complex)
    J_coh(:,:,prn) = ifft( convFreqDomain ,size(code_blocks_fft,2),2);
end


%% integrate over Blocks_of_1ms and normalize

%J_coh_int = squeeze(sum(J_coh)/Blocks_of_1ms);
J_noncoh_int = squeeze(sum(real(J_coh).^2 + imag(J_coh).^2)/Integration_blocks);
%normalization
J_noncoh_int = fftshift(J_noncoh_int/max(J_noncoh_int));


%% CNR Estimation:
%% Approach 1: Max peak divided by mean noise
%find maximum peak
[maxpeak,P]=max(abs(J_noncoh_int),[],2);

%build window close to the main peak
windowsize=P-100+1:P+100;
windowsize=windowsize(windowsize>0);%Only takes the positive values of the window
%measure noise, removing main peak
Acf_bis=abs(J_noncoh_int);

Acf_bis(:,windowsize)=NaN*ones(ParamGNSS.SV_Length, length(windowsize));

SignalEst = maxpeak;
NoiseEst = mean(abs(Acf_bis),2,'omitnan');

SNR = 10*log10(SignalEst./NoiseEst);
CNR=SNR+30;

%% Approach 2: Spilker
M = floor(ParamSim.Nc/5);; % number of sequnces of length Nc to average
K = round(ParamSim.Nc/M);
T = (ParamGNSS.SF(gnssband)/1023)*1e-3;%1e-3; % 1 milli second in case of GPS L1 (coherent integration time)

if K>1
    [~, P]=max(abs(J_coh),[],2);

    I_prompt = zeros(1, K);
    Q_prompt = zeros(1, K);
    for ii = 1:size(J_coh,1)
        I_prompt(ii) = real(J_coh(ii,P(ii)));
        Q_prompt(ii) = imag(J_coh(ii,P(ii)));
    end

        %reshape to K blocks
        I_prompt_k=reshape(I_prompt,M,[]);
        Q_prompt_k=reshape(Q_prompt,M,[]);

        wideband_power = sum(I_prompt_k.^2 + Q_prompt_k.^2);
        narrowband_power = (sum(I_prompt_k).^2) + (sum(Q_prompt_k).^2);

        estimated_normalized_power = narrowband_power ./ wideband_power;%NP in equation
        mu = mean(estimated_normalized_power);%Mu inequation
        estimated_normalized_power_mean = mu;

        tmp =((mu-1)/(M-mu))  / T;

        %if tmp > 0 % CNR must be above 30 dB or more for GPS L1 signal
            CN0_spilker = abs(10*log10(tmp));
        %else
            %warning('Signal level too low to estimate CN0 with this method')
         %   CN0_spilker =NaN;
       % end

        % Ruben's implementation for comparison
        %CN0_spilker = abs(10*log10(1 / ParamSim.Nc*1e-3) + 10*log10( (estimated_normalized_power_mean - 1) ) - 10*log10( M - estimated_normalized_power_mean ))
else
    CN0_spilker =NaN;
end