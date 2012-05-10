function [params, names] = multvargplvmExtractParam(model)

if nargout  > 1
[params, names] = svargplvmExtractParam(model);
else
    params = svargplvmExtractParam(model);
end
