function model = multVargplvmStackModels(prevModel, curLayer, Q, iters, saveName, saveIntermediate, globalOpt)

if nargin < 7
    globalOpt = prevModel.globalOpt;
end
if nargin < 6
    saveName =[];
end

if ~isempty(globalOpt)
    hsvargplvm_init;
end

experimentNo = 404;


for i=1:size(prevModel.X,2)
    Ytr{i} = prevModel.X(:,i);
end

globalOpt.indPoints = min(globalOpt.indPoints, size(Ytr{1},1));
globalOpt.latentDim = min(Q, prevModel.q);

%%

options = svargplvmOptions(Ytr, globalOpt);
optionsDyn= [];



model = multvargplvmCreate(Ytr, globalOpt, options, optionsDyn);
model.type = 'stackedVargplvm';

if globalOpt.enableParallelism
    fprintf('# Parallel computations w.r.t the submodels!\n');
    model.parallel = 1;
    model = svargplvmPropagateField(model,'parallel', 1);
end

if ~isempty(saveName)
    model.saveName = saveName;
else
    model.saveName = vargplvmWriteResult([], 'stackedVargplvm', '',experimentNo,['Layer' num2str(curLayer)]);
end

%model = svargplvmPropagateField(model, 'learnSigmaf',1);%%%%%
% Force kernel computations
params = svargplvmExtractParam(model);
model = svargplvmExpandParam(model, params);
model.globalOpt = globalOpt;
%%
%fprintf('# Median of vardist. covars: %d \n',median(median(model.vardist.covars)));
%fprintf('# Min of vardist. covars: %d \n',min(min(model.vardist.covars)));
%fprintf('# Max of vardist. covars: %d \n',max(max(model.vardist.covars)));

% model, pruneModel, saveModel, {initVardistIters, itNo}
if globalOpt.displayIters
    model = svargplvmOptimiseModel(model, true, saveIntermediate, iters);
else
    model = svargplvmOptimiseModelNoDisplay(model, true, saveIntermediate, iters);
end

