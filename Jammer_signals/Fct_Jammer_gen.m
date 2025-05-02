function Interf_sign_withch = Fct_Jammer_gen(ParamJam, ParamChannel, ParamSim, Channel, jJSR, jam_type, gnssband)

%% Jammer parameters init
jam_param = Fct_jammer_param_init_rand(jam_type,  ParamChannel.Max_Doppler_G2A, gnssband);
%% Generates jammer, adds channel and applyies specific JSR
[Interf_sign_withch] = Fct_jammer_withch(ParamJam, ParamSim, ParamChannel, Channel, jam_param, jJSR, jam_type, gnssband);
