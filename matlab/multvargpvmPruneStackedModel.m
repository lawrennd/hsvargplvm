function stackedModel = multvargpvmPruneStackedModel(stackedModel, onlyData, keepBaseData)

if nargin < 3
    keepBaseData = onlyData;
    stackedModel.layer{1}.y;
end
if nargin < 2
    onlyData = false;
end


for i=1:stackedModel.numLayers
    stackedModel.layer{i} = svargplvmPruneModel(stackedModel.layer{i}, onlyData);
    stackedModel.layer{i} = rmfield(stackedModel.layer{i}, 'globalOpt');
end

if keepBaseData
    stackedModel.layer{1}.y = baseData;
end