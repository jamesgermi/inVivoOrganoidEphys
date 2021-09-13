close all
%for spikeFilterInd = 1:size(allSpikeInfo.rate,1)
if ~exist(sprintf('/%s/unitSummary/Individual',summaryFigSaveDir),'dir')
    mkdir(sprintf('/%s/unitSummary/Individual',summaryFigSaveDir))
end
for spikeFilterInd = 2
plotLabels = false;
    figure('position',[100 100 400 700])
    %subplot(1,4,1)
    beloworg = allSpikeInfo.depthFromOrg(spikeFilterInd,:) < 0;
    %barh(fliplr(1:length(spikeDepths(~isnan(spikeDepths)))),fliplr(unitsByDepth(~isnan(spikeDepths))))
    histogram(allSpikeInfo.depthFromOrg(spikeFilterInd,~isnan(allSpikeInfo.rate(spikeFilterInd,:))&~beloworg),'BinWidth',0.05,'BinLimits',[-0.1 max(spikeDepths)+0.1],'orientation','horizontal','FaceColor','k','EdgeColor','none')
    %set(gca,'ytick',1:length(spikeDepths(~isnan(spikeDepths))),'yticklabel',(spikeDepths(~isnan(spikeDepths))))
    if plotLabels
        ylabel('Distance Above Bottom of Organoid (mm)')
        xlabel('Number of Units')
    end
    %ylim([min(spikeDepths)-0.1 0])
    ylim([-0.1 max(spikeDepths)+0.1])
    set(gca,'FontSize',18)
    print('-painters','-tiff','-r300','-depsc2',sprintf('/%s/unitSummary/Individual/%s_units_by_depth.eps',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
        
    figure('position',[100 100 400 700])
    if runParams.colorByTrack
        h=gscatter(allSpikeInfo.rate(spikeFilterInd,~beloworg),allSpikeInfo.depthFromOrg(spikeFilterInd,~beloworg),trackNums(~beloworg));
    else
        groupLabels = cell(1,length(allSpikeInfo.evokedMS));
        groupLabels(isnan(allSpikeInfo.evokedMS)) = {'Not Evoked'};
        groupLabels(~isnan(allSpikeInfo.evokedMS)) = {'Evoked'};
        h=gscatter(allSpikeInfo.rate,allSpikeInfo.depthFromOrg,groupLabels','kr');
    end
    legend off
    childHand = get(gca,'Children');
    set(childHand,'MarkerSize',40)
    set(gca,'xscale','log','xlim',[0 100])
    if plotLabels
        xlabel('Firing Rate (Hz)')
        ylabel('Distance Above Bottom of Organoid (mm)')
    end
    ylim([-0.1 max(spikeDepths)+0.1])
    set(gca,'FontSize',18)
    print('-painters','-tiff','-r300','-depsc2',sprintf('/%s/unitSummary/Individual/%s_rate_by_depth.eps',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
       
    figure('position',[100 100 400 700])
    if runParams.colorByTrack
        h=gscatter(allSpikeInfo.width(spikeFilterInd,~beloworg),allSpikeInfo.depthFromOrg(spikeFilterInd,~beloworg),trackNums(~beloworg));
    else
        h=gscatter(allSpikeInfo.width(spikeFilterInd,~beloworg),allSpikeInfo.depthFromOrg(spikeFilterInd,~beloworg),groupLabels','kr');
    end
    legend off
    
    childHand = get(gca,'Children');
    set(childHand,'MarkerSize',40)
    if plotLabels
        xlabel('Spike Width')
        ylabel('Distance Above Bottom of Organoid (mm)')
    end
    ylim([-0.1 max(spikeDepths)+0.1])
    set(gca,'FontSize',18)
    print('-painters','-tiff','-r300','-depsc2',sprintf('/%s/unitSummary/Individual/%s_width_by_depth.eps',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
       
    figure('position',[100 100 400 700])
    if runParams.colorByTrack
        h=gscatter(allSpikeInfo.amp(spikeFilterInd,~beloworg),allSpikeInfo.depthFromOrg(spikeFilterInd,~beloworg),trackNums(~beloworg));
    else
        h=gscatter(allSpikeInfo.amp(spikeFilterInd,~beloworg),allSpikeInfo.depthFromOrg(spikeFilterInd,~beloworg),groupLabels','kr');
    end
    ylim([-0.1 max(spikeDepths)+0.1])
    legend off
    childHand = get(gca,'Children');
    set(childHand,'MarkerSize',40)
    if plotLabels
        xlabel('Spike Amplitude (\muV)')
        ylabel('Distance Above Bottom of Organoid (mm)')
    end
    set(gca,'FontSize',18)
    print('-painters','-tiff','-r300','-depsc2',sprintf('/%s/unitSummary/Individual/%s_amp_by_depth.eps',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
       
    
    figure('position',[100 100 400 700])
    if runParams.colorByTrack
        gscatter(zeros(1,length(unTracks)),zeros(1,length(unTracks)),unTracks)
    else
        h=gscatter(zeros(1,length(unique(groupLabels))),zeros(1,length(unique(groupLabels))),unique(groupLabels)','kr');
    end
    
    ylim([1 2])
    childHand = get(gca,'Children');
    set(childHand,'MarkerSize',40)
    axis off
    set(gca,'FontSize',18)
    hleg = get(gca,'legend');
    if runParams.colorByTrack
        htitle = get(hleg,'Title');
        set(htitle,'String','Track Number')
    end
print('-painters','-tiff','-r300','-depsc2',sprintf('/%s/unitSummary/Individual/%s_labels.eps',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
       
end