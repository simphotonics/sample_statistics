# Histogram graph settings
set key inside nobox vertical font ", 14"
set title "Histogram" font ",16"
set grid lw 1

set tics font ", 13"

set style line 1 lt 1 pt 6 lc rgb "#0608aaff" lw 2
set style line 2 lt 2 lw 3 lc rgb "blue" pt 6 ps 2

set xlabel "Sample values\n" font ", 16"
set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel "Probability density\n" font ", 16"
set yrange [ 0 : * ] noreverse writeback
set y2range [ 0 : * ] noreverse writeback

set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
