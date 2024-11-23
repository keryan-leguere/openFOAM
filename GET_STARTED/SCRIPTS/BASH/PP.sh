#!bin/bash

# Results file in postProcessing directory
FILENAME_RESULTS="./postProcessing/Cd_Re.dat"
touch $FILENAME_RESULTS
echo "Cd   		 Re" > $FILENAME_RESULTS

# Extract Cd from sampling
FILENAME_CD="postProcessing/forceCoeffs_object/0/forceCoeffs.dat"
Cd=$(tail -n -1 $FILENAME_CD | awk '{print $3}')

# Return the Reynolds number base on Lref and the patch at 0/ to calculate the freestream velocity
Re=$(python3 ./SCRIPTS/PYTHON/calculate_reynolds.py 1 left)

# Append Cd and Re values to the results file in scientific notation
printf "%s   %s\n" "$Cd" "$Re" >> $FILENAME_RESULTS

echo "Results saved to $FILENAME_RESULTS"
cat $FILENAME_RESULTS


