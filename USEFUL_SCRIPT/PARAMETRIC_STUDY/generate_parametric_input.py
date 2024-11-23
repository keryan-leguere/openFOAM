import numpy as np

def calculate_nu(Re, U, distance):
    """
    Calculate kinematic viscosity (nu) from Reynolds number (Re), velocity (U), and distance.
    """
    return U * distance / Re

def generate_input_file(output_file="input_parametric_study.txt"):
    """
    Generate a parametric study input file for OpenFOAM based on specified distances, discrete numbers,
    and Reynolds number range.
    """
    # Parameters setup
    U = 1.0  # Example velocity
    distances = [10, 20, 50]  # Distances to vary
    discrete_numbers = [20, 40]  # Discrete numbers to vary
    num_reynolds = 10  # Number of Reynolds numbers to generate between 1 and 100
    re_values = np.linspace(1, 100, num_reynolds)  # Reynolds number range

    # Write to output file in required format
    with open(output_file, "w") as f:
        f.write("# Specify the file paths that need to be modified in each case\n")
        f.write("FILES_TO_MODIFY=system/blockMeshDict,system/blockMeshDict,system/blockMeshDict,constant/transportProperties\n\n")
        
        f.write("# Specify the parameter names in those files that will be modified\n")
        f.write("PARAMETERS_TO_MODIFY=distancePositive,distanceNegative,discreteNumber,nu\n\n")
        
        f.write("# Define parameter values for each case\n")
        f.write("CASE_VALUES=(\n")
        
        # Iterate over each combination of distance, discrete number, and Reynolds number
        for distance in distances:
            distance_negative = -distance
            for discrete_number in discrete_numbers:
                nu_values = [calculate_nu(re, U, 1) for re in re_values]
                for nu in nu_values:
                    # Format each case with distance, discrete number, and calculated nu
                    f.write(f"\"{distance},{distance_negative},{discrete_number},{nu}\"\n")
        
        f.write(")\n")

    print(f"Input file '{output_file}' generated successfully with all combinations.")

if __name__ == "__main__":
    generate_input_file()
