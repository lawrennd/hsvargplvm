% A simple script run on simple hierarchical toy data.

% SEE ALSO: demMultvargplvmStackToy1.m

% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);

addpath(genpath('../'))

if ~exist('experimentNo'), experimentNo = 404; end
if ~exist('K'), K = 6; end
if ~exist('Q'), Q = 6; end
if ~exist('initial_X'), initial_X = 'separately'; end
if ~exist('baseKern'), baseKern = {'linard2','white','bias'}; end
if ~exist('itNo'), itNo = 2; end
if ~exist('initVardistIters'), initVardistIters = []; end
if ~exist('multVargplvm'), multVargplvm = false; end

if ~exist('dynamicsConstrainType'), dynamicsConstrainType = {'time'}; end

% That's for the ToyData2 function:
if ~exist('toyType'), toyType = 'gps'; end % Other options: 'gps'
if ~exist('hierSignalStrength'), hierSignalStrength = 1;  end
if ~exist('noiseLevel'), noiseLevel = 0.05;  end
if ~exist('numHierDims'), numHierDims = 1;   end
if ~exist('numSharedDims'), numSharedDims = 1; end
if ~exist('Dtoy'), Dtoy = 3;            end
if ~exist('Ntoy'), Ntoy = 18;           end


hsvargplvm_init;



globalOpt.dataSetName = 'toyDynamic';

[Ytr, dataSetNames, Z] = hsvargplvmCreateToyData2(toyType,Ntoy,Dtoy,numSharedDims,numHierDims, noiseLevel,hierSignalStrength);

if globalOpt.multOutput
    Ynew = [Ytr{1} Ytr{2}];
    Ytr = cell(1,size(Ynew,2));
    for i=1:size(Ynew,2)
        Ytr{i} = Ynew(:,i);
    end
end


%%
[options, optionsDyn] = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';

optionsAll = hsvargplvmCreateOptions(Ytr, options, globalOpt);
initXOptions = cell(1, options.H);
for h=1:options.H
    if strcmp(optionsAll.initX, 'vargplvm') | strcmp(optionsAll.initX, 'fgplvm')
        initXOptions{h}{1} = optionsAll;
        % DOn't allow the D >> N trick for layers > 1
        if h~=1
            if isfield(initXOptions{h}{1}, 'enableDgtN')
                initXOptions{h}{1}.enableDgtN = false;
            end
        end
        initXOptions{h}{1}.latentDim = optionsAll.Q{h};
        initXOptions{h}{1}.numActive = optionsAll.K{h}{1};
        initXOptions{h}{1}.kern = optionsAll.kern{h}{1};
        initXOptions{h}{1}.initX = 'ppca';
        initXOptions{h}{1}.initSNR = 90;
        initXOptions{h}{1}.numActive = 50;
        initXOptions{h}{2} = 160;
        initXOptions{h}{3} = 30;
        if exist('stackedInitVardistIters'),  initXOptions{h}{2} = stackedInitVardistIters;   end
        if exist('stackedInitIters'), initXOptions{h}{3} = stackedInitIters;   end
        if exist('stackedInitSNR'), initXOptions{h}{1}.initSNR = stackedInitSNR; end
        if exist('stackedInitK'), initXOptions{h}{1}.numActive = stackedInitK; end
    else
        initXOptions{h} = {};
    end
end
%---


model = hsvargplvmModelCreate(Ytr, options, globalOpt, initXOptions);

% Add prior on the parent node!!!
model = hsvargplvmAddParentPrior(model, globalOpt, optionsDyn);

params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);

modelInit = model;

model.globalOpt = globalOpt;

fprintf('# Scales after init. latent space:\n')
hsvargplvmShowScales(modelInit,false);
%%
if exist('skipGradchek') && skipGradchek
    model = hsvargplvmOptimise(model, true, itNo);
else
    model = hsvargplvmOptimise(model, true, itNo, 'gradcheck', true);
end


%[model,modelPruned, modelInitVardist] = hsvargplvmOptimiseModel(model, true, true);
