function [params, names] = hsvargplvmExtractParam(model)

% HSVARGPLVMEXTRACTPARAM Extract a parameter vector from a hierarchical Var-GP-LVM model.
% FORMAT
% DESC extracts a parameter vector from a given SVARGPLVM model.
% ARG model : svargplvm model from which to extract parameters
% RETURN params : model parameter vector
%
%
% We assume a graphical model:
%
% X_H -> X_{H-1} -> ......... -> X_{1} -> {Y{1}, Y{2}, ..., Y{M} }
%  |_______|  |_____|         |____| |______________|
%  layer{H}   layer{H-1}    layer{2}     layer{1} 
%
% Parameters are extracted as a vector in the following order (left to right) 
% Imagine a stack where get extracts from the BOTTOM (not the top)
% - parameter | size :
%
% For h=1:H                     % h=1 is the very lower layer in the graphical model
%   get: varmeans_{q(X_h)}(:)'                     --> N x Q_h
%   get: varcovs_{q(X_h}(:)'                       --> N x Q_h
%   for i=1:M (for the M of the current layer h)
%       get: X_u(:)'_{h,i}    % inducing points    --> K_{h,i} x Q_{h}
%       get: \theta_{h,i}     % kernel hyperparameters --> ...
%       get: beta_{h,i}         ---> 1
%   end
% end
%
% SEEALSO : svargplvmCreate, svargplvmExpandParam, modelExtractParam
%
% COPYRIGHT : Andreas C. Damianou, 2011

% SVARGPLVM

if nargout > 1
    returnNames = true;
else
    returnNames = false;
end

params = [];
names = {};

for h=1:model.H
    % Variational distribution
    if returnNames
        [params_i, names_i] = modelExtractParam(model.layer{h}.vardist);
        params = [params params_i];
        names = {names{:} names_i{:}};
    else
        params = [params modelExtractParam(model.layer{h}.vardist)];
    end
    
    % Now extract the "private" parameters of every sub-model. This is done by
    % just calling vargplvmExtractParam and then ignoring the parameter indices
    % that are shared for all models (because we want these parameters to be
    % included only once).
    for i = 1:model.layer{h}.M
        if returnNames
            [params_i,names_i] = vargplvmExtractParamNoVardist(model.layer{h}.comp{i});
        else
            params_i = vargplvmExtractParamNoVardist(model.layer{h}.comp{i});
        end
                
        params = [params params_i];
        
        if returnNames          
            names = {names{:} names_i{:}};
        end
    end
    
end




