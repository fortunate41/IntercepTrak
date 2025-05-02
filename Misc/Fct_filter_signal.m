function [rx_fading_fin] = Fct_filter_signal(rx_fading_input, All_parameters, txBOC_Ns)
         
%% Variables allocation 
N_BOC_vec         = All_parameters.N_BOC_vec;
ChipRate_Hz       = All_parameters.ChipRate_Hz;
filt_type         = All_parameters.Filt_type;
filter_parameters = All_parameters.Filter_parameters;
B_T               = All_parameters.B_T;
Ns                = All_parameters.Ns;
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Add a filter (if bandwidth limited signals) %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[rx_fading_fin,Hz,ht,Rcorr_filt,PSD_sim,delay_filter,filter_order,fax] = Fct_filtered_sign_refcodeforIIR(...
    rx_fading_input, filt_type, filter_parameters, N_BOC_vec, ...
    ChipRate_Hz/1e6, B_T, Ns, 'passband', txBOC_Ns);      

fsampling_MHz = ChipRate_Hz/1e6*Ns*prod(N_BOC_vec);%Sampling rate in MHz



          