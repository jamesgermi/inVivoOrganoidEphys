function [allSpikeInfo,propEvoked] = makeSummarySpikeFigures(allSpikeInfo,runParams)
individFigures=true;
asiFields = fields(allSpikeInfo);
for fi = 2:length(asiFields)
    if strcmp(asiFields{fi},'badUnitVect') || iscell(eval(sprintf('allSpikeInfo.%s',asiFields{fi})))
        continue
    else
    eval(sprintf('allSpikeInfo.%s(:,%s)=nan',asiFields{fi},'allSpikeInfo.badUnitVect'))
    end
end

for spikeFilterInd = 2
    spikeDepths = unique(allSpikeInfo.depthFromOrg(spikeFilterInd,:));
    unitsByDepth = nan(1,length(spikeDepths));
    for di = 1:length(spikeDepths)
        thisDepth = spikeDepths(di);
        unitsByDepth(di) = sum(allSpikeInfo.depthFromOrg(spikeFilterInd,:)==thisDepth&~isnan(allSpikeInfo.rate(spikeFilterInd,:)));
    end
    
    close all
    figure('position',[0 0 900 400])
    subplot(1,4,1)
    barh(fliplr(1:length(spikeDepths(~isnan(spikeDepths)))),fliplr(unitsByDepth(~isnan(spikeDepths))))
    set(gca,'ytick',1:length(spikeDepths(~isnan(spikeDepths))),'yticklabel',(spikeDepths(~isnan(spikeDepths))))
    ylabel('Distance Above Bottom of Organoid (mm)')
    xlabel('Number of Units')
    
    trackNums = cell2mat(cellfun(@str2num,allSpikeInfo.trackNum(spikeFilterInd,:),'un',0));
    unTracks=unique(trackNums);
    trackPlotColors = jet(length(unTracks));
    unitColors = nan(length(trackNums),3);
    for trI=1:length(unTracks)
        unitColors(trackNums == unTracks(trI),:) = repmat(trackPlotColors(trI,:),[sum(trackNums == unTracks(trI)),1]);
    end
    
    subplot(1,4,2)
    scatter(allSpikeInfo.rate(spikeFilterInd,:),allSpikeInfo.depthFromOrg(spikeFilterInd,:),60,unitColors,'o','filled')
    set(gca,'xscale','log','xlim',[0 100])
    xlabel('Firing Rate (Hz)')
    ylabel('Distance Above Bottom of Organoid (mm)')
    
    
    subplot(1,4,3)
    scatter(allSpikeInfo.width(spikeFilterInd,:),allSpikeInfo.depthFromOrg(spikeFilterInd,:),60,unitColors,'o','filled')
    xlabel('Spike Width')
    ylabel('Tetrode')
    
    subplot(1,4,4)
    scatter(allSpikeInfo.amp(spikeFilterInd,:),allSpikeInfo.depthFromOrg(spikeFilterInd,:),60,unitColors,'o','filled')
    xlabel('Spike Amplitude (\muV)')
    ylabel('Tetrode')
    
    colormap(jet)
    cb=colorbar;
    cb.Position = [.95 .11 .0102 .8150];
    caxis([0 length(unTracks)])
    cb.Ticks = 0:length(unTracks);
    cb.TickLabels = horzcat(' ',num2cell(unTracks));
    set(get(cb,'label'),'string','Track Number');
    
    sgtitle(strrep(sprintf('%s',runParams.animalID),'_',' '))
    summaryFigSaveDir = strsplit(runParams.saveFigDir,'/');
    summaryFigSaveDir = fullfile('/',summaryFigSaveDir{1:end-1},'summaryFigs');
    
    
    if ~exist(summaryFigSaveDir,'dir')
        mkdir(summaryFigSaveDir)
    end
    saveas(gcf,sprintf('/%s/unitSummary_%s.png',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
    close all
    
    figure
    histogram(allSpikeInfo.evokedMS,20)
    ylabel('Number of units')
    xlabel('latency (ms)')
    title(sprintf('Latency to Evoked Activity for %s (%d/%d units)\nBaseline %d to %d. z-score Threshold %.2f',strrep(runParams.animalID,'_',' '),sum(~isnan(allSpikeInfo.evokedMS)),length((allSpikeInfo.evokedMS)),runParams.evokedBaseline(1),runParams.evokedBaseline(2),runParams.evokedZscore))
    saveas(gcf,sprintf('/%s/evokedUnits_%s.png',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
    close all
    
    evokedUnits = allSpikeInfo.evokedMS;
    evokedVect = ~isnan(evokedUnits)&allSpikeInfo.numEOI>10;
    clear evokedUnits
    evokedUnits.unitNum = allSpikeInfo.unitNum(evokedVect);
    evokedUnits.Recording = allSpikeInfo.RecordingNum(spikeFilterInd,evokedVect);
    evokedUnits.TT = allSpikeInfo.ttNums(spikeFilterInd,evokedVect);
    evokedUnits.rate = allSpikeInfo.rate(spikeFilterInd,evokedVect);
    evokedUnits.depth = allSpikeInfo.depth(spikeFilterInd,evokedVect);
    evokedUnits.amp = allSpikeInfo.amp(spikeFilterInd,evokedVect);
    evokedUnits.RefChan = allSpikeInfo.RefChan(spikeFilterInd,evokedVect);
    evokedUnits.evokedMS = allSpikeInfo.evokedMS(evokedVect);
    save(fullfile(summaryFigSaveDir,'evokedUnits.mat'),'evokedUnits')
    thisSubjTracks = unique(allSpikeInfo.trackNum(spikeFilterInd,:));
    for ti = 1:length(thisSubjTracks)
        thisT = cell2mat(thisSubjTracks(ti));
        thisTrackVect=cell2mat(allSpikeInfo.trackNum(spikeFilterInd,:))==thisT;
        thisTrackDepths = allSpikeInfo.depthFromOrg(spikeFilterInd,thisTrackVect);
        thisTrackRecNums = allSpikeInfo.RecordingNum(spikeFilterInd,thisTrackVect);
        thisTrackRef = allSpikeInfo.RefChan(spikeFilterInd,thisTrackVect);
        recInds = nan(1,length(thisTrackRecNums));
        uniqueRecs = unique(thisTrackRecNums);
        for ri = 1:length(uniqueRecs)
            thisRec = uniqueRecs{ri};
            recInds(cellfun(@(x) strcmp(x,thisRec),thisTrackRecNums))=ri;
        end
        
        screwRecs = strcmp(thisTrackRef,'Screw');
        
        figure
        scatter(recInds(screwRecs),thisTrackDepths(screwRecs),'k','filled')
        hold all
        scatter(recInds(~screwRecs),thisTrackDepths(~screwRecs),'xr')
        xlim([0,length(uniqueRecs)+1])
        set(gca,'xtick',[1:length(uniqueRecs)],'xticklabel',cellfun(@(x) strrep(x,'_',' '),uniqueRecs,'UniformOutput',false))
        xlabel('Recording')
        ylabel('Distance Above Bottom of Organoid (mm)')
        title(sprintf('%s Units for Track %s',strrep(runParams.animalID,'_',' '),thisT))
        saveas(gcf,sprintf('/%s/Track_%s_units_by_depth_%s.png',summaryFigSaveDir,thisT,runParams.spikeFilterLabels{spikeFilterInd}))
        close all
    end
    if individFigures
        makeIndividualSingleAnimalSummaryFigures
    else
        makeGrantFigsScratch2
    end
    propEvoked = [sum(evokedVect),sum(allSpikeInfo.numEOI>10&~isnan(allSpikeInfo.unitNum))];
end
