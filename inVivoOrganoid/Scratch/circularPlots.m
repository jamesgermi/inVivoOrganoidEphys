thisFreqPh = squeeze(fullphase(1,5,:));
thisUnitThisFreqPh = thisFreqPh(thisUnitSamps);
[MeanAng, MeanLength] = circmean( thisUnitThisFreqPh );
figure
h=polarhistogram(thisUnitThisFreqPh,'FaceColor',uint8([25 25 25]));
set(gca,'fontsize',18)
hold all
rlimscale = rlim;
polarplot([MeanAng;MeanAng],[0,MeanLength*rlimscale(2)],'linewidth',5)
% 
% figure
% CircHist(rad2deg(thisUnitThisFreqPh))
figure(1)
polar([0 90 270; 0 90 270]*pi/180, [0 0 0; 1 1 1]*54)               % Use ‘polar’
figure(2)
polarplot([0 90 270; 0 90 270]*pi/180, [0 0 0; 1 1 1]*54)   