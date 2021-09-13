function [OSIs,DSIs] = calcOS(runParams,TTL_struct,unit_struct,allSpikeInfo)
figFormat = 5;
if ~exist(runParams.saveFigDir,'dir')
    mkdir(runParams.saveFigDir)
end
if ~exist(fullfile(runParams.saveFigDir,'OSI'),'dir')
    mkdir(fullfile(runParams.saveFigDir,'OSI'))
end
if ~exist(fullfile(runParams.saveFigDir,'OSI_mean'),'dir')
    mkdir(fullfile(runParams.saveFigDir,'OSI_mean'))
end
if ~exist(fullfile(runParams.saveFigDir,'OSI2'),'dir')
    mkdir(fullfile(runParams.saveFigDir,'OSI2'))
end
if ~exist(fullfile(runParams.saveFigDir,'DSI'),'dir')
    mkdir(fullfile(runParams.saveFigDir,'DSI'))
end
gratingTimes = [];
gratingAngs= [];
for gratingOrient = 1:8
    gratingTimes = vertcat(gratingTimes,TTL_struct.timestamps(TTL_struct.ttls==gratingOrient)');
    gratingAngs = vertcat(gratingAngs,repmat(str2double(runParams.TTL_legend{gratingOrient+1}),sum(TTL_struct.ttls==gratingOrient),1));
end
gratingTimes(:,2) = gratingTimes(:,1) + runParams.driftingDur;
OSIs=[];
DSIs = [];
unitCount = 0;
for TTind = 1:length(unit_struct)
   if ~isempty(unit_struct(TTind).CellNumbers) && any(unit_struct(TTind).CellNumbers~=0)
      thisTTunits =  unique(unit_struct(TTind).CellNumbers);
      thisTTunits(thisTTunits==0) = [];
      for unitInd = 1:length(thisTTunits)
         unitCount = unitCount + 1;
          thisUnit = thisTTunits(unitInd);
         thisUnitVect = unit_struct(TTind).CellNumbers==thisUnit;
         thisUnitTimes = unit_struct(TTind).Timestamp(thisUnitVect);
         spikeOffsetByEv = [];
         for evInd = 1:size(gratingTimes,1)
            spikeOffsetByEv{evInd} = (thisUnitTimes(thisUnitTimes>gratingTimes(evInd,1) & thisUnitTimes<gratingTimes(evInd,2)) - gratingTimes(evInd,1))/10^6;
         end
         numSpikesByEv = sum(thisUnitTimes>gratingTimes(:,1) & thisUnitTimes<gratingTimes(:,2),2);
         
         unAngs = unique(gratingAngs);
         thisUnitMeanSpikesByDir = nan(8,1);
         scatterXvals = nan(size(gratingAngs));
         for angInd = 1:length(unAngs)
             thisAng = unAngs(angInd);
             thisUnitMeanSpikesByDir(angInd) = mean(numSpikesByEv(gratingAngs==thisAng));
             scatterXvals(gratingAngs==thisAng)=angInd;
         end
         
         
         [prefDirMeanSpikes,indexPrefDir] = max(thisUnitMeanSpikesByDir);
%          orthoPosInd = mod(indexPrefDir+2,8);
%          if orthoPosInd == 0
%              orthoPosInd = 8;
%          end
         nullInd = mod(indexPrefDir+4,8);
         if nullInd == 0
             nullInd = 8;
         end
%          orthoNegInd = mod(indexPrefDir+6,8);
%          if orthoNegInd == 0
%              orthoNegInd = 8;
%          end
         %orthoPosMeanSpikes = thisUnitMeanSpikesByDir(orthoPosInd);
         nullMeanSpikes = thisUnitMeanSpikesByDir(nullInd);
         %orthoNegMeanSpikes = thisUnitMeanSpikesByDir(orthoNegInd);
         DSIs(unitCount) = (prefDirMeanSpikes - nullMeanSpikes)/(prefDirMeanSpikes + nullMeanSpikes);
        
         
         thisUnitMeanSpikesByOr = nan(4,1);
         for orInd = 1:4
            thisAng = unAngs(orInd);
            thisUnitMeanSpikesByOr(orInd) = mean(numSpikesByEv(gratingAngs==thisAng|gratingAngs==thisAng+180));
         end
         [prefOrMeanSpikes,indexPrefOr] = max(thisUnitMeanSpikesByOr);
         orthoInd = mod(indexPrefOr+2,4);
         if orthoInd == 0
             orthoInd = 4;
         end
         orthoMeanSpikes = thisUnitMeanSpikesByOr(orthoInd);
         
         %OSIs(unitCount) = ((prefNumSpikes - nullMeanSpikes) - (orthoPosMeanSpikes + orthoNegMeanSpikes)) / (prefNumSpikes + nullMeanSpikes);
         OSIs(unitCount) = (prefOrMeanSpikes - orthoMeanSpikes)/(prefOrMeanSpikes+orthoMeanSpikes);
         %OSIs(unitCount) = (prefMeanSpikes - orthoPosMeanSpikes)/(prefMeanSpikes+orthoPosMeanSpikes);
         if figFormat == 1
             figure
             polarscatter(deg2rad(gratingAngs),numSpikesByEv,100,'k','Filled')
             title(sprintf('%s Recording %s Tetrode %d Unit %d (n=%d, OSI = %.2f, DSI = %.2f)',strrep(runParams.animalID,'_',' '),strrep(runParams.recordingNum,'_',' '),TTind,thisUnit,length(numSpikesByEv)/8,OSIs(unitCount),DSIs(unitCount)))
             set(gca,'FontSize',12)
             print('-painters','-tiff','-r300','-depsc2',sprintf('%s/OSI/TT%d_unit_%d_spikes_by_angle.eps',runParams.saveFigDir,TTind,thisUnit))
             close all
         elseif figFormat == 2
             figure('position',[0 0 400 500])
             angMeans = nan(1,length(unAngs));
             angSTDs = nan(1,length(unAngs));
             for angInd = 1:length(unAngs)
                 thisAngVals = numSpikesByEv(gratingAngs==unAngs(angInd))/90;
                 angMeans(angInd) = nanmean(thisAngVals);
                 angSTDs(angInd) = std(thisAngVals);
             end
             scatter(angMeans,unAngs,40,'k','filled')
             hold all
             errorbar(angMeans,unAngs,angSTDs','horizontal','LineStyle','none','color','k','LineWidth',2)
             set(gca,'FontSize',14)
             ylim([-10,325])
             xlabel('Firing Rate (Hz)')
             ylabel('Grating Orientation')
%              
%              figure('position',[100 400 1000 500])
%              recordingTimeWinds = [0,TTL_struct.timestamps(end)-TTL_struct.timestamps(1)]/(10^6);
%              plot([allSpikeInfo.allUnitSpikeTimes/(10^6); allSpikeInfo.allUnitSpikeTimes/(10^6)], [allSpikeInfo.allUnitNums'-0.5,allSpikeInfo.allUnitNums'+0.5]', '-k','LineWidth',3)
%              xlim(recordingTimeWinds)
%              set(gca,'FontSize',24,'ytick',[])
%              %saveas(gcf,sprintf('%s/raster/TT%d_unit_%d_raster.eps',runParams.saveFigDir,TTind,thisUnit))
             %print('-painters','-tiff','-r300','-depsc2',sprintf('%s/raster/all_unit_raster.eps',runParams.saveFigDir))
             
         elseif figFormat == 3
             figure('position',[0 0 700 500])
             boxplot(numSpikesByEv,gratingAngs,'Color','k')
             set(findobj(gca,'type','line'),'linew',2)
             hold on
             scatter(scatterXvals,numSpikesByEv,40,'k','filled')
             set(gca,'FontSize',14)
         elseif figFormat == 4
             figure
             uniqueAngs = unique(gratingAngs);
             for angInd = 1:length(uniqueAngs)
                 thisAngVals = numSpikesByEv(gratingAngs==uniqueAngs(angInd));
                 thisAngMean = nanmean(thisAngVals);
                 thisAngSTD = std(thisAngVals);
                 
                 if thisAngMean - thisAngSTD<0
                     polarplot(repmat(deg2rad(uniqueAngs(angInd)),1,2),[0,thisAngMean+thisAngSTD],'-r','LineWidth',3)
                 else
                     polarplot(repmat(deg2rad(uniqueAngs(angInd)),1,2),[thisAngMean-thisAngSTD,thisAngMean+thisAngSTD],'-r','LineWidth',3)
                 end
                 hold all
                 polarscatter(deg2rad(uniqueAngs(angInd)),thisAngMean,100,'k','filled')
                 hold all
             end
             title(sprintf('%s Recording %s Tetrode %d Unit %d (n=%d, OSI = %.2f, DSI = %.2f)',strrep(runParams.animalID,'_',' '),strrep(runParams.recordingNum,'_',' '),TTind,thisUnit,length(numSpikesByEv)/8,OSIs(unitCount),DSIs(unitCount)))
             set(gca,'FontSize',12)
             print('-painters','-tiff','-r300','-depsc2',sprintf('%s/OSI_mean/TT%d_unit_%d_spikes_by_angle.eps',runParams.saveFigDir,TTind,thisUnit))
             close all
             
             
             close all
         elseif figFormat == 5
             figure
             uniqueAngs = unique(gratingAngs);
             angMeans = nan(length(uniqueAngs),1);
             angSTD = nan(length(uniqueAngs),1);
             angUL = nan(length(uniqueAngs),2);
             for angInd = 1:length(uniqueAngs)
                 thisAngVals = numSpikesByEv(gratingAngs==uniqueAngs(angInd));
                 angMeans(angInd) = nanmean(thisAngVals);
                 angSTD(angInd) = std(thisAngVals);
                 angUL(angInd,2)=angMeans(angInd)+angSTD(angInd);
                 if angMeans(angInd)-angSTD(angInd)<0
                     angUL(angInd,1)=0;
                 else
                     angUL(angInd,1)=angMeans(angInd)-angSTD(angInd);
                 end
                 polarscatter(deg2rad(uniqueAngs(angInd)),angMeans(angInd),100,'k','filled')
                 hold all
             end
             uniqueAngs = vertcat(uniqueAngs,uniqueAngs(1));
             angMeans = vertcat(angMeans,angMeans(1));
             angUL = vertcat(angUL,angUL(1,:));
             polarplot(deg2rad(uniqueAngs),angMeans,'-k')
             hold all
             polarplot(deg2rad(uniqueAngs),angUL(:,1),'-','Color',[0.7 0.7 0.7])
             hold all
             polarplot(deg2rad(uniqueAngs),angUL(:,2),'-','Color',[0.7 0.7 0.7])
             annotation('textbox', [0.05, 0.85, 0.1, 0.1],'string',sprintf('OSI = %.2f\nDSI = %.2f',OSIs(unitCount),DSIs(unitCount)))
             %title(sprintf('%s Recording %s Tetrode %d Unit %d (n=%d, OSI = %.2f, DSI = %.2f)',strrep(runParams.animalID,'_',' '),strrep(runParams.recordingNum,'_',' '),TTind,thisUnit,length(numSpikesByEv)/8,OSIs(unitCount),DSIs(unitCount)))
             set(gca,'FontSize',12)
             print('-painters','-tiff','-r300','-depsc2',sprintf('%s/OSI2/TT%d_unit_%d_spikes_by_angle.eps',runParams.saveFigDir,TTind,thisUnit))
             close all
         end
      end
   end
end
figure
histogram(OSIs,[0:0.1:1],'FaceColor',[0.17 0.17 0.17])
xlabel('OSI')
ylabel('Number of Units')
title(sprintf('%s Orientation Selectivity',strrep(runParams.animalID,'_',' ')))
print('-painters','-tiff','-r300','-depsc2',sprintf('%s/OSI/summaryHistogram.eps',runParams.saveFigDir))
set(gca,'FontSize',18)

close all
figure
histogram(DSIs,[0:0.1:1],'FaceColor',[0.17 0.17 0.17])
xlabel('DSI')
ylabel('Number of Units')
title(sprintf('%s Direction Selectivity',strrep(runParams.animalID,'_',' ')))
print('-painters','-tiff','-r300','-depsc2',sprintf('%s/DSI/summaryHistogram.eps',runParams.saveFigDir))
set(gca,'FontSize',18)


