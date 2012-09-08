  _                                    _                 
 | |                                  | |                
 | |__  _____   ____ _ _ __ __ _ _ __ | |_   ___ __ ___  
 | '_ \/ __\ \ / / _` | '__/ _` | '_ \| \ \ / / '_ ` _ \ 
 | | | \__ \\ V / (_| | | | (_| | |_) | |\ V /| | | | | |
 |_| |_|___/ \_/ \__,_|_|  \__, | .__/|_| \_/ |_| |_| |_|
                            __/ | |                      
                           |___/|_|                      


% Copyright: Andreas C. Damianou, 2012


                              R E A D M E

___________________________________________________________________________
############################# GENERAL #####################################
___________________________________________________________________________

This is the implementation of a hierarchical variatioanl GPLVM, where
instead of the standard one latent space, there's a hierarchy of those.
As a sub-case, there is another difference from the standard model:
instead of considering one observation space Y, we can choose to
consider more. If we choose different subsets or modalities, [Y1, Y2],
this is exactly equivalent to svargplvm. We might also choose one modality
per output dimension, i.e. we will have as outputs SEPARATE [y1 y2 y3...].
where subscript indexes dimensions. This is the implementation of
*multvargplvm* and it's basically a wrapper for svargplvm with a few
tweaks to work well on one-dimensional outputs.

In theory, the "multvargplvm" principle can also be applied to intermediate
latent nodes in a hierarchy. To summarize, in the full model we can select:
   
   * PARAMETERS for STRUCTURE:
   ________________________________________________________________________
    - The number H of hierarchical nodes and their dimensionalities
      Q_1, Q_2, ..., Q_H

    - The number S of outputs in the leaf nodes, Y_1, Y_2, ..., Y_S
        X_H -> X_{H-1} -> ... -> X_1 -> [Y_1, ..., Y_S]

    - Whether to define the number of outputs in the leaf nodes to be
      equal to the number of dimensions of a single dataset,
      i.e Yall would be [y_1, y_2, ..., y_d]

    - Whether to treat all intermediate layers X_1, ..., X_{H-1} as a
      single space, or if we will also apply the "multvargplvm" principle
      there and have many intermediate input/outputs, e.g.
      X_h would then be treated as [x_h;1, ..., x_h;q]
    

    * PARAMETERS for the actual MODEL:
    _______________________________________________________________________
     - The prior distribution of the parent, p(X_H). For the moment, this
       is taken to be a standard normal.
     - The mappings F_h, h=1:H between the nodes (see below) => 
                 kernel parameters and inducing points for each node
     - variational parameters for each node.


    * Special case: MULTVARGPLVM (v. 0.1)
    _______________________________________________________________________

    This is the special case where the number of outputs is equal to the
    number of the single given output dimensions and we have only one
    layer of latent points (i.e. an svargplvm with a few tweaks to work
    well with the large number of one-dimensional outputs).



    * Current implementation of HSVARGPLVM (v. 0.1) -- TODO
    _______________________________________________________________________
    
    In the current implementation of hsvargplvm, we treat the intermediate
    latent nodes as one space and the leaf nodes (outputs) can be treated
    either as one space, or subsets (like svargplvm), or one set per
    dimension (like multvargplvm). 




 
___________________________________________________________________________
########################## HSVARGPLVM ####################################
___________________________________________________________________________

_____________________________ STRUCTURE
This is the model that implements the hierarchical vargplvm. The general
structure is:
X_H -> F -> X_{H-1} -> ... -> X_1 -> {F_1 -> Y_1, ..., F_M -> Y_M}
where H is the total number of layers, Y are the observed data which can
be split into M subsets (e.g. modalities) and all F's are associated with
different a) kernel parameters b) inducing points and all X's are associated
with different variational distribution. There is also a different beta
for each F. In other words, each F is a different GP.

X_H is the parent latent space
X_1:X_{H-1} are the intermediate ones.


* Definition: A model is all of the above associated with a different GP,
i.e a variational distribution, inducing points, beta, F.

* More than one models in the same layer are only allowed (for the moment)
in the leaf nodes (TODO: change that !!!). These models share a variational
distribution, exactly as in svargplvm.

* Models of different layers, are coupled as follows:
    model.y of layer h is the model.X of layer h-1.
    model.m of layer h is the centered data of layer h-1.
TODO: The equations at the moment do NOT include the bias, so model.m for 
layers > 1 are uncentered...


_____________________________ BOUND and derivatives

The bound is as follows: (see notes) - 5 different kinds of terms


_____________________________ Initialisation

Check the hsvargplvmModelCreate in combination with hsvargplvm_init.
In general, the values can either be given as a single variable (in which
case this value is inherited in all models), or as a cell array (in which
case a specific value is defined for each model). 


_____________________________ Optimisation

The optimisation can be done while initialising the variational
distributions of some layers and then normal optimisation.
This is done by calling:
    model = hsvargplvmPropagateField(model, 'initVardist', true,dims);
    model = hsvargplvmPropagateField(model, 'learnSigmaf', false,dims);
for the initialisation, and
    model = hsvargplvmPropagateField(model, 'initVardist', false,dims);
    model = hsvargplvmPropagateField(model, 'learnSigmaf', true,dims);
for afterwards. dims can be omitted to init. everything, but it is often
useful to only fix only the leaf layers (i.e. dims = 1), -at least for 
beta-, because the rest of the layers have different data variance in each
iteration and the SNR cannot be fixed. For this reason, it might be also
good to give a higher initSNR value to intermediate nodes, by using:
e.g. initSNR = {100, 200}; if there are two layers.


After optimisation, use hsvargplvmShowSNR(model) and
hsvargplvmShowScales(model) to see the results, and
hsvargplvmPlotX(model, layer, dims) to plot the dimensions.


!! Note that if rbfardjit is used as a mapping kernel, then its variance
(sigmaf) is always initialised to the variance of the data, var(m(:)),
so by keeping both sigmaf and beta fixed the SNR is fixed in a better
way that just fixing beta and using some other mapping kernel. 



_____________________________ Current issues

1) How to also segment X_h, h > 1? So that I can have the multvargplvm
approach in the intermediate layers?
2) How to manage the fact that some of the dimensions of X_h are irrelevant
but nevertheless the upper level inherits all of the space? (hopefully
the upper level's scales will "understand" and "inherit" the information
about the irrelevant scales?)
3) How to handle the fact that the data variance of a model in layer h>1
always changes (since its data come from a X of the below layers which
changes)? Does that affect the optimisation of beta of that particular
layer? SNR should be relatively high and it depends on the variance of
the data and the value of beta.



___________________________________________________________________________
                                                                      ...



________________________________________________________________________
 