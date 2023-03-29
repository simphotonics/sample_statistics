# To use this script navigate to the folder: `example/bin`
# and issue the command:
# $ gnuplot
# Followed by:
# gnuplot: load 'plot_histogram_truncated_normal600.gp'
reset

# Apply graph settings


# Import pdf
load 'normal_pdf.gp'
set grid lw 1
set style line 1 lt 2 lw 2 pt 6 ps 2 lc rgb "#0608aaff"
set style line 2 lt 2 lw 2 pt 6 ps 2 lc rgb "0x007700"
set style line 3 lt 2 lw 2 pt 6 ps 2 lc rgb "red"

hist1 = '../data/truncated_normal600.hist'
vars1 = '../data/truncated_normal600.dat'

stats hist1 u 1
#show variables STATS
intervals = STATS_records

# Import pdf parameters: sampleSize, min, max, mean, stdDev.
load vars1

 # set fit errorscaling
 #fit truncatedNormalPdf(x,min,max,mean,stdDev) file u 1:2 via mean, stdDev

yMax = truncatedNormalPdf(mean, min, max, mean, stdDev)

meanCorr = meanTruncatedNormal(min, max, mean, stdDev)


set label  sprintf('interval size = %.3f', (max - min)/intervals) at 0.65*max, 0.45 \
 font " ,12" textcolor rgb "0x332222"

set label  sprintf('mean = %.3f', sampleMean) at 0.65*max, 0.4 font " ,12" \
  textcolor rgb "0x007700" front

set arrow 1 front from mean, 0 to mean, truncatedNormalPdf(mean, min, max, mean, stdDev) \
  backhead ls 2
show arrow
set xrange [1:6]
set yrange [0: 0.6]
set boxwidth (max - min)/intervals

set term pngcairo size 500, 500 font "Sans,12"
set output '../plots/histogram_truncated_normal600.png'
plot hist1 u 1: 2 with boxes t sprintf('histogram sample size: %d', sampleSize) ls 1, \
hist1 u 1: 3 ls 3 t "truncated normal dist."
