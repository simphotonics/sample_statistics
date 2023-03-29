# To use this script navigate to the folder: `example/bin`
# and issue the command:
# $ gnuplot
# Followed by:
# gnuplot: load 'plot_histogram_truncated_normal6000.gp'
reset


if (!exists("suffix")) suffix=600
print 'Sample size: '.suffix
# Apply graph settings


# Import pdf
load 'normal_pdf.gp'
set grid lw 1
set style line 1 lt 2 lw 2 pt 6 ps 2 lc rgb "#0608aaff"
set style line 2 lt 2 lw 2 pt 6 ps 2 lc rgb "0x007700"
set style line 3 lt 2 lw 2 pt 6 ps 2 lc rgb "red"

hist = '../data/truncated_normal'.suffix.'.hist'
var = '../data/truncated_normal'.suffix.'.var'
dat = '../data/truncated_normal'.suffix.'.dat'


stats hist u 1
#show variables STATS
intervals = STATS_records

# Import pdf parameters: sampleSize, min, max, mean, stdDev.
load var

 # set fit errorscaling
 #fit truncatedNormalPdf(x,min,max,mean,stdDev) file u 1:2 via mean, stdDev

yMax = truncatedNormalPdf(mean, min, max, mean, stdDev)


set label  sprintf('interval size = %.3f', (max - min)/intervals) at 0.65*max, 0.45 \
 font " ,10" textcolor rgb "0x332222"

set label  sprintf('sample mean = %.3f', sampleMean) at 0.65*max, 0.4 font " ,10" \
  textcolor rgb "0x007700" front

set arrow 1 front from mean, 0 to \
  mean, truncatedNormalPdf(mean, min, max, meanOfParent, stdDevOfParent) \
  backhead ls 2

set xrange [1.5:6.5]
set yrange [0: 0.6]
# set boxwidth 2*(max - min)/intervals relative
show boxwidth
print max
print min
print intervals

set term pngcairo size 400, 400 font "Sans,10"
set output '../plots/histogram_truncated_normal'.suffix.'.png'
plot hist u 1: 2 with boxes t sprintf('histogram sample size: %d', sampleSize) ls 1, \
hist u 1: 3 ls 3 t "truncated normal dist."
