% Here, a single layer is passed as a model
function hsvargplvmClusterScales(model, noClusters)

if nargin < 2 || isempty(noClusters), noClusters = 2; end

% for compatibility with svargplvm
if ~isfield(model, 'type')  || ~strcmp(model.type, 'svargplvm')
    model.numModels = model.M;
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
clu = kmeans(allScalesMat,noClusters, 'emptyact', 'drop','distance','sqeuclidean');
clu2 = kmeans(binaryScales, noClusters,  'emptyact', 'drop','distance','sqeuclidean');
imagesc(clu'), figure, imagesc(clu2')



%{
for i=1:model.numModels
    bar(allScales{i})
    title(num2str(i))
    pause
end
%}
