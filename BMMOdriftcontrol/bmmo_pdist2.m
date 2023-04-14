function D = bmmo_pdist2(X,Y)
% function D = bmmo_pdist2(X,Y)
%
% R13-compatible implementation of (required functionality of) pdist2 (a Matlab builtin in subsequent 
% versions). 
%
% Input:
%   X: MX x 2 double matrix
%   Y: MY x 2 double matrix
%
% Output: 
%   D: MX x MY double matrix of pairwise Euclidean distances between X and Y

[nx,p] = size(X);
[ny,py] = size(Y);

if p == 2 & p == py
    D = zeros(nx,ny);
  
    for i = 1:ny            
        D(:,i) = sqrt(( (X(:,1) - Y(i,1)).^2 + (X(:,2) - Y(i,2)).^2));
    end    
else
    error('bmmo_pdist2: Input data must have two columns');
end



