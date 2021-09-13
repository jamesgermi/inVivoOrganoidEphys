function [allTTspikeRates,allTTmaxAmp,allTTspikeWidth,TTnum,unitNums,TTdepth,TrackNum,RefChan,allEvokedMS,RecordingNum] = makeUnitFigures2(unit_struct,TTL_struct,CSC_struct,runParams)

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
baselineStartEvs = find(timeDiff > runParams.minBaselineSec);

baselineEvents = [];
baselineOffsetWinds = [];
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
               baselineEvents = vertcat(baselineEvents,[thisRecBaselineStartEvs(bsi),thisRecBaselineStartEvs(bsi)+1]);
               baselineOffsetWinds = vertcat([baselineOffsetWinds,TTL_struct.timestamps(thisRecBaselineStartEvs(bsi))-TTL_struct.timestamps(recNumInds(ri,1)),TTL_struct.timestamps(thisRecBaselineStartEvs(bsi)+1)-TTL_struct.timestamps(recNumInds(ri,1))]);
           end
           
        end
    end
else
    totalDur(1) = (TTL_struct.timestamps(end)-TTL_struct.timestamps(1))/(10^6);
    if any(baselineStartEvs)
        for bsi = 1:length(baselineStartEvs)
            totalDur(2) = totalDur(2) + (TTL_struct.timestamps(baselineStartEvs(bsi)+1) - TTL_struct.timestamps(baselineStartEvs(bsi)))/10^6;
            baselineEvents = vertcat(baselineEvents,[baselineStartEvs(bsi),baselineStartEvs(bsi)+1]);
            baselineOffsetWinds = vertcat([baselineOffsetWinds,TTL_struct.timestamps(baselineStartEvs(bsi))-TTL_struct.timestamps(1),TTL_struct.timestamps(baselineStartEvs(bsi)+1)-TTL_struct.timestamps(1)]);
        end
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
    TrackNum=[];
    RefChan = {};
    allEvokedMS = [];
    RecordingNum = [];
    return
end
for TTind = 1:length(unit_struct)
    thisTTunits = unique(unit_struct(TTind).CellNumbers);
    spikeRates = nan(3,length(thisTTunits));
    maxAmplitude = nan(3,length(thisTTunits));
    spikeWidths = nan(3,length(thisTTunits));
    thisTTunitNums = nan(1,length(thisTTunits));
    maxChans = nan(1,length(thisTTunits));
    evokedMS = nan(1,length(thisTTunits));
    spikeTimeOffset = unit_struct(TTind).Timestamp - TTL_struct.timestamps(1);
    if any(thisTTunits)
        for unitInd = 1:length(thisTTunits)
            thisUnit = thisTTunits(unitInd);
            
            if thisUnit ~= 0
                thisUnitVect = repmat(unit_struct(TTind).CellNumbers == thisUnit,3,1);
                
                thisUnitTimes = spikeTimeOffset(thisUnitVect(1,:));
                thisUnitVect(2,:) = false(size(thisUnitTimes));
                for baselineInd = 1:size(baselineOffsetWinds,1)
                    thisBaselineSpikes = thisUnitTimes > baselineOffsetWinds(baselineInd,1) & thisUnitTimes < baselineOffsetWinds(baselineInd,2);
                    thisUnitVect(2,:) = thisUnitVect(2,:) | thisBaselineSpikes;
                end
                spikeRates(2,unitInd) = sum(thisUnitVect(2,:))/baselineDur;
                %Make Raster Plot
                figure('position',[100 200 1000 75])
                recordingTimeWinds = [0,TTL_struct.timestamps(end)-TTL_struct.timestamps(1)]/(10^6);
                plot([thisUnitTimes/(10^6); thisUnitTimes/(10^6)], [0 1]', '-k','LineWidth',3)
                xlim(recordingTimeWinds)
                set(gca,'FontSize',24,'ytick',[])
                %saveas(gcf,sprintf('%s/raster/TT%d_unit_%d_raster.eps',runParams.saveFigDir,TTind,thisUnit))
                print('-painters','-tiff','-r300','-depsc2',sprintf('%s/raster/TT%d_unit_%d_raster.eps',runParams.saveFigDir,TTind,thisUnit))
                thisTTunitNums(unitInd) = thisUnit;
                %Make the figure that shows the waveforms on the four electrodes
                %that make up a tetrode for each unit
                numSpikes = sum(thisUnitVect(1,:));
                spikeRates(1,unitInd) = numSpikes/totalDur(1);
                unitWaveforms = unit_struct(TTind).DataPoints(:,:,thisUnitVect);
                sampDurMS = (1/unit_struct(TTind).SampFreq)*(10^3);
                waveTimeVect = (1:size(unitWaveforms,1))*sampDurMS;
                numFigs = runParams.runUnitFigs + runParams.runAutocorr + runParams.runPSTHfigs;
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
                    set(gca,'ylim',[-150 150],'FontSize',24)
                    %ylabel('\muV')
                    %xlabel('ms')
                    %title(sprintf('Electrode %d',electrodeInd))
                end
                %saveas(gcf,sprintf('%s/waveforms/TT%d_unit_%d_waveforms.eps',runParams.saveFigDir,TTind,thisUnit))
                print('-painters','-tiff','-r300','-depsc2',sprintf('%s/waveforms/TT%d_unit_%d_waveforms2.eps',runParams.saveFigDir,TTind,thisUnit))
                if runParams.runAutocorr
                    autocorr = spikeAuto_KMB(spikeTimeOffset(thisUnitVect)/(10^3),0);
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
                    print('-painters','-tiff','-r300','-depsc2',sprintf('%s/AutoCorr/TT%d_unit_%d_AutoCorr.eps',runParams.saveFigDir,TTind,thisUnit))
                    close all
                    
                end
                
                %Generate the PSTH figures
                if runParams.runPSTHfigs
                    %Create the PSTH bins
                    psth_bins = -runParams.PSTH.offsetPreMS:runParams.PSTH.binSizeMS:runParams.PSTH.offsetPostMS;
                    %Get the times of the TTLs
                    targetTTLvect = TTL_struct.ttls == runParams.PSTH.targetTTL;
                    targetTTLtimes = TTL_struct.timestamps(targetTTLvect)/(10^3);
                    %Get the spike times for this unit
                    thisUnitSpikes = unit_struct(TTind).Timestamp(thisUnitVect)/(10^3);
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
                figure('position',[100 200 1000 400])
                histogram(spikeTTLoffsetMS,'BinEdges',psth_bins,'FaceColor','k','EdgeColor','none');
                hold all
                plot([0 0], ylim, '-k','linewidth',4)
                
                if max(ylim) <= 5
                    ytickint = 1;
                elseif max(ylim) <= 10
                    ytickint = 2;
                else
                    ytickint = 5;
                end
                
                set(gca,'xtick',[-runParams.PSTH.offsetPreMS:500:runParams.PSTH.offsetPostMS],'FontSize',24,'ylim',[0 max(ylim)],'ytick',[0:ytickint:max(ylim)])
                %xl=xlabel('time (ms) since light on');
                %yl=ylabel('spike count','FontSize',20);
                %xl.FontSize=20;
                
                %title(sprintf('PSTH (TTL = %d, %d Events, Bin Size = %d ms)',runParams.PSTH.targetTTL, length(targetTTLtimes), runParams.PSTH.binSizeMS))
                %title(sprintf('PSTH for %s Unit %d (%.3f mm)',subjName,thisUnit,runParams.DepthInfo.TT_depths(TTind)))
                %Save the unit figure
                %saveas(gcf,sprintf('%s/PSTH/TT%d_unit_%d_PSTH.eps',runParams.saveFigDir,TTind,thisUnit))
                print('-painters','-tiff','-r300','-depsc2',sprintf('%s/PSTH/TT%d_unit_%d_PSTH.eps',runParams.saveFigDir,TTind,thisUnit))
                   
                end
                close all
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %Get spike amplitude
                maxAmplitude(unitInd) = max(unitWaveforms(:));
                %get spike widths
                [spikeWidths(unitInd),maxChans(unitInd)] = getSpikeWidth(unitWaveforms,unit_struct(TTind).SampFreq);
                
            end
        end
        
        if ~exist('allTTmaxAmp','var')
            allTTspikeRates = spikeRates;
            allTTmaxAmp = maxAmplitude;
            allTTspikeWidth = spikeWidths;
            TTnum = repmat(TTind,size(maxAmplitude));
            unitNums = thisTTunitNums;
            TTdepth =repmat(runParams.DepthInfo.TT_depths(TTind),size(maxAmplitude));
            TrackNum = repmat(runParams.DepthInfo.TrackNumber,size(maxAmplitude));
            RefChan = repmat(runParams.DepthInfo.RefChan,size(maxAmplitude));
            allEvokedMS = evokedMS;
            RecordingNum = repmat({runParams.recordingNum},size(maxAmplitude));
        else
            allTTspikeRates = horzcat(allTTspikeRates,spikeRates);
            allTTmaxAmp = horzcat(allTTmaxAmp,maxAmplitude);
            allTTspikeWidth = horzcat(allTTspikeWidth,spikeWidths);
            TTnum = horzcat(TTnum,repmat(TTind,size(maxAmplitude)));
            unitNums = horzcat(unitNums,thisTTunitNums);
            TTdepth = horzcat(TTdepth,repmat(runParams.DepthInfo.TT_depths(TTind),size(maxAmplitude)));
            TrackNum = horzcat(TrackNum,repmat(runParams.DepthInfo.TrackNumber,size(maxAmplitude)));
            RefChan = horzcat(RefChan,repmat(runParams.DepthInfo.RefChan,size(maxAmplitude)));
            allEvokedMS = horzcat(allEvokedMS,evokedMS);
            RecordingNum = horzcat(RecordingNum,repmat({runParams.recordingNum},size(maxAmplitude)));
        end
    end
    
end

%Make a figure showing spike rates and spike amplitudes for all units
figure('position',[0 0 800 1000])
subplot(1,3,1)
scatter(allTTspikeRates,-TTnum,100,'xk')
set(gca,'xscale','log','ylim',[-8 -1],'xlim',[0 max(allTTspikeRates)]*1.1)
xlabel('Firing Rate (Hz)')
ylabel('Tetrode')
subplot(1,3,2)
scatter(allTTmaxAmp,-TTnum,100,'xk')
set(gca,'ylim',[-8 -1],'xlim',[0 max(allTTmaxAmp)*1.1])
xlabel('Spike Amplitude (\muV)')
ylabel('Tetrode')
subplot(1,3,3)
scatter(allTTspikeWidth,-TTnum,100,'xk')
set(gca,'ylim',[-8 -1],'xlim',[0 max(allTTspikeWidth)*1.1])
xlabel('Spike Width')
ylabel('Tetrode')
sgtitle(sprintf('%s Recording %s',subjName,recNum))
%saveas(gcf,sprintf('%s/rate_amp/allRateAmp.png',runParams.saveFigDir))
print('-painters','-tiff','-r300','-depsc2',sprintf('%s/rate_amp/allRateAmp.png',runParams.saveFigDir))