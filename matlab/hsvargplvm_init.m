% Initialise options. If the field name of 'defaults' already exists as a
% variable, the globalOpt will take this value, otherwise the default one.

% hvargplvm_init

addpath(genpath('../../vargplvm/matlab'))
addpath(genpath('../../svargplvm/matlab/'))

if ~exist('globalOpt')
    svargplvm_init 
    defaults = globalOpt;
    clear globalOpt
    
 
    %-------------------------------------------- Extra for hsvargplvm-----
    %%%%%%%%%%%%%%%%%%%%% VARIOUS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    defaults.displayIters = true;
    
    
    %%%%%%%%%%%%%%%%%%%%%% GRAPHICAL MODEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This is one entry, being replicated in all models, all layers.
    defaults.mappingKern = 'rbfardjit';
    
    % For multvargplvm: This has to be as big as the number of submodels
    % (horizontally in the graphical model X -> [Y_1, ..., Y_K])
    % For hsvargplvm it should be a cell array in 2 dimensions, where e.g.
    % {{'K1','K2'}, {K3}} means that bottom layer has kernels K1 and K2 and
    % upper layer has kernel K3 (the order goes bottom - up).
    % For hsvargplvm, this is also allowed to just be a single string, in
    % which case it is replicated (it acts like defaults.mappingKern).
    defaults.baseKern = 'rbfardjit';
    
    
    % The number of latent space layers
    defaults.H = 2;
    
       
    % The number of inducing points for each layer. If this is a single
    % number, then the same number is replicated in all models, all layers.
    % Otherwise it should be a cell array in 2 dimensions, where e.g.
    % {{'K1','K2'}, {K3}} means that bottom layer has number K1 and K2 and
    % upper layer has number K3 (the order goes bottom - up). The entry 
    % -1 means that K == N.
    defaults.K = -1;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%   LATENT SPACE %%%%%%%%%%%%%%%%%%%%%%%%%
    % The dimensionality of each latent space layer. If it's a cell array, then
    % it defines the dimensinality of each layer separately and needs to be
    % in the same size as H.
    defaults.Q = 10;
    
    
    % How to initialise the latent space in level h based on the data of
    % level h-1. This can either be a signle entry (replicated in all
    % levels) or it can be a cell array of length H, i.e. different
    % initialisation for each level.
    % The values of this field are either strings, so that [@initX 'Embed']
    % is called, or it can be a matrix of an a priori computed latent space.
    defaults.initX = 'ppca';
    
    % How to initialise the latent space of level h in case there are more than one
    % "modalities" in level h-1. This can either be a cell array of length
    % H or a single entry replicated in all layers, or
    % it is disregarded if there is only 1 modality per layer.
    % The allowed values in this field are:
    % 'concatenated', 'separately', 'custom'. 
    % 'separately', means apply the initX function to each
    % of the datasets and then concatenate. 'concatenated', means first concatenate
    % the datasets and then apply the 'initX' function. 'custom' is like the
    % "separately", but it implies that latentDimPerModel is a cell specifying
    % how many dimensions to use for each submodel.
    defaults.initial_X = 'concatenated';
    
    % !! The latent space dimensionality in case there are several
    % modalities arises as follows:
    % If initial_X is 'concatenated', then it is the corresponding Q
    % parameter set above. If it is 'separately', then the latent
    % dimensionality per model will be ceil(Q/num.Modalities).
    % 'custom' is not yet supported
    
    
    %{
        % In case initial_X is 'separately', this says how many dimensions to
        % set per modality. This can either be a cell array of length
        % H or a single entry replicated in all layers, or
        % it is disregarded if  initial_X is 'concatenated' (see below)
        defaults.latentDimPerModel = {8};
    
    
        % In case initial_X is 'concatenated', this says how many dimensions to
        % keep in total for layer h. This can either be a cell array of length
        % H or a single entry replicated in all layers, or
        % it is disregarded if  initial_X is 'separately' or 'custom' (see above)
        defaults.latentDim = 15;
    %}
    %-
    
    fnames = fieldnames(defaults);
    for i=1:length(fnames)
        if ~exist(fnames{i})
            globalOpt.(fnames{i}) = defaults.(fnames{i});
        else
            globalOpt.(fnames{i}) = eval(fnames{i});
        end
    end
    
    
    clear('defaults', 'fnames');
    
end