function options = hsvargplvmOptions(globalOpt, Ytr)



%-- One options structure where there are some parts shared for all
% models/layers and some parts specific for a few layers / submodels.


options = vargplvmOptions('dtcvar');

% Taken from globalOpt
options.H = globalOpt.H;
options.baseKern = globalOpt.baseKern;
options.Q = globalOpt.Q;
options.K = globalOpt.K;
options.enableDgtN = globalOpt.DgtN;
options.initial_X = globalOpt.initial_X;
options.initX = globalOpt.initX;

% 
options.optimiser = 'scg2';



% !!!!! Be careful to use the same type of scaling and bias for all models!!!
% scale = std(Ytr);
% scale(find(scale==0)) = 1;
%options.scaleVal = mean(std(Ytr));
% options.scaleVal = sqrt(var(Ytr{i}(:))); %%% ??
options.scale2var1 = globalOpt.scale2var1;




