# L'objectif de ce script python est de ploter les différents profils de vitesse pour différents x

print ("\n---- Python Script : Velocity Profile for different x values ----\n")

# MODULES :
import numpy as np

# VARIABLES : 
Ue = 1
nu = 1e-5

# EXTRACTION DES PROFILS ADIMENSIONNES

x_range = np.array([1, 5, 10 , 25, 50],dtype=int)
x_rangeTXT = np.array(["01","05","10","25","50"])

for index,x in enumerate(x_range):
    
    # 1. Import data
    data = np.loadtxt("postProcessing/sampleDict/2000/profile_x_%s_interpolated_U.xy"%(x_rangeTXT[index]), usecols=(1,3))

    # 2. Dimensionless y and U columns
    eta = data[:,0]*np.sqrt(Ue/(nu*x))
    U = data[:,1]/Ue

    # 3. Write data
    results = np.column_stack((eta,U))
    np.savetxt("postProcessing/sampleDict/2000/profile_x_%s_interpolated_U.xy.dimensionless"%(x_rangeTXT[index]),results,fmt='%.6f',header='eta      U/Ue')

# 4. Loop through x

print ("\n---- End of the script ---- \n")


