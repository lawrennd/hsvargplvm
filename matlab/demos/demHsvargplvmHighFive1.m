%{
clear; experimentNo=1; baseKern = 'rbfardjit'; initial_X = 'separately'; tic; demHsvargplvmHighFive1; toc
%}

% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);


if ~exist('experimentNo'), experimentNo = 404; end
if ~exist('baseKern'), baseKern = 'rbfardjit'; end %baseKern = {'linard2','white','bias'};
if ~exist('initial_X'), initial_X = 'separately'; end

dataSetName = 'highFive';


hsvargplvm_init;

% ------- LOAD DATASET
YA = vargplvmLoadData('hierarchical/demHighFiveHgplvm1',[],[],'YA');
YB = vargplvmLoadData('hierarchical/demHighFiveHgplvm1',[],[],'YB');



if globalOpt.multOutput
    %------- REMOVE dims with very small var (then when sampling outputs, we
    % can replace these dimensions with the mean)
    vA = find(var(YA) < 1e-7);
    meanRedundantDimA = mean(YA(:, vA));
    dmsA = setdiff(1:size(YA,2), vA);
    YA = YA(:,dmsA);
    
    vB = find(var(YB) < 1e-7);
    meanRedundantDimB = mean(YB(:, vB));
    dmsB = setdiff(1:size(YB,2), vB);
    YB = YB(:,dmsB);
    %---
end

Yall{1} = YA; Yall{2} = YB;

options = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';

model = hsvargplvmModelCreate(Yall, options, globalOpt);


params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
modelInit = model;

%%
model.globalOpt = globalOpt; 

model = hsvargplvmOptimiseModel(model, true, true);


%% 
% Now call:
% hsvargplvmShowSkel(model);