function [allScales, binaryScales, clu, allScalesMat] =  multvargplvmClusterScales(model, numClusters)

if nargin < 2
    numClusters = min(10, size(model.X,2));
end

allScales = svargplvmScales('get',model);
%  thresh = max(model.comp{obsMod}.kern.comp{1}.inputScales) * 0.001;
thresh = 0.005;
binaryScales = zeros(model.numModels, model.q);
allScalesMat = zeros(model.numModels, model.q);
for i=1:model.numModels
    % Normalise values between 0 and 1
    allScales{i} = allScales{i} / max(allScales{i});
    retainedScales{i} = find(allScales{i} > thresh);
    allScalesMat(i,:) = allScales{i};
    binaryScales(i,retainedScales{i}) = 1;
end
% sharedDims = intersect(retainedScales{obsMod}, retainedScales{infMod});
%imagesc(binaryScales')
%htree = linkage(allScalesMat,'single');
%clu = cluster(htree, 12);
clu = kmeans(allScalesMat, numClusters);
imagesc(clu')