

timeOff=CSC.Timestamp(index_from)-thisUnitTimes;

thisUnitPhases = fullphase(index_from)+pi;

figure
h=polarhistogram(thisUnitPhases,18,'FaceColor',uint8([25 25 25]));
if strcmp(runParams.entrainment.powMethod,'wavelet')
    title(sprintf('%s TT %d Unit %d Recording %s %.0f Hz Entrainment (R = %.2f)',strrep(runParams.animalID,'_',' '),TTind,thisTTuniqueUnitNums(unitInd),recordingNums{recordingInd},runParams.entrainment.freqs(freqInd),entrainR(unitCount,freqInd)))
else
    title(sprintf('%s TT %d Unit %d Recording %s %.0f-%.0f Hz Entrainment (R = %.2f)',strrep(runParams.animalID,'_',' '),TTind,thisTTuniqueUnitNums(unitInd),recordingNums{recordingInd},runParams.entrainment.freqs(freqInd,1),runParams.entrainment.freqs(freqInd,2),entrainR(unitCount,freqInd)))
end
hold all
rlimscale = rlim;
polarplot([MeanAng;MeanAng],[0,entrainR(unitInd,freqInd)*rlimscale(2)],'linewidth',5)
set(gca,'fontsize',14)
