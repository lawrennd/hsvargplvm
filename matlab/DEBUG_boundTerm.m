X = model.layer{1}.vardist.means;
means = X;
covars = model.layer{1}.vardist.covars;
Q = size(X,2);
N = size(X,1);

%% For the TrYYT term (preliminary): All of the below are equivalent

sumAll = 0;
for q=1:Q
    sumAll = sumAll + (X(:,q)' * X(:,q));
end


sumAll2 = 0;
for q=1:Q
    sumAll2 = sumAll2 + trace(X(:,q) * X(:,q)');
end


sumAll3 = 0;
for q=1:Q
    sumAll3 = sumAll3 + X(:,q) * X(:,q)';
end
sumAll3 = trace(sumAll3);

sumAll4 = trace(X*X');
sumAll5 = sum(sum(X.*X));

sumAll+sumAll2+sumAll3+sumAll4+sumAll5; % To test dimensions

if min([sumAll, sumAll2, sumAll3, sumAll4, sumAll5]) ~= max([sumAll, sumAll2, sumAll3, sumAll4, sumAll5])
    error('')
end

%% For the TrYYT term:
sumAll=0;
for q=1:Q
    sumAll = sumAll + (means(:,q)*means(:,q)'+diag(covars(:,q)));
end
sumAll = trace(sumAll);

% Break the trace
sumAll2 = sum(sum(means.*means)) + sum(sum(covars));


%% For the F3 term (involving P)
sumAll = 0;
for q=1:Q
  sumAll = sumAll + (means(:,q)*means(:,q)'+diag(covars(:,q)));
end
res = chol(sumAll);



%% For the derivatives
Z = randomCovMatrix(N);
sumAll = 0;
for q=1:Q
    sumAll = sumAll + Z'*means(:,q);
end
sumAll2 = sum(means'*Z);

%%
S = model.layer{1}.vardist.covars;
sumAll = 0;
for n=1:size(S,1)
    sumAll = sumAll + log(det(diag(S(n,:))));
end
sum(sum(log(S)))