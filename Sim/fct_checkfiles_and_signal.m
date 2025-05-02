function fct_checkfiles_and_signal(ParamSim, fileNameGNSS, fileNameJammer, PathName, scenario, checkSignalFlag)

fileJammer     = [PathName fileNameJammer];
fileGNSS       = [PathName fileNameGNSS];

%% Check if Jammer file exissts
if ~exist(fileJammer, 'file')
error(['File ' fileNameJammer ' not found']);
end

fileInfo = dir(fileJammer);
fileSize_byte = fileInfo.bytes;
if fileSize_byte == 0
    warning('File is empty: %i bytes.\nAborting!', fileSize_byte);
    return;
end
fprintf('\nSize of file to be read: %i (bytes)\n', fileSize_byte);

%% Check if GNSS file exists
if ~exist(fileGNSS, 'file')
error(['File ' fileGNSS ' not found']);
end

fileInfo = dir(fileGNSS);
fileSize_byte = fileInfo.bytes;
if fileSize_byte == 0
    warning('File is empty: %i bytes.\nAborting!', fileSize_byte);
    return;
end
fprintf('\nSize of file to be read: %i (bytes)\n', fileSize_byte);

%% Open files
fileId_GNSS   = fopen(fileGNSS, 'r');
if fileId_GNSS <= 0
    error(['File ' fileGNSS ' not found']);
end
fileId_Jammer = fopen(fileJammer, 'r');
if fileId_Jammer <= 0
    error(['File ' fileJammer ' not found']);
end

%% check signal
if checkSignalFlag == 1
    %Read a certain amount of samples and disard them
    timetoDiscard = 60;%seconds
    fs = ParamSim.Fs;
    samplestoDiscard = timetoDiscard*fs;
    piecesToRead = 10;

    fseek( fileId_GNSS, samplestoDiscard, 'bof');
    fseek( fileId_Jammer, samplestoDiscard, 'bof');

    %--- Complex-valued IF data are stored interleaved in file -------------
    [dataIQ, count] = fread( fileId_GNSS, [1, 2*piecesToRead*ParamSim.SamplesPerms], ParamSim.DataTypeStr, 'ieee-be');
    %--- Read error check --------------------------------------------------
    if ( count ~= length(dataIQ) )
        error( '***  READ ERROR - End-of-file reached!!  ***' );
    end
    Idata = dataIQ(1:2:end);
    Qdata = dataIQ(2:2:end);
    dataGNSS = Idata + 1i.* Qdata;
    % convert int16 to floating point
if strcmp(ParamSim.DataTypeStr, 'int16')
    dataGNSS = dataIQ/(2^16/2-1);
elseif strcmp(ParamSim.DataTypeStr, 'int8')
    dataGNSS = dataIQ/(2^8/2-1);
end
    %--- Complex-valued IF data are stored interleaved in file -------------
    [dataIQ, count] = fread( fileId_Jammer, [1, 2*piecesToRead*ParamSim.SamplesPerms], ParamSim.DataTypeStr, 'ieee-be');
    %--- Read error check --------------------------------------------------
    if ( count ~= length(dataIQ) )
        error( '***  READ ERROR - End-of-file reached!!  ***' );
    end
    Idata = dataIQ(1:2:end);
    Qdata = dataIQ(2:2:end);
    dataJammer = Idata + 1i.* Qdata;
    % convert int16 to floating point
if strcmp(ParamSim.DataTypeStr, 'int16')
    dataJammer = dataIQ/(2^16/2-1);
elseif strcmp(ParamSim.DataTypeStr, 'int8')
    dataJammer = dataIQ/(2^8/2-1);
end
    
    %% Plot time-domain data GNSS
    xax = (0:1:length(dataGNSS)-1)/fs;

    figure()
    plot(xax, real(dataGNSS))
    % set(gca, 'FontSize', 16)
    xlabel('time (s)')
    ylabel('amplitude')
    title('GNSS time-domain data');
    
    %% Plot time-domain data jammer
    xax = (0:1:length(dataJammer)-1)/fs;

    figure()
    plot(xax, real(dataJammer))
    % set(gca, 'FontSize', 16)
    xlabel('time (s)')
    ylabel('amplitude')
    title('Jammer time-domain data');

    %% Plot Spectrum
    Nfft = 2^18;
    %GNSS
    figure()
    plotFreqSpectrum(dataGNSS, fs, Nfft, 'GNSS Spectrum')

    %Jammer
    figure()
    plotFreqSpectrum(dataJammer, fs, Nfft, 'Jammer Spectrum')

    %% Plot Spectrogram
    %GNSS
    obs_window_microsec = piecesToRead*1e-3*1e6;%PiecesToRead is in ms
    xlabel_name='Time [\mu s]';
    figure()
    plotSpectrogramBaseband(dataGNSS, fs );

    %Jammer
    figure()
    plotSpectrogramBaseband(dataJammer, fs);
end

    %% Check if the file is long enough acording to the required iterations
    TotalNumberOfSamples = ParamSim.TotalSamples(scenario)*ParamSim.Nrandompoints;
    
    LengthEnoughGNSS = fseek( fileId_GNSS, TotalNumberOfSamples, 'bof');
    LengthEnoughJammer = fseek( fileId_Jammer, TotalNumberOfSamples, 'bof');
    
    if LengthEnoughGNSS==-1 || LengthEnoughJammer==-1
        error('File is not long enough according to the specified number of iterations, aborting...');
    end