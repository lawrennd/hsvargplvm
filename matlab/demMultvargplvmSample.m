function mu = demMultvargplvmSample(model, skel, q, la, numSamples, fps)

if nargin < 6
    fps = 1/30;
end
if nargin < 5
    numSamples = 120;
end
if nargin < 4
    la = length(model.layer); % layer to sample
end
if nargin < 3
    q=1;
end


minX = min(model.layer{la}.X(:,q));
maxX = max(model.layer{la}.X(:,q));
%minX = minX - abs(minX);
%maxX = maxX + abs(maxX);
xSampDims = minX:(maxX - minX)./(numSamples-1):maxX;
xSamp = zeros(length(xSampDims), model.layer{la}.q); %%% Can also initialise with first pose
xSamp(:,q) = xSampDims';
mu{la} = multvargplvmPosteriorMeanVar(model.layer{la}, xSamp);

for curLayer = la-1:-1:1
    xSamp = mu{curLayer+1};
    mu{curLayer} = multvargplvmPosteriorMeanVar(model.layer{curLayer}, xSamp);
end
% Base layer
%--?
bias = mean(mu{1});
for i = 1:size(mu{1},2)
  mu{1}(:, i) = mu{1}(:, i) - bias(i);
end
%--?

mu{1} = skelGetChannels(mu{1});



skelPlayData(skel, mu{1}, fps);
    
    