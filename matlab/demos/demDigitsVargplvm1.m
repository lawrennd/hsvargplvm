%{ 
% Old: 
'vercatBig': Very good visualisation
# Vargplvm errors in the 2-D projection: 6
# Vargplvm errors in the 10-D projection: 6
----

vercat2:
Very good visualisation
# Final SNR: 29.042932
# Vargplvm errors in the 2-D projection: 10
# Vargplvm errors in the 9-D projection: 4
% Bound: # Bound: 14426.864776
%}

% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);

dataSetName = 'usps';
Y=lvmLoadData('usps');
dataMerge = 'vercat2';
dataSetName = [dataSetName '_' dataMerge];

experimentNo = 1;

switch dataMerge
    case 'vercat'
        YA = Y(100:150,:); % 0
        YB = Y(5000:5050,:); % 6
        Y = [YA; YB];
    case 'vercatBig'
        YA = Y(1:70,:);   NA = size(YA,1);% 0
        YB = Y(5001:5070,:); NB = size(YB,1); % 6
        Y = [YA; YB];
        lbls = zeros(size(Y,1),2);
        lbls(1:NA,1)=1;
        lbls(NA+1:end,2)=1;
    case 'vercat2'
        YA = Y(1:50,:);  NA = size(YA,1);% 0
        YB = Y(5001:5050,:);  NB = size(YB,1); % 6
        YC = Y(1601:1650,:);  NC = size(YC,1); % ones
        Y = [YA ; YB ; YC];
        lbls = zeros(size(Y,1),3);
        lbls(1:NA,1)=1;
        lbls(NA+1:NA+NB,2)=1;
        lbls(NA+NB+1:end,3)=1;
end


%%

% Set up model
options = vargplvmOptions('dtcvar');
%options.kern = {'rbfard2', 'bias', 'white'};
options.kern = 'rbfardjit';
options.numActive = 50; 
%options.tieParam = 'tied';  

options.optimiser = 'scg2';
latentDim = 10;
d = size(Y, 2);

% demo using the variational inference method for the gplvm model
model = vargplvmCreate(latentDim, d, Y, options);
%
model = vargplvmParamInit(model, model.m, model.X); 
model.vardist.covars = 0.5*ones(size(model.vardist.covars)) + 0.001*randn(size(model.vardist.covars));

% Optimise the model.
iters = 1000;
initVardistIters = 350;
display = 1;
initSNR = 100;
model.beta = 1/((1/initSNR * var(model.m(:))));
model.learnBeta = false; model.learnSigmaf = false; model.initVardist = true;
model = vargplvmOptimise(model, display, initVardistIters);
model.learnBeta = true; model.learnSigmaf = true; model.initVardist = false;

model = vargplvmOptimise(model, display, iters);

fprintf('# Final SNR: %f\n', vargplvmShowSNR(model))

capName = dataSetName;
capName(1) = upper(capName(1));
modelType = model.type;
modelType(1) = upper(modelType(1));
save(['dem' capName modelType num2str(experimentNo) '.mat'], 'model');

% order wrt to the inputScales 
mm2 = vargplvmReduceModel2(model,2);
QQ = length(vargplvmRetainedScales(model));
mm = vargplvmReduceModel2(model,QQ);
errors2 = fgplvmNearestNeighbour(mm2, lbls);
errors = fgplvmNearestNeighbour(mm, lbls);


%% plot the two largest twe latent dimensions 
%if exist('printDiagram') & printDiagram
  lvmScatterPlot(mm2, lbls);
  figure
  bar(model.kern.inputScales);
%end
fprintf('# Vargplvm errors in the 2-D projection: %d\n', errors2)
fprintf('# Vargplvm errors in the %d-D projection: %d\n', QQ, errors)