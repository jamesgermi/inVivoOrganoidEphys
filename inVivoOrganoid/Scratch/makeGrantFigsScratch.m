close all
%for spikeFilterInd = 1:size(allSpikeInfo.rate,1)
for spikeFilterInd = 2
plotLabels = false;
    figure('position',[0 0 1920 518])
    %subplot(1,4,1)
    tiledlayout(1,5);
    nexttile
    %barh(fliplr(1:length(spikeDepths(~isnan(spikeDepths)))),fliplr(unitsByDepth(~isnan(spikeDepths))))
    histogram(allSpikeInfo.depthFromOrg(spikeFilterInd,~isnan(allSpikeInfo.rate(spikeFilterInd,:))),'BinWidth',0.05,'BinLimits',[-0.1 max(spikeDepths)+0.1],'orientation','horizontal','FaceColor','k','EdgeColor','none')
    %set(gca,'ytick',1:length(spikeDepths(~isnan(spikeDepths))),'yticklabel',(spikeDepths(~isnan(spikeDepths))))
    if plotLabels
        ylabel('Distance Above Bottom of Organoid (mm)')
        xlabel('Number of Units')
    end
    %ylim([min(spikeDepths)-0.1 0])
    ylim([-0.1 max(spikeDepths)+0.1])
    set(gca,'FontSize',18)
    
    %subplot(1,4,2)
    nexttile
    if runParams.colorByTrack
        h=gscatter(allSpikeInfo.rate(spikeFilterInd,:),allSpikeInfo.depthFromOrg(spikeFilterInd,:),trackNums);
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
    
    %subplot(1,4,3)
    nexttile
    if runParams.colorByTrack
        h=gscatter(allSpikeInfo.width(spikeFilterInd,:),allSpikeInfo.depthFromOrg(spikeFilterInd,:),trackNums);
    else
        h=gscatter(allSpikeInfo.width(spikeFilterInd,:),allSpikeInfo.depthFromOrg(spikeFilterInd,:),groupLabels','kr');
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
    
    %subplot(1,4,4)
    nexttile
    if runParams.colorByTrack
        h=gscatter(allSpikeInfo.amp(spikeFilterInd,:),allSpikeInfo.depthFromOrg(spikeFilterInd,:),trackNums);
    else
        h=gscatter(allSpikeInfo.amp(spikeFilterInd,:),allSpikeInfo.depthFromOrg(spikeFilterInd,:),groupLabels','kr');
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
    
    nexttile
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
    sgtitle(strrep(sprintf('%s',runParams.animalID),'_',' '),'FontSize',24)
    if plotLabels
        %saveas(gcf,sprintf('/%s/unitSummaryLabels_%s.eps',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
        print('-painters','-tiff','-r300','-depsc2',sprintf('/%s/unitSummaryLabels_%s.eps',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
        
    else
        saveas(gcf,sprintf('/%s/unitSummaryNoLabels_%s.eps',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
        print('-painters','-tiff','-r300','-depsc2',sprintf('/%s/unitSummaryNoLabels_%s.eps',summaryFigSaveDir,runParams.spikeFilterLabels{spikeFilterInd}))
    end
end