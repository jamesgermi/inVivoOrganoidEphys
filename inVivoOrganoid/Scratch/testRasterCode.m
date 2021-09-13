[spikeMat, tVec] = poissonSpikeGen(30, 1, 20);
figure
[spikeMat, tVec] = poissonSpikeGen(30, 1, 20);
plotRaster(spikeMat, tVec*1000);
xlabel('Time (ms)');
ylabel('Trial Number');

function [] = plotRaster(spikeMat, tVec)
hold all;
for trialCount = 1:size(spikeMat,1)
    spikePos = tVec(spikeMat(trialCount, :));
    for spikeCount = 1:length(spikePos)
        plot([spikePos(spikeCount) spikePos(spikeCount)], ...
            [trialCount-0.4 trialCount+0.4], 'k');
    end
end
ylim([0 size(spikeMat, 1)+1]);
end

function [spikeMat, tVec] = poissonSpikeGen(fr, tSim, nTrials)
dt=1/1000;%s
nBins = floor(tSim/dt);
spikeMat = rand(nTrials, nBins) < fr*dt;
tVec = 0:dt:tSim-dt;
end