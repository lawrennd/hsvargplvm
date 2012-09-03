% A simple script run on simple hierarchical toy data.

% SEE ALSO: demMultvargplvmStackToy1.m

% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);

addpath(genpath('../'))

if ~exist('experimentNo'), experimentNo = 404; end

baseKern = {'linard2','white','bias'};
initial_X = 'separately';

%baseKern = 'rbfardjit';

hsvargplvm_init;

[Ytr, dataSetNames, Z] = hsvargplvmCreateToyData2();

options = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';

model = hsvargplvmModelCreate(Ytr, options, globalOpt);


params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
modelInit = model;

model = hsvargplvmOptimise(model, true, 500);