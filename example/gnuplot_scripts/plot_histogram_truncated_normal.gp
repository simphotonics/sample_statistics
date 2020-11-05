# To use this script navigate to the folder: `example/bin`
# and issue the command:
# $ gnuplot
# Followed by:
# gnuplot: load 'plot_histogram_truncated_normal.gp'
reset

# Apply graph settings
load 'histogram_settings.gp'

# Import pdf
load 'normal_pdf.gp'

hist1 = '../sample_data/truncated_normal1000.hist'
hist2 = '../sample_data/truncated_normal6750.hist'
vars1 = '../sample_data/truncated_normal1000.dat'
vars2 = '../sample_data/truncated_normal6750.dat'

set multiplot layout 1, 2 title 'Random Sample Histograms - Truncated Normal Distribution' font ", 28"


# ------------------------------------- Left plot
stats hist1 u 1
#show variables STATS
intervals = STATS_records

# Import pdf parameters: sampleSize, min, max, mean, stdDev.
load vars1

 # set fit errorscaling
 #fit truncatedNormalPdf(x,min,max,mean,stdDev) file u 1:2 via mean, stdDev

yMax = truncatedNormalPdf(mean, min, max, mean, stdDev)

meanCorr = meanTruncatedNormal(min, max, mean, stdDev)


set label  sprintf('interval size = %.3f', (max - min)/intervals) at 0.75*max, 0.5*yMax \
 font " ,20" textcolor rgb "0x332222"

set label  sprintf('mean = %.3f', sampleMean) at 0.6*mean, 1.1*yMax font " ,20" textcolor rgb "blue" front

set arrow front from mean, 0 to mean, truncatedNormalPdf(mean, min, max, mean, stdDev) backhead ls 2

set yrange [0: 0.5]
#set boxwidth (max - min)/intervals
plot hist1 u 1: 2 with boxes t sprintf('histogram sample size: %d', sampleSize) ls 1, \
hist1 u 1: 3 ls 2 t "truncated normal dist."
unset yrange

# ------------------------------------------ Right plot

unset label
unset ylabel
stats hist2 u 1
#show variables STATS
intervals = STATS_records

# Import pdf parameters: sampleSize, min, max, mean, stdDev.
load vars2

 # set fit errorscaling
 #fit truncatedNormalPdf(x,min,max,mean,stdDev) file u 1:2 via mean, stdDev

yMax = truncatedNormalPdf(mean, min, max, mean, stdDev)

meanCorr = meanTruncatedNormal(min, max, mean, stdDev)

set label  sprintf('interval size = %.3f', (max - min)/intervals) at 0.75*max, 0.5*yMax \
 font " ,20" textcolor rgb "0x332222"

set label  sprintf('mean = %.3f', sampleMean) at 0.7*mean, 1.1*yMax font " ,20" textcolor rgb "blue" front

unset arrow
set arrow from mean, 0 to mean, truncatedNormalPdf(mean, min, max, mean, stdDev) backhead ls 2

set yrange [0: 0.5]
#set boxwidth (max - min)/intervals
plot hist2 u 1: 2 with boxes t sprintf('histogram sample size: %d', sampleSize) ls 1, \
hist2 u 1: 3 ls 2 t "truncated normal dist."
unset yrange
