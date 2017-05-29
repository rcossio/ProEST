# ProEST
ProEST (Protein Essential Space Test) is a tool to check the convergence of the essential space of proteins from AMBER molecular dynamics

# Download
To download this branch (script+example) you should use the command

     git clone https://github.com/rcossio/ProEST.git --branch release_v1.0

# Usage
To check usage please use the command 

     ./ProEST.sh -h

or 

     ./ProEST.sh --help

# What does it do?
This script reads trajectory files, aligns them to the first molecule and creates 
an average structure which will be the new reference to realign trajectories.

After rewriting aligned trajectories it starts a for-loop for each sample. 
In each loop, it takes randomly an indicated number of trajectories and performs Combined 
Essential Dynamics (i.e concatenated Principal Component Analysis) retrieving the indicated 
number of vectors and calculating Root Mean Square Inner Product.

After the indicated samples have been made, the probability distribution function and 
the cumulative distribution function are calculated.

# Dependencies
You should have installed AmberTools (available at http://ambermd.org/), in particular the script
uses Cpptraj and ante-MMPBSA.py

Also, a Python2.7 version is needed with access to Sys, Numpy and Random libraries. 

# More information
For more information please check the example/ folder or write us to 

     sciprot.unq@gmail.com 

or check the following publication 

    Cossio-Pérez, R., Palma, J., & Pierdominici-Sottile, G. (2017). "Consistent principal component modes 
    from molecular dynamics simulations of proteins". Journal of Chemical Information and Modeling.

Cheers! 

SciProt Team
