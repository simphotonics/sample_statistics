reset

# Apply graph settings
load 'histogram_settings.gp'

# Import pdf
load 'normal_pdf.gp'

hist1 = '../plots/truncated_normal400.hist'
hist2 = '../plots/truncated_normal3000.hist'
vars1 = '../plots/truncated_normal400.dat'
vars2 = '../plots/truncated_normal3000.dat'

set multiplot layout 1, 2 title 'Random Sample Histograms - Truncated Normal Distribution' font ", 18"


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


set label  sprintf('interval size = %.3f', (max - min)/intervals) at 0.8*max, 0.5*yMax \
 font " ,16" textcolor rgb "0x332222"

set label  sprintf('mean = %.3f', sampleMean) at 0.7*mean, 1.1*yMax font " ,16" textcolor rgb "blue"

set arrow from mean, 0 to mean, truncatedNormalPdf(mean, min, max, mean, stdDev) backhead ls 2

set yrange [0: 0.5]
plot hist1 u 1: 2 with boxes t sprintf('histogram sample size: %d', sampleSize) ls 1, \
hist1 u 1: 3 ls 2 t "truncated normal dist."
unset yrange

# ------------------------------------------ Right plot

unset label
stats hist2 u 1
#show variables STATS
intervals = STATS_records

# Import pdf parameters: sampleSize, min, max, mean, stdDev.
load vars2

 # set fit errorscaling
 #fit truncatedNormalPdf(x,min,max,mean,stdDev) file u 1:2 via mean, stdDev

yMax = truncatedNormalPdf(mean, min, max, mean, stdDev)

meanCorr = meanTruncatedNormal(min, max, mean, stdDev)

set label  sprintf('interval size = %.3f', (max - min)/intervals) at 0.8*max, 0.5*yMax \
 font " ,16" textcolor rgb "0x332222"

set label  sprintf('mean = %.3f', sampleMean) at 0.7*mean, 1.1*yMax font " ,16" textcolor rgb "blue"

set arrow from mean, 0 to mean, truncatedNormalPdf(mean, min, max, mean, stdDev) backhead ls 2

set yrange [0: 0.5]
plot hist2 u 1: 2 with boxes t sprintf('histogram sample size: %d', sampleSize) ls 1, \
hist2 u 1: 3 ls 2 t "truncated normal dist."
unset yrange
