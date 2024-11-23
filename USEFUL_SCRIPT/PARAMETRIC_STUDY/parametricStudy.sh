#!/bin/bash 

# ============================================================================
# GENERALIZED BASH SCRIPT FOR OPENFOAM PARAMETRIC STUDY WITH LOGGING
# Handles block-structured files using | notation and logs each case
# ============================================================================

# ----------------------------------------------------------------------------
# COLOR OUTPUT SETTINGS
# ----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ----------------------------------------------------------------------------
# 1. ENVIRONMENT SETUP
# ----------------------------------------------------------------------------
echo -e "\n${GREEN}============================================="
echo -e "        INITIALIZING ENVIRONMENT"
echo -e "=============================================${NC}\n"

# Load OpenFOAM environment (adjust according to your setup)
source /opt/openfoam9/etc/bashrc

# Define paths and variables
ROOT_DIR=$(pwd)
TEMPLATE_CASE_DIR="$ROOT_DIR/baseCase"
RESULTS_DIR="$ROOT_DIR/RESULTS"
RUN_SCRIPT="$ROOT_DIR/SCRIPTS/BASH/run_all.sh"
LOG_FILE="$RESULTS_DIR/parametric_study.log"
README_FILE="$RESULTS_DIR/logCase.txt"

# Initialize log file
mkdir -p "$RESULTS_DIR"
echo "Parametric Study Log - $(date)" > "$LOG_FILE"
echo "Log File: $LOG_FILE"

# ----------------------------------------------------------------------------
# 2. PARSE INPUT FILE AND USER OPTIONS
# ----------------------------------------------------------------------------
INPUT_FILE="$1"
RUN_OPTION="$2"  # 'run' to execute simulations, 'structure' to create only the structure

# Ensure INPUT_FILE is provided and exists
if [[ -z "$INPUT_FILE" || ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}Error: First argument must be a valid input file path.${NC}"
    echo "Usage: $0 <input_file> <structure|run>" >> "$LOG_FILE"
    exit 1
fi

# Ensure RUN_OPTION is provided and is either 'structure' or 'run'
if [[ -z "$RUN_OPTION" || ( "$RUN_OPTION" != "structure" && "$RUN_OPTION" != "run" ) ]]; then
    echo -e "${RED}Error: Second argument must be either 'structure' or 'run'.${NC}"
    echo "Usage: $0 <input_file> <structure|run>" >> "$LOG_FILE"
    exit 1
fi

echo "Parsed input file: $INPUT_FILE" >> "$LOG_FILE"
echo "Execution mode: $RUN_OPTION" >> "$LOG_FILE"

# Read configurations from the input file
FILES_TO_MODIFY=$(grep "FILES_TO_MODIFY=" "$INPUT_FILE" | cut -d '=' -f 2 | tr -d ' ')
PARAMETERS_TO_MODIFY=$(grep "PARAMETERS_TO_MODIFY=" "$INPUT_FILE" | cut -d '=' -f 2 | tr -d ' ')

# Parse CASE_VALUES manually by reading lines after "CASE_VALUES=(" until ")"
CASE_VALUES=()
inside_case_values=false
while IFS= read -r line; do
    # Check if we have reached the CASE_VALUES block
    if [[ $line == *"CASE_VALUES=("* ]]; then
        inside_case_values=true
        continue
    fi

    # If inside CASE_VALUES block, add lines until we hit ")"
    if $inside_case_values; then
        if [[ $line == *")"* ]]; then
            inside_case_values=false
            continue
        fi
        # Remove quotes and add line to CASE_VALUES array
        CASE_VALUES+=("$(echo "$line" | tr -d '"')")
    fi
done < "$INPUT_FILE"

# Split FILES_TO_MODIFY and PARAMETERS_TO_MODIFY into arrays
IFS=',' read -r -a FILES_ARRAY <<< "$FILES_TO_MODIFY"
IFS=',' read -r -a PARAMETERS_ARRAY <<< "$PARAMETERS_TO_MODIFY"

# Get the number of cases from CASE_VALUES
NUM_CASES=${#CASE_VALUES[@]}

echo "Parsed input file: $INPUT_FILE" >> "$LOG_FILE"
echo "Files to modify: ${FILES_ARRAY[@]}" >> "$LOG_FILE"
echo "Parameters to modify: ${PARAMETERS_ARRAY[@]}" >> "$LOG_FILE"
echo "Number of cases: $NUM_CASES" >> "$LOG_FILE"

# ----------------------------------------------------------------------------
# Helper function to create a sanitized case name
# ----------------------------------------------------------------------------
sanitize_case_name() {
    local name="$1"
    # Replace spaces and pipes with underscores
    name=$(echo "$name" | sed 's/[ |]/_/g')
    echo "$name"
}

# ----------------------------------------------------------------------------
# 3. OVERWRITE OR SAVE OLD RESULTS
# ----------------------------------------------------------------------------
echo -e "${YELLOW}Do you want to overwrite existing results or save old runs?${NC}"
echo "Choose an option:"
echo "1) Overwrite (erase existing results)"
echo "2) Save old runs (rename old files with timestamp)"
read -p "Enter choice [1-2]: " CHOICE

if [[ "$CHOICE" == "1" ]]; then
    echo "User chose to overwrite existing results." >> "$LOG_FILE"
elif [[ "$CHOICE" == "2" ]]; then
    echo "User chose to save old results." >> "$LOG_FILE"
else
    echo -e "${RED}Invalid choice. Exiting...${NC}"
    echo "Error: Invalid choice. Exiting." >> "$LOG_FILE"
    exit 1
fi

# ----------------------------------------------------------------------------
# 4. MAIN LOOP: CREATE STRUCTURE AND PLAN SUMMARY
# ----------------------------------------------------------------------------
echo -e "\n${YELLOW}============================================="
echo -e "       STARTING PARAMETRIC STUDY SETUP"
echo -e "=============================================${NC}\n"
echo "Starting parametric study setup at $(date)" >> "$LOG_FILE"

for CASE_NUM in $(seq 1 "$NUM_CASES"); do
    # Read each line for the case values, keeping underscores
    IFS=',' read -r -a PARAM_VALUES <<< "${CASE_VALUES[$CASE_NUM-1]}"
    
    # Construct dynamic case name with parameter names and values, sanitized
    CASE_NAME="Case"
    for i in "${!PARAMETERS_ARRAY[@]}"; do
        PARAM_NAME="${PARAMETERS_ARRAY[i]}"
        PARAM_VALUE="${PARAM_VALUES[i]}"
        # Replace spaces and special characters in parameter name and value
        SANITIZED_NAME=$(sanitize_case_name "${PARAM_NAME}_${PARAM_VALUE}")
        CASE_NAME+="_$SANITIZED_NAME"
    done

    CASE_DIR="$RESULTS_DIR/$CASE_NAME"
    
    echo -e "${GREEN}Planning setup for $CASE_NAME at $CASE_DIR${NC}\n"
    echo "Planning setup for $CASE_NAME at $CASE_DIR" >> "$LOG_FILE"

    # Check if the case directory already exists
    if [ -d "$CASE_DIR" ]; then
        if [ "$CHOICE" == "1" ]; then
            echo -e "${RED}Existing case at $CASE_DIR will be overwritten.${NC}\n"
            rm -rf "$CASE_DIR"
            echo "Overwriting existing case directory: $CASE_DIR" >> "$LOG_FILE"
        elif [ "$CHOICE" == "2" ]; then
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            NEW_DIR="${CASE_DIR}_old_$TIMESTAMP"
            mv "$CASE_DIR" "$NEW_DIR"
            echo "Renamed existing case directory to: $NEW_DIR" >> "$LOG_FILE"
        fi
    fi

    # Create the case directory
    mkdir -p "$CASE_DIR"
    echo "Created case directory: $CASE_DIR" >> "$LOG_FILE"

    # Copy baseCase structure, excluding polyMesh
    rsync -av --exclude 'constant/polyMesh' "$TEMPLATE_CASE_DIR/" "$CASE_DIR/" >> "$LOG_FILE"
    ln -s "$ROOT_DIR/SCRIPTS" "$CASE_DIR"
    echo "Linked scripts directory to case directory." >> "$LOG_FILE"

    # Link polyMesh if available
    if [ -d "$TEMPLATE_CASE_DIR/constant/polyMesh" ]; then
        ln -s "$TEMPLATE_CASE_DIR/constant/polyMesh" "$CASE_DIR/constant/polyMesh"
        echo "Linked polyMesh from baseCase to case directory." >> "$LOG_FILE"
    fi

    echo -e "${GREEN}Parameters for $CASE_NAME:${NC}"
    MODIFIED_PARAMETERS="Case $CASE_NAME:"

    # Modify parameters based on the specified values
    for INDEX in "${!FILES_ARRAY[@]}"; do
        FILE_TO_MODIFY="${FILES_ARRAY[$INDEX]}"
        PARAMETER_TO_MODIFY="${PARAMETERS_ARRAY[$INDEX]}"
        VALUE_TO_APPLY="${PARAM_VALUES[$INDEX]}"
        
        # Replace underscores with spaces for the actual value to apply
        VALUE_TO_APPLY="${VALUE_TO_APPLY//_/ }"

        mkdir -p "$(dirname "$CASE_DIR/$FILE_TO_MODIFY")"

        # Handle block-structured parameters
        if [[ "$PARAMETER_TO_MODIFY" == *"|"* ]]; then
            BLOCK_PARAM=$(echo "$PARAMETER_TO_MODIFY" | cut -d '|' -f 1)
            INNER_PARAM=$(echo "$PARAMETER_TO_MODIFY" | cut -d '|' -f 2)
            sed -i "/$BLOCK_PARAM/,/}/s/$INNER_PARAM.*/$INNER_PARAM         $VALUE_TO_APPLY;/" "$CASE_DIR/$FILE_TO_MODIFY"
        else
            # Modify parameter directly with space-preserved value
            sed -i "s/^$PARAMETER_TO_MODIFY\s*.*/$PARAMETER_TO_MODIFY        $VALUE_TO_APPLY;/" "$CASE_DIR/$FILE_TO_MODIFY"
        fi

        echo -e "${YELLOW}  - $PARAMETER_TO_MODIFY set to $VALUE_TO_APPLY in $FILE_TO_MODIFY${NC}"
        echo "Modified $PARAMETER_TO_MODIFY in $FILE_TO_MODIFY to $VALUE_TO_APPLY" >> "$LOG_FILE"
        MODIFIED_PARAMETERS+=" $PARAMETER_TO_MODIFY in $FILE_TO_MODIFY = $VALUE_TO_APPLY;"
    done

    echo "$MODIFIED_PARAMETERS" >> "$README_FILE"
done

# ----------------------------------------------------------------------------
# 5. SUMMARY BEFORE EXECUTION
# ----------------------------------------------------------------------------
echo -e "\n${GREEN}============================================="
echo -e "       SUMMARY OF PLANNED CASES"
echo -e "=============================================${NC}"
echo -e "${YELLOW}Results will be saved in: $RESULTS_DIR${NC}"
echo -e "${YELLOW}Number of Cases to Process: $NUM_CASES${NC}"
echo -e "Listing planned cases:\n"

echo -e "\nSummary of planned cases:" >> "$LOG_FILE"
echo "Results directory: $RESULTS_DIR" >> "$LOG_FILE"
echo "Total cases to process: $NUM_CASES" >> "$LOG_FILE"

for CASE_NUM in $(seq 1 "$NUM_CASES"); do
    PARAM_VALUES=(${CASE_VALUES[$CASE_NUM-1]//,/ })
    CASE_NAME="Case"
    for i in "${!PARAMETERS_ARRAY[@]}"; do
        PARAM_NAME="${PARAMETERS_ARRAY[i]}"
        PARAM_VALUE="${PARAM_VALUES[i]}"
        SANITIZED_NAME=$(sanitize_case_name "${PARAM_NAME}_${PARAM_VALUE}")
        CASE_NAME+="_$SANITIZED_NAME"
    done
    echo -e "  - $CASE_NAME"
    echo "Planned case: $CASE_NAME" >> "$LOG_FILE"
done

# ----------------------------------------------------------------------------
# 6. RUN SIMULATION OR EXIT
# ----------------------------------------------------------------------------
if [[ "$RUN_OPTION" == "run" ]]; then
    echo -e "\n${GREEN}============================================="
    echo -e "       EXECUTING PARAMETRIC STUDY"
    echo -e "=============================================${NC}\n"
    echo "Starting simulations at $(date)" >> "$LOG_FILE"
    
    for CASE_NUM in $(seq 1 "$NUM_CASES"); do
        PARAM_VALUES=(${CASE_VALUES[$CASE_NUM-1]//,/ })
        CASE_NAME="Case"
        for i in "${!PARAMETERS_ARRAY[@]}"; do
            PARAM_NAME="${PARAMETERS_ARRAY[i]}"
            PARAM_VALUE="${PARAM_VALUES[i]}"
            SANITIZED_NAME=$(sanitize_case_name "${PARAM_NAME}_${PARAM_VALUE}")
            CASE_NAME+="_$SANITIZED_NAME"
        done
        CASE_DIR="$RESULTS_DIR/$CASE_NAME"
        
        echo -e "${GREEN}Running custom script for $CASE_NAME...${NC}\n"
        echo "Running custom script for $CASE_NAME at $(date)" >> "$LOG_FILE"
        
        cd "$CASE_DIR"
        bash "$RUN_SCRIPT" >> "$LOG_FILE" 2>&1
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Custom script completed successfully for $CASE_NAME${NC}\n"
            echo "Simulation completed successfully for $CASE_NAME" >> "$LOG_FILE"
        else
            echo -e "${RED}Error during custom script for $CASE_NAME. Check logs.${NC}\n"
            echo "Error during simulation for $CASE_NAME" >> "$LOG_FILE"
        fi
        cd "$ROOT_DIR"
    done
else
    echo -e "${YELLOW}Structure-only option selected. No simulations executed.${NC}"
    echo "Structure-only option selected. No simulations executed." >> "$LOG_FILE"
fi

echo -e "\n${GREEN}============================================="
echo -e "       PARAMETRIC STUDY COMPLETED"
echo -e "=============================================${NC}\n"
echo "Parametric study completed at $(date)" >> "$LOG_FILE"

