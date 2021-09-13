function TTL_struct = getEventsMerged(runParams)
%   This code will load Events.nev files for a recording. If the recording
%   has an underscore in the name, it will be assumed that multiple
%   recordings were stitched together. The code will look for
%   Events_####.nev for each recording.

%INPUTS:
%   runParams: this structure created in inVivoOrganoidWrapper is only
%   needed to get the data directory in the current version of the code.
%   This input can be replaced with a string containing the directory where
%   the events file should be searched.


if contains(runParams.recordingNum,'_')
    individRecordings = strsplit(runParams.recordingNum,'_');
    
    for recInd = 1:length(individRecordings)
        [temp_TTL_struct.timestamps, temp_TTL_struct.ttls, temp_TTL_struct.header,temp_TTL_struct.EvStrings] = getTTLs(fullfile(runParams.dataDir,sprintf('Events_%s.nev',individRecordings{recInd})));
        if temp_TTL_struct.timestamps(end)-temp_TTL_struct.timestamps(1) <= 0 
            badEvPath = strsplit(runParams.saveFigDir,'/');
            badEvPath = horzcat(strjoin(badEvPath(1:end-1),'/'),'/BadEvents.txt');
            fid = fopen(badEvPath, 'a' );
            fprintf( fid, 'Animal %s Recording %s timestamps off\n', runParams.animalID,individRecording{recInd});
            
            fclose(fid);
        end
        %check for multiple recordings that were merged on neuralynx before
        %expore
        temp_TTL_struct = addRecordingNumbers(temp_TTL_struct,individRecordings{recInd});
        if recInd == 1
           TTL_struct = temp_TTL_struct;
        else
            TTL_fields = fields(TTL_struct);
            for fieldInd = 1:length(TTL_fields)
                eval(sprintf('TTL_struct.%s = horzcat(TTL_struct.%s,temp_TTL_struct.%s);',TTL_fields{fieldInd},TTL_fields{fieldInd},TTL_fields{fieldInd}));
            end
        end
    end
else
    [TTL_struct.timestamps, TTL_struct.ttls, TTL_struct.header,TTL_struct.EvStrings] = getTTLs(fullfile(runParams.dataDir,'Events.nev'));
    
    if TTL_struct.timestamps(end)-TTL_struct.timestamps(1) <= 0
        badEvPath = strsplit(runParams.saveFigDir,'/');
        badEvPath = horzcat(strjoin(badEvPath(1:end-1),'/'),'/BadEvents.txt');
        fid = fopen(badEvPath, 'a' );
        fprintf( fid, 'Animal %s Recording %s timestamps off\n', runParams.animalID,runParams.recordingNum);
        
        fclose(fid);
    end
    
    TTL_struct = addRecordingNumbers(TTL_struct,runParams.recordingNum);
end

function temp_TTL_struct = addRecordingNumbers(temp_TTL_struct,recordingNum)
%check for multiple recordings that were merged on neuralynx before
%expore
if sum(cellfun(@(x) strcmp(x,'Starting Recording'),temp_TTL_struct.EvStrings))>1
    recStartInds =  find(cellfun(@(x) strcmp(x,'Starting Recording'),temp_TTL_struct.EvStrings));
    recStopInds = find(cellfun(@(x) strcmp(x,'Stopping Recording'),temp_TTL_struct.EvStrings));
    if any(~ismember(recStopInds(1:end-1)+1,recStartInds))
        disp('Stop TTL sent and not followed by Start TTL')
        pause
    end
    for recInd = 1:length(recStartInds)
        thisRecEvents = recStartInds(recInd):recStopInds(recInd);
        temp_TTL_struct.recording_number(recStartInds(recInd):recStopInds(recInd)) = repmat({horzcat(recordingNum,char(96+recInd))},1,length(thisRecEvents));
    end
else
    temp_TTL_struct.recording_number = repmat({recordingNum},1,length(temp_TTL_struct.timestamps));
end