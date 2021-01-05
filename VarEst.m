function [A Om eps fitted] = VarEst(data,p)
Y = data(p+1:end,:);
T = size(Y,1);
Xtemp = lagsMulti(data,p);
X = [ones(T,1) Xtemp];

A = inv(X'*X)*X'*Y;
fitted = X*A;
eps = Y-X*A;
Om = eps'*eps/T;
end