function makePSTHfigs(unit_struct,CSC_struct,TTL_struct,targetTTL,offsetPre,offsetPost,PSTHbinSize,bipolarRef,LFPbinSize,saveFigDir)

%Make a folder to save the figures
if ~exist(saveFigDir,'dir')
    mkdir(saveFigDir)
end
if ~exist(fullfile(saveFigDir,'psth'),'dir')
    mkdir(fullfile(saveFigDir,'psth'))
end

%Get the subject number and recording number to title figures
subjRec = strsplit(saveFigDir,'/');
subjRec = strsplit(subjRec{end},'_');
subjName = strjoin(subjRec(1:end-1),'_');
recNum = subjRec{end};

for TTind = 1:length(unit_struct)
    thisTTunits = unique(unit_struct(TTind).CellNumbers);
    
    for unitInd = 1:length(thisTTunits)
        thisUnit = thisTTunits(unitInd);
        thisUnitVect = unit_struct(TTind).CellNumbers == thisUnit;
        %Make the PSTH for each unit
        targetTTL_times = TTL_struct.timestamps(TTL_struct.ttls==targetTTL);
        thisUnitTimes = unit_struct(TTind).Timestamp(thisUnitVect);
        spikeTTLoffset = (thisUnitTimes' - targetTTL_times)/(10^6);
        psthMask = spikeTTLoffset > -offsetPre & spikeTTLoffset < offsetPost;
        if any(sum(psthMask,2))>1
            pause
        end
        spikeTTLoffset(~psthMask)=nan;
        spikeTTLoffset = max(spikeTTLoffset,[],1);
        psth_bins = -offsetPre:PSTHbinSize:offsetPost;
        
        figure('position',[ 0 0 800 200])
        if ~isempty(CSC_struct)
            yyaxis left
        end
        histogram(spikeTTLoffset,'BinEdges',psth_bins)
        xlabel('time rel to TTL (s)')
        set(gca,'xtick',[-offsetPre:PSTHbinSize*10:offsetPost])
        ylabel('spike count')
        if ~isempty(CSC_struct)
            thisTTchans = (TTind-1)*4+1:(TTind-1)*4+4;
            if ~isempty(bipolarRef)
                csc_samps = CSC_struct.Samples(thisTTchans,:)-repmat(CSC_struct.Samples(bipolarRef,:),[length(thisTTchans),1]);
            else
                csc_samps = CSC_struct.Samples(thisTTchans,:);
            end
            [LFPbyEv,ERP,plotBins] = getEventLFPs(CSC_struct.Timestamps(thisTTchans,:),csc_samps,targetTTL_times,offsetPre,offsetPost,LFPbinSize);
            yyaxis right
            plot(plotBins,ERP,'-k')
            ylabel('voltage')
        end
        title(sprintf('%s Recording %s TT%d Unit %d PSTH\nBin Size = %d ms',subjName,recNum,TTind,unitInd,PSTHbinSize*1000))
        saveas(gcf,sprintf('%s/psth/TT%d_unit_%d_psth.png',saveFigDir,TTind,thisUnit))
        close all
    end
end
end


function [LFPbyEv,ERP,plotBins] = getEventLFPs(CSC_timestamps,CSC_samples,targetTTL_times,offsetPre,offsetPost,LFPbinSize)
if size(unique(CSC_timestamps,'rows'),1)>1
    pause
end
LFP_TTL_offset = (CSC_timestamps(1,:)' - targetTTL_times)/(10^6);
LFP_mask = LFP_TTL_offset > -offsetPre & LFP_TTL_offset < offsetPost;
if any(sum(LFP_mask,2))>1
    pause
end
LFP_TTL_offset(~LFP_mask)=nan;
LFPbins = -offsetPre:LFPbinSize:offsetPost;
LFPbyEv = nan(4,size(LFP_TTL_offset,2),length(LFPbins)-1);
for evInd = 1:size(LFP_TTL_offset,2)
   thisEvOffset = LFP_TTL_offset(:,evInd);
   for binInd = 1:length(LFPbins)-1
      thisBinMask = thisEvOffset >= LFPbins(binInd) & thisEvOffset < LFPbins(binInd+1);
      LFPbyEv(:,evInd,binInd) = nanmean(CSC_samples(:,thisBinMask),2);
   end
end
ERP = squeeze(nanmean(LFPbyEv,2));
plotBins = LFPbins(1:end-1)+ diff(LFPbins)/2;
end