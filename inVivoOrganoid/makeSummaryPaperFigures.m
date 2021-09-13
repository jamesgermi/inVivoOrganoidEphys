close all
%numUnits = cell2mat(cellfun(@(x) sum(~isnan(x)),{allAnimalInfo.unitNum},'UniformOutput',false));
numUnits=[];
%for spikeFilterInd = 1:size(allSpikeInfo.rate,1)
grpAnimals = horzcat(ones(1,length(numUnits)-1),2);
for spikeFilterInd = 2
    %     figure('position',[0 0 300 500])
    %     boxplot(numUnits,grpAnimals,'Color','k')
    %     set(findobj(gca,'type','line'),'linew',2)
    %     hold all
    %     scatter(grpAnimals,numUnits,100,'k','filled')
    %     yorig=ylim;
    %     ylim([-0.1 yorig(2)])
    %     set(gca,'FontSize',24,'xtick',[])
    %     saveas(gcf,fullfile(acrossSubjFigDir,'numUnitsAllAnimals.eps'))
    allRates = {allAnimalInfo.rate};
    allDepths = {allAnimalInfo.depthFromOrg};
    for animInd = 1:length(allRates)
        thisAnimalRates = allRates{1,animalInd};
        thisAnimalDepths = allDepths{1,animalInd};
        numUnits(animalInd) = sum(~isnan(thisAnimalRates(spikeFilterInd,:))&thisAnimalDepths(spikeFilterInd,:)>=0);
    end
    numUnits =cell2mat((cellfun(@(x) sum(~isnan(x(spikeFilterInd,:))),allRates,'UniformOutput',false)));
    figure('position',[0 0 600 500])
    boxplot(numUnits,postTransplTimes,'Color','k')
    set(findobj(gca,'type','line'),'linew',2)
    hold all
    scatter(postTransplTimes,numUnits,'k','filled')
    ylim([0,max(numUnits)+5])
    %ylabel('Number of Units')
    %xlabel('Months post-transplant')
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

    aaiFields = fields(allAnimalInfo);
    for fi2 = 2:4
        
        plotOrders = [1 3 4 5 2 6];
        plotNames = {'1M-1','1M-2','2M-1','2M-2','2M-3','Naive'};
        plotVals = [];
        eval(sprintf('plotValsOG={allAnimalInfo.%s};',aaiFields{fi2}))
        for ai=1:length(plotValsOG)
            thisApv = plotValsOG{ai};
            thisAsr = allAnimalInfo(ai).rate(spikeFilterInd,:);
            thisAsd = allAnimalInfo(ai).depthFromOrg(spikeFilterInd,:);
            if ~isempty(thisApv(spikeFilterInd,thisAsr>0.1 & thisAsd>0))
            plotVals{end+1} = thisApv(spikeFilterInd,thisAsr>0.1 & thisAsd>0);
            else
                plotOrders(plotOrders>plotOrders(ai))=plotOrders(plotOrders>plotOrders(ai))-1;
                plotOrders(ai)=[];
                for ai2=ai+1:length(plotNames)
                plotNames{ai2-1}=plotNames{ai2};
                end
                plotNames{end} = [];
            end
        end
        plotGroups=[];
        plotGroupLabels = {};
        
        for ai = 1:length(plotVals)
             plotGroups = [plotGroups;ones(length(plotVals{ai}),1)*plotOrders(ai)];
        end
        plotVals = [plotVals{:}];
        plotGroups(isnan(plotVals))=[];
        plotVals(isnan(plotVals))=[];
        figure('position',[0 0 700 500])
        boxplot(plotVals,plotGroups,'Color','k')
        set(findobj(gca,'type','line'),'linew',2)
        hold all
        scatter(plotGroups,plotVals,40,'k','filled')
        
        if fi2==2
            ylim([0 20])
            set(gca,'FontSize',24,'yscale','log','xticklabel',plotNames ,'ytick',[0.01 0.1 1 10],'yticklabel',{'0.01','0.1','1','10'},'YMinorTick','off')
        elseif fi2== 3
            set(gca,'xticklabel',plotNames ,'FontSize',24)
            ylim([15 200])
        else
            set(gca,'xticklabel',plotNames,'FontSize',24)
            ylim([0.1 0.35])
        end
        saveas(gcf,fullfile(acrossSubjFigDir,sprintf('%sAllAnimals_%s.eps',aaiFields{fi2},runParams.spikeFilterLabels{spikeFilterInd})))
    end
    
    
    evokedUnitCount = [0, 11; 0, 2;12, 43;0, 1;11, 15];
    evokedUnitPercent = evokedUnitCount(:,1)./evokedUnitCount(:,2);
    figure('position',[0 0 300 500])
    boxplot(evokedUnitPercent,'Color','k')
    set(findobj(gca,'type','line'),'linew',2)
    hold all
    scatterXpos=ones(1,length(evokedUnitPercent));
    scatterXpos(1) = .95;scatterXpos(4) = 1.05;
    scatter(scatterXpos,evokedUnitPercent,100,'k','filled')
    yorig=ylim;
    ylim([-0.1 0.8])
    set(gca,'FontSize',24,'xtick',[])
    saveas(gcf,fullfile(acrossSubjFigDir,sprintf('evokedUnitsAllAnimals_%s.eps',runParams.spikeFilterLabels{spikeFilterInd})))
end

OSIs(cellfun(@(x) isempty(x),OSIs))=[];
numUnits = cellfun(@(x) length(x),OSIs);
numUnits(numUnits==0)=[];
OSIgrp = [];
for ai = 1:length(OSIs)
    OSIgrp = vertcat(OSIgrp,repmat(ai,numUnits(ai),1));
end
animalNames = {'2M-2','N1'};
OSIvals = [OSIs{:}];
figure('position',[0 0 350 500])
boxplot(OSIvals,OSIgrp,'Color','k')
set(findobj(gca,'type','line'),'linew',2)
hold all
scatter(OSIgrp,OSIvals,'k','filled')
ylim([0,1])
%ylabel('OSI')
%xlabel('Animal')
unAs = unique(OSIgrp);
nByA = nan(length(unAs),1);
clear xticklabelStr
for ai = 1:length(unAs)
    nByA(ai) = sum(OSIgrp==ai);
    xticklabelStr{ai} = sprintf('%s (n=%d)',animalNames{ai},nByA(ai));
end
xticklabels(xticklabelStr)
set(gca,'FontSize',24)
%saveas(gcf,fullfile(acrossSubjFigDir,'numUnitsByMo.png'))
print('-painters','-tiff','-r300','-depsc2',fullfile(acrossSubjFigDir,'OSI_by_animal.eps'))

DSIvals = [DSIs{:}];
figure('position',[0 0 350 500])
OSIgrp(OSIgrp==3)=1;
OSIgrp(OSIgrp==6)=2;
boxplot(DSIvals,OSIgrp,'Color','k')
set(findobj(gca,'type','line'),'linew',2)
hold all
scatter(OSIgrp,DSIvals,'k','filled')
ylim([0,1])
%ylabel('OSI')
%xlabel('Animal')
unAs = unique(OSIgrp);
nByA = nan(length(unAs),1);
clear xticklabelStr
for ai = 1:length(unAs)
    nByA(ai) = sum(OSIgrp==ai);
    xticklabelStr{ai} = sprintf('%s (n=%d)',animalNames{ai},nByA(ai));
end
xticklabels(xticklabelStr)
set(gca,'FontSize',24)
print('-painters','-tiff','-r300','-depsc2',fullfile(acrossSubjFigDir,'DSI_by_animal.eps'))