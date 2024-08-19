function [streamlines,n_nodes] = load_streamlines(directory,pattern)
% Load the streamlines given the pattern that represents the groups

% Get a list of txt files in the directory
fileList = dir(fullfile(directory, "*-"+pattern+"*.txt"));

% Initialize the 3D matrix and the list of person numbers
numFiles = numel(fileList);
streamlines = [];

% Iterate through each txt file
for fileIndex = 1:numFiles
    % Get the file name
    fileName = fileList(fileIndex).name;
    
    % Construct the full file path
    filePath = fullfile(directory, fileName);
    
    % Load the data from the CSV file
    data = load(filePath);

    % Append the data along the 3rd dimension
    streamlines = cat(2, streamlines, reshape(data, [size(data) 1]));
end

% Get number of regions
n_nodes = length(streamlines(:,1));

end