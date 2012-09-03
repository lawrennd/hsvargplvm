
% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);


if ~exist('experimentNo'), experimentNo = 404; end



%baseKern = 'rbfardjit';
baseKern = {'linard2','white','bias'};
initial_X = 'separately';

hsvargplvm_init;

% ------- LOAD DATASET
YA = vargplvmLoadData('hierarchical/demHighFiveHgplvm1',[],[],'YA');
YB = vargplvmLoadData('hierarchical/demHighFiveHgplvm1',[],[],'YB');




%------- REMOVE dims with very small var
vA = find(var(YA) < 1e-7);
dmsA = setdiff(1:size(YA,2), vA);
YA = YA(:,dmsA);
vB = find(var(YB) < 1e-7);
dmsB = setdiff(1:size(YB,2), vB);
YB = YB(:,dmsB);
%---


Yall{1} = YA; Yall{2} = YB;

options = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';

model = hsvargplvmModelCreate(Yall, options, globalOpt);


params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
modelInit = model;

model = hsvargplvmOptimise(model, true, 500);


