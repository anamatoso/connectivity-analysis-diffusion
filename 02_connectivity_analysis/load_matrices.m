function [matrices, n_nodes, personList, filenames, uniqueStrings, numFiles] = load_matrices(directory,pattern,varargin)
% Load the matrices given the pattern that represents the groups

% Get a list of CSV files in the directory
fileList = dir(fullfile(directory, "*-"+pattern+"*.csv"));

% Initialize the 3D matrix and the list of person numbers
numFiles = numel(fileList);
matrices = [];
personList = cell(numFiles,1);
filenames = strings(numFiles,1);

% Iterate through each CSV file
for fileIndex = 1:numFiles
    % Get the file name
    fileName = fileList(fileIndex).name;
    filenames(fileIndex) = fileName;
    % Construct the full file path
    filePath = fullfile(directory, fileName);
    %disp(filePath)
    % Load the data from the CSV file
    data = load(filePath);
    if ~isempty(varargin)
        matrix = remap_matrix(data,varargin{1},true);
        data=matrix;
    end
   
    % Append the data along the 3rd dimension
    matrices = cat(3, matrices, reshape(data, [size(data) 1]));

    % Extract the person number from the file name
    personNumber = fileName(1:14);
    
    % Append the person number to the list
    personList{fileIndex} = personNumber;
end

% Get number of nodes
n_nodes = length(matrices(:,:,1));

% Get list of unique subjects
uniqueStrings = categories(categorical(personList));


end