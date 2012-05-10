function Y = multvargplvmJoinY(model)
Y = zeros(model.N, model.numModels);  %% Or model.d?

for i=1:model.numModels
    Y(:,i) = model.comp{i}.y;
end
