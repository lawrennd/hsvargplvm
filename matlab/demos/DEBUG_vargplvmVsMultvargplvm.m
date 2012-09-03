%%%% In the below, compare model (of vargplvm) with model.comp{1} of
%%%% multvargplvm.

%%% It seems that they are the same (apart from the scale's
%%% initialisation), but nevertheless multvargplvm with many submodels is
%%% numerically unstable.

clear
Y = vargplvmLoadData('hierarchical/demHighFiveHgplvm1',[],[],'YA');
Y = scaleData(Y);
initX = ppcaEmbed(Y,4);

Y = Y(:,1);
latentDim = 4;
initVardistIters = 30;
itNo = 40;
indPoints = -1;
mappingKern = {'linard2','white','bias'};

demVargplvm1
%%

clear
Y = vargplvmLoadData('hierarchical/demHighFiveHgplvm1',[],[],'YA');
Y = scaleData(Y);
initX = ppcaEmbed(Y,4); 
%initX = pcaEmbed(Y,4); % -> This causes problems

% Y = Y(:,1:30); %%% NUMERICAL INSTABILITIES AFTER I PUT > ~40 DIMS
% --> I can therefore do the following:
% a) Y = ... (vargplvm reduction to D2 dimensions, or fgplvm)
% b) Y = ppcaEmbed(Y, 30); %--> BETTER WITH pcaEmbed 
Y = ppcaEmbed(Y,30);

latentDim = 4;
initVardistIters = 20;%30;
itNo = [];%40;
hsvargplvm_init
for i=1:size(Y,2)
    globalOpt.baseKern{i} = {'linard2','white','bias'};
end
demMultvargplvm

% !!!!!!!!!!!!!!!!!!!! PROBLEM FOUND: variance in some dimensions was too
% small and initial beta was too big.


%% See also demMultvargplvmHighFive1.m