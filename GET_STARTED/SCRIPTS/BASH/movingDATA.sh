#!/bin/bash -x

# Ensure the DATA_DIR is provided as an argument (relative or absolute)
DATA_DIR="$1"
if [ -z "$DATA_DIR" ]; then
    echo -e "\033[0;31mError: No DATA_DIR provided. Usage: bash postProcess.sh <DATA_DIR> <CASE_PATH>\033[0m"
    exit 1
fi


# Ensure the CASE_PATH is provided as an argument (relative or absolute)
CASE_PATH="$2"
if [ -z "$CASE_PATH" ]; then
    echo -e "\033[0;31mError: No CASE_PATH provided. Usage: bash postProcess.sh <DATA_DIR> <CASE_PATH>\033[0m"
    exit 1
fi

ROOT_DIR=$(pwd)

# ------------------------------------------------------------------------------------- #

### SAMPLE MOVING DATA, WHERE WE NEED TO DO SOME FILTER ON THE PARAMETERS:
# That corresponds to the case where you do a simulation you have some results that you send to the DATA directory. However, as you run a parametric study, you results need to concatenate with the previous results.


# # Ensure we are processing only directories that match the case name pattern
# if [[ -d "$CASE_PATH" && "$CASE_PATH" =~ Case_distancePositive_([0-9]+)_distanceNegative_[-0-9.]+_discreteNumber_([0-9]+)_nu_ ]]; then
#     # Extract parameters from the case name
#     distance="${BASH_REMATCH[1]}"
#     echo $distance
#     discrete_number="${BASH_REMATCH[2]}"
#     echo $discrete_number
# 
#     # Set the output file name based on extracted parameters
#     output_file="${DATA_DIR}/distance${distance}_discreteNumber${discrete_number}.dat"
# 
#     # Find the last line of postProcessing/Cd_Re in the case directory
#     cd_re_file="$CASE_PATH/postProcessing/Cd_Re.dat"
#     if [[ -f "$cd_re_file" ]]; then
#         # Extract the last line of Cd_Re and append it to the output file
#         tail -n 1 "$cd_re_file" >> "$output_file"
#         echo "Moved to ${output_file}"
#     else
#         echo "Warning: Cd_Re file not found in $CASE_PATH"
#     fi
# fi
