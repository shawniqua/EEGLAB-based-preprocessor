function EEG = cibs_detrend(EEG)
% detrends EEG data, either in epochs or as continuous (epochs preferred)
% assumes EEGLAB format (CHANNELS x SAMPLES x EPOCHS)

nEpochs = size(EEG.data,3);
if nEpochs >1
    eeg = permute(EEG.data, [2 3 1]);
    for ch = 1:size(eeg,3)
        eeg(:,:,ch) = detrend(eeg(:,:,ch));
    end
    EEG.data = permute(eeg, [3 1 2]);
else
    eeg = permute(EEG.data, [2 1]);
    eeg = detrend(eeg);
    EEG.data = permute(eeg, [2 1]);
end

end