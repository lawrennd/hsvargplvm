%demUspsFINAL.m
expNo = 19; % Other experiments: 10, 16,18,19



load(['matFiles/demUsps3ClassHsvargplvm' num2str(expNo)]); % also: exp. 16,18,19. 19 is the best
dataMerge = 'vercat2';
% <Load data from demUsps> .....
randn('seed', 1e5);
rand('seed', 1e5);

if ~exist('experimentNo'), experimentNo = 404; end
if ~exist('initial_X'), initial_X = 'separately'; end
if ~exist('baseKern'), baseKern = {'linard2','white','bias'}; end
if ~exist('itNo'), itNo = 500; end
if ~exist('initVardistIters'), initVardistIters = []; end
if ~exist('multVargplvm'), multVargplvm = false; end

% That's for the ToyData2 function:
if ~exist('toyType'), toyType = 'fols'; end % Other options: 'gps'
if ~exist('hierSignalStrength'), hierSignalStrength = 1;  end
if ~exist('noiseLevel'), noiseLevel = 0.05;  end
if ~exist('numHierDims'), numHierDims = 1;   end
if ~exist('numSharedDims'), numSharedDims = 5; end
if ~exist('Dtoy'), Dtoy = 10;            end
if ~exist('Ntoy'), Ntoy = 100;           end

hsvargplvm_init;

Y=lvmLoadData('usps');

globalOpt.dataSetName = 'usps';

switch dataMerge
    case 'modalities'
        YA = Y(1:100,:); % 0
        YB = Y(5001:5100,:); % 6
        Ytr{1} = YA;
        Ytr{2} = YB;
    case 'vercat'
        YA = Y(100:150,:); % 0
        YB = Y(5000:5050,:); % 6
        Ytr{1} = [YA; YB];
    case 'vercatBig'
        YA = Y(1:70,:);   NA = size(YA,1);% 0
        YB = Y(5001:5070,:); NB = size(YB,1); % 6
        Ytr{1} = [YA; YB];
        lbls = zeros(size(Ytr{1},1),2);
        lbls(1:NA,1)=1;
        lbls(NA+1:end,2)=1;
    case 'vercat2'
        YA = Y(1:50,:);  NA = size(YA,1);% 0
        YB = Y(5001:5050,:);  NB = size(YB,1); % 6
        YC = Y(1601:1650,:);  NC = size(YC,1); % ones
        Ytr{1} = [YA ; YB ; YC];
        lbls = zeros(size(Ytr{1},1),3);
        lbls(1:NA,1)=1;
        lbls(NA+1:NA+NB,2)=1;
        lbls(NA+NB+1:end,3)=1;
        globalOpt.dataSetName = 'usps3Class';
    case 'vercat3'
        YA = Y(1:40,:);  NA = size(YA,1);% 0
        YB = Y(5001:5040,:);  NB = size(YB,1); % 6
        YC = Y(1601:1640,:);  NC = size(YC,1); % 1's
        YD = Y(3041:3080,:);  ND = size(YD,1); % 3's
        Ytr{1} = [YA ; YB ; YC; YD];
        lbls = zeros(size(Ytr{1},1),4);
        lbls(1:NA,1)=1;
        lbls(NA+1:NA+NB,2)=1;
        lbls(NA+NB+1:NA+NB+NC,3)=1;
        lbls(NA+NB+NC+1:end,4)=1;
        globalOpt.dataSetName = 'usps4Class';
end

model = hsvargplvmRestorePrunedModel(model, Ytr);


% From the parent or intermediate with outputs being in the 1st layer
layer = 2;

modelP = model;
modelP.type = 'hsvargplvm';
modelP.vardist = model.layer{layer}.vardist;
modelP.X = modelP.vardist.means;
modelP.q = size(modelP.X,2);

modelP.d = size(Ytr{1},2);
if layer ==1
    modelP.y = Ytr{1};
else
    modelP.y = model.layer{layer-1}.vardist.means;
end

modelP.vis.index=-1;
modelP.vis.layer = layer;
lvmVisualiseGeneral(modelP,  [], 'imageVisualise', 'imageModify', false,[16 16], 0,0,1);
%model.comp{v}, [], 'imageVisualise', 'imageModify', [height width], 0,0,1);
%figure; hsvargplvmShowScales(model);

%% Sample automatically
layer = 5;
startingPoint = 51;
dim=6;
%hsvargplvmSampleLayer(model, lInp, lOut, ind,  dim,X, startingPoint)
[X,mu] = hsvargplvmSampleLayer(model,layer,1,-1,dim,[],startingPoint);
h=figure;
%pause

root = ['../diagrams/usps/sampleL' num2str(layer) 'Dim' num2str(dim) 'StPt' num2str(startingPoint)];
% root = []; % Comment to SAVE
if ~isempty(root)
    mkdir(root) %%%%
end
for i=1:size(mu,1)
    imagesc(reshape(mu(i,:),16,16)'), colormap('gray')
    truesize(h,[100 100])
    axis off
    if ~isempty(root)
        fileName = [root filesep num2str(i)];
        print('-dpdf', [fileName '.pdf']);
        print('-dpng', [fileName '.png']);
        fprintf('.')
    else
        pause(0.01)
        %pause
    end
end
imagesc(reshape(var(mu),16,16)'); title('variance samples')


%% Do the above for all layers, all dims...
close all
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)/4.86 scrsz(4)/1 1.2*scrsz(3)/1.6457 0.6*scrsz(4)/3.4682])
startingPoint = 1;
QQ=model.layer{1}.q; % layer 1 has the largest number of scales always
clAll = [];
for layer=1:model.H
    for dim=1:model.layer{layer}.q
        %hsvargplvmSampleLayer(model, lInp, lOut, ind,  dim,X,startingPoint)
        [X,mu] = hsvargplvmSampleLayer(model,layer,1,-1,dim,[],startingPoint);
        p = QQ*(layer-1)+dim;
        subplot(model.H,QQ ,p)  
        imagesc(reshape(var(mu), 16,16)')
        clAll = [clAll; caxis]; 
    end
end
colormap gray
% As above but use the same colormap
figure('Position',[scrsz(3)/4.86 scrsz(4)/3 1.2*scrsz(3)/1.6457 0.6*scrsz(4)/3.4682])


for layer=1:model.H
    for dim=1:model.layer{layer}.q
        [X,mu] = hsvargplvmSampleLayer(model,layer,1,-1,dim,[],startingPoint);
        p = QQ*(layer-1)+dim;
        subplot(model.H, QQ,p) 
        imagesc(reshape(var(mu), 16,16)')
        axis off
        caxis(max(clAll)); 
    end
end
colormap gray
figure('Position',[0.01*scrsz(3) 1.5*scrsz(4)/10 0.17*scrsz(3) 0.5*scrsz(4)])
hsvargplvmShowScales(model)


%% NN errors:
for h=1:model.H
    % order wrt to the inputScales
    curModel = model.layer{h}.comp{1};
    QQ = length(vargplvmRetainedScales(curModel));%curModel.q;
    if h ~= 1
        curModel.y = model.layer{h-1}.vardist.means;
    end
    curModel.vardist = model.layer{h}.vardist;
    mm = vargplvmReduceModel2(curModel,QQ);
    [mm2, ord ]= vargplvmReduceModel2(curModel,2);
    errors = fgplvmNearestNeighbour(mm, lbls);
    errors2 = fgplvmNearestNeighbour(mm2, lbls);
    % plot the two largest latent dimensions
    ax=subplot(model.H,1,h);
    lvmScatterPlot(mm2, lbls,ax); title(['Layer ' num2str(h) ' (errors:' num2str(errors) ')'])
    fprintf('# Vargplvm errors in the [%d-D | 2-D] projection: [%d | %d]\n', QQ,errors, errors2)
end




%% Visualise the latent space with the images
close all
h = 1;

curModel = model.layer{h}.comp{1};
if h ~= 1
    curModel.y = model.layer{h-1}.vardist.means;
end
curModel.vardist = model.layer{h}.vardist;
mm2 = vargplvmReduceModel2(curModel,2);
errors2 = fgplvmNearestNeighbour(mm2, lbls);



dataType = 'image';
varargs{1} = [16 16];
varargs{2} = 1;
varargs{3} = 1;
varargs{4} = 1;

visualiseFunction = 'imageVisualise';
axesWidth = 0.03;
Y = Ytr{1};

lvmScatterPlot(mm2, lbls);
% 3rd argument: if we remove overlaps
figure; hsvargplvmStaticImageVisualise(mm2, Y, false, [dataType 'Visualise'], axesWidth, varargs{:});
