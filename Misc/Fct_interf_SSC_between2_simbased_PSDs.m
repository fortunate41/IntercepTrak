function [SSC, SSC1, SSC2]=Fct_interf_SSC_between2_simbased_PSDs(PSD1, PSD2)
%%created by Simona, 13th of April 2018
%SSCC between 2 signals, having 
%the Power Spectral Densities  PSD1 and PSD2, respectively
%everything is based on simulation-based PSDs


SSC1=sum(abs(PSD1).*abs(PSD2));
%now SSC with itself used as normalization factor
%SSC2=sum(abs(PSD1).^2);
SSC2=sum(abs(PSD1));
SSC=SSC1/SSC2;    
