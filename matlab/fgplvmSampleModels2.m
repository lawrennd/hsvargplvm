function [YA,YB,XA,XB,options] = fgplvmSampleModels2(scale)

if nargin < 1
    scale = 1;
end

addpath(genpath('../../fgplvm(svn)/matlab/'))
%%
randn('seed', 1e5);
rand('seed', 1e5);


N = 50;
D = 3;
Y = rand(N,D);
Q = 1;

kkern = kernCreate(Y, {'matern32','bias','white'});
kkern.comp{1}.lengthScale = 0.2;
KK = kernCompute(kkern, Y);
Y = gsamp(zeros(1, size(KK, 1)), KK, D)';

options = fgplvmOptions('ftc');
options.kern = {'matern32','bias','white'};
d = size(Y, 2);
model = fgplvmCreate(Q, d, Y, options);
model.kern.comp{1}.lengthScale = 0.2;
model.kern.comp{2}.variance = 1e-6;
model.kern.comp{3}.variance = 1e-6;

params = modelExtractParam(model);
model = modelExpandParam(model, params);

t = linspace(1,10,size(Y,1))';
K = kernCompute(model.kern, t);
XA = gsamp(zeros(1, size(K, 1)), K, Q)';
if scale
    XA = XA ./ max(XA);
end
YA = fgplvmPosteriorMeanVar(model, XA);
if scale,    YA = YA ./ max(YA(:)); end

subplot(1,3,1)
plot(XA(:,1), 'x-'); title('XA')

%%
keep('XA','YA','scale')

N = 50;
D = 5;
Y = rand(N,1);
Q = 1;

kkern = kernCreate(Y, {'matern32','bias','white'});
kkern.comp{1}.lengthScale = 0.8;
KK = kernCompute(kkern, Y);
Y = gsamp(zeros(1, size(KK, 1)), KK, D)';

options = fgplvmOptions('ftc');
options.kern = {'matern32','bias','white'};
d = size(Y, 2);
model = fgplvmCreate(Q, d, Y, options);
model.kern.comp{1}.lengthScale = 1;
model.kern.comp{2}.variance = 1e-6;
model.kern.comp{3}.variance = 1e-6;

params = modelExtractParam(model);
model = modelExpandParam(model, params);

t = linspace(1,10,size(Y,1))';
K = kernCompute(model.kern, t);
XC = gsamp(zeros(1, size(K, 1)), K, Q)';
if scale
    XC = XC ./ max(XC);
end
YC = fgplvmPosteriorMeanVar(model, XC);
if scale,   YC = YC ./ max(YC(:)); end
subplot(1,3,3)
plot(XC(:,1), 'x-'); title('XC')

%% %%
keep('XA','YA','XC','YC','scale');


N = 50;
D = 5;
t = rand(N,1);
Q = 1;

kkern = kernCreate(t, {'rbfperiodic','bias','white'});
kkern.comp{1}.inverseWidth = 0.8;
KK = kernCompute(kkern, t);
Y = gsamp(zeros(1, size(KK, 1)), KK, D)';

options = fgplvmOptions('ftc');
d = size(Y, 2);
options.kern = {'rbfperiodic','bias','white'};
model = fgplvmCreate(Q, d, Y, options);
model.kern.comp{1}.inverseWidth = 0.6;
model.kern.comp{1}.variance = 2.1;
model.kern.comp{2}.variance = 1e-6;
model.kern.comp{3}.variance = 1e-6;


params = modelExtractParam(model);
model = modelExpandParam(model, params);
t = linspace(1,10,size(Y,1))';
K = kernCompute(model.kern, t);
XB = gsamp(zeros(1, size(K, 1)), K, Q)';
if scale
    XB = XB ./ max(XB);
end
YB = fgplvmPosteriorMeanVar(model, XB);
if scale, YB = YB./max(YB(:)); end
subplot(1,3,2)
plot(XB(:,1), 'x-'); title('XB')

%%

YA = [YA YC];
XA = [XA XC];

figure;
subplot(1,2,1)
bar(pca([XA XB])); title('pcaScales for [XA XB]')
subplot(1,2,2)
bar(pca([YA YB])); title('pcaScales for [YA YB]')

