#set terminal pngcairo size 350,262 enhanced font 'Verdana,10'

# Adjusting the key (legend)
set key left box lw 2 font 'Helvetica,20'
set key spacing 1.5

# Adding space around the plot (margins)
set lmargin 10   # Left margin
set rmargin 10   # Right margin
set bmargin 5    # Bottom margin (for the x-axis label)

# Axis numbers (xtics and ytics) made bigger
set xtics 0,0.25,2.5 font 'Courier,20'
set ytics font 'Courier,20'

# Setting up grid
set grid

# Enabling dashed lines
set termoption dashed

set title "My title" font 'Times-Roman, 28'

# Axis titles
set xlabel "Xlabel" font 'Courier,24'
set ylabel "Ylabe" font 'Courier,24'

# Legend (optional)
set key left top box

# Output to PDF
set output "./POST_PROCESSING/FIGURES/plotXY.png"

plot \
 './POST_PROCESSING/DATA/profile_x5_U.xy.BASELINE' u 2:1 w l lw 3 lt 1 lc rgb 'blue'  title 'Coarse Mesh' ,\
 './POST_PROCESSING/DATA/profile_x5_U.xy.FINE' u 2:1 w l lw 3 lt 1 lc rgb 'red'  title 'Fine Mesh' ,\
 './REFERENCES/velocity_profile_analytical.dat' u 2:1 w l lw 3 lt 1 lc 0 title 'Analytical Results'
