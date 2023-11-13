function [randmat] = random_matrix(mat)
% This function creates random matrix according to Humphries, M. D., & Gurney, K. (2008). Network ‘Small-World-Ness’: A Quantitative Method for Determining Canonical Network Equivalence. PLoS One, 3(4), e0002051. doi: 10.1371/journal.pone.0002051
% Basically it assigns each entry of the original matrix to an entry in the random matrix with uniform probability.

randmat = zeros(size(mat));
nnodes=length(mat);
for i=1:nnodes-1
    for j=i+1:nnodes
        m=1;n=1; % enter in loop
        % new entry should not be in the diagonal or in a place that already has been assigned
        while (m==n) && randmat(m,n)~=0 
            m=randi(nnodes);n=randi(nnodes);
        end
        randmat(m,n)=mat(i,j);
        randmat(n,m)=mat(i,j);
    end
end
end