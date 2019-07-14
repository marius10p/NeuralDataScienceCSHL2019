function S = loadSession(sesPath)
% function to load a session of the Steinmetz Neuropixels dataset
% Author: Michael G. Moore, Michigan State University, 
% Version:  V1 7/13/2019

% sesPath   is the directory name of the session, including any required 
%           path information

% S         a data structure containing all the session variables      

%% the npy-matlab-master package must be accessible to this function

S = struct;
S.sesPath = sesPath;

% get session name
temp = strsplit(sesPath,filesep);
S.sesName = temp{end};


% list all files and info
fdir = dir(sesPath);
fdir = fdir(3:end);

S.fileList = fdir;  

% examine each file and either read it into Matlab or ignore it
for f = 1:length(fdir)
    % check if file or subdirectory (should be unecessary)
    if fdir(f).isdir
        continue
    end
    % get file type
    temp = strsplit(fdir(f).name,'.');
    ftype = temp{end};
    fields = temp(1:(end-1));
    % keep only .npy and .tsv files
    if ~isequal(ftype,'npy') && ~isequal(ftype,'tsv')
        continue
    end
    % check fields for valid names
    for m = 1:length(fields)
        % Modify the names so that they are valid Matlab variable names
        %   if first character is not a letter, will prefix an "x" 
        %   whitespace will be deleted
        %   whitespace followed by a letter will be replaced by the capitalized letter
        %   invalid characters will be replaced by underscore
        fields{m} = matlab.lang.makeValidName(fields{m});
    end
    % read the .npy and .tsv files
    if isequal(ftype,'npy')
        val = readNPY([sesPath filesep fdir(f).name]);
    elseif isequal(ftype,'tsv')
        val = tdfread([sesPath filesep fdir(f).name]);
    end      
    % create a field of S using fields and val 
    S = setfield(S,fields{1:end},val);
   
end

end
