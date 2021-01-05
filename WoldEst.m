function C = WoldEst(data,p,k)
n = size(data,2);
%% estimate parameter with OLS
[A Om] = VarEst(data,p);
%% compute the coefficients of the Wold representation
% companion form matrix
F = [A(2:end,:)';eye(n*(p-1)) zeros(n*(p-1),n)];

% powers of F
for j = 1:k
    FF = F^(j-1);
    C(:,:,j) = FF(1:n,1:n);
end
