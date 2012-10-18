function Y = multvargplvmJoinY(model)
if ~isfield(model, 'numModels') && isfield(model, 'M')
    model.numModels = model.M;
end

if model.numModels == 1
    Y = model.comp{1}.y;
else % there's nothing to join
    Y = zeros(model.N, model.numModels);  %% Or model.d?
    
    for i=1:model.numModels
        Y(:,i) = model.comp{i}.y;
    end
end