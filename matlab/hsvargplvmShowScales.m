function scales = hsvargplvmShowScales(model, displ, varargin)
if nargin < 2 || isempty(displ)
    displ = true;
end

if nargin > 2
    layers = varargin{1};
else
    layers = 1:model.H;
end

for h=layers
    if displ
        figure
        title(['Layer ' num2str(h)]);
    end
    if model.layer{h}.M > 10 && displ
        for i=1:model.layer{h}.M
            vargplvmShowScales(model.layer{h}.comp{i});
            title(['Scales for layer ' num2str(h) ', model ' num2str(i)])
            pause
        end
    else
        scales{h} = svargplvmShowScales(model.layer{h}, displ);
    end
end