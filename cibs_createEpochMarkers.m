function cibs_createEpochMarkers(EEG, emFile)
% auto-create an epoch markers file with q3second event flags, all labeled
% 'Z'
eventDur = 3; 

if nargin < 2
    emFile = 'epochMarkers.txt';
end

latency = (1:3:EEG.times(end)*1e-3)';
eventType = repmat('Z', length(latency),1);
eventDur = repmat(eventDur, length(latency),1);

epochMarkers = table(latency, eventType, eventDur);

writetable(epochMarkers, emFile, 'Delimiter', '\t')
fprintf('output written to %s\n', emFile)
end