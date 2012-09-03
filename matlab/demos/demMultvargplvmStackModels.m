% demMultvargplvmStackModels


% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);

hsvargplvm_init;

if ~exist('experimentNo'), experimentNo = 404; end


if exist('diaryFile')
    diary(diaryFile)
end
if ~exist('baseModelName'), baseModelName =  'mats/demDecomposeSkel2.mat'; end
if ~exist('baseY')
    [Ytemp,lbls] = multvargplvmPrepareData(globalOpt.demoType, globalOpt.dataOptions);
    for i=1:size(Ytemp,2)
        baseY{i} = Ytemp(:,i);
    end
    clear Ytemp
end
if ~exist('latentSpaces'), latentSpaces = {5}; end
if ~exist('iterations'), iterations = {{300, 1700}}; end
if ~exist('saveName'), saveName = []; end
if ~exist('saveIntermediate'), saveIntermediate = false; end

stackedModel.numLayers = length(latentSpaces) + 1;
stackedModel.type = 'stackedvargplvm';
for i = 1:stackedModel.numLayers
    stackedModel.layer{i}.type = 'stackedvargplvm';%'multvargplvm';
end

%-- load base model..
temp = load(baseModelName);
stackedModel.layer{1} = temp.model; clear temp;
stackedModel.layer{1} = svargplvmRestorePrunedModel(stackedModel.layer{1}, baseY);
%--

for i = 2:stackedModel.numLayers
    stackedModel.layer{i} = multvargplvmStackModels(stackedModel.layer{i-1}, i, ...
        latentSpaces{i-1}, iterations{i-1}, saveName, saveIntermediate);
end

%%
% Prune model (only data)
stackedModel = multvargpvmPruneStackedModel(stackedModel, true, false);


%%
% Visualise results
%%{
if ~(exist(visualiseResults) & visualiseResults)
    return
end
%%

multvargplvmClusterScales(model.layer{2}, 2);


%% Skel
model = multvargplvmRestoreStackedModel(stackedModel, baseY);
dataType = 'skel';
skel = acclaimReadSkel('35.asf');
[tmpchan, skel] = acclaimLoadChannels('35_01.amc', skel);

model.layer{1}.y  = skelGetChannels(multvargplvmJoinY(model.layer{1}));%, skel);
model.layer{1}.d = size(model.layer{1}.y,2);
%lvmVisualiseHierarchical(model, lbls, [dataType 'Visualise'], [dataType 'Modify'],false, skel);
                    % model, skel, q, layer, numSamples, fps 
for q=1:model.layer{2}.q
    demMultvargplvmSample(model, skel, q, 2,     100,        1/120);
    pause
end
%%}
