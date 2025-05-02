function dataIQ = Fct_ReadData(ParamSim, fidIn, gnssband)


%--- Complex-valued IF data are stored interleaved in file -------------
[data, count] = fread( fidIn, [1, 2*ParamSim.TotalSamples(gnssband)], ParamSim.DataTypeStr, 'ieee-be');
%--- Read error check --------------------------------------------------
if ( count ~= length(data) )
    error( '***  READ ERROR - End-of-file reached!!  ***' );
end
Idata = data(1:2:end);
Qdata = data(2:2:end);
dataIQ = Idata + 1i.* Qdata;
% convert int16 to floating point
if strcmp(ParamSim.DataTypeStr, 'int16')
    dataIQ = dataIQ/(2^16/2-1);
elseif strcmp(ParamSim.DataTypeStr, 'int8')
    dataIQ = dataIQ/(2^8/2-1);
end



