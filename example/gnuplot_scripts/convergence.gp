reset

set term qt size 1000, 600

set key inside box left bottom font ", 14"

set title "Simulated Annealing - Convergence" font ",18"

set grid lw 2

set xyplane 0

set border 31+32+64+256+512 linecolor rgb "#333333" lw 1.5




#  Bit     plot        splot
#                1   bottom      bottom left front
#                2   left        bottom left back
#                4   top         bottom right front
#                8   right       bottom right back
#               16   no effect   left vertical
#               32   no effect   back vertical
#               64   no effect   right vertical
#              128   no effect   front vertical
#              256   no effect   top left back
#              512   no effect   top right back
#             1024   no effect   top left front
#             2048   no effect   top right front
#             4096   polar       no effect

set tics font ", 16"

set xlabel "Iteration" font ", 20"
set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel "" font ", 20"
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback

set zlabel "" font ", 20"
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback

# Reading maximum temperature
stats '../data/log.dat' using 8 nooutput
scale = 3/STATS_max
# Reading number of iterations.
records = STATS_records



plot '../data/log.dat' using 7 ps 1.0 pt 7 lc "#00cc4433" t 'Acceptance Probability', \
     '../data/log.dat' using 1 ps 0.75 pt 7 t "stdDev", \
     '../data/log.dat' using 2 ps 0.75 pt 7 lc "#00004433" t "mean", \
     '../data/log.dat' using ($5) ps 1.25 pt 6 t "System Energy", \
      '../data/log.dat' using ($6) ps 0.25 pt 50 lc "magenta" t "Min. System Energy", \
      '../data/log.dat' using ($8*scale) with lines lw 2 lc "blue" t sprintf('Temperature * %.2f', scale)
