clearvars
%%%%REMEMBER NLX IS ALWAYS IN MICROSECONDS 10e-6%%%%%%%%%
animalIDs = ...
    {'1300',...
    '1316',...
    '1280_DG6',...
    '1279_DG7',...
    '1310',...
    'N1'};
recordingNums = {...
    {'0000_0001';'0002_0003';'0004';'0005_0006';'0007_0008';'0009';'0010_0011';'0012';'0013_0014'},...
    {'0005_0006','0010'},...
    {'0003_0004','0005','0007','0008','0009','0011_0012','0016_0017','0020','0021','0022_0023','0024','0026','0028','0029','0030','0031_0032'},...
    {'0000','0001_0002','0009_0010','0011'},...
    {'0000_0001','0002_0003_0004_0005_0006_0007_0008','0010_0011','0013_0014'},...
    {'0000'}
    };
%  {'0003_0004','0005','0007','0008','0009','0011_0012','0016_0017','0020','0021','0022_0023','0024','0025','0026','0027','0028','0029','0030','0031_0032'},...
postTransplantMos = ...
    [1,...
    2,...
    2,...
    2,...
    1,...
    3];
unitLabels = {...
    'units',...
    'cells',...
    'cells_JG'...
    'cells',...
    'cells',...
    'cells'};

probeNumShanks = ...
    [1,...
    1,...
    1,...
    1,...
    1,...
    2];

runParams.loadCSCs = false;
runParams.localCSCs = true;
runParams.loadUnits = true;
runParams.onlyOSIanalysis =false;
runParams.runEntrainment =false;
runParams.runUnitFigs = true;
runParams.runAutocorr = false;
runParams.runPSTHfigs = false;
runParams.runPower = false;
runParams.runOSI = true;
runParams.labelFigs=false;
runParams.separateERPs = false;
runParams.getERPs = false;
runParams.plotWaveforms = false;

runParams.ElectrodeSpecs.numChans = 32;
runParams.ElectrodeSpecs.tip_mm = 75/(10^3);
runParams.ElectrodeSpecs.dist_mm = 25/(10^3);
runParams.ElectrodeSpecs.TT_config = [1:4;5:8;9:12;13:16;17:20;21:24;25:28;29:32];

runParams.synoRoot = '/Volumes/SynoData/CHEN LAB/Forebrain_OrganoidTx'; %Specify where on Syno the CSCs are saved
runParams.localCSCpath = '/Users/jgermi/Documents/Perelman/MTR/ChenLab/Data/inVivoOrganoid/CSCs';
runParams.depthSpreadsheet = '/Users/jgermi/Documents/Perelman/MTR/ChenLab/Data/inVivoOrganoid/Logs/RecordingDepthsWithOrg.xlsx';
%Set fixed parameters
runParams.driftingDur = 30*10^6; %duration of grating in nanoseconds
runParams.preDG = 2*10^6; %duration before grating to analyze spikes
runParams.postDG = 2*10^6; %duration before grating to analyze spikes
runParams.evokedBaseline = [-500,-0];
runParams.minEvokedMS = 50;
runParams.evokedZscore = 2.5;
runParams.numTrials = 3;
runParams.TTL_legend = {'FlashOff','0','45','90','135','180','225','270','315','FlashSess','FlashOn','DriftSess','TrialStart'};

runParams.numTTs = 16;

runParams.downsampFactor = 40;
runParams.colorByTrack = true;

%Settings for plotting unit waveforms
runParams.plotMean = true;
runParams.plotSTD = false;

%Settings for summary unit figures
runParams.spikeFilterLabels = {'Full_Session','Baseline','Active'};

%Settings for doing autocorr for units
runParams.autoCorrDuration = 100; %in ms
runParams.autoCorrBins = 100; %numBins

%Settings for LFPs
runParams.LFP.CSCnums = 1:32;
runParams.LFP.preMS = 1000;
runParams.LFP.postMS = 3000;
runParams.LFP.bufferMS = 1000;
runParams.LFP.filtFreqs = [0.1 4000];
runParams.LFP.targetTTL = 10;%set the TTL number you want to use as an event for PSTH
runParams.LFP.reref = true;
runParams.LFP.rerefBottom = true;

runParams.minBaselineMS = 60000;
runParams.minActiveMS = 30000;

%Settings for PSTH
runParams.PSTH.targetTTL = runParams.LFP.targetTTL; %set the TTL number you want to use as an event for PSTH. This defaults to same events for LFP. If changed, the LFPs won't match PSTH
runParams.PSTH.offsetPreMS = 500; %how many seconds before the event you want to analyze
runParams.PSTH.offsetPostMS = 1500; %how many seconds after the event you want to analyze
runParams.PSTH.binSizeMS = 25; %how large the bin should be in seconds
runParams.PSTH.bipolarRefChan = 9; %What number CSC to use for bipolar referencing
runParams.PSTH.LFPbinSizeMS = 10; %How big of a bin to use when plotting LFP
runParams.PSTH.plotERPs = true;

%Setting for Entrainment
%runParams.entrainment.freqs = (2.^((8:60)/8));
runParams.entrainment.freqs = [30,90];
runParams.entrainment.wave_number = 6;
%runParams.entrainment.powMethod = 'wavelet';
runParams.entrainment.powMethod = 'hilbert';
%Settings for evoked power
runParams.EvokedPower.targetTTL = runParams.PSTH.targetTTL;
runParams.EvokedPower.windowPreMS = 500; %time in seconds before target TTL to analyze
runParams.EvokedPower.windowPostMS = 500; %time in seconds after target TTL to analyze
runParams.EvokedPower.bipolarRef = runParams.PSTH.bipolarRefChan;
proportionEvoked = nan(length(animalIDs),2);
numUnits = nan(3,length(animalIDs));
postTransplTimes = nan(length(animalIDs),1);
clear allAnimalInfo

acrossSubjFigDir = fullfile('/Users/jgermi/Documents/Perelman/MTR/ChenLab/Figures/inVivoOrganoid/', datestr(now,'mmmm_dd_yyyy'),'acrossSubjFigs');
if ~exist(acrossSubjFigDir,'dir')
    mkdir(acrossSubjFigDir)
end

for animalInd = 1:length(animalIDs)
%for animalInd = 3
    clear('allSpikeInfo')
    runParams.animalID =animalIDs{animalInd};
    thisAnimalRecordingNums = recordingNums{animalInd};
    runParams.unit_label = unitLabels{animalInd};
    runParams.numShanks = probeNumShanks(animalInd);
    clear MI
    for recordingInd = 1:length(thisAnimalRecordingNums)
    %for recordingInd = 12
        runParams.recordingNum = thisAnimalRecordingNums{recordingInd};
        %dataDir = '/Volumes/SynoData/AcuteRatData/Organoid_2mo_post/2019-09';
        runParams.dataDir = sprintf('/Users/jgermi/Documents/Perelman/MTR/ChenLab/Data/inVivoOrganoid/WorkingData/%s/Recording_%s/',runParams.animalID,runParams.recordingNum);
        %Find the subject folder on synoData
        runParams.synoDir = findSynoDir(runParams);
        runParams.saveFigDir = fullfile('/Users/jgermi/Documents/Perelman/MTR/ChenLab/Figures/inVivoOrganoid/', datestr(now,'mmmm_dd_yyyy'),sprintf('%s/Recording_%s',runParams.animalID,runParams.recordingNum));
        if ~exist(runParams.saveFigDir,'dir')
            mkdir(runParams.saveFigDir)
        end
        runParams.DepthInfo = getDepthInfo(runParams);
        save(fullfile(runParams.saveFigDir,'runParams.mat'),'runParams')
        %Load the TTLs using getEventsMerged which will concatenate events
        %for recordings that were stitched together.
        TTL_struct = getEventsMerged(runParams);
        
        if strcmp(runParams.animalID,'1280_DG6')&&strcmp(runParams.recordingNum,'0031_0032')
            load(fullfile(runParams.dataDir,'Recording_0032_DG_TTLs.mat'))
            TTL_struct.ttls(strcmp(TTL_struct.recording_number,'0032')) = newTTL;
        elseif length(unique(TTL_struct.ttls))==2
            TTL_struct.ttls(TTL_struct.ttls==1) = 10;
        end
        
        numEOI = sum(TTL_struct.ttls==runParams.PSTH.targetTTL);
        if runParams.loadCSCs && any([TTL_struct.ttls]==runParams.LFP.targetTTL) && runParams.getERPs
            if runParams.localCSCs
                [ERPstruct] = getERPsLocal(runParams,TTL_struct);
            else
                [ERPstruct] = getERPs(runParams,TTL_struct);
                CSC_struct =[];
            end
        else
            CSC_struct = [];
            ERPstruct = [];
        end
        if runParams.loadUnits
            unit_struct = buildUnitStruct2(runParams);
            if runParams.runEntrainment
                entrainRvals = getEntrainment(runParams,unit_struct,TTL_struct);
            end
            if runParams.runUnitFigs && ~isempty(unit_struct)
                if ~exist('allSpikeInfo','var')
                    allSpikeInfo.animal=runParams.animalID;
                    [allSpikeInfo.rate,allSpikeInfo.amp,allSpikeInfo.width,allSpikeInfo.ttNums,allSpikeInfo.unitNum,allSpikeInfo.depth,allSpikeInfo.depthFromOrg,allSpikeInfo.trackNum,allSpikeInfo.RefChan,allSpikeInfo.evokedMS,allSpikeInfo.RecordingNum,allSpikeInfo.allUnitSpikeTimes,allSpikeInfo.allUnitNums,filterEntrain] = makeUnitFigures5(unit_struct,TTL_struct,ERPstruct,runParams);
                    allSpikeInfo.numEOI = repmat(numEOI,1,size(allSpikeInfo.rate,2));
                    if runParams.runEntrainment
                        allSpikeInfo.entrainR = entrainRvals(:,logical(filterEntrain),:);
                    end
                else
                    [temprate,tempamp,tempwidth,tempttNums,tempunitNum,tempdepth,tempdepthFromOrg,temptrackNum,tempRefChan,tempevokedMS,tempRecordingNum,tempallUnitSpikeTimes,tempallUnitNums,filterEntrain] = makeUnitFigures5(unit_struct,TTL_struct,ERPstruct,runParams);
                    tempnumEOI = repmat(numEOI,1,size(temprate,2));
                    asiFields = fields(allSpikeInfo);
                    for fi = 2:length(asiFields)-runParams.runEntrainment
                        eval(sprintf('allSpikeInfo.%s=horzcat(allSpikeInfo.%s,temp%s)',asiFields{fi},asiFields{fi},asiFields{fi}))
                    end
                    if runParams.runEntrainment && ~isempty(temprate)
                        entrainRvals=entrainRvals(:,logical(filterEntrain),:);
                        if size(entrainRvals,1)<size(allSpikeInfo.entrainR,1)
                            entrainRvals(end+1:size(allSpikeInfo.entrainR,1),:,:)=nan;
                        elseif size(entrainRvals,1)>size(allSpikeInfo.entrainR,1)  
                            tempAllSpikeInfoEntrainR = allSpikeInfo.entrainR;
                            tempAllSpikeInfoEntrainR(end+1:size(entrainRvals,1),:,:)=nan;
                            allSpikeInfo.entrainR = tempAllSpikeInfoEntrainR;
                        end
                        
                        allSpikeInfo.entrainR = cat(2,allSpikeInfo.entrainR,entrainRvals);
                    end
                end
                if runParams.runEntrainment && size(allSpikeInfo.entrainR,2)~= size(allSpikeInfo.rate,2)
                    pause
                end
%                 if runParams.runEntrainment
% %                     try
% %                         MI{recordingInd} = getEntrainment(runParams,unit_struct,TTL_struct);
% %                     catch e
% %                         disp('Issue with entrainment')
% %                     end
%                 end
            end
            
            if length(unique(TTL_struct.ttls))>6 && runParams.runOSI
                [OSIs{animalInd},DSIs{animalInd}] = calcOS(runParams,TTL_struct,unit_struct,allSpikeInfo);
            end
            
            
        end
    end
    if exist('allSpikeInfo','var') && ~isempty(allSpikeInfo)
        %Find any units that are within 0.05 mm from the same track and
        %different recordings
        diffTracks = unique(allSpikeInfo.trackNum(1,:));
        badUnitVect = false(1,length(allSpikeInfo.unitNum));
        for trackInd = 1:length(diffTracks)
            thisTrack = diffTracks{trackInd};
            thisTrackVect = strcmp(allSpikeInfo.trackNum(1,:),thisTrack);
            thisTrackRecordings = unique(allSpikeInfo.RecordingNum(1,thisTrackVect));
            if length(thisTrackRecordings)>1
                for thisTRI = 1:length(thisTrackRecordings)-1
                    thisTRvect = strcmp(allSpikeInfo.RecordingNum(1,:),thisTrackRecordings{thisTRI})&thisTrackVect;
                    thisTRdepths =  allSpikeInfo.depthFromOrg(1,thisTRvect);
                    for otherTRI = thisTRI+1:length(thisTrackRecordings)
                        otherTRvect = strcmp(allSpikeInfo.RecordingNum(1,:),thisTrackRecordings{otherTRI})&thisTrackVect;
                        otherTRdepths = allSpikeInfo.depthFromOrg(1,otherTRvect);
                        distBetwUnits = thisTRdepths - otherTRdepths';
                        tooCloseUnits = abs(distBetwUnits) < 0.05;
                        if any(tooCloseUnits(:))
                            thisTRrate = allSpikeInfo.rate(2,thisTRvect);
                            otherTRrate = allSpikeInfo.rate(2,otherTRvect);
                            if ~any(~isnan(thisTRrate))||~any(~isnan(otherTRrate))
                                continue
                            else
                                thisTRunitNums = allSpikeInfo.unitNum(thisTRvect);
                                otherTRunitNums = allSpikeInfo.unitNum(otherTRvect);
                                [otherTRduplicateUnitInds,thisTRduplicateUnitInds] = find(tooCloseUnits);
                                for duplicateInd = 1:length(thisTRduplicateUnitInds)
                                    if thisTRrate(thisTRduplicateUnitInds(duplicateInd))>otherTRrate(otherTRduplicateUnitInds(duplicateInd))
                                        thisUnitNum = thisTRunitNums(thisTRduplicateUnitInds(duplicateInd));
                                        badUnitVect = badUnitVect | thisTRvect & allSpikeInfo.unitNum == thisUnitNum;
                                    elseif thisTRrate(thisTRduplicateUnitInds(duplicateInd))<otherTRrate(otherTRduplicateUnitInds(duplicateInd))
                                        thisUnitNum = otherTRunitNums(otherTRduplicateUnitInds(duplicateInd));
                                        badUnitVect = badUnitVect | otherTRvect & allSpikeInfo.unitNum == thisUnitNum;
                                    else
                                        continue
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        allSpikeInfo.badUnitVect = badUnitVect;
        [allSpikeInfo,proportionEvoked(animalInd,:)] = makeSummarySpikeFigures(allSpikeInfo,runParams);
        beloworg = allSpikeInfo.depthFromOrg < 0;
        allSpikeInfo.rate(beloworg)=nan;
        numUnits(:,animalInd) = sum(~isnan(allSpikeInfo.rate),2);
        postTransplTimes(animalInd) = postTransplantMos(animalInd);
        allAnimalInfo(animalInd) = allSpikeInfo;
        save(fullfile(runParams.saveFigDir,'allSpikeInfo.mat'),'allSpikeInfo')
        save(fullfile(runParams.saveFigDir,'allAnimalInfo.mat'),'allAnimalInfo')
    end
    
end

percentEvoked = proportionEvoked(:,1)./proportionEvoked(:,2);

close all
figure('position',[0 0 300 400])
boxplot(percentEvoked,'Color','k')
hold all
scatter(ones(1,length(percentEvoked)),percentEvoked,'k','filled')
yorig=ylim;
ylim([-0.1 yorig(2)])
ylabel('Percent of Units')
title('Evoked (Algorithm)')
set(gca,'ytick',[0:0.1:yorig(2)],'xtick',[],'FontSize',24)
%saveas(gcf,fullfile(acrossSubjFigDir,'percEvokedAlgorithm.png'))
print('-painters','-tiff','-r300','-depsc2',fullfile(acrossSubjFigDir,'percEvokedAlgorithm.eps'))

close all
percentEvoked2=[0.000;0.000;0.74074;0.000;1;1];
plotXvals = [1;1;2;2;1;3];
plotXlabel = {'1 Month','2 Months','Naive'};
figure('position',[0 0 500 400])
boxplot(percentEvoked2,plotXvals,'Color','k')
set(findobj(gca,'type','line'),'linew',2)
hold all
scatter(plotXvals,percentEvoked2,40,'k','filled','jitter','on','jitterAmount',0.05);
yorig=ylim;
ylim([-0.1 1.1])
%ylabel('Percent of Units')
%title('Evoked Units')
set(gca,'ytick',[0:0.2:1],'xtick',[1:length(plotXvals)],'xticklabel',plotXlabel,'FontSize',24)
%saveas(gcf,fullfile(acrossSubjFigDir,'percEvokedManual.png'))
print('-painters','-tiff','-r300','-depsc2',fullfile(acrossSubjFigDir,'percEvokedManual.eps'))

figure('position',[0 0 600 400])
barLabels = categorical({'1M-1','1M-2','2M-1','2M-2','2M-3','Naive'});
b=bar(barLabels,evokedInfo,'stacked');
b(4).FaceColor = [.9 .9 .9];
b(3).FaceColor = [.6 .6 .6];
b(2).FaceColor = [.4 .4 .4];
b(1).FaceColor = [.1 .1 .1];
legend({'Evoked','Not Evoked','Low Firing Rate','Suppressed'},'Location','northwest')
set(gca,'FontSize',24)
print('-painters','-tiff','-r300','-depsc2',fullfile(acrossSubjFigDir,'evokedBarStack.eps'))

for spikeFilterInd = 1:size(allSpikeInfo.rate,1)
    figure('position',[0 0 600 500])
    boxplot(numUnits(spikeFilterInd,:),postTransplTimes,'Color','k')
    hold all
    scatter(postTransplTimes,numUnits(spikeFilterInd,:),'k','filled')
    ylim([0,max(numUnits(spikeFilterInd,:))+5])
    ylabel('Number of Units')
    xlabel('Months post-transplant')
    unMos = unique(postTransplTimes);
    nByMo = nan(length(unMos),1);
    clear xticklabelStr
    for mi = 1:length(unMos)
        nByMo(mi) = sum(postTransplTimes==unMos(mi));
        xticklabelStr{mi} = sprintf('%d mos (N=%d)',unMos(mi),nByMo(mi));
    end
    xticklabelStr{3} = 'Naive';
    xticklabels(xticklabelStr)
    set(gca,'FontSize',24)
    %saveas(gcf,fullfile(acrossSubjFigDir,'numUnitsByMo.png'))
    print('-painters','-tiff','-r300','-depsc2',fullfile(acrossSubjFigDir,sprintf('numUnitsByMo_%s.eps',runParams.spikeFilterLabels{spikeFilterInd})))
end
makeSummaryPaperFigures