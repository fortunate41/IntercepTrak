function Threshold = Fct_SetThreshold(detType, CNR, cnr,CNR_dBHz_Vec, gnssband, LoadThreshold_true)

if LoadThreshold_true==1
    
    load('Threshold.mat', 'Threshold')
    if strcmp(gnssband,'L1CA')==1
        Threshold=Threshold(1,find(CNR_dBHz_Vec(cnr)==CNR_dBHz_Vec),detType);
    elseif strcmp(gnssband,'L5')==1
        Threshold=Threshold(2,find(CNR_dBHz_Vec(cnr)==CNR_dBHz_Vec),detType);
    elseif strcmp(gnssband,'E1OS')==1
        Threshold=Threshold(3,find(CNR_dBHz_Vec(cnr)==CNR_dBHz_Vec),detType);
    end
            
else
    switch detType
        case 1 %TPD
            %Curve Fitting (myFit = fit(10.^(CNR_dBHz_Vec/10).',squeeze(mean(Teststat(:,1,:,1,1,2))),'power2');)
            %Original coeficients Simulated Data: a=1.022982693334929e+07, b=-1, c=0.9976.
            %%Original coeficients In-lab Data: a=1.022967894625893e+06, b=-1, c=0.9993
            if strcmp(gnssband,'L1CA')==1
                a     = 1.023026522242312e+07;
                b     = -1;
                c     = 1.0043;
                stdev = 0.4475;
            elseif strcmp(gnssband,'L5')==1
                a     = 1.023020469804799e+07;
                b     = -1;
                c     = 1.0016;
                stdev = 0.4541;
            elseif strcmp(gnssband,'E1OS')==1
                a     = 4.092021387109476e+07;
                b     = -1;
                c     = 1.0055;
                stdev = 0.4980;
            end

            x = 10^(CNR/10);
            Threshold = a*x^b+c;
            Threshold = Threshold+1*stdev;

        case 2 %FPD
            %Curve Fitting 
            %Original coeficients Simulated Data: a=1.046492488380593e+13, b=-1, c=1.018045515835103e+06
            %Original coeficients In-lab Data: a=2.045969849777610e+12, b=-1, c=1.966420956590438e+06
            if strcmp(gnssband,'L1CA')==1
                a     = 1.046995257534290e+12;
                b     = -1;
                c     = 1.085112806163567e+05;
                stdev = 4.361844053974921e+05;
            elseif strcmp(gnssband,'L5')==1
                a     = 1.046216425740308e+12;
                b     = -1;
                c     = 1.004959314791783e+05;
                stdev = 4.734610297560198e+05;
            elseif strcmp(gnssband,'E1OS')==1
                a     = 1.674480820473676e+13;
                b     = -1;
                c     = 4.163814030134178e+05;
                stdev = 1.772195059724313e+06;
            end

            x = 10^(CNR/10);
            Threshold = a*x^b+c;
            Threshold = Threshold+1*stdev;
            
        case 3 %AGC
            %Curve Fitting
            %OOriginal coeficients Simulated Data: a=3201, b=-0.5005, c=0.07031
            %%Original coeficients In-lab Data: a=1035, b=-0.5044, c=0.2164
            if strcmp(gnssband,'L1CA')==1
                a     = 3216.9;
                b     = -0.5012;
                c     = 0.1403;
                stdev = 0.0189;%std for 30 dB CNR (higher std) under H0. 3*std includes 0.99 of the values of the pdf
            elseif strcmp(gnssband,'L5')==1
                a     = 3217.1;
                b     = -0.5013;
                c     = 0.1404;
                stdev = 0.0189;
            elseif strcmp(gnssband,'E1OS')==1
                a     = 6397.7;
                b     = -0.5003;
                c     = 0.0710;
                stdev = 0.018;
            end
            
            x = 10^(CNR/10);
            Threshold = a*x^b+c;
            Threshold = Threshold+1*stdev;
    end
end