#!/bin/bash

# This is an example of ProEST.sh usage
# In this example, 20 simulations of BPTI have been made and, to avoid havy files,
# only the coordinates of alpha carbons (CA) have been saved in trajectory files
# A parameter-topology file that matches the atoms of the trajectories has been 
# made using ante-MMPBSA.py.
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

