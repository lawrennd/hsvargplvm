function multvargplvmShowScales(model, varargin)

for i=1:model.numModels
    vargplvmShowScales(model.comp{i}, varargin{:});
    title(['Scales for model ' num2str(i)])
    pause
end