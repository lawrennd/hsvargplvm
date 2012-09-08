% clear; close all; toyType = 'clusters'; Q = 3; initVardistIters = 100; itNo = 2000; demToyHsvargplvm1 % not good
% clear; close all; toyType = 'clusters'; Q = 3; initVardistIters = 100; itNo = 2000; multOutput=1; demToyHsvargplvm1
%{
clear; toyType = 'hgplvmSample'; baseKern='rbfardjit'; Q = {4,2}; initSNR = {100, 200};
  initVardistLayers = 1:2; initVardistIters = 100; itNo = 500; demToyHsvargplvm1;

clear; toyType = 'hgplvmSample'; baseKern='rbfardjit'; Q = {4,2}; initSNR = {100, 200}; initial_X = 'concatenated';
  initVardistLayers = 1:2; initVardistIters = 100; itNo = 500; demToyHsvargplvm1;
    % GOOD!!

clear; toyType = 'hgplvmSampleShared'; baseKern='rbfardjit'; Q = {3,1}; initSNR = {100, 200}; initial_X = 'separately';
  initVardistLayers = 1:2; initVardistIters = 100; itNo = 500; demToyHsvargplvm1;
% Not good


clear; toyType = 'hgplvmSampleShared'; baseKern='rbfardjit'; Q = {3,1}; initSNR = {100, 200}; initial_X = 'concatenated';
  initVardistLayers = 1:2; initVardistIters = 300; itNo = 2500; demToyHsvargplvm1;
%}



% A simple script run on simple hierarchical toy data.

% SEE ALSO: demMultvargplvmStackToy1.m

% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);

addpath(genpath('../'))

if ~exist('experimentNo'), experimentNo = 404; end
if ~exist('initial_X'), initial_X = 'separately'; end
if ~exist('baseKern'), baseKern = {'linard2','white','bias'}; end
if ~exist('itNo'), itNo = 500; end
if ~exist('initVardistIters'), initVardistIters = []; end
if ~exist('multVargplvm'), multVargplvm = false; end

% That's for the ToyData2 function:
if ~exist('toyType'), toyType = 'fols'; end % Other options: 'gps'
if ~exist('hierSignalStrength'), hierSignalStrength = 1;  end
if ~exist('noiseLevel'), noiseLevel = 0.05;  end
if ~exist('numHierDims'), numHierDims = 1;   end
if ~exist('numSharedDims'), numSharedDims = 5; end
if ~exist('Dtoy'), Dtoy = 10;            end
if ~exist('Ntoy'), Ntoy = 100;           end

hsvargplvm_init;


[Ytr, dataSetNames, Z] = hsvargplvmCreateToyData2(toyType,Ntoy,Dtoy,numSharedDims,numHierDims, noiseLevel,hierSignalStrength);

globalOpt.dataSetName = ['toy_' toyType];

% If this option is active, then instead of having one modalities for each
% signal, we'll have one modality per each dimension of the concatenated
% signal
if globalOpt.multOutput
    fprintf('### Mult - hsvargplvm!! \n ###')
    initial_X = 'concatenated';
    Ynew=[];
    for i=1:length(Ytr)
        Ynew = [Ynew Ytr{i}];
    end
    clear Ytr
    for d=1:size(Ynew,2)
        Ytr{d} = Ynew(:,d);
    end
    clear Ynew
end

options = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';


model = hsvargplvmModelCreate(Ytr, options, globalOpt);


params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
modelInit = model;


%{
%%
initX1 = model.layer{1}.vardist.means;
initX2 = model.layer{2}.vardist.means;
initXA = initX1(:,1:2);
initXB = initX1(:,3:4);
figure
subplot(2,2,1)
plot(initX2(:,1), initX2(:,2), 'x-');
subplot(2,2,3)
plot(initXA(:,1), initXA(:,2), 'x-');
subplot(2,2,4)
plot(initXB(:,1), initXB(:,2), 'x-');
%%
%}

%model = hsvargplvmOptimise(model, true, 5000);


%%
model.globalOpt = globalOpt;
model = hsvargplvmOptimiseModel(model, true, true);


