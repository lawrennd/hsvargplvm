function [mu, varsigma] = multvargplvmPosteriorMeanVar(model, X, varX) % This is basically for the multOutput

mu = zeros(size(X,1), model.numModels);
for i=1:model.numModels
    mu(:,i) = vargplvmPosteriorMeanVar(model.comp{i},X);
end

% TODO: sigma
