function Fct_plotting_results(ParamJam, ParamSim, ParamGNSS, Pd_CFA, Pfa_CFA, Pd_Sta, Pfa_Sta, Pd_PDFBased, CNR_estimateH0, CN0_spilker_estH0, ...
    CNR_estimateH1, CN0_spilker_estH1, CN0_effH1, TeststatH0, TeststatH1)

    %% Plots seleector
    EffectiveCNRPlot_true   = ParamSim.EffectiveCNRPlot_true;
    TestStatisticPlot_true  = ParamSim.TestStatisticPlot_true;
    PdfBasedMethod_true     = ParamSim.PdfBasedMethod_true;
    CFAMethod_true          = ParamSim.CFAMethod_true;
    StatisticalMethod_true  = ParamSim.StatisticalMethod_true;
    EstimatedCNR_true       = ParamSim.EstimatedCNR_true;

    %% Variable allocation
    Total_Iterations  = ParamSim.Nrandompoints;
    JSR_dB_Vec        = [ParamJam.JSR_dB_Vec];
    JSR_dB_Vec_lgnd   = strcat(string(JSR_dB_Vec), 'dB JSR');
    Det_type_Length   = ParamJam.Detectors_type_Length;
    JammerType_Length = ParamJam.Jammers_Length;
    GNSS_Band_Length  = length(ParamGNSS.GNSS_Band);
    CNR_dBHz_length   = ParamGNSS.CNR_dBHz_Length;
    GNSS_Band_Vec     = ParamGNSS.GNSS_Band;
    JammerType_Vec    = [ParamJam.Jam_type_Vec];
    Det_type_Vec      = [ParamJam.Det_type_Vec];
    CNR_dBHz_Vec      = [ParamGNSS.CNR_dBHz];
    JSR_dB_length     = ParamJam.JSR_dB_Length;
    
    Colorset  = {[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.4660 0.6740 0.1880]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.3010 0.7450 0.9330]; [0.6350 0.0780 0.1840];...
                    [1 0.2 0.6]; [0 0.4 0]};%Different colors
    
    Markerset = [{'+'}; {'s'}; {'o'}; {'*'}; {'^'}; {'.'}; {'x'}; {'v'}; {'>'}; {'<'}];            
                
    set(0,'defaultAxesFontSize',30)

    
    %% Built jammer for legend use
    pos=1;
    for jam_type = JammerType_Vec
        if jam_type==1
            jammerTypes{pos} = 'No jammer';
            pos=pos+1;
        elseif jam_type==2
            jammerTypes{pos} = 'AM-tone';
            pos=pos+1;
        elseif jam_type==3
            jammerTypes{pos} ='Chirp 10 MHz';
            pos=pos+1;
        elseif jam_type==4
            jammerTypes{pos} ='Chirp 20 MHz';
            pos=pos+1;
        elseif jam_type==5
            jammerTypes{pos} ='FM-tone';
            pos=pos+1;
        elseif jam_type==6
            jammerTypes{pos} ='Dual chirp';
            pos=pos+1;
        elseif jam_type==7
            jammerTypes{pos} ='Multichirp';
            pos=pos+1;
        elseif jam_type==8
            jammerTypes{pos} ='Borio chirp';
            pos=pos+1;
        elseif jam_type==9
            jammerTypes{pos} ='DME';
            pos=pos+1;
        elseif jam_type==10
            jammerTypes{pos} ='1 kHz NB noise jammer';
            pos=pos+1;
        elseif jam_type==11
            jammerTypes{pos} ='Double tone AM';
            pos=pos+1;
        elseif jam_type==12
            jammerTypes{pos} ='Double FM';
            pos=pos+1;
        elseif jam_type==13
            jammerTypes{pos} ='1 MHz NB noise jammer';
            pos=pos+1;
        end
    end

    %% Built detector for legend use
    for det_type = Det_type_Vec
        if det_type==1
            detectorTypes{det_type} = 'TPD';
        elseif det_type==2
            detectorTypes{det_type} = 'FPD';
        elseif det_type==3
            detectorTypes{det_type} = 'AGC';
        end
    end
    
    %% Built gnss for legend use
    for gnssband=1:GNSS_Band_Length
        if gnssband==1
            gnssBands{gnssband} = 'GPS L1';
        elseif gnssband==2
            gnssBands{gnssband} = 'GPS L5';
        elseif gnssband==3
            gnssBands{gnssband} = 'GAL E1';
        end
    end
            
   %% Built scenarios for legend use  
   pos=1;
   for a=1:length(gnssBands)
       for b=1:length(detectorTypes)
           Scenarios{pos} = [gnssBands{a} ' + ' jammerTypes{b}];
           pos=pos+1;
       end
   end
   
      %% Built scenarios for legend use  
    pos=1;
   for a=1:length(Scenarios)
       for b=1:2
           if mod(b,2)==0
            ScenariosPfa{pos} = [Scenarios{a} ', Pfa'];
           else
               ScenariosPfa{pos} = Scenarios{a};
           end
           pos=pos+1;
       end
   end
    
    %% Approach 1 PDF-based plot. [Pd vs JSR]
    if PdfBasedMethod_true==1
        for cnr = 1:CNR_dBHz_length
            for det_type = 1:Det_type_Length
                figure()%1 figure for each detector and all the scenarios (GNSS bands + detectors) at a certain CNR
                i=1;
                j=1;
                for gnssband=1:GNSS_Band_Length
                    for jam_type = 1:JammerType_Length
                        plot(JSR_dB_Vec, squeeze(Pd_PDFBased(gnssband, cnr, :, jam_type ,det_type)), 'color', Colorset{i}, 'marker', Markerset{j}, 'linewidth', 2, 'markersize', 12);hold on
                        ylim([-0.1 1.1])
                        ylabel('Pd')
                        xlabel('JSR (dB)')
                        %xlim([-15 10])
                        i=i+1;
                        if mod(i-1, 3)==0
                            j=j+1;
                        end
                    end
                end
                legend(Scenarios, 'fontsize', 24,'Location', 'Best')
                title(['PDF-based Results for all considered scenarios, CNR= ' num2str(CNR_dBHz_Vec(cnr)) 'dB'])
            end
        end
    end

    %% Approach 2: CFA
    if CFAMethod_true==1
        for cnr = 1:CNR_dBHz_length
            for det_type = 1:Det_type_Length
                figure()%1 figure for each detector and all the scenarios (GNSS bands + detectors) at a certain CNR
                i=1;
                j=1;
                for gnssband=1:GNSS_Band_Length
                    for jam_type = 1:JammerType_Length
                        %Pd
                        plot(JSR_dB_Vec, squeeze(Pd_CFA(1,gnssband,cnr,:,jam_type,det_type)), '-','color', Colorset{i}, 'marker', Markerset{j}, 'linewidth', 2, 'markersize', 12);hold on
                        ylabel('Pd')
                        ylim([-0.1 1.1])
                        i=i+1;
                        if mod(i-1, 3)==0
                            j=j+1;
                        end
                    end
                end
                legend(Scenarios, 'fontsize', 18,'Location', 'Best')
                title(['CFA-based Results for all considered scenarios, CNR= ' num2str(CNR_dBHz_Vec(cnr)) 'dB'])
            end
        end
    end
    
    %% Approach 3 Analytical thresholding plot. [Pd vs JSR]
    if StatisticalMethod_true==1
        for cnr = 1:CNR_dBHz_length
            for det_type = 1:Det_type_Length
                figure()%1 figure for each detector and all the scenarios (GNSS bands + detectors) at a certain CNR
                i=1;
                j=1;
                for gnssband=1:GNSS_Band_Length
                    for jam_type = 1:JammerType_Length
                        %Pd
                        plot(JSR_dB_Vec, squeeze(Pd_Sta(1,gnssband,cnr,:,jam_type,det_type)), '-','color', Colorset{i}, 'marker', Markerset{j}, 'linewidth', 2, 'markersize', 12);hold on
                        ylabel('Pd')
                        ylim([-0.1 1.1])
                        yyaxis right
                        %Pfa
                        plot(JSR_dB_Vec, ones(1,length(JSR_dB_Vec))*Pfa_Sta(1,gnssband,cnr,det_type), '--','color', Colorset{i}, 'marker', '*', 'linewidth', 2, 'markersize', 12);hold on
                        xlabel('JSR (dB)')
                        ylabel('Pfa')
                        xlabel('JSR (dB)')
                        ylim([-0.1 1.1])
                        i=i+1;
                        if mod(i-1, 3)==0
                            j=j+1;
                        end
                    end
                end
                legend(ScenariosPfa, 'fontsize', 18,'Location', 'Best')
                suptitle(['Statistical thresholding Results for all considered scenarios, CNR= ' num2str(CNR_dBHz_Vec(cnr)) 'dB'])
            end
        end
    end
    
    %%  Estimated CNR vs Real CNR
    %H0
%     if EstimatedCNR_true==1 && ~isempty(find(isnan(CNR_estimateH0)))
%         for gnssband=1:GNSS_Band_Length
%             figure()
%             plot(CNR_dBHz_Vec, squeeze(mean(CNR_estimateH0(:,gnssband,:))), 'color', Colorset{1},'LineWidth', 2);hold on
%             plot(CNR_dBHz_Vec, squeeze(mean(CN0_spilker_estH0(:,gnssband,:))), 'color', Colorset{2}, 'LineWidth', 2)
%             plot(CNR_dBHz_Vec, CNR_dBHz_Vec, 'color', Colorset{3},'LineWidth', 2)
%             legend('peak vs mean noise approach', 'Spilker approach', 'Real CNR', 'Location', 'Best')
%             xlabel('Real CNR')
%             ylabel('CNR estimate')
%             title(['Estimated CNR vs real CNR (H0 hypothesis) for ' GNSS_Band_Vec(gnssband)])
%         end
%     end
%     %H1
%     if EstimatedCNR_true==1 && ~isempty(find(isnan(CNR_estimateH1)))
%         for gnssband=1:GNSS_Band_Length
%             figure()
%             plot(CNR_dBHz_Vec, squeeze(mean(CNR_estimateH1(:,gnssband,:))), 'color', Colorset{1}, 'LineWidth', 2);hold on
%             plot(CNR_dBHz_Vec, squeeze(mean(CN0_spilker_estH1(:,gnssband,:))), 'color', Colorset{2}, 'LineWidth', 2)
%             plot(CNR_dBHz_Vec, CNR_dBHz_Vec, 'color', Colorset{3}, 'LineWidth', 2)
%             legend('peak vs mean noise approach', 'Spilker approach', 'Real CNR', 'Location', 'Best')
%             xlabel('Real CNR')
%             ylabel('CNE estimate')
%             title(['Estimated CNr vs real CNR (H1 hypothesis) for ' GNSS_Band_Vec(gnssband)])
%         end
%     end

    %% Effective CNR Plot
    if EffectiveCNRPlot_true ==1
        figure(); hold on;
        i=1;
        j=1;
        for cnr = 1:CNR_dBHz_length
            line(JSR_dB_Vec, CNR_dBHz_Vec(cnr)*ones(1,length(JSR_dB_Vec)), 'color', 'k', 'LineWidth', 2)
            for gnssband=1:GNSS_Band_Length
                for jam_type = 1:JammerType_Length
                    plot(JSR_dB_Vec, squeeze(mean(CN0_effH1(:,gnssband, cnr,:,jam_type))), 'color', Colorset{i}, 'marker', Markerset{j},  'LineWidth', 2)
                    i=i+1;
                    if mod(i-1, 3)==0
                        j=j+1;
                    end
                end
                legend([cellstr('Real CNR') Scenarios{:}], 'Location', 'Best')
                %title(string(strjoin(['Mean Effective CN0 for different JSR and jammer types for ' GNSS_Band_Vec(gnssband) ', CNR= ' num2str(CNR_dBHz_Vec(cnr)) 'dB' ])))
                xlabel('JSR (dB)'); ylabel('CN0 Eff (dB-Hz)');
            end
        end
    end
    
    %% Test statistic H0 vs H1 plot
    if TestStatisticPlot_true==1
        for gnssband=1:GNSS_Band_Length
            for cnr = 1:CNR_dBHz_length
                for jam_type = 1:JammerType_Length
                    for det_type = 1:Det_type_Length
                        figure()
                        i=2;
                        j=2;
                        plot(1:Total_Iterations, squeeze(TeststatH0(:, gnssband, cnr , det_type)), 'color', Colorset{1}, 'marker', Markerset{1}, 'LineWidth', 2);hold on
                        for jJSR=1:JSR_dB_length
                            plot(1:Total_Iterations, squeeze(TeststatH1(:, gnssband, cnr, jJSR, jam_type, det_type)), 'color', Colorset{i}, 'marker', Markerset{j}, 'LineWidth', 2)
                            ylabel('Test statistic')
                            xlabel('JSR (dB)')
                            %xlim([-20 5])
                            i=i+1;
                            if i==12
                                i=2;
                                j=j+1;
                            end
                        end  
                            legend([cellstr('No Jammer') JSR_dB_Vec_lgnd], 'Location', 'Best')
                            title(string(strjoin(['Test statistic comparison H0 vs H1 for ' GNSS_Band_Vec(gnssband) ' against ' jammerTypes(jam_type)  ', detector' detectorTypes{det_type} 'and CNR= ' num2str(CNR_dBHz_Vec(cnr)) 'dB'])), 'fontsize', 20)
                    end
                end
            end
        end
    end
end