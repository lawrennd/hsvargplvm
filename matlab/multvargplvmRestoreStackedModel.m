function model = multvargplvmRestoreStackedModel(model, baseY, onlyData)

if nargin < 3
    if isfield(model.layer{1}.comp{1}, 'At')
        onlyData = true;
    else
        onlyData = false;
    end
end
% Deal with base model
model.layer{1} = svargplvmRestorePrunedModel(model.layer{1}, baseY, onlyData);

for i=2:model.numLayers
    for q=1:model.layer{i}.numModels
        curY{q} = model.layer{i-1}.X(:,q);
    end
    model.layer{i} = svargplvmRestorePrunedModel(model.layer{i}, curY, onlyData);
end