function evokedMS = findEvokedUnits2(spikeTTLoffsetMS,psth_bins,runParams)
optionA = false;
minSpikes = 5;
x=spikeTTLoffsetMS;
xc = mat2cell(x, ones(1,size(x,1)), size(x,2));                 % Split Matrix Into Cells By Row
[hcell,hedges] = cellfun(@(x) histcounts(x,psth_bins), xc, 'Uni',0);   % Do ‘histcounts’ On Each Column
hmtx = cell2mat(hcell);                                         % Recover Numeric Matrix From Cell Array
edges = cell2mat(hedges);
if optionA
    baselineNumSpikes = sum(hmtx(:,edges(1,:) >= runParams.evokedBaseline(1) & edges(1,:) <= runParams.evokedBaseline(2)),2)./sum(edges(1,:) >= runParams.evokedBaseline(1) & edges(1,:)<= runParams.evokedBaseline(2));
    baselineSpikeMean = nanmean(baselineNumSpikes);
    baselineSpikeSTD = nanstd(baselineNumSpikes);
else
    sizeEvokedBaseline = runParams.evokedBaseline(2) - runParams.evokedBaseline(1);
    subBaselineWindSize = sizeEvokedBaseline/10;
    newBaseline = runParams.evokedBaseline(1):subBaselineWindSize:runParams.evokedBaseline(2);
    
    for subBaselineInd = 1:length(newBaseline)-1
        baselineNumSpikes = sum(hmtx(:,edges(1,:) >= newBaseline(subBaselineInd) & edges(1,:) <= newBaseline(subBaselineInd+1)),2)./sum(edges(1,:) >= newBaseline(subBaselineInd) & edges(1,:)<= newBaseline(subBaselineInd+1));
        subBaselineSpikeMean(subBaselineInd) = nanmean(baselineNumSpikes);
        subBaselineSpikeSTD(subBaselineInd) = nanstd(baselineNumSpikes);
    end
    baselineSpikeMean = max(subBaselineSpikeMean);
    maxVect = subBaselineSpikeMean == baselineSpikeMean;
    baselineSpikeSTD = max(subBaselineSpikeSTD(maxVect));
end
if baselineSpikeMean > 0 && baselineSpikeSTD > 0
    hmtx(hmtx<minSpikes) = 0;
    if optionA
        normCounts = (hmtx - baselineSpikeMean)/baselineSpikeSTD;
    else
        normCounts = (hmtx - baselineSpikeMean*2)/baselineSpikeSTD;
    end
    sigCounts = normCounts > runParams.evokedZscore;
    if any(any(sigCounts))
        sigTimes = edges(sigCounts);
        if any(sigTimes >= runParams.minEvokedMS)
            evokedMS = min(sigTimes(sigTimes >= runParams.minEvokedMS));
        else
            evokedMS = nan;
        end
    else
       evokedMS = nan; 
    end
else
    evokedMS = nan;
end