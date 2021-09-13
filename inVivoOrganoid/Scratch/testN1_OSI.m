TTLlabels = {'FlashOff','0','45','90','135','180','225','270','315','FlashSess','FlashOn','DriftSess','TrialStart'};
cluster3stamps = dv_Shank1.units(1).stamps;
numSpikes = nan(length(EV_Timestamps),1);
for evInd = 1:length(EV_Timestamps)-2
   thisEVtime = EV_Timestamps(evInd);
   nextEVtime = EV_Timestamps(evInd)+30*10^6;
   thisEVspikes = cluster3stamps > thisEVtime & cluster3stamps < nextEVtime;
   numSpikes(evInd) = sum(thisEVspikes);
end

diffTTLs = unique(EV_TTLs);
for TTLind = 1:length(diffTTLs)
   thisTTL = diffTTLs(TTLind);
   thisTTLvect = EV_TTLs == thisTTL;
   spikesByTTL{TTLind} = numSpikes(thisTTLvect);
end