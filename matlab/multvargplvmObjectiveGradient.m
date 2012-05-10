function [f, g] = multvargplvmObjectiveGradient(params, model)

if nargout > 1
    [f,g] = svargplvmObjectiveGradient(params, model);
else
    f = svargplvmObjectiveGradient(params, model);
end