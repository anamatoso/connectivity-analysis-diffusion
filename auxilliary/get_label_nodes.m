function [labels] = get_label_nodes(file)
% This funtion gets the labels of each node from a txt file and puts them in a string matrix

cell_labels=importdata(file);
n_nodes=length(cell_labels);
labels=strings(1,n_nodes);
for i=1:n_nodes
    labels(i)=cell_labels(i);
end
end

