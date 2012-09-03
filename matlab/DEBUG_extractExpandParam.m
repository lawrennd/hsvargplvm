clear
N = 10; 
D1 = 6;
D2 = 5;

Ytr{1} = rand(N,D1);
Ytr{2} = rand(N,D2);
Q = 2;
K = 3;

baseKern = {'rbfard2','white','bias'};
%baseKern = 'rbfardjit';

hsvargplvm_init;
options = hsvargplvmOptions(globalOpt);
model = hsvargplvmModelCreate(Ytr, options, globalOpt);

%%
sum(sum(abs(model.layer{2}.comp{1}.m - scaleData(model.layer{1}.vardist.means))))

%%
params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);

mm = model;

mm.layer{1}.comp{1}.X_u = rand(size(mm.layer{1}.comp{1}.X_u)) .*10;
mm.layer{1}.comp{2}.X_u = rand(size(mm.layer{1}.comp{1}.X_u)).*10;
mm.layer{2}.comp{1}.X_u = rand(size(mm.layer{1}.comp{1}.X_u)).*10;


mm.layer{1}.comp{1}.kern.comp{1}.inputScales = rand(size(mm.layer{1}.comp{1}.kern.comp{1}.inputScales)).*10;
mm.layer{1}.comp{2}.kern.comp{1}.inputScales = rand(size(mm.layer{1}.comp{1}.kern.comp{1}.inputScales)).*10;
mm.layer{2}.comp{1}.kern.comp{1}.inputScales = rand(size(mm.layer{2}.comp{1}.kern.comp{1}.inputScales)).*10;
mm.layer{1}.vardist.means = rand(size(mm.layer{1}.vardist.means)).*10;
mm.layer{2}.vardist.means = rand(size(mm.layer{2}.vardist.means)).*10;
mm.layer{2}.vardist.covars = rand(size(mm.layer{2}.vardist.covars)).*10;
mm.layer{1}.vardist.covars = rand(size(mm.layer{1}.vardist.covars)).*10;

mm.layer{2}.comp{1}.beta = rand.*10;
mm.layer{1}.comp{1}.beta = rand.*10;
mm.layer{1}.comp{2}.beta = rand.*10;

comp_struct(model.layer{1},mm.layer{1})
comp_struct(model.layer{2},mm.layer{2})
comp_struct(model.layer{1}.comp{1},mm.layer{1}.comp{1})
comp_struct(model.layer{1}.comp{2},mm.layer{1}.comp{2})
comp_struct(model.layer{2}.comp{1},mm.layer{2}.comp{1})

params = hsvargplvmExtractParam(model);
mm = hsvargplvmExpandParam(mm, params);


comp_struct(model.layer{1},mm.layer{1})
comp_struct(model.layer{2},mm.layer{2})
comp_struct(model.layer{1}.comp{1},mm.layer{1}.comp{1})
comp_struct(model.layer{1}.comp{2},mm.layer{1}.comp{2})
comp_struct(model.layer{2}.comp{1},mm.layer{2}.comp{1})
