function channel = Fct_Channel_Gen(ParamChannel, ParamGNSS, ParamJam, ParamSim, gnssband, Option)

    %% Initialize arrays for allocation
    Samplestot=ParamSim.TotalSamples(gnssband);
	
    L_pathsS2A      = NaN*ones(1, ParamGNSS.SV_Length);
    delS2A          = NaN*ones(ParamChannel.L_paths_maxS2A, ParamGNSS.SV_Length);
    av_powers_dBS2A = NaN*ones(ParamChannel.L_paths_maxS2A, ParamGNSS.SV_Length);
    alpha_chS2A     = NaN*ones(ParamGNSS.SV_Length, Samplestot);
    L_pathsG2A      = NaN*ones(1, ParamChannel.L_paths_max_jammerG2A);
    delG2A          = NaN*ones(ParamChannel.L_paths_max_jammerG2A, ParamJam.Jammers_ON);
    av_powers_dBG2A = NaN*ones(ParamChannel.L_paths_max_jammerG2A, ParamJam.Jammers_ON);
    alpha_chG2A     = NaN*ones(ParamJam.Jammers_ON, Samplestot);%only one Jammer at the same time?

    %Generate the ground to aircraft (G2A) channel for jammer
    [L_pathsG2A, ~, delG2A, av_powers_dBG2A] = Fct_chparam_generate(ParamChannel, ParamSim, ParamChannel.Xmax_jammerG2A, ParamChannel.L_paths_max_jammerG2A, ParamChannel.Random_path_flagG2A);  

    for nsv = 1:ParamGNSS.SV_Length%For each one of the satellites
       %Generate Satellite to aircraft (S2A) channel for GNSS signal
        %first generate a random number of paths between 1 and L_paths_max; keep the
        %same delays and av_powers for all the non-coherent integration time.
        [L_pathsS2A(1,nsv), ~, delS2A(nsv), av_powers_dBS2A(nsv)] = Fct_chparam_generate(ParamChannel, ParamSim, ParamChannel.XmaxS2A, ParamChannel.L_paths_maxS2A, ParamChannel.Random_path_flagS2A);    
        clear rx*; 
        clear prncodelong_last;
        clear tax;
        if ParamChannel.Static_channel_true == 1 %static channel is composed by 1's. No fadding is found
            alpha_chS2A(nsv,:) = ones(L_pathsS2A(nsv), Samplestot);
            alpha_chG2A = ones(L_pathsG2A, Samplestot);
        else
            %GENERATE THE S2A CHANNEL at chip rate; keep it constant over 1 chip.
            [alpha_chS2A(nsv,:)] = Fct_Gen_Nakagamich_Galileo(ParamSim.Fs, ParamGNSS.CarrierFrequencyGNSS_Hz(gnssband), ...
                abs(ParamChannel.Speed_GNSS_SV_kmh-ParamChannel.Speed_aircraft_kmh), Samplestot, ...
                av_powers_dBS2A(nsv), ParamChannel.Correl_typeS2A, ParamChannel.Rho_correlS2A, ParamChannel.Alpha_correlS2A,...
                ParamChannel.Type_chS2A, ParamChannel.Rice_exp1S2A);  
            if nsv == 1
                 %GENERATE THE G2A CHANNEL too, also at chip rate; keep it constant
                 %over 1 chip for reduced complexity; this one is
                 %the same for all NSV
                 [alpha_chG2A] = Fct_Gen_Nakagamich_Galileo(ParamSim.Fs, ParamJam.JammerCarrierFreq_Hz(gnssband), ...
                    abs(ParamChannel.Speed_aircraft_kmh-ParamChannel.Speed_jammer_kmh), Samplestot, ...
                      av_powers_dBG2A, ParamChannel.Correl_typeG2A, ParamChannel.Rho_correlG2A, ParamChannel.Alpha_correlG2A,...
                    ParamChannel.Type_ch_jammerG2A, ParamChannel.Rice_exp1_jammerG2A);
            end %end nsv == 1
        end %end if static_channel_true == 1
    end %end nsv

    %% Output allocation
    channel.L_pathsG2A      = L_pathsG2A;
    channel.DelG2A          = delG2A;
    channel.Av_powers_dBA2G = av_powers_dBG2A;
    channel.Alpha_chG2A     = alpha_chG2A;
    channel.L_pathsS2A      = L_pathsS2A;
    channel.DelS2A          = delS2A;
    channel.Av_powers_dBS2A = av_powers_dBS2A;
    channel.Alpha_chS2A     = alpha_chS2A;
    
%% Sort parameters alphabetically
channel = orderfields(channel);