% TODO: 1) Fix X_u to inpX (not tie, fix). Or fix X_u to the ones optimised by
% fitc GP.
% 2) In the "inputs" initialisation of X, actually initialise with scaled X 
% 3) Tie inducing points in hsvargplvm to X.
% 



% A simple script run on simple hierarchical toy data.
%
% clear; Ntoy=30; K=6;Q=2; multOutput = 0; doGradchek = 1; demToyDynamics % gradchek !! Uncomment the multOutput code
%
% experimentNo = 1; toyType = 'hgplvmSample2';
%   baseKern='rbfardjit'; Q = {6,3}; initSNR = {100, 300}; initial_X = 'separately';
%   initVardistLayers = 1:2; initVardistIters = 250; itNo = [5000 1000]; demToyHsvargplvm1;
%
% clear; initVardistIters = 400; initSNR = {100, 300}; itNo = [500 500]; K=60; trendEffect=2; Q=10; tic; demToyDynamics; toc
% clear; initVardistIters = 400; H=3; initSNR = {100, 300, 300}; itNo = [500 500];K=60; trendEffect=2; Q=10; tic; demToyDynamics; toc
% clear; initVardistIters = 400; H=2; initSNR = {100, 300}; itNo = [500 500];K=60; toyType='hgplvmSample2'; Q=5; tic; demToyDynamics; toc
% clear; initVardistIters = 400; H=3; Ntr=15;  initSNR = {100, 2000, 2000}; itNo = [500 500];K=60; trendEffect=2; Q=10; tic; demToyDynamics; toc
% clear; initVardistIters = 600; H=2; initSNR = {230, 15000}; itNo = [100];K=60; toyType='hierGps'; Dtoy=10; Q=Dtoy; initX='outputs';Ntr=30;vardistCovarsMult=1.5; demToyDynamics;
% clear; initVardistIters = 400; H=2; Ntr=15; initSNR = {100, 200}; itNo = [100];K=60; toyType='hierGpsNonstat'; Q=Dtoy; initX='outputs'; demToyDynamics;
% clear; initVardistIters = 400; H=2; Ntr=40; initSNR = {100, 300}; itNo = [100];K=60; toyType='nonstationaryLog'; Dtoy=10; Q=Dtoy; vardistCovarsMult=2; demToyDynamics;
% clear; initVardistIters = 400; H=2; Ntr=12; initSNR = {100, 300}; itNo = [100];K=60; toyType='nonstationaryLog'; Dtoy=10; Q=Dtoy; initX='outputs'; vardistCovarsMult=2; demToyDynamics;
% clear; initVardistIters = 400; H=2; Ntr=15; initSNR = {100, 2000}; itNo = [500];K=60; trendEffect=2; Q=10; tic; demToyDynamics; toc
% ! clear; initVardistIters = 1000; H=2; Ntr=15; initSNR = {200, 80000};initX='outputs'; itNo = [];K=60; trendEffect=1; vardistCovarsMult=2;Q=10; demToyDynamics;

% Only run the hierarchical:
% clear; dynamicKern = {'lin','white','bias'};initVardistIters = 400; H=2; initSNR = {100, 100}; itNo = [100];K=60; toyType='hierGpsNEW'; Dtoy=10; Q={1, 1}; initX='inputs';Ntr=20;vardistCovarsMult=[]; runGP=0;learnInducing=1;demToyDynamics;fprintf('# Error GPLVM pred   : %.4f / %.4f (with/without covars)\n', errorGPLVM, errorGPLVMNoCovars);fprintf('# Error GPLVMInitPred: %.4f\n',errorGPLVMIn);

% SEE ALSO: demMultvargplvmStackToy1.m

% Fix seeds
%randn('seed', 1e5);
%rand('seed', 1e5);

addpath(genpath('../'))

if ~exist('experimentNo'), experimentNo = 404; end
if ~exist('K'), K = 30; end
if ~exist('Q'), Q = 6; end
if ~exist('initial_X'), initial_X = 'separately'; end
if ~exist('baseKern'), baseKern = 'rbfardjit'; end % {'rbfard2','white','bias'}; end
if ~exist('itNo'), itNo = 100; end
if ~exist('initVardistIters'), initVardistIters = []; end
if ~exist('H'), H = 2; end
if ~exist('multVargplvm'), multVargplvm = false; end

if ~exist('dynamicsConstrainType'), dynamicsConstrainType = {'time'}; end

% That's for the ToyData2 function:
if ~exist('toyType'), toyType = 'nonstationary'; end % Other options: 'gps'
if ~exist('hierSignalStrength'), hierSignalStrength = 1;  end
if ~exist('noiseLevel'), noiseLevel = 0.01;  end
if ~exist('numHierDims'), numHierDims = 2;   end
if ~exist('numSharedDims'), numSharedDims = 2; end
if ~exist('Dtoy'), Dtoy = 10;            end
if ~exist('Ntoy'), Ntoy = 120;           end
if ~exist('trendEffect'), trendEffect = 2;           end
if ~exist('vardistCovarsMult'), vardistCovarsMult = 1; end
if ~exist('runVGPDS'), runVGPDS = false; end

hsvargplvm_init;

% Automatically calibrate initial variational covariances
globalOpt.vardistCovarsMult = [];


if ~exist('Ntr'), Ntr = ceil(Ntoy/2); end

globalOpt.dataSetName = 'toyDynamic';

%[X,Y,Yorig,t,model] = hgplvmSampleModel3(2, 4, 100,5,false);

demToyDynamicsCreateData
demToyDynamicsSplitDataset % Split into training and test set

%%
if ~(exist('runGP') && ~runGP)
    fprintf('# ----- Training a normal GP... \n')
    optionsGP = gpOptions('ftc');
    if ~strcmp(optionsGP.approx, 'ftc')
        optionsGP.numActive = size(inpX,1);
    end
    % Scale outputs to variance 1.
    %optionsGP.scale2var1 = true;
    modelGP = gpCreate(size(inpX,2), size(Ytr{1},2), inpX, Ytr{1}, optionsGP);
    modelGP = gpOptimise(modelGP, 1, 1000);
    [muGP, varSigmaGP] = gpPosteriorMeanVar(modelGP, Xstar);
    errorGP = sum(mean(abs(muGP-Yts{1}),1));
    errorRecGP = sum(mean(abs(gpPosteriorMeanVar(modelGP, inpX)-Ytr{1}),1));
    %{
close
for i=1:size(muGP,2)
    plot(muGP(:,i), 'x-'); hold on; plot(Yts{1}(:,i), 'ro-'); hold off; pause
end
    %}
end
%%
[options, optionsDyn] = hsvargplvmOptions(globalOpt, inpX);


% ---- Special initialisations for X -----
if ~iscell(globalOpt.initX) && strcmp(globalOpt.initX, 'inputs')
    options = rmfield(options, 'initX');
    for i=1:options.H
        options.initX{i} = inpX;
    end
    optionsDyn.initX = inpX;
    globalOpt.initX = options.initX;
end

% Initialise half of the latent spaces with inputs, half with PCA on outputs
if ~iscell(globalOpt.initX) && strcmp(globalOpt.initX, 'inputsOutputs')
    options = rmfield(options, 'initX');
    oldQ = Q; clear Q
    for i=options.H:-1:floor(options.H/2)+1
        options.initX{i} = inpX;
        Q{i} = size(inpX,2);
    end
    optionsDyn.initX = inpX;

    YtrScaled = scaleData(Ytr{1}, options.scale2var1); 
    Xpca  = ppcaEmbed(YtrScaled, oldQ);
    for i=1:floor(options.H/2)
        options.initX{i} = Xpca;
        Q{i} = oldQ;
    end
    options.Q = Q;
    globalOpt.Q = Q;
    globalOpt.initX = options.initX;
end



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


%--
% Learn inducing points? (that's different to fixInducing, ie tie them
% to X's, if learnInducing is false they will stay in their original
% values, ie they won't constitute parameters of the model).
if exist('learnInducing') && ~learnInducing
    model = hsvargplvmPropagateField(model, 'learnInducing', false);
    % If we initialise X with the inputs (for regression) then fix the
    % inducing points to these inputs (that's not necessarily good, check
    % also without this option).
%    for h=1:options.H
%        if ~ischar(options.initX{h})
%            for m=1:model.layer{h}.M
%                model.layer{h}.comp{m}.X_u = inpX;
%            end
%        end
%    end
end
%--

if globalOpt.fixInducing && globalOpt.fixInducing
    model = hsvargplvmPropagateField(model, 'fixInducing', true);
    for m=1:model.layer{end}.M % Not implemented yet for parent node
        model.layer{end}.comp{m}.fixInducing = false;
    end
end

params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);

modelInit = model;

model.globalOpt = globalOpt;
model.parallel = globalOpt.enableParallelism;

fprintf('# Scales after init. latent space:\n')
hsvargplvmShowScales(modelInit,false);
%%
if exist('doGradchek') && doGradchek
    %model = hsvargplvmOptimise(model, true, itNo);
    if isfield(model.layer{end}, 'dynamics')
        model.layer{end}.dynamics.learnVariance = 1; % For the gradchek to pass
    end
    model = hsvargplvmOptimise(model, true, itNo, 'gradcheck', true);
else
    [model,modelPruned, modelInitVardist] = hsvargplvmOptimiseModel(model, true, true);
end


% For more iters...
% modelOld = model; [model,modelPruned, ~] = hsvargplvmOptimiseModel(model, true, true, [], {0, [100]});



%% ----- Run VGPDS
if runVGPDS
    % Temporary: just to print the hier.GPLVM and GP results before
    % training VGPDS
    runVGPDS = false;
    demToyDynamicsPredictions
    runVGPDS = true;

    optionsVGPDS = vargplvmOptions('dtcvar');
    optionsVGPDS.kern = 'rbfardjit';
    optionsVGPDS.numActive = globalOpt.K;
    optionsVGPDS.optimiser = 'scg2';
    optionsVGPDS.initSNR = 100;
    optionsVGPDS.fixInducing = 1;
    optionsVGPDS.fixIndices = 1:size(Ytr{1},1);
    
    if iscell(options.initX)
        optionsVGPDS.initX = options.initX{1};
    else
        optionsVGPDS.initX = options.initX;
    end
    
    fprintf('# ----- Training VGPDS... \n')
    if iscell(Q), Qvgpds=Q{1}; else Qvgpds = Q; end
    if ~exist('VGPDSinitVardistIters'), VGPDSinitVardistIters = 100; end
    if ~exist('VGPDSiters'), VGPDSiters = 220; end
    [XVGPDS, sigma2, W, modelVGPDS,modelInitVardistVGPDS] = vargplvmEmbed(Ytr{1}, Qvgpds, optionsVGPDS,VGPDSinitVardistIters,VGPDSiters,1,optionsDyn);
    [TestmeansVGPDS TestcovarsVGPDS] = vargplvmPredictPoint(modelVGPDS.dynamics, Xstar);
    [muVGPDS, varsigmaVGPDS] = vargplvmPosteriorMeanVar(modelVGPDS, TestmeansVGPDS, TestcovarsVGPDS);
    errorVGPDS = sum(mean(abs(muVGPDS-Yts{1}),1));

    [TestmeansVGPDSIn TestcovarsVGPDSIn] = vargplvmPredictPoint(modelInitVardistVGPDS.dynamics, Xstar);
    [muVGPDSIn, varsigmaVGPDSIn] = vargplvmPosteriorMeanVar(modelInitVardistVGPDS, TestmeansVGPDSIn, TestcovarsVGPDSIn);
    errorVGPDSIn = sum(mean(abs(muVGPDSIn-Yts{1}),1));
    
    [TestmeansTrVGPDS TestcovarsTrVGPDS] = vargplvmPredictPoint(modelVGPDS.dynamics, inpX);
    errorRecVGPDS = sum(mean(abs(vargplvmPosteriorMeanVar(modelVGPDS, TestmeansTrVGPDS, TestcovarsTrVGPDS)-Ytr{1}),1));
end

%% Predictions
demToyDynamicsPredictions

%% Sample from the trained model
