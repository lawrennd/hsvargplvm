%{
clear; experimentNo=1;  baseKern = 'rbfardjit'; dataMerging = 'vercat';
initVardistIters = 500; itNo = [500 500 500 500]; initSNR = {100,1500}; 
initVardistLayers = 1:2; indPoints=100; demSkelDecomposeHsvargplvm1;


clear; experimentNo=2;  baseKern = 'rbfardjit'; dataMerging = 'YA';
initVardistIters = 500; itNo = [500 500 500 500]; initSNR = {100,1500}; 
initVardistLayers = 1:2; indPoints=-1; demSkelDecomposeHsvargplvm1;


clear; experimentNo=3;  baseKern = 'rbfardjit'; dataMerging = 'horalign';
initVardistIters = 500; itNo = [500 500 500 500]; initSNR = {100,1500}; 
initVardistLayers = 1:2; indPoints=-1; demSkelDecomposeHsvargplvm1;
%}


% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);



if ~exist('experimentNo'), experimentNo = 404; end
if ~exist('baseKern'), baseKern = 'rbfardjit'; end %baseKern = {'linard2','white','bias'};
if ~exist('initial_X'), initial_X = 'separately'; end
if ~exist('dataMerging'), dataMerging = 'vercat'; end

dataSetName = 'skelDecompose';


hsvargplvm_init;

% ------- LOAD DATASET


lbls=[];
[Y, lbls] = lvmLoadData('cmu35WalkJog');
seq = cumsum(sum(lbls)) - [1:31];

% load data
[Y, lbls, Ytest, lblstest] = lvmLoadData('cmu35gplvm');

% Walk
seqFrom=1;
seqEnd=1;
if seqFrom ~= 1
    Yfrom = seq(seqFrom-1)+1;
else
    Yfrom = 1;
end
Yend=seq(seqEnd);
YA=Y(Yfrom:Yend,:);


% Run
seqFrom=25;
seqEnd=25;
if seqFrom ~= 1
    Yfrom = seq(seqFrom-1)+1;
else
    Yfrom = 1;
end
Yend=seq(seqEnd);
YB=Y(Yfrom:Yend,:);

skel = acclaimReadSkel('35.asf');
[tmpchan, skel] = acclaimLoadChannels('35_01.amc', skel);

%{
    channelsA = demCmu35VargplvmLoadChannels(YA,skel);
    channelsB = demCmu35VargplvmLoadChannels(YB,skel);
    %skelPlayData(skel, channels, 1/20);
    skelPlayData2(skel, {channelsA,channelsB}, 1/5);
%}

% ----------------

if globalOpt.multOutput
    %------- REMOVE dims with very small var (then when sampling outputs, we
    % can replace these dimensions with the mean)
    vA = find(var(YA) < 1e-7);
    meanRedundantDimA = mean(YA(:, vA));
    dmsA = setdiff(1:size(YA,2), vA);
    YA = YA(:,dmsA);
    
    vB = find(var(YB) < 1e-7);
    meanRedundantDimB = mean(YB(:, vB));
    dmsB = setdiff(1:size(YB,2), vB);
    YB = YB(:,dmsB);
    if ~isempty(vA) || ~isempty(vB)
        warning('Removed some dimensions with tiny variance!')
    end
    %---
end

switch dataMerging
    case 'vercat'
        Yall = [YA ; YB]; %  Yall{1}=YA; Yall{2}=YB; cannot work because they have different number of points
        % Subsample!!
        if ~(exist('subsample') && ~subsample)
            Yall = {Yall(1:2:end,:)};
        else
            Yall = {Yall};
        end
    case 'YA'
        Yall = {YA};
    case 'YB';
        Yall = {YB};
    case 'horalignSep'
        Yall{1} = YA(1:size(YB,1),:); % Assumes YA bigger than YB
        Yall{2} = YB;
    case 'horalignCat'
        Yall{1} = [YA(1:size(YB,1),:) YB]; % Assumes YA bigger than YB
end
        
%Yall = {Yall};

if globalOpt.multOutput
    globalOpt.initial_X = 'concatenated';
    if length(Yall) > 1
        error('cannot do mult. output with shared latent spaces')
    end
    disp(['MultOutput status is: ' num2str(globalOpt.multOutput) ])
    Ytmp = Yall{1};
    Yall = cell(1,size(Ytmp,2));
    for d=1:size(Ytmp,2)
        Yall{d} = Ytmp(:,d);
    end
    clear Ytmp
end

options = hsvargplvmOptions(globalOpt);
options.optimiser = 'scg2';

%%
model = hsvargplvmModelCreate(Yall, options, globalOpt);


params = hsvargplvmExtractParam(model);
model = hsvargplvmExpandParam(model, params);
modelInit = model;

%%
model.globalOpt = globalOpt; 

[model,modelPruned,modelInitVardist] = hsvargplvmOptimiseModel(model, true, true);

return %%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%% VISUALISATION %%%%%%%%%%%%%%%%%%%%%%%%
% Now call:

%% %--- Scales
if globalOpt.multOutput
    close all
    SNR = hsvargplvmShowSNR(model,[],false);
    exclDim = find(SNR{1} < 6); % Exclude from the computations the dimensions that were learned with very low SNR
    [clu, clu2, clu3]= hsvargplvmClusterScales(model.layer{1}, 5,'skel59dim',exclDim);
    scales = hsvargplvmRetainedScales(model);
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
%%
figure
% Now from the parent
modelP = model;
modelP.type = 'hsvargplvm';
modelP.vardist = model.layer{2}.vardist;
modelP.X = modelP.vardist.means;
modelP.q = size(modelP.X,2);

modelP.d = size(Yall{m},2);
modelP.y = Ytochannels(Yall{m});
modelP.Ytochannels = true; 

modelP.vis.index=m;
modelP.vis.layer = 1;
lvmVisualiseGeneral(modelP, [], [dataType 'Visualise'], [dataType 'Modify'],false, skel);
ylim([-20, 10]);
% USE e.g. ylim([-18 8]) to set the axis right if needed




