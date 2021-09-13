function evokedMS = findEvokedUnits(spikeTTLoffsetMS,psth_bins,runParams)
x=spikeTTLoffsetMS;
xc = mat2cell(x, ones(1,size(x,1)), size(x,2));                 % Split Matrix Into Cells By Row
[hcell,hedges] = cellfun(@(x) histcounts(x,psth_bins), xc, 'Uni',0);   % Do ‘histcounts’ On Each Column
hmtx = cell2mat(hcell);                                         % Recover Numeric Matrix From Cell Array
edges = cell2mat(hedges);
baselineNumSpikes = sum(hmtx(:,edges(1,:) >= runParams.evokedBaseline(1) & edges(1,:) <= runParams.evokedBaseline(2)),2)./sum(edges(1,:) >= runParams.evokedBaseline(1) & edges(1,:)<= runParams.evokedBaseline(2));
baselineSpikeMean = nanmean(baselineNumSpikes);
baselineSpikeSTD = nanstd(baselineNumSpikes);
if baselineSpikeMean && baselineSpikeSTD > 0
    normCounts = (hmtx - baselineSpikeMean)/baselineSpikeSTD;
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