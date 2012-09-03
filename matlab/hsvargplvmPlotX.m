function hsvargplvmPlotX(model, layer, dims, symb)

if nargin < 4
    symb = 'x';
end

if nargin < 3
    error('At least hree arguments required')
end

if length(dims) > 3
    error('Can only plot two or three dimensions against each other')
end


switch length(dims)
    case 1
        plot(model.layer{layer}.vardist.means(:, dims(1)), symb);
    case 2
        plot(model.layer{layer}.vardist.means(:,dims(1)), model.layer{layer}.vardist.means(:, dims(2)), symb);
    case 3
        plot3(model.layer{layer}.vardist.means(:,dims(1)), ... 
            model.layer{layer}.vardist.means(:, dims(2)), ...
            model.layer{layer}.vardist.means(:, dims(3)), symb); grid on
end