%{
 
%}
% This demo is similar to demSkelDecomposeHsvargplvm1 but it has a greater
% variety of motions to learn from

% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);



if ~exist('experimentNo'), experimentNo = 404; end
if ~exist('baseKern'), baseKern = 'rbfardjit'; end 
if ~exist('initial_X'), initial_X = 'concatenated'; end

if ~exist('subject'), subject = '17'; end
dataSetName = 'motionDecompose2';


hsvargplvm_init;

%--- LOAD DATa
[Y, skel, remIndices]=hsvargplvmLoadSkelData(subject, true);
% ----------------

if globalOpt.multOutput
    %------- REMOVE dims with very small var (then when sampling outputs, we
    % can replace these dimensions with the mean)
    vA = find(var(Y) < 1e-7);
    meanRedundantDim = mean(Y(:, vA));
    dms = setdiff(1:size(Y,2), vA);
    Y = Y(:,dms);

    
    if ~isempty(vA)
        warning('Removed some dimensions with tiny variance!')
    end
    globalOpt.initial_X = 'concatenated';
    
    for d=1:size(Y,2)
        Yall{d} = Y(:,d);
    end
    %---
end

 

options = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';

%%
model = hsvargplvmModelCreate(Yall, options, globalOpt);

% Some dimensions might be not learned but nevertheless required as an
% output so that the dimensions are right (e.g. hsvargplvmClassVisualise).
% In that case, just pad these dims. with zeros
model.zeroPadding.rem = vA; % these are not learned
model.zeroPadding.keep = dms; % These are the ones kept

params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
modelInit = model;

%%
model.globalOpt = globalOpt; 

[model,modelPruned,modelInitVardist] = hsvargplvmOptimiseModel(model, true, true);

% For more iters...
%modelOld = model;
%model = hsvargplvmOptimiseModel(model, true, true, [], {0, [2000]});



return %%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%% VISUALISATION %%%%%%%%%%%%%%%%%%%%%%%%
% Now call:

%% %--- Scales
if globalOpt.multOutput
    close all
    SNR = hsvargplvmShowSNR(model,[],false);
    exclDim = find(SNR{1} < 6); % Exclude from the computations the dimensions that were learned with very low SNR
    [clu, clu2, clu3]= hsvargplvmClusterScales(model.layer{1},9,'skel59dim',exclDim);
    scales = hsvargplvmRetainedScales(model);
end

%%
cl = caxis; % From one of the above
close all
Xt = [1 8 15 24 33 42 51]; 
titles = {'Lleg','Rleg','Torso','Head','Lhand','Rhand'};
figure
for i=1:length(Xt)-1
    curInds = Xt(i):Xt(i+1)-1;
    cluSorted{i} = sort(clu(curInds));
    subplot(1,length(Xt),i); imagesc(cluSorted{i})'; caxis(cl); title(titles{i})
end
figure
for i=1:length(Xt)-1
    curInds = Xt(i):Xt(i+1)-1;
    clu2Sorted{i} = sort(clu2(curInds));
    subplot(1,length(Xt),i); imagesc(clu2Sorted{i})'; caxis(cl); title(titles{i})
end
figure
for i=1:length(Xt)-1
    curInds = Xt(i):Xt(i+1)-1;
    clu3Sorted{i} = sort(clu3(curInds));
    subplot(1,length(Xt),i); imagesc(clu3Sorted{i})'; caxis(cl); title(titles{i})
end

%% % --- Skeleton
m = 1;

% First, sample from the intermediate layer
model2 = model.layer{1}.comp{m};
model2.vardist = model.layer{1}.vardist;
model2.X = model2.vardist.means;
% Needed because here we learn on a different 59-dim space and need to map
% to the original 62-dim space
model2.Ytochannels = true; 
model2.y = Ytochannels(model2.y);
%channelsA = skelGetChannels(Yall{m});
dataType = 'skel';
lvmVisualiseGeneral(model2, [], [dataType 'Visualise'], [dataType 'Modify'],false, skel);

ylim([-12 15])

%% Maybe this code can be used for the leaves as well as a better
%alternative

figure
dataType = 'skel';
% Now from the parent
modelP = model;
modelP.type = 'hsvargplvm';
modelP.vis.index=-1;
modelP.vis.layer = 2; % The layer we are visualising FROM

modelP.vardist = model.layer{modelP.vis.layer}.vardist;
modelP.X = modelP.vardist.means;
modelP.q = size(modelP.X,2);

modelP.d = model.layer{model.H}.M;
YY = multvargplvmJoinY(model.layer{1});
Ynew = zeros(size(YY,1), size(YY,2)+length(vA));
Ynew(:, dms) = YY;
modelP.y = Ytochannels(Ynew);
modelP.Ytochannels = true; 


lvmVisualiseGeneral(modelP, [], [dataType 'Visualise'], [dataType 'Modify'],false, skel);
ylim([-20, 10]);
% USE e.g. ylim([-18 8]) to set the axis right if needed




