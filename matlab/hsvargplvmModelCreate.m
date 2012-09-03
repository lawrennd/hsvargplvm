function hmodel = hsvargplvmModelCreate(Ytr, options, globalOpt)


% ################  Fix the structure of the model #################-%

if ~iscell(options.Q)
    Q = options.Q;
    options = rmfield(options, 'Q');
    for h=1:options.H
        options.Q{h} = Q;
    end
end

YtrOrig = Ytr;

for h = 1:options.H
    clear('m','mAll','initX','initial_X','curX');
    
    % Number of models in leaves layer
    M = 1;
    if iscell(Ytr), M = length(Ytr); end
    
    Q = options.Q{h};
    
    %------------- Latent space ---------------------------------------------
    mAll = [];
    for i = 1:M
        m{i} = scaleData(Ytr{i}, options.scale2var1);
        mAll = [mAll m{i}];
    end
    
    
    
    
    if iscell(options.initX)
        initX = options.initX{h};
    else
        initX = options.initX;
    end
    
    if M == 1
         % Initialise in the vargplvm style
        if isstr(initX)
            fprintf('# Initialising level %d with %s\n',h, initX)
            initFunc = str2func([initX 'Embed']);
            curX  = initFunc(mAll, Q);
        end
    else % M > 1
        % Initialise in the svargplvm style
        if iscell(options.initial_X)
            initial_X = options.initial_X{h};
        else
            initial_X = options.initial_X;
        end
        
        initFunc = str2func([initX 'Embed']);
        if strcmp(initial_X,'concatenated')
            fprintf('# Initialising level %d  with concatenation and %s\n',h, initX)
            curX  = initFunc(mAll, Q);
        elseif strcmp(initial_X,'separately')
            fprintf('# Initialising level %d separately with %s\n', h,initX)
            Q1 = ceil(Q / M);
            curX = [];
            for i = 1:M
                curX = [curX initFunc(m{i}, Q1)];
            end
            Q = Q1 * M;
            options.Q{h} = Q;
        else
            error([initialX ' is unknown'])
        end
    end
    
    %------------- Vargplvm sub-models ---------------------------------------------
    for i = 1:M
        if ~iscell(options.K)
            K = options.K;
        else
            K = options.K{h}{i};
        end
        if K == -1
            K = size(Ytr{i},1);
        end
               
        opt = options;
        
        opt.latentDim = Q;
        opt.numActive = K;
        opt.initX = curX;
        
        if iscell(options.baseKern) && iscell(options.baseKern{1})
            opt.kern = globalOpt.baseKern{h}{i}; %{'rbfard2', 'bias', 'white'};
        else
            opt.kern = globalOpt.baseKern;
        end
        
        
        model{i} = vargplvmCreate(Q, size(Ytr{i},2), Ytr{i}, opt); 
        
        % Init vargplvm model
        %model{i}.X = curX; 
        model{i}.vardist.means = curX;
        model{i} = vargplvmParamInit(model{i}, m{i}, curX, globalOpt);
        %model{i}.X = curX;
        model{i}.vardist.means = curX;
        
        if isfield(globalOpt, 'inputScales') && ~isempty(globalOpt.inputScales)
            inpScales = globalOpt.inputScales;
        else
            inpScales = globalOpt.inverseWidthMult./(((max(curX)-min(curX))).^2); % Default 5
            %inpScales(:) = max(inpScales); % Optional!!!!!
        end
        if ~isfield(model{i}.kern, 'comp')
             model{i}.kern.inputScales = inpScales;
        else
             model{i}.kern.comp{1}.inputScales = inpScales;
        end
        
        %params = vargplvmExtractParam(model{i}); % !!!
        %model{i} = vargplvmExpandParam(model{i}, params); % !!!
        model{i}.vardist.covars = 0.5*ones(size(model{i}.vardist.covars)) + 0.001*randn(size(model{i}.vardist.covars));
    end
        
    
    %---- Fix the structure of the big model
    hmodel.layer{h}.vardist = model{1}.vardist;
    %hmodel.layer{h}.X = model{1}.X;
    hmodel.layer{h}.N = model{1}.N;
    hmodel.layer{h}.q = model{1}.q;
    hmodel.layer{h}.M = M;
    
    for i=1:M
        hmodel.layer{h}.comp{i} = model{i};
        % Remove model.vardist and model.X (which is shared)
        hmodel.layer{h}.comp{i} = rmfield(hmodel.layer{h}.comp{i}, 'vardist');
        hmodel.layer{h}.comp{i} = rmfield(hmodel.layer{h}.comp{i}, 'X');
        
        % No need to keep hmodel.layer.comp{..}.y, apart from the very first
        % model which has the actual observed data. For the rest, y in layer h
        % is X in layer h-1.
        if h ~= 1
             hmodel.layer{h}.comp{i} = rmfield(hmodel.layer{h}.comp{i}, 'y');
        end
    
    end
    
    
    % CHANGE Ytr for next iteration to be equal to current X
    if h ~= options.H
        clear Ytr;
        %Ytr{1} = hmodel.layer{h}.X; % TODO!!! Allow multiple models here
        Ytr{1} = hmodel.layer{h}.vardist.means; 
    end
    

end

hmodel.date = date;
hmodel.info = ' Layers are indexed bottom-up. The bottom ones, i.e. layer{1}.comp{:} are the observed data.';
hmodel.info = [hmodel.info sprintf('\n The top layer is the parent latent space.')];
hmodel.H = options.H;
hmodel.options = options;
hmodel.type = 'hsvargplvm';
