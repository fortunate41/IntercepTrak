function [fdout,freq_axis]= fdcorr(a,b,frange) 
%FDCORR Joint frequency and delay correlation
%   Performs an efficient circular cross correlation between 
%   two vectors over all possible frequency offsets (Dopplers) 
%   between -pi and pi where 2pi is the sampling rate.
%
%[FDOUT, FREQ_AXIS] = FDCORR(A,B)
%
%   A:   vector representing received signal sampled at FS = 2pi
%   B:   vector representing correlation code sampled at FS = 2pi
% 
%   FDOUT: 2D Correlation surface vs delay and frequency offset
%   FREQ_AXIS: Frequency values aligned to frequency axis (-pi to pi)
%
%[FDOUT, FREQ_AXIS] = FDCORR(A,B,FRANGE)
%
%   Limits frequency range as defined in FRANGE.    Typically
%   frequency offsets are much smaller than the Nyquist bandwidth, so
%   using a reduced range for FRANGE from -pi to pi will be more
%   efficient.
%
%  FRANGE: Two element vector from lowest to highest frequency to
%          search over within a frequency range from -pi to pi.
%          Example [-pi/10 pi/10]
%
%FDCORR(A,B,<FRANGE>) with no output arguments plots the surface
%       correlation magnitude vs frequency and delay offset in the 
%       current figure window.  FRANGE optional.
%
% 
% Dan Boschen 11/22/2009

%==========================================================
% VERSION HISTORY
%
% 11/22/2009     Inital Release
% 02/06/2017	 Fixed typo in Application Notes section 
%
%==========================================================

%==========================================================
% APPLICATION NOTES:
%
% Vector "A" represents a received signal that has been encoded with 
% a correlation code (such as GPS and CDMA applications) or a training 
% sequence.  It has an unknown frequency offset due to Doppler offsets
% and frequency offsets in the receiver, and an unkown delay shift 
% relative to the start of the code sequence represented by vector "B".  
% FDCORR will efficiently find the correlation between the received 
% sequence and reference code over frequency and delay offsets.  
% Vectors A and B are interchangable.
%
% To detect the maximum correlation value and delay and freq location use:
% [temp1, temp2]=max(fdout);
% [maxcorr,freq_index]=max(temp1);
% delay =temp2(freq_index)-1;
% freq= freq_axis(freq_index);
%
% The basic operation uses the Cross-Correlation theorem: 
% xcorr= ifft(fft(a).*conj(fft(b))) 
%
% Note the detected frequency offset is course and is the 
% frequency of the closest Doppler bin where each Doppler bin
% is seperated by 2pi/N
%
%==========================================================

%
%error handling
if nargin==3
    if length(frange)~= 2
        error('FRANGE must be a two element vector')
    elseif abs(frange)> pi
        error('FRANGE values must be between -pi and pi')
    end 
end

%force column vectors:
a=a(:);
b=b(:);

%============================================================
%create all doppler versions of a by shifting the fft:
%============================================================

N=max(length(a),length(b));
fft_a= fft(a,N);

%frequency axis for all doppler bins -pi to pi

%index is the "fft shifted" freq axis. Method below faster than
%using fftshift(0:N-1), but same result.
freq_index=[-floor((N-1)/2):floor(N/2)];
freq_axis= freq_index*2*pi/N;   %convert to -pi to pi range

if nargin==3     %reduced doppler range
    freq_include=find(freq_axis>=frange(1) & freq_axis<=frange(2));
    freq_axis=freq_axis(freq_include);
    freq_index=freq_index(freq_include);
    num_freqs=length(freq_index);
else
    num_freqs=N;
end

%create Hankel matrix for all Dopplers (each column is the fft
%of vector a at a different Doppler offset)  
fft_idx=(1:N)';
fft_dopplers = fft_idx(:,ones(num_freqs,1))+freq_index(ones(N,1),:);
fft_dopplers= mod(fft_dopplers-1,N)+1;    %Hankel subscripts
fft_dopplers(:)=  fft_a(fft_dopplers);      %fill data  

%alternate method if solving for all Doppler bins (processing intensive):
%fft_all_dopplers= hankel(fft_a,[fft_a(end); fft_a(2:end)]);

%==================================================================
%Circular Correlation using circ_corr= ifft(fft(a).*conj(fft(b))
%==================================================================
fft_code_mtx= fft(b,N)*ones(1,num_freqs);
fdout=(ifft(fft_code_mtx.*conj(fft_dopplers)));

%===============================================================
%plot result
%===============================================================
if nargout ==0
    surf(freq_axis,1:N,(abs(fdout)));
    shading interp; 
    xlabel('Normalized Frequency (xpi rad/sample)');
    ylabel('Delay Index');

end