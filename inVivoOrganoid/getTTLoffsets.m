clearvars
dataFold = '/Users/jgermi/Documents/Perelman/MTR/ChenLab/Data/inVivoOrganoid/WorkingData';

subFolds = dir(dataFold);
subFolds = {subFolds(4:end).name};
for subInd = 1:length(subFolds)
%for subInd =2
    thisSubj = subFolds{subInd};
    saveFigDir = fullfile('/Users/jgermi/Documents/Perelman/MTR/ChenLab/Figures/inVivoOrganoid/', datestr(now,'mmmm_dd_yyyy'),thisSubj,'summaryFigs');
    if ~exist(saveFigDir,'dir')
        mkdir(saveFigDir)
        mkdir(fullfile(saveFigDir,'TTL_summary'))
    elseif ~exist(fullfile(saveFigDir,'TTL_summary'),'dir')
        mkdir(fullfile(saveFigDir,'TTL_summary'))
    end
    thisSubjDir = fullfile(dataFold,thisSubj);
    [~,thisSubjFolds]=dirContents(thisSubjDir);
    recFolds = thisSubjFolds(cellfun(@(x) contains(x,'Recording_'),thisSubjFolds))';
    for foldInd = 1:length(recFolds)
        thisFold = recFolds{foldInd};
        multiRec = strsplit(thisFold,'_');
        
        for recInd = 1:length(multiRec)-1
            thisRec = multiRec{recInd+1};
            if length(multiRec)>2
                try
                    [timestamps,values,~] = getTTLs(fullfile(thisSubjDir,recFolds{foldInd},sprintf('Events_%s.nev',thisRec)));
                end
            else
                try
                    [timestamps,values,~] = getTTLs(fullfile(thisSubjDir,recFolds{foldInd},sprintf('Events.nev',thisRec)));
                end
            end
            fullSess = (timestamps - timestamps(1))/(10^6);
            
            TTL_offset = diff(timestamps)/(10^6);
            short=TTL_offset(TTL_offset>0.2&TTL_offset<0.4);
            long = TTL_offset(TTL_offset>2.15&TTL_offset<2.4);
            figure('position',[0 100 1400 600])
            subplot(2,3,[1,2,3])
            scatter(fullSess,values,'xk')
            xlabel('Time (s)')
            ylabel('TTL values')
            ylim([-0.5 max(values)+0.5])
            set(gca,'ytick',[0:max(values)],'yticklabel',{0:max(values)})
            title(sprintf('TTL times (rel to rec start) for %s Recording %s',strrep(thisSubj,'_',' '),thisRec))
            subplot(2,3,4)
            histogram(TTL_offset)
            xlabel('Time between TTLs')
            ylabel('Number of TTLs')
            title('All TTLs')
            subplot(2,3,5)
            histogram(short)
            xlabel('Time between TTLs')
            ylabel('Number of TTLs')
            title('TTLs between 0.2 and 0.4 s')
            subplot(2,3,6)
            histogram(long)
            xlabel('Time between TTLs')
            ylabel('Number of TTLs')
            title('TTLs between 2.15 and 2.4 s')
            saveas(gcf,sprintf('%s/TTL_summary/Recording_%s_TTLs.png',saveFigDir,thisRec))
            close all
        end
        
    end
end