function [allTTspikeRates,allTTmaxAmp,allTTspikeWidth,TTnum,unitNums,TTdepth,TTdepthFromOrg,TrackNum,RefChan,allEvokedMS,RecordingNum,allUnitSpikeTimes,allUnitNum,filterEntrain] = makeUnitFigures5(unit_struct,TTL_struct,ERPstruct,runParams)
    
close all
plotIndividRaster = false;
plotIndividTT = false;
findEvoked = true;
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
timeDiff = diff(TTL_struct.timestamps)/10^6;
baselineStartEvs = find(timeDiff > runParams.minBaselineMS/10^3);
baselineOffsetWinds = [];
baselineRecInd = [];
activeOffsetWinds = [];
activeRecInd = [];

totalDur = zeros(3,1);
if length(recNumsFromEV)>1
    recNumInds = nan(length(recNumsFromEV),2);
    totalDur(1) = 0;
    for ri = 1:length(recNumsFromEV)
        thisRN = recNumsFromEV{ri};
        recNumInds(ri,1) = find(cell2mat(cellfun(@(x) strcmp(x,thisRN),TTL_struct.recording_number,'UniformOutput',0)),1,'first');
        recNumInds(ri,2) = find(cell2mat(cellfun(@(x) strcmp(x,thisRN),TTL_struct.recording_number,'UniformOutput',0)),1,'last');
        totalDur(1) = totalDur(1) + (TTL_struct.timestamps(recNumInds(ri,2))-TTL_struct.timestamps(recNumInds(ri,1)))/(10^6);
        thisRecBaselineStartEvs = baselineStartEvs(ismember(baselineStartEvs,recNumInds(ri,1):recNumInds(ri,2)));
        
        if any(thisRecBaselineStartEvs)
           for bsi = 1:length(thisRecBaselineStartEvs)
               totalDur(2) = totalDur(2) + (TTL_struct.timestamps(thisRecBaselineStartEvs(bsi)+1) - TTL_struct.timestamps(thisRecBaselineStartEvs(bsi)))/10^6;
               baselineOffsetWinds = vertcat([baselineOffsetWinds,TTL_struct.timestamps(thisRecBaselineStartEvs(bsi))-TTL_struct.timestamps(recNumInds(ri,1)),TTL_struct.timestamps(thisRecBaselineStartEvs(bsi)+1)-TTL_struct.timestamps(recNumInds(ri,1))]);
               baselineRecInd = vertcat(baselineRecInd,repmat(ri,[length(thisRecBaselineStartEvs),1]));
           end
        end
        
        stimVect = strcmp(TTL_struct.recording_number,thisRN)&TTL_struct.ttls == runParams.PSTH.targetTTL;
        activeStartTimes = TTL_struct.timestamps(stimVect);
        endStimVect = false(size(stimVect));
        if max(find(stimVect)) <= length(TTL_struct.ttls)-1
            stimInds=find(stimVect);
            endStimVect(stimInds(1:end-1)+2)=true;
            endStimVect(end) = true;
        else
            endStimVect(stimVect+2)=true;
        end
        activeStopTimes = TTL_struct.timestamps(endStimVect);
        
        if any(activeStartTimes)
            activeWindDur = (activeStopTimes-activeStartTimes)/10^6;
            totalDur(3) = totalDur(3) + sum(activeWindDur);
            activeOffsetWinds = vertcat(activeOffsetWinds,horzcat(activeStartTimes' - TTL_struct.timestamps(recNumInds(ri,1)),activeStopTimes' - TTL_struct.timestamps(recNumInds(ri,1))));
            activeRecInd = vertcat(activeRecInd,repmat(ri,[length(activeStartTimes),1]));
        end
        
    end
    
else
    recNumInds=[1,length(TTL_struct.timestamps)];
    totalDur(1) = (TTL_struct.timestamps(end)-TTL_struct.timestamps(1))/(10^6);
    if any(baselineStartEvs)
        for bsi = 1:length(baselineStartEvs)
            totalDur(2) = totalDur(2) + (TTL_struct.timestamps(baselineStartEvs(bsi)+1) - TTL_struct.timestamps(baselineStartEvs(bsi)))/10^6;
            baselineOffsetWinds = vertcat([baselineOffsetWinds,TTL_struct.timestamps(baselineStartEvs(bsi))-TTL_struct.timestamps(1),TTL_struct.timestamps(baselineStartEvs(bsi)+1)-TTL_struct.timestamps(1)]);
            baselineRecInd = ones(length(baselineStartEvs),1);
        end
    end
    activeStartTimes = TTL_struct.timestamps(TTL_struct.ttls == runParams.PSTH.targetTTL);
    
    if any(activeStartTimes)
        
        if max(find(TTL_struct.ttls == runParams.PSTH.targetTTL))+2 <= length(TTL_struct)
            activeStopTimes = TTL_struct.timestamps(find(TTL_struct.ttls == runParams.PSTH.targetTTL)+2);
        else
            stopInds = find(TTL_struct.ttls == runParams.PSTH.targetTTL)+2;
            stopInds(end) = length(TTL_struct.timestamps);
            activeStopTimes = TTL_struct.timestamps(stopInds);
        end
        activeWindDur = (activeStopTimes-activeStartTimes)/10^6;
        totalDur(3) = totalDur(3) + sum(activeWindDur);
        activeOffsetWinds = activeStartTimes' - TTL_struct.timestamps(1);
        activeOffsetWinds(:,2) = activeStopTimes' - TTL_struct.timestamps(1);
        activeRecInd = ones(length(activeStartTimes),1);
    end
    

end

%If the events don't make sense, stop making figures.
if totalDur(1) <0
    allTTspikeRates=[];
    allTTmaxAmp=[];
    allTTspikeWidth=[];
    TTnum=[];
    unitNums=[];
    TTdepth=[];
    TTdepthFromOrg=[];
    TrackNum=[];
    RefChan = {};
    allEvokedMS = [];
    RecordingNum = [];
    allUnitSpikeTimes = [];
    allUnitBaselineTimes = [];
    allUnitNum = [];
    allUnitBaselineNum = [];
    filterEntrain = [];
    return
end
allUnitSpikeTimes = [];
allUnitBaselineTimes = [];
allUnitNum = [];
allUnitBaselineNum = [];
unitCount = 1;
filterEntrain = [];
for TTind = 1:length(unit_struct)
    thisTTunits = unique(unit_struct(TTind).CellNumbers);
    thisTTunits(thisTTunits==0)=[];
    spikeRates = nan(3,length(thisTTunits));
    maxAmplitude = nan(3,length(thisTTunits));
    spikeWidths = nan(3,length(thisTTunits));
    thisTTunitNums = nan(1,length(thisTTunits));
    maxChans = nan(3,length(thisTTunits));
    evokedMS = nan(1,length(thisTTunits));
    spikeTimeOffset = [];
    spikeTimeRecInd = [];
    goodRIunitNumbers = [];
    for ri = 1:length(recNumsFromEV)
        thisRIspikes = unit_struct(TTind).Timestamp(unit_struct(TTind).Timestamp>=(TTL_struct.timestamps(recNumInds(ri,1)))&unit_struct(TTind).Timestamp<=(TTL_struct.timestamps(recNumInds(ri,2))));
        thisRIoffset = thisRIspikes - TTL_struct.timestamps(recNumInds(ri,1));
        spikeTimeOffset = horzcat(spikeTimeOffset,thisRIoffset);
        spikeTimeRecInd = horzcat(spikeTimeRecInd,repmat(ri,1,length(thisRIoffset)));
        thisRIunitNumbers = unit_struct(TTind).CellNumbers(unit_struct(TTind).Timestamp>=(TTL_struct.timestamps(recNumInds(ri,1)))&unit_struct(TTind).Timestamp<=(TTL_struct.timestamps(recNumInds(ri,2))));
        goodRIunitNumbers = horzcat(goodRIunitNumbers,thisRIunitNumbers);
    end
    if isempty(spikeTimeOffset)
        filterEntrain=horzcat(filterEntrain,false(1,length(thisTTunits)));
        continue
    end
    %spikeTimeOffset = unit_struct(TTind).Timestamp - TTL_struct.timestamps(1);
    if any(thisTTunits)
        for unitInd = 1:length(thisTTunits)
            thisUnit = thisTTunits(unitInd);
            
            if thisUnit ~= 0
                thisUnitVect = false(3,length(goodRIunitNumbers));
                thisUnitVect(1,:) = goodRIunitNumbers == thisUnit;
                
                filterEntrain=horzcat(filterEntrain,true);
                for baselineInd = 1:size(baselineOffsetWinds,1)
                    thisBaselineRecInd = baselineRecInd(baselineInd);
                    sameRecSpikes = spikeTimeRecInd == thisBaselineRecInd;
                    if isempty(sameRecSpikes)
                        continue
                    end
                    thisBaselineSpikes = spikeTimeOffset > baselineOffsetWinds(baselineInd,1) & spikeTimeOffset < baselineOffsetWinds(baselineInd,2) & thisUnitVect(1,:) & sameRecSpikes;
                    thisUnitVect(2,:) = thisUnitVect(2,:) | thisBaselineSpikes;
                end
                for activeInd = 1:size(activeOffsetWinds,1)
                    thisActiveRecInd = activeRecInd(activeInd);
                    sameRecSpikes = spikeTimeRecInd == thisActiveRecInd;
                    if isempty(sameRecSpikes)
                        continue
                    end
                    thisActiveSpikes = spikeTimeOffset > activeOffsetWinds(activeInd,1) & spikeTimeOffset < activeOffsetWinds(activeInd,2) & thisUnitVect(1,:) & sameRecSpikes;
                    thisUnitVect(3,:) = thisUnitVect(3,:) | thisActiveSpikes;
                end
                
                trueSpikeTimes = spikeTimeOffset;
                trueBaselineTimes = baselineOffsetWinds;
                trueActiveTimes = activeOffsetWinds;
                for ri=1:length(recNumsFromEV)
                   if ri>1
                      lastRecDur = TTL_struct.timestamps(recNumInds(ri-1,2))-TTL_struct.timestamps(recNumInds(ri-1,1));
                      thisRecStart = TTL_struct.timestamps(recNumInds(ri,1));
                      timeLapse = thisRecStart - TTL_struct.timestamps(recNumInds(ri-1,2));
                      trueSpikeTimes(spikeTimeRecInd == ri) = trueSpikeTimes(spikeTimeRecInd == ri) + lastRecDur + timeLapse;
                      trueBaselineTimes(baselineRecInd == ri) = trueBaselineTimes(baselineRecInd == ri) + lastRecDur + timeLapse;
                      trueActiveTimes(activeRecInd == ri) = trueActiveTimes(activeRecInd == ri) + + lastRecDur + timeLapse;
                   end
                end
                thisUnitTimes = trueSpikeTimes(thisUnitVect(1,:));
                allUnitSpikeTimes = horzcat(allUnitSpikeTimes,thisUnitTimes);
                allUnitBaselineTimes = horzcat(allUnitBaselineTimes,trueSpikeTimes(thisUnitVect(2,:)));
                allUnitBaselineNum = horzcat(allUnitBaselineNum,repmat(unitCount,1,length(trueSpikeTimes(thisUnitVect(2,:)))));
                allUnitNum = horzcat(allUnitNum,repmat(unitCount,1,length(thisUnitTimes)));
                unitCount = unitCount + 1;
                %Make Raster Plot
                if plotIndividRaster
                    figure('position',[100 200 1000 75])
                    recordingTimeWinds = [0,TTL_struct.timestamps(end)-TTL_struct.timestamps(1)]/(10^6);
                    plot([thisUnitTimes/(10^6); thisUnitTimes/(10^6)], [0 1]', '-k','LineWidth',3)
                    hold all
                    scatter(trueBaselineTimes/(10^6),repmat(1.1,1,length(trueBaselineTimes)),100,'sk','filled')
                    hold all
                    scatter(trueActiveTimes(:,1)/(10^6),repmat(1.1,1,size(trueActiveTimes,1)),30,'sy','filled')
                    %plot([trueBaselineTimes/(10^6); trueBaselineTimes/(10^6)], [1 1.2]', 'sk','LineWidth',2)
                    xlim(recordingTimeWinds)
                    set(gca,'FontSize',24,'ytick',[])
                    %saveas(gcf,sprintf('%s/raster/TT%d_unit_%d_raster.eps',runParams.saveFigDir,TTind,thisUnit))
                    print('-painters','-tiff','-r300','-depsc2',sprintf('%s/raster/TT%d_unit_%d_raster.eps',runParams.saveFigDir,TTind,thisUnit))
                end
                unitPlotPrefix = sprintf('%s_Recording_%s_',runParams.animalID,runParams.recordingNum);
                thisTTunitNums(unitInd) = thisUnit;
                %Make the figure that shows the waveforms on the four electrodes
                %that make up a tetrode for each unit
                
                for spikeFilterInd = 1:size(thisUnitVect,1)
                    if any(thisUnitVect(spikeFilterInd,:))
                        spikeRates(spikeFilterInd,unitInd) = sum(thisUnitVect(spikeFilterInd,:))/totalDur(spikeFilterInd);
                        unitWaveforms = unit_struct(TTind).DataPoints(:,:,thisUnitVect(spikeFilterInd,:));
                        sampDurMS = (1/unit_struct(TTind).SampFreq)*(10^3);
                        waveTimeVect = (1:size(unitWaveforms,1))*sampDurMS;
                        %Get spike amplitude
                        maxAmplitude(spikeFilterInd,unitInd) = max(unitWaveforms(:));
                        %get spike widths
                        [spikeWidths(spikeFilterInd,unitInd),maxChans(spikeFilterInd,unitInd)] = getSpikeWidth(unitWaveforms,unit_struct(TTind).SampFreq);
                        
                        if  runParams.plotWaveforms
                            if size(unitWaveforms,2)>4
                                figure
                                if size(unitWaveforms,3)>1000
                                    plot(waveTimeVect,squeeze(unitWaveforms(:,maxChans(spikeFilterInd,unitInd),1:1000)),'Color',[175/255,175/255,175/255],'LineWidth',2)
                                else
                                    plot(waveTimeVect,squeeze(unitWaveforms(:,maxChans(spikeFilterInd,unitInd),:)),'Color',[175/255,175/255,175/255],'LineWidth',2)
                                end
                                hold all
                                if runParams.plotMean
                                    waveMean = squeeze(nanmean(unitWaveforms(:,maxChans(spikeFilterInd,unitInd),:),3));
                                    plot(waveTimeVect,waveMean,'Color','k','LineWidth',2)
                                    hold all
                                    if runParams.plotSTD
                                        waveSTD = nanstd(unitWaveforms(:,maxChans(spikeFilterInd,unitInd),:),[],3);
                                        plot(waveTimeVect,waveMean+waveSTD*1.96,'Color','r')
                                        plot(waveTimeVect,waveMean-waveSTD*1.96,'Color','r')
                                        plot(waveTimeVect,waveMean+waveSTD,'Color','y')
                                        plot(waveTimeVect,waveMean-waveSTD,'Color','y')
                                    end
                                end
                                set(gca,'ylim',[-100 200],'FontSize',24)
                            else
                                if plotIndividTT
                                    figure('position',[0 0 800 600])
                                    for electrodeInd = 1:size(unitWaveforms,2)
                                        subplot(2,2,electrodeInd)
                                        if size(unitWaveforms,3)>1000
                                            plot(waveTimeVect,squeeze(unitWaveforms(:,electrodeInd,1:1000)),'Color',[175/255,175/255,175/255],'LineWidth',2)
                                        else
                                            plot(waveTimeVect,squeeze(unitWaveforms(:,electrodeInd,:)),'Color',[175/255,175/255,175/255],'LineWidth',2)
                                        end
                                        hold all
                                        if runParams.plotMean
                                            waveMean = squeeze(nanmean(unitWaveforms(:,electrodeInd,:),3));
                                            plot(waveTimeVect,waveMean,'Color','k','LineWidth',2)
                                            
                                            if runParams.plotSTD
                                                waveSTD = nanstd(unitWaveforms(:,electrodeInd,:),[],3);
                                                plot(waveTimeVect,waveMean+waveSTD*1.96,'Color','r')
                                                plot(waveTimeVect,waveMean-waveSTD*1.96,'Color','r')
                                                plot(waveTimeVect,waveMean+waveSTD,'Color','y')
                                                plot(waveTimeVect,waveMean-waveSTD,'Color','y')
                                            end
                                        end
                                        set(gca,'ylim',[-100 200],'FontSize',24)
                                        %ylabel('\muV')
                                        %xlabel('ms')
                                        %title(sprintf('Electrode %d',electrodeInd))
                                    end
                                else
                                    figure
                                    if size(unitWaveforms,3)>1000
                                        plot(waveTimeVect,squeeze(unitWaveforms(:,maxChans(spikeFilterInd,unitInd),1:1000)),'Color',[175/255,175/255,175/255],'LineWidth',2)
                                    else
                                        plot(waveTimeVect,squeeze(unitWaveforms(:,maxChans(spikeFilterInd,unitInd),:)),'Color',[175/255,175/255,175/255],'LineWidth',2)
                                    end
                                    hold all
                                    if runParams.plotMean
                                        waveMean = squeeze(nanmean(unitWaveforms(:,maxChans(spikeFilterInd,unitInd),:),3));
                                        plot(waveTimeVect,waveMean,'Color','k','LineWidth',2)
                                        hold all
                                        if runParams.plotSTD
                                            waveSTD = nanstd(unitWaveforms(:,maxChans(spikeFilterInd,unitInd),:),[],3);
                                            plot(waveTimeVect,waveMean+waveSTD*1.96,'Color','r')
                                            plot(waveTimeVect,waveMean-waveSTD*1.96,'Color','r')
                                            plot(waveTimeVect,waveMean+waveSTD,'Color','y')
                                            plot(waveTimeVect,waveMean-waveSTD,'Color','y')
                                        end
                                    end
                                    set(gca,'ylim',[-100 200],'FontSize',24)
                                end
                            end
                            
                            %saveas(gcf,sprintf('%s/waveforms/TT%d_unit_%d_waveforms.eps',runParams.saveFigDir,TTind,thisUnit))
                            
                            print('-painters','-tiff','-r300','-depsc2',sprintf('%s/waveforms/%s_TT%d_unit_%d_waveforms_%s.eps',runParams.saveFigDir,unitPlotPrefix,TTind,thisUnit,runParams.spikeFilterLabels{spikeFilterInd}))
                        end
                    end
                    
                    if runParams.runAutocorr
                        autocorr = spikeAuto_KMB(spikeTimeOffset(thisUnitVect(spikeFilterInd,:))/(10^3),0);
                        autocorr = autocorr(autocorr<runParams.autoCorrDuration & autocorr > -runParams.autoCorrDuration);
                        
                        figure('position',[100 200 1000 400])
                        histogram(autocorr,runParams.autoCorrBins,'FaceColor','k','EdgeColor','none');
                        hold all
                        plot([0 0], ylim, '-k','linewidth',4)
                        
                        if max(ylim) <= 5
                            ytickint = 1;
                        elseif max(ylim) <= 10
                            ytickint = 2;
                        else
                            ytickint = 5;
                        end
                        
                        set(gca,'FontSize',24)
                        
                        %saveas(gcf,sprintf('%s/AutoCorr/TT%d_unit_%d_AutoCorr.eps',runParams.saveFigDir,TTind,thisUnit))
                        print('-painters','-tiff','-r300','-depsc2',sprintf('%s/AutoCorr/%s_TT%d_unit_%d_AutoCorr_%s.eps',runParams.saveFigDir,unitPlotPrefix,TTind,thisUnit,runParams.spikeFilterLabels{spikeFilterInd}))
                        close all
                        
                    end
                end
                %Generate the PSTH figures
                if runParams.runPSTHfigs
                    %Create the PSTH bins
                    psth_bins = -runParams.PSTH.offsetPreMS:runParams.PSTH.binSizeMS:runParams.PSTH.offsetPostMS;
                    %Get the times of the TTLs
                    targetTTLvect = TTL_struct.ttls == runParams.PSTH.targetTTL;
                    if any(targetTTLvect)
                        targetTTLtimes = TTL_struct.timestamps(targetTTLvect)/(10^3);
                        %Get the spike times for this unit
                        thisUnitSpikes = unit_struct(TTind).Timestamp(thisUnitVect(1,:))/(10^3);
                        %Find the offset between spikes and TTLs
                        spikeTTLoffsetMS = (thisUnitSpikes - targetTTLtimes');%Each column is a spike and each row is an event. Values correspond to how far each spike are from each event in milliseconds
                        %Mask the offsets to only include spikes in the desired
                        %range
                        spikeTTLoffsetMS(spikeTTLoffsetMS<-runParams.PSTH.offsetPreMS | spikeTTLoffsetMS>runParams.PSTH.offsetPostMS)=nan;
                        %If any spikes count for more than 2 events pause and
                        %figure out why this happened
                        
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %MAKE SEPARATE PSTH
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if findEvoked
                        evokedMS(unitInd) = findEvokedUnits2(spikeTTLoffsetMS,psth_bins,runParams);
                        end
                        
                       if ~isempty(ERPstruct)
                            fig = figure('position',[100 200 1000 400]);
                            set(fig,'defaultAxesColorOrder',[[0 0 0];[0 0 0]]);
                            yyaxis left
                        else
                            figure('position',[100 200 1000 400])
                        end
                        
                        histogram(spikeTTLoffsetMS,'BinEdges',psth_bins,'FaceColor','k','EdgeColor','none');
                        hold all
                        plot([0 0], ylim, '-k','linewidth',3)
%                         if ~isnan(evokedMS)
%                             plot([evokedMS evokedMS], ylim, ':r','linewidth',3)
%                         end
                        if max(ylim) <= 5
                            ytickint = 1;
                        elseif max(ylim) <= 10
                            ytickint = 2;
                        else
                            ytickint = 5;
                        end
                        set(gca,'xtick',[-runParams.PSTH.offsetPreMS:500:runParams.PSTH.offsetPostMS],'FontSize',14,'ylim',[0 max(ylim)],'ytick',[0:ytickint:max(ylim)])
                        %xl=xlabel('time (ms) since light on');
                        %yl=ylabel('spike count','FontSize',14);
                        %xl.FontSize=14;
                        if ~isempty(ERPstruct) && size(ERPstruct.ERPs,1)>length(runParams.LFP.CSCnums)
                            disp('Less ERPs than desired CSCs')
                            pause
                        end
                        
                        if runParams.PSTH.plotERPs
                            maxChanERPvect=runParams.LFP.CSCnums==maxChans(spikeFilterInd,unitInd);
                            if any(maxChanERPvect) && ~isempty(ERPstruct)
                                yyaxis right
                                plot(ERPstruct.tvect(ERPstruct.tvect>=-runParams.PSTH.offsetPreMS&ERPstruct.tvect<=runParams.PSTH.offsetPostMS),ERPstruct.ERPs(maxChanERPvect,ERPstruct.tvect>=-runParams.PSTH.offsetPreMS&ERPstruct.tvect<=runParams.PSTH.offsetPostMS),'-k','LineWidth',2)
                                %ylabel('Voltage')
                            end
                        end
                        %title(sprintf('PSTH (TTL = %d, %d Events, Bin Size = %d ms)',runParams.PSTH.targetTTL, length(targetTTLtimes), runParams.PSTH.binSizeMS))
                        %title(sprintf('PSTH for %s Unit %d (%.3f mm, %d Events)',subjName,thisUnit,runParams.DepthInfo.TT_depths(unit_struct(TTind).TTnum),length(targetTTLtimes)))
                        %Save the unit figure
                        %saveas(gcf,sprintf('%s/PSTH/TT%d_unit_%d_PSTH.eps',runParams.saveFigDir,TTind,thisUnit))
                        print('-painters','-tiff','-r300','-depsc2',sprintf('%s/PSTH/%s_TT%d_unit_%d_PSTH.eps',runParams.saveFigDir,unitPlotPrefix,unit_struct(TTind).TTnum,thisUnit))
                        
                    end
                end
                close all
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
               
            end
        end
        
        if ~exist('allTTmaxAmp','var')
            allTTspikeRates = spikeRates;
            allTTmaxAmp = maxAmplitude;
            allTTspikeWidth = spikeWidths;
            TTnum = repmat(unit_struct(TTind).TTnum,size(maxAmplitude));
            unitNums = thisTTunitNums;
            TTdepth =repmat(runParams.DepthInfo.TT_depths(unit_struct(TTind).TTnum),size(maxAmplitude));
            TTdepthFromOrg = repmat(runParams.DepthInfo.TT_depthsFromOrg(unit_struct(TTind).TTnum),size(maxAmplitude));
            TrackNum = repmat(runParams.DepthInfo.TrackNumber,size(maxAmplitude));
            RefChan = repmat(runParams.DepthInfo.RefChan,size(maxAmplitude));
            allEvokedMS = evokedMS;
            RecordingNum = repmat({runParams.recordingNum},size(maxAmplitude));
        else
            allTTspikeRates = horzcat(allTTspikeRates,spikeRates);
            allTTmaxAmp = horzcat(allTTmaxAmp,maxAmplitude);
            allTTspikeWidth = horzcat(allTTspikeWidth,spikeWidths);
            TTnum = horzcat(TTnum,repmat(unit_struct(TTind).TTnum,size(maxAmplitude)));
            unitNums = horzcat(unitNums,thisTTunitNums);
            TTdepth = horzcat(TTdepth,repmat(runParams.DepthInfo.TT_depths(unit_struct(TTind).TTnum),size(maxAmplitude)));
            TTdepthFromOrg = horzcat(TTdepthFromOrg,repmat(runParams.DepthInfo.TT_depthsFromOrg(unit_struct(TTind).TTnum),size(maxAmplitude)));
            TrackNum = horzcat(TrackNum,repmat(runParams.DepthInfo.TrackNumber,size(maxAmplitude)));
            RefChan = horzcat(RefChan,repmat(runParams.DepthInfo.RefChan,size(maxAmplitude)));
            allEvokedMS = horzcat(allEvokedMS,evokedMS);
            RecordingNum = horzcat(RecordingNum,repmat({runParams.recordingNum},size(maxAmplitude)));
        end
    end
    
end
if ~isempty(allUnitSpikeTimes)
    %Make Raster Plot
    figure('position',[100 200 1000 500])
    recordingTimeWinds = [0,TTL_struct.timestamps(end)-TTL_struct.timestamps(1)]/(10^6);
    plot([allUnitSpikeTimes/(10^6); allUnitSpikeTimes/(10^6)], [allUnitNum'-0.5,allUnitNum'+0.5]', '-k','LineWidth',3)
    hold all
    if ~isempty(trueBaselineTimes)
        scatter(trueBaselineTimes/(10^6),repmat(max(allUnitNum)+0.6,1,length(trueBaselineTimes)),100,'sk','filled')
        hold all
    end
    if ~isempty(trueActiveTimes)
        scatter(trueActiveTimes(:,1)/(10^6),repmat(max(allUnitNum)+0.6,1,size(trueActiveTimes,1)),30,'sy','filled')
    end
    %plot([trueBaselineTimes/(10^6); trueBaselineTimes/(10^6)], [1 1.2]', 'sk','LineWidth',2)
    xlim(recordingTimeWinds)
    set(gca,'FontSize',24,'ytick',[])
    %saveas(gcf,sprintf('%s/raster/TT%d_unit_%d_raster.eps',runParams.saveFigDir,TTind,thisUnit))
    print('-painters','-tiff','-r300','-depsc2',sprintf('%s/raster/all_unit_raster.eps',runParams.saveFigDir))
    
    if plotIndividTT
        for spikeFilterInd = 1:size(allTTspikeRates,1)
            if any(~isnan(allTTspikeRates(spikeFilterInd,:)))
                %Make a figure showing spike rates and spike amplitudes for all units
                figure('position',[0 0 800 1000])
                subplot(1,3,1)
                scatter(allTTspikeRates(spikeFilterInd,:),-TTnum(spikeFilterInd,:),100,'xk')
                set(gca,'xscale','log','ylim',[-8 -1],'xlim',[0 max(allTTspikeRates(spikeFilterInd,:))]*1.1)
                xlabel('Firing Rate (Hz)')
                ylabel('Tetrode')
                subplot(1,3,2)
                scatter(allTTmaxAmp(spikeFilterInd,:),-TTnum(spikeFilterInd,:),100,'xk')
                set(gca,'ylim',[-8 -1],'xlim',[0 max(allTTmaxAmp(spikeFilterInd,:))*1.1])
                xlabel('Spike Amplitude (\muV)')
                ylabel('Tetrode')
                subplot(1,3,3)
                scatter(allTTspikeWidth(spikeFilterInd,:),-TTnum(spikeFilterInd,:),100,'xk')
                set(gca,'ylim',[-8 -1],'xlim',[0 max(allTTspikeWidth(spikeFilterInd,:))*1.1])
                xlabel('Spike Width')
                ylabel('Tetrode')
                sgtitle(sprintf('%s Recording %s',subjName,recNum))
                %saveas(gcf,sprintf('%s/rate_amp/allRateAmp.png',runParams.saveFigDir))
                print('-painters','-tiff','-r300','-depsc2',sprintf('%s/rate_amp/allRateAmp_%s.png',runParams.saveFigDir,runParams.spikeFilterLabels{spikeFilterInd}))
            end
        end
    end
else

    allTTspikeRates=[];
    allTTmaxAmp=[];
    allTTspikeWidth=[];
    TTnum=[];
    unitNums=[];
    TTdepth=[];
    TTdepthFromOrg=[];
    TrackNum=[];
    RefChan = {};
    allEvokedMS = [];
    RecordingNum = [];
    allUnitSpikeTimes = [];
    allUnitNum = [];
end
if ~isempty(allUnitBaselineTimes)
    plotRaster(allUnitBaselineTimes/((10^6)*60),allUnitBaselineNum)
    print('-painters','-tiff','-r300','-depsc2',sprintf('%s/raster/AllUnitRaster.eps',runParams.saveFigDir))
end