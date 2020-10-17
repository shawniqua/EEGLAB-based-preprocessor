function EEG = cibs_relabel(EEG)
% Change channel labels to recognized labels
%
% (c) Shawniqua Williams Roberson, MEng, MD
%     Vanderbilt University Medical Center
%
% 5/22/19 Created
% 6/26/19 Updated to include T7 and T8 as recognized labels
% 8/18/19 Include T1 and T2 as well

knownLabels = {'Fp1', 'Fp2', 'F3', 'F4', 'F7', 'F8', 'C3', 'C4', 'P3', 'P4', 'P7', 'P8', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'O1', 'O2', 'A1', 'A2', 'Fz', 'Cz', 'Pz', 'Oz'};
disp ('current labels:')
{EEG.chanlocs.labels}'
for chNum = 1:EEG.nbchan
%     fprintf('channel %d: %s\n',chNum, EEG.chanlocs(chNum).labels)
    for klNum = 1:length(knownLabels)
%         fprintf('\tcomparing %s against %s...\n', EEG.chanlocs(chNum).labels, knownLabels{klNum})
        if contains(EEG.chanlocs(chNum).labels, knownLabels{klNum})
%             disp('GOT IT!')
            EEG.chanlocs(chNum).labels = knownLabels{klNum};
        end
    end
end
disp ('new labels:')
{EEG.chanlocs.labels}'
        