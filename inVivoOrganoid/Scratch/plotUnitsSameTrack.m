thisSubjTracks = unique(allSpikeInfo.trackNum);
for ti = 1:length(thisSubjTracks)
    thisT = cell2mat(thisSubjTracks(ti));
    thisTrackVect=cell2mat(allSpikeInfo.trackNum)==thisT;
    thisTrackDepths = allSpikeInfo.depth(thisTrackVect);
    thisTrackRecNums = allSpikeInfo.RecordingNum(thisTrackVect);
    thisTrackRef = allSpikeInfo.RefChan(thisTrackVect);
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
    ylabel('Depth (mm)')
    title(sprintf('%s Units for Track %s',strrep(runParams.animalID,'_',' '),thisT))
end