dataFold = '/Volumes/SynoData/CHEN LAB/Forebrain_OrganoidTx/2M_FB2.0_R01-1279_DG7/2019-02-22_13-08-56';
subFolds = dir(dataFold);
subFolds = {subFolds([subFolds.isdir]&cellfun(@(x) contains(x,'Recording_'),{subFolds.name})).name}';
recStamps = nan(length(subFolds),2);
for foldInd = 1:length(subFolds)
   try 
    [timestamps,~,~] = getTTLs(fullfile(dataFold,subFolds{foldInd},'Events.nev'));
    recStamps(foldInd,1) = timestamps(1)/(10^6);
    recStamps(foldInd,2) = timestamps(end)/(10^6);
   end
end