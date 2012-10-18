clear

N = 200; 
D1 = 60;
D2 = 50;

Ytr{1} = rand(N,D1);
Ytr{2} = rand(N,D2);
Q = 100;
K = 100;

baseKern = {'rbfard2','white','bias'};
%baseKern = 'rbfardjit';

hsvargplvm_init;
options = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';

model = hsvargplvmModelCreate(Ytr, options, globalOpt);

params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
model = orderfields(model);




modelInit = model;

prunedModel = hsvargplvmPruneModel(model);
model2 = hsvargplvmRestorePrunedModel(prunedModel, Ytr);
params = hsvargplvmExtractParam(model2);
model2 = hsvargplvmExpandParam(model2, params);

for h=1:model.H
    for m=1:model.layer{h}.M
        model.layer{h}.comp{m} = orderfields(model.layer{h}.comp{m});
    end
    model.layer{h} = orderfields(model.layer{h});
end

for h=1:model2.H
    for m=1:model2.layer{h}.M
        model2.layer{h}.comp{m} = orderfields(model2.layer{h}.comp{m});
    end
    model2.layer{h} = orderfields(model2.layer{h});
end


a=comp_struct(model, model2);
b=comp_struct(model2, model);
if ~isempty({a{:}, b{:}})
    a
    b
    error('Not mathch!')
else
    disp('OK!')
end

ByteSize(model)
ByteSize(prunedModel)