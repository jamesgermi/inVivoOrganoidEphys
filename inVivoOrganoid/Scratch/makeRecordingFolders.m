%subjPath = '/Volumes/SynoData/CHEN LAB/Forebrain_OrganoidTx/3M_FB2.3_R16-1311/2019-09-04_11-11-53';
%subjPath = '/Volumes/SynoData/CHEN LAB/Forebrain_OrganoidTx/2M_FB2.6_R10-1386/2019-12-20_11-58-50';
%subjPath = '/Volumes/SynoData/CHEN LAB/Forebrain_OrganoidTx/2M_FB2.6_R11-1387/2019-12-18_13-02-19';
subjPath = '/Volumes/SynoData/CHEN LAB/Forebrain_OrganoidTx/2M_FB2.6_R09-1385/2019-12-19_11-46-58';
foldContents = dirContents(subjPath);
numRec = sum(cellfun(@(x) any(strfind(x,'Events')),foldContents));
for recInd = 2:numRec
    thisRecName = sprintf('Recording_%04d',recInd-1);
    if ~exist(fullfile(subjPath,thisRecName),'dir')
        mkdir(fullfile(subjPath,thisRecName))
    end
    try
        if recInd == 1
            copyfile(fullfile(subjPath,'Events.nev'),fullfile(subjPath,thisRecName,'Events.nev'))
            for TTnum = 1:12
                copyfile(fullfile(subjPath,sprintf('TT%d.ntt',TTnum)),fullfile(subjPath,thisRecName,sprintf('TT%d.ntt',TTnum)))
            end
        else
            copyfile(fullfile(subjPath,sprintf('Events_%04d.nev',recInd-1)),fullfile(subjPath,thisRecName,'Events.nev'))
            for TTnum = 1:12
                copyfile(fullfile(subjPath,sprintf('TT%d_%04d.ntt',TTnum,recInd-1)),fullfile(subjPath,thisRecName,sprintf('TT%d.ntt',TTnum)))
            end
        end
    catch e
        continue
    end
    
end