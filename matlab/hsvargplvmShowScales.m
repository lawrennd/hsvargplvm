function scales = hsvargplvmShowScales(model)

for h=1:model.H
    figure
    scales{h} = svargplvmShowScales(model.layer{h});
    title(['Layer ' num2str(h)]);
end