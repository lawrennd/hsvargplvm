% Initialise options. If the field name of 'defaults' already exists as a
% variable, the globalOpt will take this value, otherwise the default one.

% hvargplvm_init

addpath(genpath('../../vargplvm/matlab'))
addpath(genpath('../../svargplvm/matlab/'))

defaults.experimentNo = 404;
defaults.itNo = [500 2000];
defaults.indPoints = 100;
defaults.latentDim = {10,10};
defaults.initVardistIters = 300;
% Set to 1 to tie the inducing points with the latent vars. X
defaults.fixInd = 0;
defaults.baseKern = 'rbfardjit'; %{'rbfard2', 'white'};
defaults.dynamicKern = {'rbf','white', 'bias'};
defaults.initX = 'ppca';
%%%defaults.backConstraints = 1; % Substituted with dynamicsConstrainType
defaults.vardistCovarsMult = 2; 
defaults.dataSetName = 'skelDecompose';  % 'bc/wine', 'bc/...'
defaults.demoType = 'skelDecompose';  % 'bc/wine', 'bc/...'
defaults.dataOptions = {};
defaults.mappingInitialisation = 0;
defaults.scale2var1 = 0;
% Set to -1 to use all data. Set to scalar d, to only take d points from
% each class. Set to a vector D with length equal to the number of classes C,
% to take D(c) points from class c.
defaults.dataPerClass = -1;
% Set to -1 to keep all the training data, set to a number N to only keep N
% datapoints.
defaults.dataToKeep = -1;
% Signal to noise ratio (initialisation for model.beta).
defaults.initSNR = 100;
% How many iterations to do to initialise the model with a static B. gplvm.
% -1 means that no such initialisation will be done.
defaults.initWithStatic = -1;
% If initWithStatic ~= -1, this says how many iters with fixed
% beta/sigmaf to perform.
defaults.initWithStaticInitVardist = 300;
% If initWithStatic ~= -1, this says what the initial SNR will be for the
% initial static model.
defaults.initStaticSNR = 25;
% If true, then if also initWithStatic ~=1, we initialise the model.beta
% and model.kern based on the initialised static model.
defaults.initWithStaticAll = false;
defaults.dynamicsConstrainType = []; % {'time'}; % Leave empty [] for no dynamics
% If set to fals, then the dynamics kernel is not initialised with
% bc_initdynKernel
defaults.initDynKernel = 1;
% A second (probably better) way to initialise the model
defaults.initDynKernel2 = 0;
% See bc_backConstraintsModelCreate and bc_restorePrunedModel
defaults.labelMatrixPower = 0.5;
% if not empty, the corresponding gradients of the kernel will be zero,
% i.e. not learning these elements (typically for the variance of the
% rbf/matern etc of a invcmpnd)
defaults.fixedKernVarianceIndices = [];
% If discrKernel is 'ones', then the discriminative kernel is
% simply build based on a matrix with ones and minus ones, otherwise it is
% based on a measure on the distance of each label from the mean of each
% class.
defaults.discrKernel = 'ones';
% Default variance for a fixedwhite kernel
defaults.fixedwhiteVar = 1e-5;
% If set to some value, call it x, then after learning a constrained model,
% (and if the function runStaticModel is called), a static model will be
% initialised with the constrained model's latent space and learned for x iterations.
defaults.runStaticModel = -1;
defaults.runStaticModelInitIters = [];
% Possible values: (none, one or both of them): 'labelsYinputs' and
% 'labelsYoutputs'. If the first is there, then the Y of p(X|Y) is
% augmented with the labels as C extra dimensions, where C is the total
% number of classes (as we use 1-of-K encoding). Similarly with labelsYoutputs.
defaults.dataConstraints = {};
% Option to only run a static model.
defaults.staticOnly = false;
defaults.periodicPeriod = 2*pi;
defaults.givenStaticModel = [];
defaults.learnKernelVariance = 0;
% Replaces optionsDyn.inverseWidth
defaults.inverseWidthMult = 20;
defaults.reconstrIters = 1500;

defaults.DgtN = false;
defaults.numLayers = 2;
defaults.indTr = -1; % All data in the training set
defaults.latentDimPerModel =1;
defaults.latentDim = 15;
defaults.initial_X = 'concatenated';
defaults.displayIters = true;
defaults.enableParallelism = true;

 fnames = fieldnames(defaults);
 for i=1:length(fnames)
    if ~exist(fnames{i})
        globalOpt.(fnames{i}) = defaults.(fnames{i});
    else
        globalOpt.(fnames{i}) = eval(fnames{i});
    end
 end
 
 
 clear('defaults', 'fnames');

