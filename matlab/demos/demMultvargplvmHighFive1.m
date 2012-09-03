%{
clear
experimentNo = 3;
initSNR = 30;
initVardistIters = 100;
itNo = [];
mappingKern = {'linard2','white','bias'};
demMultvargplvmHighFive1
%}

%{
experimentNo = 3;
initVardistIters = 50;
itNo = 200;
mappingKern = 'rbfardjit';
demMultvargplvmHighFive1
clear
experimentNo = 3;
initVardistIters = 20;
itNo = 100;
mappingKern = 'rbfardjit';
demMultvargplvmHighFive1
%}

% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);

% ------- LOAD DATASET
YA = vargplvmLoadData('hierarchical/demHighFiveHgplvm1',[],[],'YA');
YB = vargplvmLoadData('hierarchical/demHighFiveHgplvm1',[],[],'YB');


%YA = ppcaEmbed(YA, 15);
%YB = ppcaEmbed(YB, 15);

% ---------- REDUCE Y
% Y = Y(:,1:30); %%% NUMERICAL INSTABILITIES AFTER I PUT > ~40 DIMS
% --> I can therefore do the following:
% a) Y = ... (vargplvm reduction to D2 dimensions, or fgplvm)
% b) Y = ppcaEmbed(Y, 30); %--> BETTER WITH pcaEmbed 
%Y = pcaEmbed(Yorig,30);

%------- REMOVE dims with very small var
%YA = scaleData(YA,true,[]); % This removes some of the dims with ery small var.
%YB = scaleData(YB,true,[]);
% But the following is better (?)
vA = find(var(YA) < 1e-7);
dmsA = setdiff(1:size(YA,2), vA);
YA = YA(:,dmsA);
vB = find(var(YB) < 1e-7);
dmsB = setdiff(1:size(YB,2), vB);
YB = YB(:,dmsB);
%---


Yorig = [YA YB];
%Yorig = scaleData(Yorig);
Y = Yorig;

% ---------- INIT X for all models
latentDim = 4;
initX = ppcaEmbed(Y,latentDim); 
%initX = pcaEmbed(Y,4); % -> This causes problems



% ----------- OPTIONS
inputScales = 0.5*ones(1,latentDim)+randn(1,latentDim)*0.08;

%---
%initVardistIters = 50;
%itNo = 200;
%mappingKern = {'linard2','white','bias'};
%---

hsvargplvm_init

for i=1:size(Y,2)
    globalOpt.baseKern{i} = globalOpt.mappingKern;
end

demMultvargplvm

multvargplvmShowScales(model)




%% OLD

% addpath(genpath('../'))
% 
% try
%     keep('Y')
%     Yorig = Y;
% catch e
%     keep('Yorig') % from demHighFive1.m
%     Y = Yorig;
% end
% 
% 
% %-
% Ynew = Y;
% scale = std(Y);
% bias = mean(Y);
% for i = 1:size(Y,2)
%   Ynew(:, i) = Ynew(:, i) - bias(i);
%   if scale(i)
%     Ynew(:, i) = Ynew(:, i)/scale(i);
%   end
% end
% Y = Ynew;
% %-
% 
% experimentNo=1;
% saveName = 'demHighFiveMultvargplvm1.mat';
% 
% initVardistIters = 50;
% itNo = 200;
% hsvargplvm_init
% for i=1:size(Y,2)
%     globalOpt.baseKern{i} = {'rbfard2','white','bias'}; % ORIG: linard2
% end
% %-- options
% globalOpt.enableParallelism = 1;
% globalOpt.initial_X = 'concatenated'; globalOpt.latentDim = 4; % globalOpt.scale2var1 = 1;
% demMultvargplvm

%%