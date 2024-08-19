function [new_matrix] = remap_matrix(matrix,idx_map,noselfconnections)
% This function remaps the matrix given the new indices in idx_map

[n_nodes,~]=size(matrix);

if n_nodes~=length(idx_map)
    error("The length of the mapping vector must be equal to the number of nodes of the original matrix.")
end

n_newnodes=length(unique(idx_map));
new_matrix=zeros(n_newnodes,n_newnodes);

for i=1:n_nodes-1
    for j=i:n_nodes
        new_i= idx_map(i);
        new_j= idx_map(j);
        if noselfconnections
            if new_i~=new_j
                new_matrix(new_i,new_j)=new_matrix(new_i,new_j)+matrix(i,j);
                new_matrix(new_j,new_i)=new_matrix(new_j,new_i)+matrix(j,i);
            end
        else
            new_matrix(new_i,new_j)=new_matrix(new_i,new_j)+matrix(i,j);
            new_matrix(new_j,new_i)=new_matrix(new_j,new_i)+matrix(j,i);
        end
    
    end
end
end

