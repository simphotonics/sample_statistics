# Histogram graph settings
set key inside nobox vertical font ", 20"
#set title "Histogram" font ",16"
set grid lw 2

set tics font ", 18"

set style line 1 lt 1 pt 6 lc rgb "#0608aaff" lw 3.5
set style line 2 lt 2 lw 3 lc rgb "blue" pt 6 ps 3

set xlabel "Sample values" font ", 24"
set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel "Probability density\n\n" font ", 24"
set yrange [ 0 : * ] noreverse writeback
set y2range [ 0 : * ] noreverse writeback

set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
