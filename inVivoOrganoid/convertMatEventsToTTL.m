function [newTTL,expParams] = convertMatEventsToTTL(TTL_struct)

runParams.TTL_legend = {'FlashOff','0','45','90','135','180','225','270','315','FlashSess','FlashOn','DriftSess','TrialStart'};
TTL_labels = {'SCREEN OFF','DRIFTING_GRATING','DRIFTING_GRATING','DRIFTING_GRATING','DRIFTING_GRATING','DRIFTING_GRATING','DRIFTING_GRATING','DRIFTING_GRATING','DRIFTING_GRATING',' ','SCREEN ON',' ',' ','CONTROL','BASELINE'};
angleLabels = [0,45,90,135,180,225,270,315];

matEventLogPath ='/Users/jgermi/Documents/Perelman/MTR/ChenLab/Data/inVivoOrganoid/DG_info/DriftingGratingData/DG5_2_event_log.mat';
load(matEventLogPath)
singleRecTTLmask = cell2mat(arrayfun(@str2double,TTL_struct.recording_number,'UniformOutput',0)) == 32;
TTL_times = TTL_struct.timestamps(singleRecTTLmask);
newTTL = nan(1,length(TTL_times));
for labelInd = 1:length(TTL_labels)
    if ~strcmp(TTL_labels{labelInd},'DRIFTING_GRATING')
        thisLabelMask = cellfun(@(x) strcmp(x,TTL_labels(labelInd)),{event_log.type});
        newTTL(thisLabelMask) = labelInd-1;
    else
        
        thisLabelMask = cellfun(@(x) strcmp(x,TTL_labels{labelInd}),{event_log.type}) & [event_log.angle] == angleLabels(labelInd -1);
        newTTL(thisLabelMask) = labelInd-1;
        
    end
end
newTTL(isnan(newTTL))=-1;
flashDur = (TTL_times(newTTL==0)-TTL_times(newTTL==10))/10^6;
expParams.ScreenOnMS = 20;
expParams.ScreenOffMS = 2000;
expParams.DGdurMS = 30000;
expParams.ControlDurMS = 10000;
expParams.BaselineMS = 60000;