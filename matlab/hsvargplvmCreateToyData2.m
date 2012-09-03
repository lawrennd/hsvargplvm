% Create toy data. Give [] as an argument if the default value is to be
% used for the corresponding parameter.
%
% Note: This is like hsvargplvmCreateToyData.m but the noise and the
% mapping to higher dimensions is added in the end only once (same effect,
% simple code)
%
% TODO: fix numSharedDims, numHierDims, numPrivSignalDims to add more than
% one dimension for each signal category.

function [Yall, dataSetNames, Z] = hsvargplvmCreateToyData2(type, N, D, numSharedDims, numHierDims, noiseLevel,hierSignalStrength)


if nargin < 7 || isempty(hierSignalStrength),     hierSignalStrength = 0.6;  end
if nargin < 6 || isempty(noiseLevel),             noiseLevel = 0.1;  end
if nargin < 5 || isempty(numHierDims),            numHierDims = 1;   end
if nargin < 4 || isempty(numSharedDims),          numSharedDims = 5; end
if nargin < 3 || isempty(D),                      D = 10;            end
if nargin < 2 || isempty(N),                      N = 100;           end
if nargin < 1 || isempty(type),                   type = 'fols';     end

switch type
    case 'fols'
        alpha = linspace(0,4*pi,N);
        privSignalInd = [1 2];
        sharedSignalInd = 3;
        hierSignalInd = 4;
        
        % private signals
        Z{1} = cos(alpha)';
        Z{2} = sin(alpha)';
        % Shared signal
        Z{3}= (cos(alpha)').^2;
        % Hierarchical signal
        Z{4} = heaviside(linspace(-10,10,N))'; % Step function
       % Z{3} = heaviside(Z{3}); % This turns the signal into a step function
       % Z{3} = 2*cos(2*alpha)' + 2*sin(2*alpha)' ; %
        
        
        % Scale and center data
        for i=1:length(Z)
            bias_Z{i} = mean(Z{i});
            Z{i} = Z{i} - repmat(bias_Z{i},size(Z{i},1),1);
            scale_Z{i} = max(max(abs(Z{i})));
            Z{i} = Z{i} ./scale_Z{i};
        end
        
        % Attach the shared to the private signal after mapping to higher
        % dimentions
        for i=privSignalInd
            % Map 1-Dim to D-Dim and add some noise
            Zp{i} = [Z{i}*rand(1,ceil(D/2)) Z{sharedSignalInd}*rand(1,ceil(D/2))];
        end
        
        % Map hier. signal to higher dimensions as well
        Zp{hierSignalInd} = Z{hierSignalInd}*rand(1, size(Zp{privSignalInd(1)},2));
        
        % Apply hier. signal and then apply noise.
        for i=privSignalInd
            Zpp{i} = Zp{i} + hierSignalStrength.*Zp{hierSignalInd}; %           
            Yall{i} = Zpp{i} + noiseLevel.*randn(size(Zpp{i})); % Add noise
        end
        
        % How many signals are there in the whole dataset?
        
        bar(pca([Yall{1} Yall{2}]))
        %---

        dataSetNames={'fols_cos', 'fols_sin'};
        
        for i=privSignalInd
            figure
            title(['model ' num2str(i)])
            subplot(2,1,1)
            plot(Z{i}), hold on
            plot(Z{sharedSignalInd}, 'r')
            plot(pcaEmbed(Yall{i},1), 'm')
            legend('Orig.','Shared','Final')
            subplot(2,1,2)
            plot(Z{hierSignalInd});
            legend('Hier.')
        end
end

%{ 
%This should return the original signals (in case there is no
%hierarchical signal)
[Yall, dataSetNames, Z] = hsvargplvmCreateToyData([],[],[],[],[],[],0);
close all;plot(pcaEmbed(Yall{1},2))
close all;plot(pcaEmbed(Yall{2},2))
%}

%%
%{
for i=length(privSignalInd)
    ZZ{i} = [Z{privSignalInd(i)} Z{sharedSignalInd}]+repmat(Z{hierSignalInd},1,size([Z{privSignalInd(i)} Z{sharedSignalInd}],2)).*0.6;
end
%}
%%