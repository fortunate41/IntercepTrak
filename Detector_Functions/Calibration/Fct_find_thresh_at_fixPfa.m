function thresh_gamma =  Fct_find_thresh_at_fixPfa( zH0, fixed_Pfa, interpPDF_true)
%compute the required threshold and the corresponding Pd in order
%to get a fixed Pfa.
%zH1 = the decision statistic when H1:signal+noise is true (in our case:
%zH1 will be the case of signal only, i.e., jamming absent)
%zH0 = the decision statistic when 0: noise only is true  (in our case: zH0
%is the case of signal + jamming (jamming present)
%fixed_Pfa = false alarm probability fixed by the yser
%thresh_gamma = decision threshold needed to reach the fixed_Pfa
%err_pfa = error in reaching the pfa (if too large => Pd is far from the
%          true value)
%Pd = detection probability at the considered fixed_Pfa
%xaxH0 = x axis in plotting the CDF for H0 hypothesis
%cdfH0 = interpolated CDF under H0 hypothesis
%xaxH1 = x axis in plotting the CDF for H1 hypothesis
%cdfH1 = interpolated CDF under H1 hypothesis
%
%created on 6th October 2004, by Simona
%updated 13th of June 2013, Simona
%@TUT

%choose the number of bins in building pdf
bins = 100;
%build the histograms in correct and incorrect windows

temp2 = zH0(:);
[histo_incorrect, edgesH0] = histcounts(temp2, bins);
xaxH0 = edgesH0(1:end-1)+ diff(edgesH0)/2;
pdfH0 = histo_incorrect/sum(histo_incorrect);

cdfH0 = zeros(1,length(xaxH0));
for xx = 1:length(xaxH0)
    cdfH0(xx)= sum(pdfH0(1:xx));
end
    
%Interpolate PDF before compute CDF; interpolation done either in PDF or in
%CDF
%added Oct 2013
%because xaxH0 and xaxH1 are not overlapping, we interpolate in order to
%get overlapping curves
xax_min = min(xaxH0);
xax_max = max(xaxH0);
stepi = (xax_max-xax_min)/1e4; %interpolate with 10^4 points
xax_common = [xax_min:stepi:xax_max];
methodi = 'linear';

%% 
%plotting the pdfs under H0 and H1
%plot(xaxH0, pdfH0, 'b--s'); hold on; drawnow; pause(0.1); line([thresh_gamma thresh_gamma], [0 0.06], 'linewidth', 3); hold off; legend ('H0','H1', 'Threshold')
%% 

if interpPDF_true==1
    %use interpolation of PDF
    %introduce first and last points in original axes
    xaxH01 = xaxH0; 
    pdfH01 = pdfH0;
    if xaxH0(1)>xax_common(1)
      xaxH01 = [xax_common(1) xaxH0];
      pdfH01 = [0 pdfH01];
    end
    if xaxH0(end)<xax_common(end)
      xaxH01 = [xaxH01 xax_common(end)];
      pdfH01 = [pdfH01 0];
    end

    pdfH0_interp = interp1(xaxH01, pdfH01, xax_common, methodi);
    pdfH0_interp = pdfH0_interp /sum(pdfH0_interp );

%     figure; plot(xax_common, pdfH0_interp, 'b-')
%     hold on; plot(xax_common, pdfH1_interp, 'r-')
%     plot(xaxH01, pdfH01, 'b--s'); plot(xaxH11, pdfH11, 'r--s')
% 
  
    cdfH0_interp = zeros(1,length(xax_common));
    for xx = 1:length(xax_common)
        cdfH0_interp(xx) = sum(pdfH0_interp(1:xx));
    end
else
    %use interpolation on CDF
    %do the same for interpolation in CDF
    xaxH01 = xaxH0; 
    cdfH01 = cdfH0;
    if xaxH0(1)>xax_common(1)
      xaxH01 = [xax_common(1) xaxH0];
      cdfH01 = [0 cdfH01];
    end
    if xaxH0(end)<xax_common(end)
      xaxH01 = [xaxH01 xax_common(end)];
      cdfH01 = [cdfH01 1];
    end

    cdfH0_interp = interp1(xaxH01, cdfH01, xax_common, methodi);
end

%    figure; plot(xax_common, cdfH0_interp, 'b-')
%     hold on; plot(xax_common, cdfH1_interp, 'r-')
%     plot(xaxH0, cdfH0, 'b--s'); plot(xaxH1, cdfH1, 'r--s')
% %  

 [ a, min_pos] = min(abs(1-cdfH0_interp-fixed_Pfa));
 %[ ~, min_pos] = min(abs(1-pdfH0_interp-fixed_Pfa));

% temp = sort((abs(1-cdfH0_interp-fixed_Pfa)),'descend');
% temp2 = find(temp<1e-4);
% min_pos = temp2(1);

thresh_gamma = xax_common(min_pos);
%figure;plot(xaxH0, pdfH0, 'b--s'); hold on; line([thresh_gamma thresh_gamma], [0 max(pdfH0)], 'linewidth', 3);
end
 