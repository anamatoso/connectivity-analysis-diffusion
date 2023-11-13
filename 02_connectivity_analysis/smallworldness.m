function [S] = smallworldness(mat)
% This function calculates the small-worldness of a given connectivity
% matrix.

% Calculate C and L of original matrix
len_mat=1./mat;                 % conection-length matrix
d_mat= distance_wei(len_mat);
C=mean(clustering_coef_wu(weight_conversion(mat, 'normalize'))); % clustering coefficient
[L,~]=charpath(d_mat,0,0);

% Create random matrix
randmat=random_matrix(mat);

% Calculate C and L of random matrix
len_mat_rand=1./randmat;                 % conection-length matrix
d_mat_rand= distance_wei(len_mat_rand);
Crand=mean(clustering_coef_wu(weight_conversion(randmat, 'normalize'))); % clustering coefficient
[Lrand,~]=charpath(d_mat_rand,0,0);

%Calculate S
S=(C/Crand)/(L/Lrand);

end

