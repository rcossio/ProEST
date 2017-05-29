#!/bin/bash

#    ProEST v1.0
#    Copyright (C) 2017 Rodrigo Cossio-Perez
#    under GPU GPL v3 Licence
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# 1. Reading arguments
while [[ $# -ge 1 ]]
do
case "$1" in

  -h|--help)
  echo "
  ProEST - Protein Essential Space Test
  
  Usage: 

    ./ProEST.sh --dim DIM --total TOTAL --concat CONCAT --traj TRAJECTORY.X --mask MASK --prmtop PRMTOP --prefix PREFIX --output OUTPUT --samples SAMPLES
 
  where DIM is the list of dimensions of the protein subspace used in the RMSIP.
        TOTAL is the total number of molecular dynamics. It should be at least twice the CONCAT number.
        CONCAT is the number of trajectories concatenated for PCA.
        TRAJECTORY.X is the name of the trajectory files. The X will be replaced for numbers 1,2,3...,TOTAL
        MASK is the AMBER mask used to choose which atom coordinates will be used for PCA
        PRMTOP is the AMBER parameter/topology file compatible with the trajectory files
        PREFIX is a name to define output and temporary files. 
        OUTPUT is the result of this analysis. It contains a probability and cumulative distribution function.
        SAMPLES is the number of samples used to make the distributions. 

  For more information please write us to 

     sciprot.unq@gmail.com 

  or check the following publication 

    \"Cossio-Pérez, R., Palma, J., & Pierdominici-Sottile, G. (2017). Consistent principal component modes 
    from molecular dynamics simulations of proteins. Journal of Chemical Information and Modeling.\"

  Cheers! 

  SciProt Team
  "
  exit
  shift 
  ;;

  --dim)
  DIM=$2
  shift 
  ;;

  --total)
  TOTAL=$2
  shift
  ;;

  --concat)
  CONCAT=$2
  shift
  ;;

  --traj)
  TRAJ=$2
  shift
  ;;

  --mask)
  MASK=$2
  shift
  ;;

  --prmtop)
  PRMTOP=$2
  shift
  ;;

  --prefix)
  PREFIX=$2
  shift
  ;;

  --output)
  OUTPUT=$2
  shift
  ;;

  --samples)
  SAMPLES=$2
  shift
  ;;

  *)
  (>&2  echo "ProEST: ERROR: Argument $1 was not understood") && exit 
  ;;

esac
shift 
done



# 2. Checking existence of variables and files
ERROR=false
[ -z "$DIM"     ] && (>&2  echo "ProEST: ERROR: Argument --dim     was not set") && ERROR=true
[ -z "$TOTAL"   ] && (>&2  echo "ProEST: ERROR: Argument --total   was not set") && ERROR=true
[ -z "$CONCAT"  ] && (>&2  echo "ProEST: ERROR: Argument --concat  was not set") && ERROR=true
[ -z "$TRAJ"    ] && (>&2  echo "ProEST: ERROR: Argument --traj    was not set") && ERROR=true
[ -z "$MASK"    ] && (>&2  echo "ProEST: ERROR: Argument --mask    was not set") && ERROR=true
[ -z "$PRMTOP"  ] && (>&2  echo "ProEST: ERROR: Argument --prmtop  was not set") && ERROR=true
[ -z "$PREFIX"  ] && (>&2  echo "ProEST: ERROR: Argument --prefix  was not set") && ERROR=true
[ -z "$OUTPUT"  ] && (>&2  echo "ProEST: ERROR: Argument --output  was not set") && ERROR=true
[ -z "$SAMPLES" ] && (>&2  echo "ProEST: ERROR: Argument --samples was not set") && ERROR=true
$ERROR && exit

ERROR=false
[ ! -f $PRMTOP     ] && (>&2  echo "ProEST: ERROR: File $PRMTOP was not found") && ERROR=true
for i in $(seq 1 1 $TOTAL)
do
    trajfile=$(sed "s/X/$i/" <<< $TRAJ)
    [ ! -f $trajfile ] && (>&2  echo "ProEST: ERROR: File $trajfile was not found") && ERROR=true
done
$ERROR && exit

[ "$((2*$CONCAT))" -gt "$TOTAL" ] && (>&2  echo "ProEST: ERROR: TOTAL must be at twice CONCAT") && exit

# 3. Checking cpptraj, ante-MMPBSA.py and python
PTRAJ=$(command -v cpptraj) || (>&2 echo "ProEST: ERROR: cpptraj was not found. Please add it to the \$PATH variable and try again."&& exit)

PYTHON=$(command -v python) || (>&2 echo "ProEST: ERROR: python not found. Please add it to the \$PATH variable and try again." && exit)
echo "
try:
    import numpy,sys,random
except:
    print 'error' 
" > $PREFIX.py
[ "$($PYTHON $PREFIX.py)" == "error" ] && echo "ERROR: python does not have 'numpy','random' or 'sys' libraries. Please install them and try again." && exit
/bin/rm $PREFIX.py

ANTEMMPBSA=$(command -v ante-MMPBSA.py) || (>&2  echo "ERROR: ante-MMPBSA.py was not found. Please add it to the \$PATH variable and try again."&& exit)

# 4. Getting max dimension
DIMLIST=$(sed "s/ /,/g" <<< "[$DIM]")
MAXDIM=$($PYTHON -c "print max($DIMLIST)")

# 5. Header of output and report
echo "
#
#  ProEST - Protein Essential Space Test
#
#  Using variables:
#     AMBER prmtop:            $PRMTOP
#     AMBER trajectories:      $TRAJ
#     AMBER mask:              $MASK
#     Trajectory analyser:     $PTRAJ
#     Prmtop converter:        $ANTEMMPBSA
#     Python package:          $PYTHON
#     Total number of DM:      $TOTAL
#     Num. of concatenated DM: $CONCAT
#     RMSIP dimension:         $DIM (max. $MAXDIM)
#     Temporary files prefix:  $PREFIX
#
#  For more information please write us to 
#
#     sciprot.unq@gmail.com 
#
#  If you find this information valuable for your work, please cite 
#  \"Cossio-Pérez, R., Palma, J., & Pierdominici-Sottile, G. (2017). Consistent 
#  principal component modes from molecular dynamics simulations of proteins. 
#  Journal of Chemical Information and Modeling.\"
#
#  Have a great day!
#
# SciProt Team
#
# RESULTS
" > $OUTPUT

echo "

  ProEST - Protein Essential Space Test

  Using variables:
     AMBER prmtop:            $PRMTOP
     AMBER trajectories:      $TRAJ
     AMBER mask:              $MASK
     Trajectory analyser:     $PTRAJ
     Prmtop converter:        $ANTEMMPBSA
     Python package:          $PYTHON
     Total number of DM:      $TOTAL
     Num. of concatenated DM: $CONCAT
     RMSIP dimension:         $DIM (max. $MAXDIM)
     Temporary files prefix:  $PREFIX

  Calculation started on $(date)
 
"

# 6. Converting topology file
[ -f $PREFIX.prmtop ] && /bin/rm $PREFIX.prmtop
$ANTEMMPBSA -p $PRMTOP -c $PREFIX.prmtop -s "!($MASK)" > /dev/null


# 7. Creating reference from average of all DMs
echo -n " Creating reference structure for PCA ... "
[ -f $PREFIX.script ] && /bin/rm $PREFIX.script
for i in $(seq 1 1 $TOTAL)
do
    trajfile=$(sed "s/X/$i/" <<< $TRAJ)
    echo "trajin $trajfile" >> $PREFIX.script
done     
echo "
rms first $MASK 
average $PREFIX.reference.pdb
go
quit" >> $PREFIX.script
$PTRAJ $PRMTOP $PREFIX.script > /dev/null
/bin/rm $PREFIX.script
echo "OK"


# 8. Rewritting
echo -n " Rewritting aligned trajectories ........ "
for i in $(seq 1 1 $TOTAL)
do
    trajfile=$(sed "s/X/$i/" <<< $TRAJ)
    echo "
    trajin $trajfile
    reference $PREFIX.reference.pdb
    rms reference $MASK
    strip !($MASK)
    trajout $PREFIX.traj.$i 
    go
    quit" > $PREFIX.script
    $PTRAJ $PRMTOP $PREFIX.script > /dev/null 
done
/bin/rm $PREFIX.script
/bin/rm $PREFIX.reference.pdb
echo "OK"

# 9. Creating 3 python scripts
echo "
import random,numpy
n = int($TOTAL)
m = int($CONCAT)
a = numpy.arange(1,n+1)
random.shuffle(a)
for i in range(m):
    print a[i],
print ''
for i in range(m):
    print a[i+m],
" > $PREFIX.array.py

echo "
import numpy as np
import sys

vecnum=int($MAXDIM)

# FIRST DM
line=open(sys.argv[1]).readlines()
resnum = int(line[1].split()[0])
if (resnum/7)*7 == resnum:
    res_lines=resnum/7
else:
    res_lines=(resnum/7)+1
V1=np.zeros((resnum,vecnum),dtype=float)
for i in range(vecnum):
    vec_temp = []
    for j in range(res_lines):
        k = (i+1)*(res_lines+2)+j+2
        words=line[k].split()
        for w in words:
            vec_temp.append(float(w))
    V1[:,i]= vec_temp

# SECOND DM
line=open(sys.argv[2]).readlines()
V2=np.zeros((resnum,vecnum),dtype=float)
for i in range(vecnum):
    vec_temp = []
    for j in range(res_lines):
        k = (i+1)*(res_lines+2)+j+2
        words=line[k].split()
        for w in words:
            vec_temp.append(float(w))
    V2[:,i]= vec_temp

# RMSIP
RMSIP=[]
for k in $DIMLIST:
    value = 0.0
    for i in range(k):
        for j in range(k):
            value += np.dot(V1[:,i],V2[:,j])**2
    value=np.sqrt((1/float(k))*value)
    RMSIP.append(str(value))
print ' '.join(RMSIP)
" > $PREFIX.rmsip.py

echo "
import numpy as np
import sys

d=int(sys.argv[1])
x = []
for line in open('$PREFIX.samples.dat'):
    x.append(float(line.split()[d-1]))

x = np.array(x,dtype=float)

pdf,e=np.histogram(x,bins=30,density=True)

pdf = pdf*(e[1]-e[0])
cdf = np.cumsum(pdf)

for i in range(len(pdf)):
    print '  %7.5f %7.5f %7.5f' %(0.5*e[i]+0.5*e[i+1],pdf[i],cdf[i])

" > $PREFIX.distributions.py

# 10. Big loop. Starts the sampling
[ -f $PREFIX.samples.dat ] && /bin/rm $PREFIX.samples.dat
echo " Starting the samples ... "
p10=0; p20=0; p30=0; p40=0; p50=0; p60=0; p70=0; p80=0; p90=0

for i in $(seq 1 1 $SAMPLES)
do
    # Report progress
    percent=$($PYTHON -c "print int($i*100/$SAMPLES)")
    if   [ $percent -ge 90 ] && [ "$p90" == "0" ]  
    then 
       echo -n '   90% '; p90=1
    elif [ $percent -ge 80 ] && [ "$p80" == "0" ]
    then
       echo -n '   80% '; p80=1
    elif [ $percent -ge 70 ] && [ "$p70" == "0" ]
    then
       echo -n '   70% '; p70=1
    elif [ $percent -ge 60 ] && [ "$p60" == "0" ] 
    then
       echo -n '   60% '; p60=1
    elif [ $percent -ge 50 ] && [ "$p50" == "0" ]
    then
       echo -n '   50% '; p50=1
    elif [ $percent -ge 40 ] && [ "$p40" == "0" ]
    then
       echo -n '   40% '; p40=1
    elif [ $percent -ge 30 ] && [ "$p30" == "0" ]
    then
       echo -n '   30% '; p30=1
    elif [ $percent -ge 20 ] && [ "$p20" == "0" ]
    then
       echo -n '   20% '; p20=1
    elif [ $percent -ge 10 ] && [ "$p10" == "0" ]
    then
       echo -n '   10% '; p10=1

    fi
 
    # Getting sequence
    $PYTHON $PREFIX.array.py > $PREFIX.seq

    # Creating vectors
    [ -f $PREFIX.script ] && /bin/rm $PREFIX.script
    for i in $(head -1 $PREFIX.seq)
    do
        echo "trajin $PREFIX.traj.$i" >> $PREFIX.script
    done
    echo "
    matrix covar name covmat $MASK
    analyze matrix covmat vecs $MAXDIM out $PREFIX.A.vec 
    go
    quit" >> $PREFIX.script
    $PTRAJ $PREFIX.prmtop $PREFIX.script > /dev/null
    /bin/rm $PREFIX.script

    for i in $(tail -1 $PREFIX.seq)
    do
        echo "trajin $PREFIX.traj.$i" >> $PREFIX.script
    done
    echo "
    matrix covar name covmat $MASK
    analyze matrix covmat vecs $MAXDIM out $PREFIX.B.vec 
    go
    quit" >> $PREFIX.script
    $PTRAJ $PREFIX.prmtop $PREFIX.script > /dev/null
    /bin/rm $PREFIX.script 
    
    # Calculating RMSIP samples
    $PYTHON $PREFIX.rmsip.py $PREFIX.A.vec $PREFIX.B.vec >> $PREFIX.samples.dat
    /bin/rm $PREFIX.A.vec $PREFIX.B.vec
    /bin/rm $PREFIX.seq

done
echo '   100%   OK'

# 11. Making distributions
for d in $DIM
do
printf "#-------  RMSIP %2s -----|" $d >> $OUTPUT
done
echo "" >> $OUTPUT

for d in $DIM
do
echo -n "#     Bin   Prob.    Cum." >> $OUTPUT
done
echo "" >>$OUTPUT

rmsipfiles=""
count=1
for d in $DIM
do
    $PYTHON $PREFIX.distributions.py $count > $PREFIX.distributions.$d.dat
    rmsipfiles=$rmsipfiles" $PREFIX.distributions.$d.dat"
    count=$(($count+1))
done
paste -d "" $rmsipfiles >> $OUTPUT

# 12. Erase left temporary files
for i in $(seq 1 1 $TOTAL)
do
    /bin/rm $PREFIX.traj.$i 
done

for d in $DIM
do  
    /bin/rm $PREFIX.distributions.$d.dat
done
/bin/rm $PREFIX.array.py
/bin/rm $PREFIX.rmsip.py
/bin/rm $PREFIX.distributions.py
/bin/rm $PREFIX.prmtop
/bin/rm $PREFIX.samples.dat
echo "
 Calculation ended on $(date)
"
