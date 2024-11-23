#!/bin/bash

# BEFORE LAUNCHING THE SCRIP, ADD:
# In the the systeme/controlDict:
        # includeFunc residuals

foamCleanCase
mkdir -p "LOG"

echo "execution of blockMesh..."
blockMesh  > ./LOG/log.blockMesh

echo "exectution of renumberMesh..."
mpirun -np 4 renumberMesh > ./LOG/log.renumberMesh -overwrite -parallel

echo "execution of checkMesh..."
checkMesh  > ./LOG/log.checkMesh

decomposePar
mpirun -np 4 simpleFoam -parallel
reconstructPar

gnuplot ./SCRIPTS/GNUPLOT/plotResidualsFigure.gp

echo "Simulation completed"
