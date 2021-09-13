function makeVisEvokedPwrFigs(CSC_struct,TTL_struct,targetTTL,windowPre,windowPost,bipolarRef,saveFigDir)

%Make a folder to save the figures
if ~exist(saveFigDir,'dir')
    mkdir(saveFigDir)
end
if ~exist(fullfile(saveFigDir,'evoked_oscillations'),'dir')
    mkdir(fullfile(saveFigDir,'evoked_oscillations'))
end


% 
% if size(unique(CSC_struct.Timestamps,'rows'),1)>0
%     pause 
% end
targetTTL_times = (TTL_struct.timestamps(TTL_struct.ttls==targetTTL))/(10^6);
preTTL_wind = horzcat(targetTTL_times' + windowPre(1),targetTTL_times' + windowPre(2));
postTTL_wind = horzcat(targetTTL_times' + windowPost(1),targetTTL_times' + windowPost(2));

for chInd = 1:size(CSC_struct.Samples,1)
    
end