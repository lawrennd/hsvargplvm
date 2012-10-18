
% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);


%--
dataSetName = 'horses';
if ~exist('Q'), Q = 15; end
if ~exist('initVardistIters'), initVardistIters = 1000; end
if ~exist('K'), K = 80; end

if ~exist('itNo'), itNo = [1000 2000]; end
initSNR = {50,90};
initVardistLayers = 1:2;
baseKern='rbfardjit';

if ~exist('scale2var1'), scale2var1 = true; end
if ~exist('binarizeData'), binarizeData = true; end
%--



[Ytr, lbls, Yts] = vargplvmLoadData('weizmann_horses');
height = lbls(1); width = lbls(2);
YtsOriginal = Yts;

% Binarize values
if binarizeData
    zeroInd = find(Ytr < 255/2);
    oneInd = find(Ytr >= 255/2);
    Ytr(zeroInd) =  0;
    Ytr(oneInd) = 1;
    clear('zeroInd', 'oneInd');
end

hsvargplvm_init;



%%
options = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';
options.enableDgtN = globalOpt.DgtN;


model = hsvargplvmModelCreate(Ytr, options, globalOpt);


params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
modelInit = model;

model.globalOpt = globalOpt;
[model,modelPruned, modelInitVardist] = hsvargplvmOptimiseModel(model, true, true);

% For more iters...
%modelOld = model;
%model = hsvargplvmOptimiseModel(model, true, true, [], {0, [1000 1000 1000]});