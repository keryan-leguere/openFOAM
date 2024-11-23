# L'objectif de ce script python est de générer est un tableau de la forme
# Position en x | delta_numerique | delta_theorique | Rex

print ("\n---- Python Script : BL Thickness for different x values ----\n")

# MODULES :
import numpy as np

# VARIABLES : 
Ue = 1
nu = 1e-5
threshold = 0.95 * Ue
t_results = np.empty((0, 4))

# EXTRACTION DELTA_NUM POUR X
x_range = np.array([1, 5, 10 , 25, 50],dtype=int)
x_rangeTXT = np.array(["01","05","10","25","50"])

for index,x in enumerate(x_range):
    
    # Il suffit de chercher dans le fichier la hauteur tq on atteint 0.99 Ue.
    data = np.loadtxt("postProcessing/sampleDict/2000/profile_x_%s_interpolated_U.xy"%(x_rangeTXT[index]), usecols=(1,3))

    # Data : y | Ux
    index = np.where(data[:,1] >= threshold) [0] [0]
    delta99_num = data[index,0]

    Rex = Ue * x / nu
    delta99_th = 5.2 * x / np.sqrt(Rex)
    
    row = np.array([x,delta99_num,delta99_th, Rex])
    row = row.reshape(1,-1)

    t_results = np.vstack((t_results, row))

# SAUVEGARDE DES RESULTATS

filename = "./postProcessing/BL_Thickness.dat"
# Save the array to a text file with the desired format
np.savetxt(
    filename,
    t_results,
    header="# x     delta_num   delta_th    Rex",
    fmt='%d      %.4f        %.4f        %.2e',
    comments=''
)

print ("\n---- End of the script ---- \n")


