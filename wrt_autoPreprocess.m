function wrt_autoPreprocess(edfFiles, varargin)

% automated preprocessing pipeline to create 3 second epochs. skis relabeling, and accommodates DC3 adn DC4 requires reviewing output to confirm artifact rejection
% Created 3/15/20 Shawniqua Williams Robeson, M.Eng., M.D.
% (c) Vanderbilt University Medical Center
%
% Date      Author  Change
% --------- ------- --------------------------------------------
% 3/15/20   SWR     Created
% 4/5/20    SWR     Updated from wrt_preprocess for INMO:
%                   added input parser and optional arguments to specify 
%                   - dsDir: location of input
%                   .edf files (dsDir, default is the current working
%                   directory), 
%                   - outputDir: output file location (default is an
%                   'epoched' subdirectory under the current working
%                   directory)
%                   - subjChars: number of characters at the beginning of
%                   each file name that designates the subject ID (default
%                   8  e.g. in all .edf files start with INMO-XXX)
%                   - chanList: list of channels to be included in the output file
%                   (default all the normal 19 channels except
%                   Fp1/Fp2 and using T5/6 [instead of P7/8] - *later changed to 
%		    include T5/6 and P7/8 by default)
%                   - filtOrder: filter Order (default 1690 which appeared
%                   to be recommended for Natus 256Hz files recorded
%                   recently)
% 9/8/20     SWR    1) allow new epochLen parameter and call 
%		    cibs_createEpochMarkers with it. 2) uncomment the call to 
%		    cibs_relabel.m 3) include P7/8 in default chanList and 
%		    restrict it to only those chans that are present when 
%		    calling pop_selectByChans

p = inputParser;
addRequired(p,'edfFiles');
addOptional(p,'dsDir',pwd);
addOptional(p,'outputDir',fullfile(pwd, 'epoched'));
addOptional(p,'subjChars',8);
addOptional(p,'chanList', {'C3' 'C4' 'O1' 'O2' 'Cz' 'F3' 'F4' 'F7' 'F8' 'Fz' 'P3' 'P4' 'Pz' 'T3' 'T4' 'T5' 'T6', 'P7', 'P8'});
addOptional(p,'filtOrder',1690);
addOptional(p,'epochLen', 3);

parse(p,edfFiles,varargin{:});
dsDir = p.Results.dsDir;
outputDir = p.Results.outputDir;
subjChars = p.Results.subjChars;
chanList = p.Results.chanList;
filtOrder = p.Results.filtOrder;
epochLen = p.Results.epochLen;

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

for fileNum = 1:length(edfFiles)
    subjID = edfFiles{fileNum}(1:subjChars);
    fileName = extractBefore(edfFiles{fileNum},'.edf');
    EEG = pop_biosig(fullfile(dsDir, edfFiles{fileNum}));
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',fileName,'gui','off'); 
    EEG = cibs_relabel(EEG);
    EEG=pop_chanedit(EEG, 'lookup',fullfile(fileparts(which('eeglab')),'plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'));
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );
    newChanList = chanList(ismember(chanList, {EEG.chanlocs.labels}));
    EEG = pop_select( EEG,'channel',newChanList);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
    EEG = cibs_detrend(EEG);
    EEG = pop_eegfiltnew(EEG, 0.5,50,filtOrder,0,[],0); %
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',sprintf('%sf',fileName),'gui','off'); 
    EEG = eeg_checkset( EEG );
    EEG = pop_rejcont(EEG, 'elecrange',[1:length(newChanList)] ,'freqlimit',[20 40] ,'threshold',10,'epochlength',0.5,'contiguous',2,'addlength',0.25,'taper','hamming');

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',sprintf('%sfc',fileName),'gui','off');
    EEG = pop_reref( EEG, []);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'setname',sprintf('%sfcc',fileName),'gui','off');
    cibs_createEpochMarkers(EEG, 'epochMarkers.txt', epochLen) % by default creates consecutive 3-second epochs, arbitrarily labels them 'Z' and places a text file with these markings in the current working directory. 
    EEG = pop_importevent( EEG, 'event',fullfile(pwd,'epochMarkers.txt'),'fields',{'latency' 'type' 'duration'},'skipline',1,'timeunit',1);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );
    EEG = pop_epoch( EEG, {  'Z'  }, [-1  epochLen-1], 'newname', sprintf('%sffcce', fileName), 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'gui','off'); 
    EEG = eeg_checkset( EEG );
    % create outputDir if it doesn't already exist
    if ~exist(outputDir, 'dir')
        mkdir(outputDir)
    end
    % save preprocessed file
    EEG = pop_saveset( EEG, 'filename',sprintf('%sfcce.set',fileName),'filepath',outputDir);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
end
