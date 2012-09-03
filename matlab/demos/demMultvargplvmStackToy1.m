
%{
clear; experimentNo = 1; initVardistIters = 100; itNo = 400; latentDimPerModel = 5; 
    latentDim = 10; saveSvargplvm = true; trainSvargplvm = true; demMultvargplvmStackToy1


%}


% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);

addpath(genpath('../'))

if ~exist('experimentNo'), experimentNo = 404; end
% Save the svargplvmModel (first layer) as a mat file
if ~exist('saveSvargplvm'), saveSvargplvm = true; end
% Attach the previous layer as a whole model (value = true) or just as the
% name of an already saved file)
if ~exist('attachPrevLayer'), attachPrevLayer = false; end
% Train the first layer (value = true) or load an already trained model
% (value = false)
if ~exist('trainSvargplvm'), trainSvargplvm = true; end

baseKern = {{'linard2','white','bias'},{'linard2','white','bias'}};
initial_X = 'concatenated';

hsvargplvm_init


[Yall, dataSetNames, Z] = hsvargplvmCreateToyData2();
numberOfDatasets = length(Yall);


%-------- Run svargplvm

if ~saveSvargplvm && trainSvargplvm
    saveName = 'noSave';
else
    saveName = ['demToyStackedSvargplvm' num2str(experimentNo) '.mat'];
end

if trainSvargplvm
    demSvargplvm2
else
    fprintf('# Loading already trained svargplvm model %s\n',saveName);
    load(saveName)
    model = svargplvmRestorePrunedModel(model, Yall);
end

retainedScales{1} = vargplvmRetainedScales(model.comp{1},0.008);
retainedScales{2} = vargplvmRetainedScales(model.comp{2},0.008);


sc = union(retainedScales{1}, retainedScales{2});


%------- Stack models
fprintf('\n\n##### Stacking models...\n\n')


Y = model.X(:,sc);
modelSvargplvm = model;

keep('modelSvargplvm', 'Y','globalOpt','attachPrevLayer' ,'Z','sc');

for i=1:size(Y,2)
    globalOpt.baseKern{i} = {'linard2','white','bias'};
end

%-- options
globalOpt.initial_X = 'concatenated'; globalOpt.latentDim = size(Y,2);
%globalOpt.initial_X = 'separately'; globalOpt.latentDimPerModel = 1;
%--

demMultvargplvm

if attachPrevLayer
    model.layer{1} = svargplvmPruneModel(modelSvargplvm);
else
    model.layer{1} = modelSvargplvm.saveName;
end
prunedModelMultvargplvm = svargplvmPruneModel(model);

fprintf('# Saving %s...\n',prunedModelMultvargplvm.saveName)
save(prunedModelMultvargplvm.saveName,'prunedModelMultvargplvm')


%{
figure, svargplvmShowScales(modelSvargplvm), mainPlotTitle('svargplvmScales')
vargplvmPlotMat(modelSvargplvm.X,sc), mainPlotTitle('svargplvm')
figure, svargplvmShowScales(model), mainPlotTitle('multvargplvmScales')
vargplvmPlotMat(model.X), mainPlotTitle('mulvargplvm')

%}
