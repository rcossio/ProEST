#!/bin/bash

# This is an example of ProEST.sh usage
# In this example, 20 simulations of BPTI have been made and, to avoid heavy files,
# only the coordinates of alpha carbons (CA) have been saved in trajectory files
# A parameter-topology file that matches the atoms of the trajectories has been 
# made using ante-MMPBSA.py.
# We are now going to check using 20 molecular dynamics if the concatenation of
# 4 trajectories is going to be enough to converge the essential space using
# 1, 3 or 4 vectors (we skip the case of 2 vectors). The atoms included in the analysis
# are alpha carbons from residues 4 to 55 (we remove N and C terminal residues). To make 
#a cumulative distribution function of RMSIP values we will use 20 samples. 
# (In real life experiments one whould make at least more than 500 samples to avoid
# statistical inaccuracy and also there is no reason to skip the analysis of an essential 
# space formed by 2 vectors)

# To understand the usage of the script please run
#
#     ../ProES.sh -h
#
# or
#
#     ../ProES.sh --help
#
#
#  For more information please write us to 
#
#     sciprot.unq@gmail.com 
#
#  or check the following publication 
#
#    "Cossio-Pérez, R., Palma, J., & Pierdominici-Sottile, G. (2017). Consistent principal component modes 
#    from molecular dynamics simulations of proteins. Journal of Chemical Information and Modeling."
#
#  Cheers! 
#
#  SciProt Team
#


   ../ProES.sh --prmtop  bpti.CA.prmtop  --traj trajectories/bpti.CA.X.mdcrd --mask ":4-55@CA" --total 20 --concat 4 --dim "1 3 4" --prefix _TEMP_ --output bpti.ES.dat --samples 20 

