function ll = hsvargplvmLogLikelihood(model)

F_leaves = hsvargplvmLogLikelihoodLeaves(model.layer{1});
F_nodes = hsvargplvmLogLikelihoodNode(model);
F_entropies = hsvargplvmLogLikelihoodEntropies(model);
% This refers to the KL quantity of the top node. The likelihood part is
% computed in hsvargplvmLogLikelihoodNode.
F_parent = hsvargplvmLogLikelihoodParent(model.layer{model.H});

ll = F_leaves + F_nodes + F_entropies + F_parent;

end


function F_leaves = hsvargplvmLogLikelihoodLeaves(modelLeaves)

F_leaves = 0;
for m=1:modelLeaves.M
    modelLeaves.comp{m}.onlyLikelihood = true;
    F_leaves = F_leaves + vargplvmLogLikelihood(modelLeaves.comp{m});
end
end


function F_nodes = hsvargplvmLogLikelihoodNode(model)
F_nodes = 0;
for h=2:model.H
    % It's just like the leaves computation, the only difference is the
    % trace(Y*Y') term which now is replaced by an expectation w.r.t the
    % latent space of the previous layer. However, this replacement is done
    % in hsvargplvmUpdateStats
    F_nodes = F_nodes + hsvargplvmLogLikelihoodLeaves(model.layer{h});
end

end

function F_entropies = hsvargplvmLogLikelihoodEntropies(model)
F_entropies = 0;
for h=1:model.H-1
    vardist = model.layer{h}.vardist;
    F_entropies = F_entropies - 0.5*(vardist.numData*vardist.latentDimension* ...
            (log(2*pi) + 1) + sum(sum(log(vardist.covars))));
end

end

function F_parent = hsvargplvmLogLikelihoodParent(modelParent)
if modelParent.M > 1
    error('Not implemented multiple models in parent node yet')
end
% Copied from vargplvmLogLikelihood:
varmeans = sum(sum(modelParent.vardist.means.*modelParent.vardist.means));
varcovs = sum(sum(modelParent.vardist.covars - log(modelParent.vardist.covars)));
F_parent = -0.5*(varmeans + varcovs) + 0.5*modelParent.q*modelParent.N;
end