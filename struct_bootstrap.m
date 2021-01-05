function STRUCT_BOOT = struct_bootstrap(data,p,k,reps)
% Identical to the bootstrap used before, modified only to compute the IRS of
% structural shocks

% INITIALIZE THE PROCESS:
% compute VAR coeff, fitted values and residuals:
[A, ~, res, fitted] = VarEst(data,p);

% BOOTSTRAP REPLICATIONS:
count= 1;       % initialize a counter for the number of repetitions
while count <= reps
    
    % sample uniformely (with replacement) a vector of residuals
    % ALWAYS from the original residuals (res)
    Rand_Res = datasample(res, length(fitted(:,1)));
    
    % create a new artificial time series
    
    new_data = data(1:p,:);     % first p obs are always equal

    for i= 1:length(fitted(:,1))
        for t= 1:p
            y_temp(:,t)= new_data(end-t+1,:)*A(2*t:2*t+1,:);
        end
        y(i,:) = A(1,:) + sum(y_temp,2)' + Rand_Res(i,:);
        new_data = [new_data; y(i,:)];
    end
    
    %given the new series, compute IRF coeff (using the updated matrices A)
    %and save the coeff in a big matrix ( 4th dimension accounts for
    %iterations)
    [VAR_coeff,Sigma,eps,~] = VarEst(new_data,4);         % var/covar matrix of residuals
    
    WOLD = WoldEst(new_data,p,k);
    phi = sum(WOLD,3);

    theta = chol(phi*Sigma*phi','lower');

    B0 = inv(theta)*phi;

    struct_eps = B0*eps';           
    
    
    
    for i = 1:k
        STRUCT_BOOT(:,:,i,count) = WOLD(:,:,i)*inv(B0);
    end
    
    count= count+1;    %update the counter
end
end