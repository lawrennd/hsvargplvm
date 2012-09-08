% This function is used for predicting in the hierarchical model.  
% All intermediate mu and sigma should be returned, (TODO!!!)  or
% the user can give extra arguments to define which outputs to get.


function [mu, varsigma] = hsvargplvmPosteriorMeanVar(model, X, varX, layer, ind)

if nargin < 4 || isempty(layer)
    layer = 1;
end

if nargin < 5 || isempty(ind)
    ind  = 1;
end

if nargin < 3 
    varX = [];
end

Xcur = X;
varXcur = varX;
for h=model.H:-1:layer
    if h == layer
        % If we reach the layer that we actually want to predict at, then
        % this is our final prediction.
        if isempty(varXcur)
            if nargout > 1
                [mu, varsigma] = vargplvmPosteriorMeanVarHier(model.layer{h}.comp{ind}, Xcur);
            else
                mu = vargplvmPosteriorMeanVarHier(model.layer{h}.comp{ind}, Xcur);
            end
        else
            if nargout > 1
                [mu,varsigma] = vargplvmPosteriorMeanVarHier(model.layer{h}.comp{ind}, Xcur, varXcur);
            else
                mu = vargplvmPosteriorMeanVarHier(model.layer{h}.comp{ind}, Xcur, varXcur);
            end
        end
    else
        % If this is just an intermediate node until the layer we want to
        % reach at, then we have to go through all the submodels in the
        % current layer, predict in each one of them and join the
        % predictions into a single output which now becomes the input for
        % the next level.
        muPart = []; varxPart = [];
        for m=1:model.layer{h}.M
            if isempty(varXcur)
                if nargout > 1
                    [mu, varx] = vargplvmPosteriorMeanVarHier(model.layer{h}.comp{m}, Xcur);
                    varxPart = [varxPart varX];
                else
                    mu = vargplvmPosteriorMeanVarHier(model.layer{h}.comp{m}, Xcur);
                end
                muPart = [muPart mu];
            else
                if nargout > 1
                    [mu, varX] = vargplvmPosteriorMeanVarHier(model.layer{h}.comp{ind}, Xcur, varXcur);
                    varxPart = [varxPart varX];
                else
                     mu = vargplvmPosteriorMeanVarHier(model.layer{h}.comp{ind}, Xcur, varXcur);
                end
                muPart = [muPart mu];
            end
        end
        Xcur = muPart;
        varXcur = varxPart;
    end
end










% The same as vargplvmPosteriorMeanVar, but a small change in the
% calculations involving model.m, because in the indermediate layers
% model.m is replaced by the expectation varmu*varmu'+Sn wrt the X of the
% bottom layer.
function [mu, varsigma] = vargplvmPosteriorMeanVarHier(model, X, varX)



if nargin < 3
  vardistX.covars = repmat(0.0, size(X, 1), size(X, 2));%zeros(size(X, 1), size(X, 2));
else
  vardistX.covars = varX;
end
vardistX.latentDimension = size(X, 2);
vardistX.numData = size(X, 1);
%model.vardist.covars = 0*model.vardist.covars; 
vardistX.means = X;
%model = vargplvmUpdateStats(model, model.X_u);


Ainv = model.P1' * model.P1; % size: NxN

if ~isfield(model,'alpha')
    if isfield(model, 'mOrig')
        model.alpha = Ainv*model.Psi1'*model.mOrig; % size: 1xD
    else
        model.alpha = Ainv*model.Psi1'*model.m; % size: 1xD
    end
end
Psi1_star = kernVardistPsi1Compute(model.kern, vardistX, model.X_u);

% mean prediction 
mu = Psi1_star*model.alpha; % size: 1xD

if nargout > 1
   % 
   % precomputations
   vard = vardistCreate(zeros(1,model.q), model.q, 'gaussian');
   Kinvk = (model.invK_uu - (1/model.beta)*Ainv);
   %
   for i=1:size(vardistX.means,1)
      %
      vard.means = vardistX.means(i,:);
      vard.covars = vardistX.covars(i,:);
      % compute psi0 term
      Psi0_star = kernVardistPsi0Compute(model.kern, vard);
      % compute psi2 term
      Psi2_star = kernVardistPsi2Compute(model.kern, vard, model.X_u);
    
      vars = Psi0_star - sum(sum(Kinvk.*Psi2_star));
      
      for j=1:model.d
         %[model.alpha(:,j)'*(Psi2_star*model.alpha(:,j)), mu(i,j)^2]
         varsigma(i,j) = model.alpha(:,j)'*(Psi2_star*model.alpha(:,j)) - mu(i,j)^2;  
      end
      varsigma(i,:) = varsigma(i,:) + vars; 
      %
   end
   % 
   if isfield(model, 'beta')
      varsigma = varsigma + (1/model.beta);
   end
   %
end
      
% Rescale the mean
mu = mu.*repmat(model.scale, size(vardistX.means,1), 1);

% Add the bias back in
mu = mu + repmat(model.bias, size(vardistX.means,1), 1);

% rescale the variances
if nargout > 1
    varsigma = varsigma.*repmat(model.scale.*model.scale, size(vardistX.means,1), 1);
end
  