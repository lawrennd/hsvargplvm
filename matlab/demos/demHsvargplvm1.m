% Simple script with random data, mostly to do gradchek and test
% development

addpath(genpath('../'));

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
options.optimiser = 'scg2';

model = hsvargplvmModelCreate(Ytr, options, globalOpt);

params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
modelInit = model;


model = hsvargplvmOptimise(model, true, 20, 'gradcheck', true);

%%
%A 3 layer hierarchy!

addpath(genpath('../'));

clear

N = 10; 
D1 = 6;
D2 = 5;

Ytr{1} = rand(N,D1);
Ytr{2} = rand(N,D2);
Q = 2;
K = 3;
H = 3;

baseKern = {'rbfard2','white','bias'};
%baseKern = 'rbfardjit';

hsvargplvm_init;
options = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';

model = hsvargplvmModelCreate(Ytr, options, globalOpt);

params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
modelInit = model;


model = hsvargplvmOptimise(model, true, 20, 'gradcheck', true);
