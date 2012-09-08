function SNR = hsvargplvmShowSNR(model, layers)

if nargin < 2
    layers = 1:model.H;
end

for h=layers
    fprintf('# Layer %d\n',h)
    for m=1:model.layer{h}.M
        if isfield(model.layer{h}.comp{m}, 'mOrig')
            varY = var(model.layer{h}.comp{m}.mOrig(:));
        else
            varY = var(model.layer{h}.comp{m}.m(:));
        end
        beta = model.layer{h}.comp{m}.beta;
        SNR{h}{m} = varY * beta;
        fprintf('    Model %d: %f  (varY=%f, 1/beta=%f)\n', m, SNR{h}{m}, varY, 1/beta)
    end
end