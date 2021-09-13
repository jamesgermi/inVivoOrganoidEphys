function [allTTspikeRates,allTTmaxAmp,allTTspikeWidth,TTnum,unitNums,TTdepth,TTdepthFromOrg,TrackNum,RefChan,allEvokedMS,RecordingNum] = makeUnitFigures3(unit_struct,TTL_struct,ERPstruct,runParams)
close all
%Make a folder to save the figures
if ~exist(runParams.saveFigDir,'dir')
    mkdir(runParams.saveFigDir)
end
if ~exist(fullfile(runParams.saveFigDir,'AutoCorr'),'dir')
    mkdir(fullfile(runParams.saveFigDir,'waveforms'))
    mkdir(fullfile(runParams.saveFigDir,'raster'))
    mkdir(fullfile(runParams.saveFigDir,'rate_amp'))
    mkdir(fullfile(runParams.saveFigDir,'PSTH'))
    mkdir(fullfile(runParams.saveFigDir,'AutoCorr'))
end

% if length(TTL_struct.timestamps)==2
%     allTTspikeRates=[];
%     allTTmaxAmp=[];
%     allTTspikeWidth=[];
%     TTnum=[];
%     unitNums=[];
%     TTdepth=[];
%     TrackNum=[];
%     RefChan = {};
%     allEvokedMS = [];
%     RecordingNum = [];
%     return
% end

%Get the subject number and recording number to title figures
% subjRec = strsplit(runParams.saveFigDir,'/');
% subjRec = strsplit(subjRec{end},'_');
% subjName = strjoin(subjRec(1:end-1),'_');
% recNum = subjRec{end};
subjName=strrep(runParams.animalID,'_',' ');
recNum = strrep(runParams.recordingNum,'_',' ');
% 
% % %Make the raster plots across the session
% % figure('position',[0 0 1000 1000])
% % for TTindRaster = 1:length(unit_struct)
% %     spikeTimeOffset = unit_struct(TTindRaster).Timestamp - TTL_struct.timestamps(1);
% %     subplot(ceil(length(unit_struct)/2),2,TTindRaster)
% %     scatter(spikeTimeOffset/(10^6),unit_struct(TTindRaster).CellNumbers,'.k')
% %     title(sprintf('TT %d',TTindRaster))
% %     xlabel('Time (s)')
% %     ylabel('Unit')
% % end
% sgtitle(sprintf('%s Recording %s',subjName,recNum))
% saveas(gcf,sprintf('%s/raster/allTTraster.png',runParams.saveFigDir))
% close all

clear('allTTmaxAmp','allTTspikeRates')
%To get recording duration, find if there are multiple recordings
recNumsFromEV = unique(TTL_struct.recording_number);

baselineEvBounds = [];
baselinePeriodInd = 1;
nonZeroTTLs = find(TTL_struct.ttls~=0);
ttlInd = 1;
for baselineBlock = 1:length(TTL_struct.ttls)
    if TTL_struct.ttls(ttlInd) == 0
        nextNonZeroTTL = min(nonZeroTTLs(nonZeroTTLs>ttlInd));
        if (TTL_struct.timestamps(nextNonZeroTTL)-TTL_struct.timestamps(ttlInd))/10^6 > runParams.minBaselineMS/10^3
           baselineEvBounds(baselinePeriodInd,1) = ttlInd;
           baselineEvBounds(baselinePeriodInd,2) = nextNonZeroTTL;
        end
        ttlInd = nextNonZeroTTL+1;
    else
        ttlInd = ttlInd + 1;
    end
end

baselineOffsetWinds = [];
activeOffsetWinds = [];
