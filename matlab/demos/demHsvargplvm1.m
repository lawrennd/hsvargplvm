% Simple script with random data, mostly to do gradchek and test
% development
rand('seed', 1e5)
randn('seed', 1e5);

addpath(genpath('../'));
 %Norm1 difference: 2.490857e-003
 %Norm2 difference: 1.965647e-003

if ~exist('H'), H=3; end
if ~exist('fixInducing'), fixInducing = false; end

N = 10;
D1 = 4;
D2 = 5;

Ytr{1} = rand(N,D1);
Ytr{2} = rand(N,D2);
Q = {5,3,2};

if fixInducing
    K = N;
else
    K = 3;
end

baseKern = {'linard2','white','bias'};
%baseKern = 'rbfardjit';

hsvargplvm_init;
[options, optionsDyn] = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';

if fixInducing
    options.fixInducing = 1;
   % options.fixIndices = 1:K;
end

if globalOpt.multOutput
    Ynew = [Ytr{1} Ytr{2}];
    Ytr = cell(1,size(Ynew,2));
    for i=1:size(Ynew,2)
        Ytr{i} = Ynew(:,i);
    end
end

model = hsvargplvmModelCreate(Ytr, options, globalOpt);

if ~isempty(globalOpt.dynamicsConstrainType)
    model = hsvargplvmAddParentPrior(model, globalOpt, optionsDyn);
    model.layer{end}.dynamics.learnVariance = 1; % For the gradchek to pass
end

[params, names] = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
modelInit = model;

model.layer{end}.comp{1}.fixInducing=0; %%%%%%%%% Not implemented yet fix inducing for parent!!

if exist('skipGradchek') && skipGradchek
    model = hsvargplvmOptimise(model, true, 5);
else
    model = hsvargplvmOptimise(model, true, 5, 'gradcheck', true);
end

%{
%--- test the "learnInducing=false" part...
model2 = hsvargplvmPropagateField(modelInit, 'learnInducing', false);
[params2, names2] = hsvargplvmExtractParam(model2);
model2 = hsvargplvmExpandParam(model2, params2);
model2 = hsvargplvmOptimise(model2, true, 5, 'gradcheck', true);
%}