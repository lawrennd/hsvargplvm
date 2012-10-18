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

dataSetName = 'motionDecompose1';


hsvargplvm_init;

% ------- LOAD DATASET
%[Y,skel, channels] = loadMocapData();
[Y, lbls, Ytest, lblstest,skel] = lvmLoadData2('cmuXNoRoot', '02', {'01','05','10'});
Yorig = Y;
% REmove motion in xz?

seq = cumsum(sum(lbls)) - [1:31];
% Ywalk = Y(1:3:70,:); % Orig: Y(1:85,:);
% Ypunch = Y(86:13:548,:); % Orig: Y(86:548,:);
% Ywash = Y(549:20:1209,:); % Orig:  Y(549:1209,:);
Ywalk = Y(1:2:70,:); % Orig: Y(1:85,:);
Ypunch = Y(86:13:548,:); % Orig: Y(86:548,:);
Ywash = Y(830:6:1140,:); % Orig:  Y(549:1209,:);

[channels xyzDiffIndices] = skelGetChannels(Ywalk);
Ywalk(:, xyzDiffIndices) = zeros(size(Ywalk(:, xyzDiffIndices) ));
[channels xyzDiffIndices] = skelGetChannels(Ypunch);
Ypunch(:, xyzDiffIndices) = zeros(size(Ypunch(:, xyzDiffIndices) ));
[channels xyzDiffIndices] = skelGetChannels(Ywash);
Ywash(:, xyzDiffIndices) = zeros(size(Ywash(:, xyzDiffIndices) ));


Y = [Ywalk; Ywash];
[channels] = skelGetChannels(Y);
%close; skelPlayData(skel, channels, 1/5);
%skelPlayData(skel, channels, 1/20);
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
    [clu, clu2, clu3]= hsvargplvmClusterScales(model.layer{1},5,'skel59dim',exclDim);
    scales = hsvargplvmRetainedScales(model);
end

%% % --- Skeleton
% Now from the parent
dataType = 'skel';
modelP = model;
modelP.type = 'hsvargplvm';
modelP.vis.index=-1;
modelP.vis.layer = 1; % The layer we are visualising FROM ("to" is always layer 1)

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




















%%%%---------- OLD
%{
if ~isempty(vA)
    % If some dims. were taken out from training, put zeros to them % TODO
end
%%
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
%%
figure
visLayer = 1;
% Now from the parent
modelP = model;
modelP.type = 'hsvargplvm';
modelP.vardist = model.layer{2}.vardist;
modelP.X = modelP.vardist.means;
modelP.q = size(modelP.X,2);

if ~globalOpt.multOutput
    modelP.d = size(Yall{m},2);
    modelP.y = Ytochannels(Yall{m});
    modelP.Ytochannels = true;
    
    modelP.vis.index=m;
    modelP.vis.layer = 1;
    lvmVisualiseGeneral(modelP, [], [dataType 'Visualise'], [dataType 'Modify'],false, skel);
    ylim([-20, 10]);
    % USE e.g. ylim([-18 8]) to set the axis right if needed
else
    modelP.d = model.layer{visLayer}.M;
    modelP.y = Ytochannels(multvargplvmJoinY(model.layer{visLayer}));
    modeP.Ytochannels = true;
    modelP.vis.index = -1; % for hsvargplvmPosteriorMeanVar, meaning to compute for all outputs
    modelP.vis.layer = visLayer;
    modelP.vis.emptyDims = vA; %%%%%%%%%%%%%%%%%%%%%%%% TODO!!! This will be passed as argument
    % to hsvargplvmPosteriorMeanVar to tell it to put columns of zeros as
    % outputs for the dims of vA, as the skeleton visualisation needs these
    % dimensions but were not included in training.
    lvmVisualiseGeneral(modelP, [], [dataType 'Visualise'], [dataType 'Modify'],false, skel);
    ylim([-20, 10]);
end

%}

