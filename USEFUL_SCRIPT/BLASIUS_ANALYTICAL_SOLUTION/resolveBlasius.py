import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp

# Define the Blasius equation as a system of first-order ODEs
def blasius_eq(eta, y):
    f = y[0]       # f(eta)
    f_prime = y[1] # f'(eta)
    f_double_prime = y[2] # f''(eta)

    # Return the derivatives
    return [f_prime, f_double_prime, -0.5 * f * f_double_prime]

# Boundary conditions
def boundary_conditions():
    # Initial guesses for f'(0) (which will be varied by the shooting method)
    f0 = [0, 0, 0.332]  # f(0), f'(0), and initial guess for f''(0)
    return f0

# Solving the Blasius equation using solve_ivp (numerical ODE solver)
def solve_blasius():
    # Define the range of eta values to solve over
    eta_max = 10
    eta_range = (0, eta_max)

    # Initial conditions from the boundary condition function
    initial_conditions = boundary_conditions()

    # Solve the Blasius equation
    solution = solve_ivp(blasius_eq, eta_range, initial_conditions, max_step=0.1, t_eval=np.linspace(0, eta_max, 100))

    return solution

# Get the solution of the Blasius equation
sol = solve_blasius()

# Extract eta and the dimensionless velocity profile f'(eta)
eta_vals = sol.t
f = sol.y[0]       # f(eta)
f_prime = sol.y[1] # f'(eta)
f_double_prime = sol.y[2] # f''(eta)
    
# ----------------------------------------------------------------------------- #
Ue = 1
nu = 1e-5

# A ce stage on a u/ue et eta.
data = np.column_stack((eta_vals, f_prime))
np.savetxt('REFERENCES/U_profile_analytical.dat', data, header='eta\tU/Ue', fmt='%.4f', delimiter='\t')

print("Velocity profile has been written to 'REFERENCES/U_profile_analytical.dat'")


# ----------------------------------------------------------------------------- #


print ("\n---- Python Script : V Velocity Profile ----\n")

# EXTRACTION X
x_range = np.array([1, 5, 10 , 25, 50],dtype=int)
x_rangeTXT = np.array(["01","05","10","25","50"])

for index,x in enumerate(x_range):
    
    Rex = Ue*x/nu
    v = Ue * (eta_vals * f_prime - f) / (2 * np.sqrt(Rex))
    y = eta_vals * np.sqrt(nu*x/Ue)
    data = np.column_stack((y, v))
    
    filename = "./REFERENCES/V_profile_analytical%s.dat"%(x_rangeTXT[index])
    # Save the array to a text file with the desired format
    np.savetxt(filename, data, header='y\tv', fmt='%.8f', delimiter='\t')
    
    print("Velocity profile has been written to '%s'"%(filename))

print ("\n---- End of the script ---- \n")




