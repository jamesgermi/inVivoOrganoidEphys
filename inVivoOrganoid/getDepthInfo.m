function DepthInfo = getDepthInfo(runParams)

[~,~,SpreadsheetContents] = xlsread(runParams.depthSpreadsheet);
SpreadsheetContents = SpreadsheetContents(2:end,:);
DepthAnimal = SpreadsheetContents(:,1);
thisAnimalDepthVect = cellfun(@(x) strcmp(x,runParams.animalID),DepthAnimal);
thisRecNum = strsplit(runParams.recordingNum,'_');
thisRecVect = cellfun(@(x) ismember(x,thisRecNum),SpreadsheetContents(:,2));
depth = unique(cell2mat(SpreadsheetContents(thisAnimalDepthVect&thisRecVect,5)));
orgDepth = unique(cell2mat(SpreadsheetContents(thisAnimalDepthVect&thisRecVect,8)));
if length(depth)>1 || length(orgDepth)>1
    disp('Merged recordings appear to have different depths or organoid depths listed are different.')
    pause
end
TrackNumbers = unique(SpreadsheetContents(thisAnimalDepthVect&thisRecVect,3));
if length(TrackNumbers)>1
    disp('Merged recordings appear to be from different tracks.')
    pause
else
    DepthInfo.TrackNumber = TrackNumbers;
end
RefChan = unique(SpreadsheetContents(thisAnimalDepthVect&thisRecVect,7));
if length(RefChan)>1
    disp('Merged recordings appear to be from different tracks.')
    pause
else
    DepthInfo.RefChan = RefChan;
end

chDepths = nan(runParams.ElectrodeSpecs.numChans,1);
TT_depths = nan(size(runParams.ElectrodeSpecs.TT_config,1),1);
if ~isempty(depth)
    elecLength = runParams.ElectrodeSpecs.dist_mm * (runParams.ElectrodeSpecs.numChans-1) + runParams.ElectrodeSpecs.tip_mm;
    for ci = 1:length(chDepths)
        chDepths(ci) = depth + elecLength - runParams.ElectrodeSpecs.dist_mm*(ci-1);
    end
end
DepthInfo.chDepths = chDepths;
if any(~isnan(chDepths))
    DepthInfo.chDepthFromOrg = chDepths + orgDepth;
else
    DepthInfo.chDepthFromOrg = chDepths;
end
if~isempty(depth)
    TT_depths = nan(size(runParams.ElectrodeSpecs.TT_config,1),1);
    for tti = 1:size(runParams.ElectrodeSpecs.TT_config,1)
        TT_depths(tti) = nanmean(chDepths(runParams.ElectrodeSpecs.TT_config(tti,:)));
    end
end
DepthInfo.TT_depths = TT_depths;
if any(~isnan(TT_depths))
    DepthInfo.TT_depthsFromOrg = TT_depths + orgDepth;
else
    DepthInfo.TT_depthsFromOrg = TT_depths;
end


