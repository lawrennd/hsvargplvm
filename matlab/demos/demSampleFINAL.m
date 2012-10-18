clear
toyType = 'hgplvmSampleTr1'; 
root = '../diagrams/toy';

%% <load data from demToyHsvargplvm1.m >
load demToy_hgplvmSampleTr1Hsvargplvm27
model = hsvargplvmRestorePrunedModel(model, Ytr);
%figure; hsvargplvmShowScales(model);
svargplvmShowScales(model.layer{1});
%figure; hsvargplvmPlotX(model, 2, [1 2]);
myPlot([model.layer{2}.vardist.means(:,1) model.layer{2}.vardist.means(:,2)], [],'hsvargplvmX2',root)
%figure; hsvargplvmPlotX(model, 1, [1 2]);
myPlot([model.layer{1}.vardist.means(:,1) model.layer{1}.vardist.means(:,2)], [],'hsvargplvmXA',root)
%figure; hsvargplvmPlotX(model, 1, [4 5]);
myPlot([model.layer{1}.vardist.means(:,4) model.layer{1}.vardist.means(:,5)], [],'hsvargplvmXB',root)

%% Stacked vargplvm:  (from this, we only need the "modelInit")
% That gives very good results basically
load demToy_vargplvm270.mat
%%% OR
experimentNo = 270; toyType = 'hgplvmSampleTr1'; 
baseKern='rbfardjit'; Q = {6,4}; initSNR = {100, 50}; initial_X = 'separately';
initX = 'vargplvm'; stackedInitIters = 200; stackedInitVardistIters = 100; stackedInitSNR = 100; 
demToyHsvargplvm1;
% CANCEL IT
[XA, s, WA, modelA] = vargplvmEmbed(Ytr{1}, 5, initXOptions{1}{:});
[XB, s, WB, modelB] = vargplvmEmbed(Ytr{2}, 5, initXOptions{1}{:});
[X2, s, W2, model2]  = vargplvmEmbed([XA XB], 5, initXOptions{2}{:});
save 'demToy_vargplvm270.mat' 'XA' 'XB' 'X2' 'WA' 'WB' 'W2' 
%% --- Compare with PCA
load '../../../DATA_local_small/hierarchical/hgplvmSampleDataTr1.mat';
Yall{1} = YA; Yall{2} = YB;
%subplot(3,2,1)
myPlot(X2,[],'X2Orig',root)
%subplot(3,2,3)
myPlot(XA,[],'XAOrig',root)
%subplot(3,2,4)
myPlot(XB,[],'XBOrig',root)
%subplot(3,2,5)
plot(YA,'x-'); title('YA');
subplot(3,2,6)
plot(YB,'x-'); title('YB');
Z = {XA,XB,X2};
dataSetNames = toyType;

figure
pcaXA = ppcaEmbed(YA, 2);
pcaXB = ppcaEmbed(YB,2);
pcaX2 = ppcaEmbed([pcaXA pcaXB],2); %%%%% Used to be: [XA XB]
%subplot(2,2,1)
myPlot(pcaX2,[],'pcaX2',root)
%subplot(2,2,3)
myPlot(pcaXA,[],'pcaXA',root)
%subplot(2,2,4)
myPlot(pcaXB,[],'pcaXB',root)

figure
isomapXA = isomap2Embed(YA, 2);
isomapXB = isomap2Embed(YB,2);
isomapX2 = isomap2Embed([isomapXA isomapXB],2); %%%%% Used to be: [XA XB]
%subplot(2,2,1)
myPlot(isomapX2,[],'isomapX2',root)
%subplot(2,2,3)
myPlot(isomapXA,[],'isomapXA',root)
%subplot(2,2,4)
myPlot(isomapXB,[],'isomapXB',root)


%% %%%%%%%





clear
toyType = 'hgplvmSampleTr1';

%% <load data from demToyHsvargplvm1.m >
load demToy_hgplvmSampleTr1Hsvargplvm14
model = hsvargplvmRestorePrunedModel(model, Ytr);
figure; hsvargplvmShowScales(model);
figure; hsvargplvmPlotX(model, 2, [1 3]);
