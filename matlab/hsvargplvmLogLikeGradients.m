function g = hsvargplvmLogLikeGradients(model)

g_leaves = hsvargplvmLogLikeGradientsLeaves(model.layer{1});
[g_nodes g_sharedLeaves] = hsvargplvmLogLikeGradientsNodes(model);
% Amend the vardistr. derivatives of the leaves only with those of the
% higher layer.
%%% TEMP %%%% !!
%g_leaves(1:model.layer{1}.vardist.nParams) = g_leaves(1:model.layer{1}.vardist.nParams).*0;
%%%%%%%%%%
g_leaves(1:model.layer{1}.vardist.nParams) = g_leaves(1:model.layer{1}.vardist.nParams) + g_sharedLeaves;

g_entropies = hsvargplvmLogLikeGradientsEntropies(model);

% This is the gradient of the entropies (only affects covars). It's just -0.5*I
N = model.layer{1}.N;
Q1 = model.layer{1}.q;
%g_entropies = -0.5.*g_leaves(N*Q1+1:model.layer{1}.vardist.nParams);
g_leaves(N*Q1+1:model.layer{1}.vardist.nParams) = g_leaves(N*Q1+1:model.layer{1}.vardist.nParams) + g_entropies;
for h=2:model.H-1
    N = model.layer{1}.N;
    Q1 = model.layer{1}.q;
    % g_entropies is the same for all models (constant)
    % TODO!!!
    % g_nodes(indicesForCovarsInThisNode)=g_nodes(indicesForCovarsInThisNode)+g_entropies;
end
g_parent = hsvargplvmLogLikeGradientsParent(model.layer{model.H});
g = [g_leaves  g_nodes];

% Amend the derivatives of the parent's var.distr. with the terms coming
% from the KL.
startInd = model.nParams-model.layer{model.H}.nParams+1;
endInd = startInd + model.layer{model.H}.vardist.nParams-1;
g(startInd:endInd) = g(startInd:endInd) + g_parent;


%%%TEMP
%g = [g zeros(1,model.nParams - length(g))];
%%%

end



function g = hsvargplvmLogLikeGradientsLeaves(model)

g = [];
gShared = zeros(1, model.vardist.nParams);

for i=1:model.M
    model.comp{i}.vardist = model.vardist;
    model.comp{i}.onlyLikelihood = true;
    g_i = vargplvmLogLikeGradients(model.comp{i});
    % Now add the derivatives for the shared parameters (vardist)
    gShared = gShared + g_i(1:model.vardist.nParams);
    g_i = g_i((model.vardist.nParams+1):end);
    g = [g g_i];
end
g = [gShared g];
end

% g: The gradients for the "likelihood"+vardist part (ie no entropies, no
% KL) of all nodes
% gSharedLeaves: The gradients for the vardist part of the variational
% distribution of the first layer only, which has to be amended with the
% gradient obtained by hsvargplvmLogLikeGradientsLeaves. The vardist.
% gradients of the variational distributions of the other layers (apart from
% the parent) is handled internally (no need if H == 2)
function [g gSharedLeaves] = hsvargplvmLogLikeGradientsNodes(model)
g=[]; % Final derivative
gSharedLeavesMeans = 0;
gSharedLeavesCovars = 0;
for h=2:model.H
    g_h = []; % Derivative wrt params of layer h
    
    means = model.layer{h-1}.vardist.means;
    covars = model.layer{h-1}.vardist.covars;
    
    gShared = zeros(1, model.layer{h}.vardist.nParams); % Derivatives of the var. distr. of layer h
    for i=1:model.layer{h}.M % Derivative of the likelihood term of the m-th model of layer h
        model.layer{h}.comp{i}.vardist = model.layer{h}.vardist;
        model.layer{h}.comp{i}.onlyLikelihood = true;
        g_i = vargplvmLogLikeGradients(model.layer{h}.comp{i});
        % Now add the derivatives for the shared parameters (vardist)
        gShared = gShared + g_i(1:model.layer{h}.vardist.nParams);
        g_i = g_i((model.layer{h}.vardist.nParams+1):end);
        
        %-- Amend the gShared OF THE PREVIOUS LAYER with the new terms due to the expectation
        beta = model.layer{h}.comp{i}.beta;
        if h == 2
            %-- Previous layer is leaves
            % Amend for the F3 term of the bound
            gSharedLeavesMeans = gSharedLeavesMeans + beta * ...
                model.layer{h}.comp{i}.Z' * means;
            gSharedLeavesCovars = gSharedLeavesCovars + 0.5*beta * ...
                repmat(diag(model.layer{h}.comp{i}.Z), 1, size(means,2));
            
            % Amend for the F0 term of the bound
            gSharedLeavesMeans = gSharedLeavesMeans - beta * means;
            gSharedLeavesCovars = gSharedLeavesCovars - 0.5*beta * ones(size(gSharedLeavesCovars));
            
            % Reparametrization: from dF/dS -> dF/d log(S)
            gSharedLeavesCovars = covars.*gSharedLeavesCovars;
        else
            error('H > 2 not implemented yet!!')
            % TODO!!!! For > 2 layers:
            % Previous layer is intermediate nodes
            % TODO: Here, we don't return the result but we added directly
            % to the previous iterations derivative (since everything
            % happens in the same function).
        end
        %--
        
        g_h = [g_h g_i];
    end
    g_h = [gShared g_h];
    
    % TODO!! (for H > 2)
    % ...
    g = [g g_h];
end
gSharedLeaves = [gSharedLeavesMeans(:)' gSharedLeavesCovars(:)'];
end


function g = hsvargplvmLogLikeGradientsEntropies(model)
g=-0.5*ones(1,model.layer{1}.N * model.layer{1}.q);
end

function gVar = hsvargplvmLogLikeGradientsParent(modelParent)
model = modelParent.comp{1};
model.vardist = modelParent.vardist;
gVarmeans = - model.vardist.means(:)';
% !!! the covars are optimized in the log space (otherwise the *
% becomes a / and the signs change)
gVarcovs = 0.5 - 0.5*model.vardist.covars(:)';


if isfield(model, 'fixInducing') & model.fixInducing
    % TODO!!!
    warning('Implementation for fixing inducing points is not complete yet...')
    % Likelihood terms (coefficients)
    [gK_uu, gPsi0, gPsi1, gPsi2, g_Lambda, gBeta, tmpV] = vargpCovGrads(model);
    
    % Get (in three steps because the formula has three terms) the gradients of
    % the likelihood part w.r.t the data kernel parameters, variational means
    % and covariances (original ones). From the field model.vardist, only
    % vardist.means and vardist.covars and vardist.lantentDimension are used.
    [gKern1, gVarmeans1, gVarcovs1, gInd1] = kernVardistPsi1Gradient(model.kern, model.vardist, model.X_u, gPsi1');
    [gKern2, gVarmeans2, gVarcovs2, gInd2] = kernVardistPsi2Gradient(model.kern, model.vardist, model.X_u, gPsi2);
    [gKern0, gVarmeans0, gVarcovs0] = kernVardistPsi0Gradient(model.kern, model.vardist, gPsi0);
    
    %%% Compute Gradients with respect to X_u %%%
    gKX = kernGradX(model.kern, model.X_u, model.X_u);
    % The 2 accounts for the fact that covGrad is symmetric
    gKX = gKX*2;
    dgKX = kernDiagGradX(model.kern, model.X_u);
    for i = 1:model.k
        gKX(i, :, i) = dgKX(i, :);
    end
    % Allocate space for gX_u
    gX_u = zeros(model.k, model.q);
    % Compute portion associated with gK_u
    for i = 1:model.k
        for j = 1:model.q
            gX_u(i, j) = gKX(:, j, i)'*gK_uu(:, i);
        end
    end
    % This should work much faster
    %gX_u2 = kernKuuXuGradient(model.kern, model.X_u, gK_uu);
    gInd = gInd1 + gInd2 + gX_u(:)';
    %gVarmeans(model.inducingIndices, :) = gVarmeans(model.inducingIndices,
    %:) + gInd; % This should work AFTER reshaping the matrices...but here
    %we use all the indices anyway.
    gVarmeans = gVarmeans + gInd;
end

gVar = [gVarmeans gVarcovs];
if isfield(model.vardist,'paramGroups')
    gVar = gVar*model.vardist.paramGroups;
end


end
