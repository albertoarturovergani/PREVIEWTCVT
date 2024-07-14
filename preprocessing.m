%% PRE-PROCESSING TCVT

Delete all
clc

readingFolder = append('D:\PREVIEWmaster_ERPs\MASTER\ALL');
writingFolder = append('D:\PREVIEWmaster_ERPs\MASTER\ALL_PROCESSED\3CVT\');

% Get the list of folders in the root directory  
subDirs = dir(readingFolder);

% Iterate on each folder
%for i = 1:length(subDirs)
for i = length(subDirs):-1:1

    clearvars -except readingFolder writingFolder subDirs i;

    currentDir = fullfile(readingFolder, subDirs(i).name);
   
    % Get the list of files in the current directory
    files = dir(fullfile(currentDir, '*.edf'));
   
    % Iterate on each file in the current directory
    for j = 1:length(file)
        eeglab
        currentFile = fullfile(currentDir, files(j).name);
       
        % Checks whether the file name contains 'SIR'.
        if contains(currentFile, '3CVT')
            % Perform file-specific actions *SIR*.edf
            disp(['File found: ', currentFile]);
            EEG = pop_file(currentFile, 'dataformat', 'auto');
            EEG = pop_select( EEG, 'nochannel',{'ECG','EOG','A','B','MK'});
            % rename the channels by removing the partial string 'EEG'.
            for chan = 1:61
                EEG.chanlocs(chan).labels = erase(EEG.chanlocs(chan).labels, 'EEG');
            end
            EEG = pop_chanedit(EEG, 'lookup','C:\Users\Albert\OneDrive - Scuola Superiore Sant'Anna\dellXXX-laptop\temp_SSSP\PROJECTS\eeglab_current\eeglab2021.1\plugins\dipfit\standard_BEM\elec\standard_1020.elc');
            EEG = pop_eegfiltnew(EEG, 'locutoff', 1,'hicutoff',40,'plotfreqz',0);
            EEG_CLEANED = pop_clean_rawdata(EEG, ...
                'FlatlineCriterion',5, ...
                'ChannelCriterion',0,8, ...
                'LineNoiseCriterion', 4, ...
                'Highpass', 'off', ...
                BurstCriterion', 20, ...
                'WindowCriterion', 0.25, ... %0.25
                BurstRejection','off', ...
                'Distance','Euclidian', ...
                'WindowCriterionTolerances',[-Inf 7] );
            EEG = pop_interp(EEG_CLEANED, EEG.chanlocs, 'spherical');
            EEG = pop_reref( EEG, []);
            % ICA
            EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
            EEG = pop_iclabel(EEG, 'default');
            a = EEG.etc.ic_classification.ICLabel.classifications
            [n_components, labels]=size(a)
            for components = 1:n_components
                b(components) = find(a(components,:)' == max(a(components,:)')
            end
            muscle = find(b==2)
            eye = find(b==3)
            heart = find(b==4)
            lnoise = find(b==5)
            cnoise = find(b==6)
            %other = find(b==7)
            compKO = [muscle, eye, heart, lnoise, cnoise].
            EEG_ICA = pop_subcomp(EEG, compKO, 0);
            original_filename = sprintf('%s', strrep(files(j).name, '.edf', ''), '_ICA.set')
            parts = strsplit(original_filename, '_');
            inverted_filename = [sprintf('%04s', parts{2}), '_', parts{1}, '_', parts{3}];
            pop_saveset(EEG_ICA, 'filename', inverted_filename, 'filepath', writingFolder3CVT);
           
            %EPOCHING 3CVT - TRIANGLE OK
            EEG_ICA_EPOCHED_TARGET = pop_epoch( EEG_ICA, { 'Triangle' }, [-0.1 1], 'newname', 'EDF file pruned with ICA epochs', 'epochinfo', 'yes');
            EEG_ICA_EPOCHED_TARGET = pop_rmbase( EEG_ICA_EPOCHED_TARGET, [-0.1 0] ,[]);
            EEG_ICA_EPOCHED_TARGET_OK = pop_selectevent( EEG_ICA_EPOCHED_TARGET, 'type',{'OK'},'deleteevents','off','deleteepochs','on','reverseepochs','off');

            % Saving
            string_to_add = 'EPOCHED_TRIANGLE-TARGET_OK';
            file_extension = '.set';
            new_filename = [string_to_add, '_', strrep(inverted_filename, '.set', ''), file_extension];  
            EEG_ICA_EPOCHED_TARGET_OK = pop_saveset( EEG_ICA_EPOCHED_TARGET_OK, 'filename',new_filename,'filepath', writingFolder3CVT);

            % INVERTED TRIANGLE OK
            EEG_ICA_EPOCHED_TARGET_R = pop_epoch( EEG_ICA, {'Inverted Triangle' }, [-0.1 1], 'newname', 'EDF file pruned with ICA epochs', 'epochinfo', 'yes');
            EEG_ICA_EPOCHED_TARGET_R = pop_rmbase( EEG_ICA_EPOCHED_TARGET_R, [-0.1 0] ,[]);
            EEG_ICA_EPOCHED_TARGET_R_OK = pop_selectevent( EEG_ICA_EPOCHED_TARGET_R, 'type',{'OK'},'deleteevents','off','deleteepochs','on','reverseepochs','off');
            % Saving
            string_to_add = 'EPOCHED_TRIANGLE-REVERSED_OK';
            file_extension = '.set';
            new_filename = [string_to_add, '_', strrep(invert_name, '.set', ''), file_extension];  
            EEG_ICA_EPOCHED_TARGET_R_OK = pop_saveset( EEG_ICA_EPOCHED_TARGET_R_OK, 'filename',new_filename,'filepath', writingFolder3CVT);
 
            % DIAMOND OK
            EEG_ICA_EPOCHED_TARGET_D = pop_epoch( EEG_ICA, { 'Diamond' }, [-0.1 1], 'newname', 'EDF file pruned with ICA epochs', 'epochinfo', 'yes');
            EEG_ICA_EPOCHED_TARGET_D = pop_rmbase( EEG_ICA_EPOCHED_TARGET_D, [-0.1 0] ,[]);
            EEG_ICA_EPOCHED_TARGET_D_OK = pop_selectevent( EEG_ICA_EPOCHED_TARGET_D, 'type',{'OK'},'deleteevents','off','deleteepochs','on','reverseepochs','off');
            % Saving
            string_to_add = 'EPOCHED_DIAMANTE_OK';
            file_extension = '.set';
            new_filename = [string_to_add, '_', strrep(inverted_filename, '.set', ''), file_extension];  
            EEG_ICA_EPOCHED_TARGET_D_OK = pop_saveset( EEG_ICA_EPOCHED_TARGET_D_OK, 'filename',new_filename,'filepath', writingFolder3CVT);

         end
    end
end