#!/bin/bash

# ============================================================================
# GENERALIZED POST-PROCESSING SCRIPT FOR OPENFOAM CASES
# Handles decompression, conversion, data extraction, cleanup, and figure generation
# Calls external processing script PP.sh located in SCRIPTS/BASH/
# ============================================================================
# Usage: bash postProcess.sh <RESULTS_DIR>
# Example: bash postProcess.sh ./RESULTS
# 
# Steps performed by this script:
# 1. DETECTION OF ARCHITECTURE AND RESULTS
# 2. DECOMPRESSION + CONVERSION TO ASCII/VTK/TECPLOT
# 3. CALLING EXTERNAL PROCESSING FUNCTION (PP.sh)
# 4. CLEANUP OF TEMPORARY FILES
# 5. CREATION OF FIGURES (via gnuplot)
# ============================================================================

# ----------------------------------------------------------------------------
# 1. DETECTION OF ARCHITECTURE AND RESULTS
# ----------------------------------------------------------------------------
echo -e "\n\033[1;32m=============================================\033[0m"
echo -e "\033[1;32m        DETECTION OF ARCHITECTURE AND RESULTS\033[0m"
echo -e "\033[1;32m=============================================\033[0m\n"

# Ensure the RESULTS_DIR is provided as an argument
if [ -z "$1" ]; then
    echo -e "\033[0;31mError: No RESULTS_DIR provided. Usage: bash postProcess.sh <RESULTS_DIR>\033[0m"
    exit 1
fi
RESULTS_DIR=$(realpath "$1")

# Define root directory as the parent of the RESULTS directory
ROOT_DIR=$(pwd)

# Ensure the RESULTS directory exists
if [ ! -d "$RESULTS_DIR" ]; then
    echo -e "\033[0;31mError: The directory $RESULTS_DIR does not exist.\033[0m"
    exit 1
fi

# Detect all case directories (e.g., SOL_Case1, SOL_Case2, etc.)
CASES=($(ls -d $RESULTS_DIR/*/))

# Define directories for post-processing results
POST_PROCESSING_DIR="$ROOT_DIR/POST_PROCESSING"
DATA_DIR="$POST_PROCESSING_DIR/DATA"
FIGURES_DIR="$POST_PROCESSING_DIR/FIGURES"
SCRIPTS_DIR="$ROOT_DIR/SCRIPTS"
BASH_SCRIPT="$SCRIPTS_DIR/BASH/PP.sh"
BASH_SCRIPT_ORGANIZATION="$SCRIPTS_DIR/BASH/movingDATA.sh"
BASH_SCRIPT_SETUP="$SCRIPTS_DIR/BASH/setup.sh"

# Ensure necessary directories exist
mkdir -p "$POST_PROCESSING_DIR" "$DATA_DIR" "$FIGURES_DIR"

# Example output of what is detected
echo -e "Detected cases for post-processing:"
for CASE in "${CASES[@]}"; do
    echo -e "  - $(basename $CASE)"
done

# Return to the root study case directory
cd "$ROOT_DIR"

# ----------------------------------------------------------------------------
# 2. DECOMPRESSION + CONVERSION (BINARY TO ASCII/VTK/TECPLOT)
# ----------------------------------------------------------------------------
# echo -e "\n\033[1;33m=============================================\033[0m"
# echo -e "\033[1;33m       DECOMPRESSION AND CONVERSION\033[0m"
# echo -e "\033[1;33m=============================================\033[0m\n"
# 
# # Loop through each case and perform decompression and conversion
# for CASE in "${CASES[@]}"; do
#     CASE_NAME=$(basename "$CASE")
#     echo -e "\033[1;34mProcessing $CASE_NAME...\033[0m"
# 
#     # Decompress and convert binary data to ASCII
#     foamFormatConvert -case "$CASE" >/dev/null 2>&1
#     echo -e "Converted binary files to ASCII for $CASE_NAME."
# 
#     # Convert OpenFOAM data to VTK
#     foamToVTK -case "$CASE" >/dev/null 2>&1
#     echo -e "Converted OpenFOAM data to VTK format for $CASE_NAME."
# 
#     # Convert OpenFOAM data to TECPLOT format (optional)
#     foamToTecplot360 -case "$CASE" >/dev/null 2>&1
#     echo -e "Converted OpenFOAM data to Tecplot format for $CASE_NAME."
# done
# 
# # Return to the root study case directory
# cd "$ROOT_DIR"

# ----------------------------------------------------------------------------
# 3. CALL EXTERNAL PROCESSING FUNCTION (PP.sh)
# ----------------------------------------------------------------------------
echo -e "\n\033[1;33m=============================================\033[0m"
echo -e "\033[1;33m         CALLING EXTERNAL PROCESSING SCRIPT\033[0m"
echo -e "\033[1;33m=============================================\033[0m\n"

# Ensure the PP.sh script exists
if [ ! -f "$BASH_SCRIPT" ]; then
    echo -e "\033[0;31mError: The script PP.sh does not exist in $SCRIPTS_DIR/BASH.\033[0m"
    exit 1
fi

# Execute the external processing script for each case
# (C'est le travail à faire par simulation. Par exemple extraire les coeff aéro, une longeur, y+ ce genre de chose. Ensuite il est trop pobable qu'on veut soit : 
# - Comparer les données entre les simulations, dans ces cas là il suffit de déplacer le fichier final dans le répertoire $DATA
# - Construire une courbe à partir des données de chaque cas. Dans ce cas un tout petit peu plus technque, je propose d'écrire la QOI toujours dans le repertoire postProcessing ou alors directement d'aller placer dans le bon rep. (sous reserve d'existence).


    echo -e "\033[1;34mCalling $BASH_SCRIPT_SETUP for $CASE_NAME...\033[0m"
    bash $BASH_SCRIPT_SETUP $DATA_DIR # Faire le travail avant de commencer setup et clean les fichiers de data global entre les cas (par exemple celui qui stock les polaires) -> script externe qu'on peut travailler appart.

for CASE in "${CASES[@]}"; do
    CASE_NAME=$(basename "$CASE")
    cd "$CASE"

    echo -e "\033[1;34mCalling $BASH_SCRIPT for $CASE_NAME...\033[0m"
    bash "$BASH_SCRIPT" # Faire le travail au sein du cas --> script externe qu'on peut travailler appart.

    echo -e "\033[1;34mCalling $BASH_SCRIPT_ORGANIZATION for $CASE_NAME...\033[0m"
    bash "$BASH_SCRIPT_ORGANIZATION" "$DATA_DIR" "$CASE" # Script pour balancer les datas dans $DATA pour pouvoir faire un gnuplot finale (surtout quand il s'agit d'une étude paramétrique) avec en paramètre justement le fichier data pour savoir où les envoyer + le nom du cas. Les 2 paramètres sont obligatoires car j'ai peur des espaces.

    cd "$ROOT_DIR"
done

# Return to the root study case directory
cd "$ROOT_DIR"

# ----------------------------------------------------------------------------
# 4. CLEANUP OF TEMPORARY FILES
# ----------------------------------------------------------------------------
# echo -e "\n\033[1;33m=============================================\033[0m"
# echo -e "\033[1;33m         CLEANING UP TEMPORARY FILES\033[0m"
# echo -e "\033[1;33m=============================================\033[0m\n"
# 
# # Remove temporary files created during decompression or conversion
# for CASE in "${CASES[@]}"; do
#     CASE_NAME=$(basename "$CASE")
#     echo -e "\033[1;34mCleaning up temporary files for $CASE_NAME...\033[0m"
# 
#     # Remove temporary files
#     rm -rf "$CASE/postProcessing/patchSummary*"
#     rm -rf "$CASE/postProcessing/VTK"
#     rm -rf "$CASE/postProcessing/Tecplot"
# 
#     echo -e "Cleaned up temporary files for $CASE_NAME."
# done
# 
# # Return to the root study case directory
# cd "$ROOT_DIR"

# ----------------------------------------------------------------------------
# 5. CREATION OF FIGURES (via gnuplot)
# ----------------------------------------------------------------------------
echo -e "\n\033[1;33m=============================================\033[0m"
echo -e "\033[1;33m       GENERATING FIGURES AND PLOTS\033[0m"
echo -e "\033[1;33m=============================================\033[0m\n"

# # Execute all gnuplot scripts in the SCRIPTS/gnuplot directory
# GNUPLOT_DIR="$SCRIPTS_DIR/GNUPLOT"
# if [ -d "$GNUPLOT_DIR" ]; then
#     for SCRIPT in "$GNUPLOT_DIR"/*.gp; do
#         echo -e "Running gnuplot script: $(basename $SCRIPT)..."
#         gnuplot "$SCRIPT" >/dev/null 2>&1
#         echo -e "Generated plot for $(basename $SCRIPT)."
#     done
# else
#     echo -e "\033[0;31mError: No gnuplot scripts found in $GNUPLOT_DIR.\033[0m"
# fi

# Return to the root study case directory
cd "$ROOT_DIR"

#python3 ./SCRIPTS/PYTHON/CdvsRe.py

# ----------------------------------------------------------------------------
# POST-PROCESSING COMPLETED
# ----------------------------------------------------------------------------
echo -e "\n\033[1;32m=============================================\033[0m"
echo -e "\033[1;32m         POST-PROCESSING COMPLETED\033[0m"
echo -e "\033[1;32m=============================================\033[0m\n"

echo -e "Post-processing results have been saved to:\n  - Data: $DATA_DIR\n  - Figures: $FIGURES_DIR"

