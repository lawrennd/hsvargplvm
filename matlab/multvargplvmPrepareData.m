function [Y, lbls] = multvargplvmPrepareData(dataType, dataOptions)

lbls = [];
switch dataType
    case 'skelDecompose'        
        [Y, lbls] = lvmLoadData('cmu35WalkJog');
        seq = cumsum(sum(lbls)) - [1:31];
                
        % load data
        [Y, lbls, Ytest, lblstest] = lvmLoadData('cmu35gplvm');
        
        seqFrom=1;
        seqEnd=1;
        if seqFrom ~= 1
            Yfrom = seq(seqFrom-1)+1;
        else
            Yfrom = 1;
        end
        Yend=seq(seqEnd);
        Y1=Y(Yfrom:Yend,:);
        
        %{
        seqFrom=25;
        seqEnd=25;
        if seqFrom ~= 1
            Yfrom = seq(seqFrom-1)+1;
        else
            Yfrom = 1;
        end
        Yend=seq(seqEnd);
        Y2=Y(Yfrom:Yend,:);
        %}
        
        %{
    skel = acclaimReadSkel('35.asf');
    [tmpchan, skel] = acclaimLoadChannels('35_01.amc', skel);
    channels = demCmu35VargplvmLoadChannels(Y1,skel);
    skelPlayData(skel, channels, 1/30);
        %}
        
        % ----------------
        
        Y = Y1; %%%%%%% Y = [Y1; Y2]
    case 'trainedX'
    % This is for "stacked" models, where the model is re-run with the
    % trained X of the previous layer being fed as outputs in the next
    % layer.
        load(dataOptions.prevModel);
        Y = model.X;
        dataOptions.curLayer = 1;

end