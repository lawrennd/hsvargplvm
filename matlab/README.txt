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
### GENERAL ####
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
### HSVARGPLVM ####
...




___________________________________________________________________________
                                                                      ...



________________________________________________________________________
 