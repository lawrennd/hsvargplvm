%demUspsFINAL.m
experiments = [10,16,18,19];
for expNo = experiments
    keep('expNo', 'experiments')
    load(['demUsps3ClassHsvargplvm' num2str(expNo)]); % also: exp. 16,18,19. 19 is the best
    dataMerge = 'vercat2';
    %% <Load data from demUsps> .....
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
    %%   
    
    model = hsvargplvmRestorePrunedModel(model, Ytr);
    %{
    curModel = model.layer{h}.comp{1};
    QQ = length(vargplvmRetainedScales(curModel));%curModel.q;
    if h ~= 1
        curModel.y = model.layer{h-1}.vardist.means;
    end
    curModel.vardist = model.layer{h}.vardist;
    mm = vargplvmReduceModel2(curModel,QQ);
    %}
    b = 0;
    for h=1:model.H
        b = b+ model.layer{h}.comp{1}.kern.nParams + 1;
    end
    b = 0.5*b * log(size(Ytr{1},1));
    BIC = hsvargplvmLogLikelihood(model) - b;
    fprintf('# H=%d, ExpNo=%d, Bound: %f BIC_bound = %f\n', model.H, expNo,hsvargplvmLogLikelihood(model),BIC)
end










%%
root = '../diagrams/usps';
for h=1:model.H
    figure;
    fileName = ['H5_scalesLayer' num2str(h)];
    bar(model.layer{h}.comp{1}.kern.inputScales);
    set(gca, 'YTickLabelMode', 'manual', 'YTickLabel', []);
    if ~isempty(root)
        fileName = [root filesep fileName];
    end
    print('-depsc', [fileName '.eps']);
    print('-dpdf', [fileName '.pdf']);
    print('-dpng', [fileName '.png']);
end
