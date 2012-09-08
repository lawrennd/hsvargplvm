
% model, pruneModel, saveModel, globalOpt, {initVardistIters, itNo} 
% (the last two arguments override the globalOpt values)
function [model, modelPruned] = hsvargplvmOptimiseModel(model, varargin)

pruneModel = true;
saveModel = true;

if isfield(model, 'saveName')
    if strcmp(model.saveName, 'noSave')
        saveModel = false;
    end
end

if isfield(model, 'globalOpt')
    globalOpt = model.globalOpt;
else
    globalOpt = varargin{3};
end


if nargin > 2
    pruneModel = varargin{1};
    if length(varargin) > 1
        saveModel = varargin{2};
    end

    if length(varargin) > 3
        globalOpt.initVardistIters = varargin{4}{1};
        globalOpt.itNo = varargin{4}{2};
    end
end

if ~isfield(model, 'optim'), model.optim = []; end
if ~isfield(model.optim, 'iters'),  model.optim.iters=0; end
if ~isfield(model.optim, 'initVardistIters'),  model.optim.initVardistIters = 0; end
% Number of evaluatiosn of the gradient
if ~isfield(model.optim, 'gradEvaluations'), model.optim.gradEvaluations = 0; end
% Number of evaluations of the objective (including line searches)
if ~isfield(model.optim, 'objEvaluations'), model.optim.objEvaluations = 0; end


display = 1;


i=1;
while ~isempty(globalOpt.initVardistIters(i:end)) || ~isempty(globalOpt.itNo(i:end))
    % do not learn beta for few iterations for intitilization
    if  ~isempty(globalOpt.initVardistIters(i:end)) && globalOpt.initVardistIters(i)
        %model.initVardist = 1; model.learnSigmaf = 0;
        model = hsvargplvmPropagateField(model,'initVardist', true, globalOpt.initVardistLayers);
        model = hsvargplvmPropagateField(model,'learnSigmaf', false, globalOpt.initVardistLayers);
        fprintf(1,'# Intitiliazing the variational distribution...\n');
        [model, gradEvaluations, objEvaluations] = hsvargplvmOptimise(model, display, globalOpt.initVardistIters); % Default: 20
        hsvargplvmShowSNR(model,[2:model.H]);
        model.optim.initVardistIters = model.optim.initVardistIters + globalOpt.initVardistIters(i);
        model.optim.gradEvaluations = model.optim.gradEvaluations + gradEvaluations;
        model.optim.objEvaluations = model.optim.objEvaluations + objEvaluations;
        if saveModel
            fprintf('# Saving model after optimising beta for %d iterations...\n\n', globalOpt.initVardistIters(i))
            if pruneModel
                modelPruned = hsvargplvmPruneModel(model);
                vargplvmWriteResult(modelPruned, modelPruned.type, globalOpt.dataSetName, globalOpt.experimentNo);
            else
                vargplvmWriteResult(model, model.type, globalOpt.dataSetName, globalOpt.experimentNo);
            end
        end
    end

    hsvargplvmShowScales(model, false);
    
    % Optimise the model.

    model.date = date;
    if  ~isempty(globalOpt.itNo(i:end)) && globalOpt.itNo(i)
        model = hsvargplvmPropagateField(model,'initVardist', false, globalOpt.initVardistLayers);
        model = hsvargplvmPropagateField(model,'learnSigmaf', true, globalOpt.initVardistLayers);

        iters = globalOpt.itNo(i); % Default: 1000
        fprintf(1,'# Optimising the model for %d iterations (session %d)...\n',iters,i);
        [model, gradEvaluations, objEvaluations] = hsvargplvmOptimise(model, display, iters);
        hsvargplvmShowSNR(model);
        model.optim.iters = model.optim.iters + iters;
        model.optim.gradEvaluations = model.optim.gradEvaluations + gradEvaluations;
        model.optim.objEvaluations = model.optim.objEvaluations + objEvaluations;
        % Save the results.
        if saveModel
            fprintf(1,'# Saving model after doing %d iterations\n\n',iters)
            if pruneModel
                modelPruned = hsvargplvmPruneModel(model);
                vargplvmWriteResult(modelPruned, modelPruned.type, globalOpt.dataSetName, globalOpt.experimentNo);
            else
                vargplvmWriteResult(model, model.type, globalOpt.dataSetName, globalOpt.experimentNo);
            end
        end
    end
    i = i+1;
end

