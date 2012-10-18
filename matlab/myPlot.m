function myPlot(X, t, fileName, root)
if nargin < 2
    t = [];
end
if nargin < 3
    fileName = [];
end
if nargin < 4
    root = [];
end
figure
plot(X(:,1), X(:,2),'--x','LineWidth',4,...
    'MarkerEdgeColor','r',...
    'MarkerFaceColor','g',...
    'MarkerSize',14); title(t); axis off

pause

if ~isempty(fileName)
    if ~isempty(root)
        fileName = [root filesep fileName];
    end
    print('-depsc', [fileName '.eps']);
    print('-dpdf', [fileName '.pdf']);
    print('-dpng', [fileName '.png']);
end