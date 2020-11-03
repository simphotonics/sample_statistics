reset

# Apply graph settings
load 'histogram_settings.gp'

# Import pdf
load 'normal_pdf.gp'

hist1 = '../sample_data/triangular_200.hist'
hist2 = '../sample_data/triangular_10000.hist'
vars1 = '../sample_data/triangular_200.dat'
vars2 = '../sample_data/triangular_10000.dat'

set multiplot layout 1, 2 title 'Random Sample Histograms - Triangular Distribution' font ", 28"


# ------------------------------------- Left plot
stats hist1 u 1
#show variables STATS
intervals = STATS_records

# Import pdf parameters: sampleSize, min, max, mean, stdDev.
load vars1

yMax = 2.0/(max - min)


set label  sprintf('interval size = %.3f', (max - min)*1.0/intervals) at 0.8*max, 0.8*yMax \
 font " ,20" textcolor rgb "0x332222"

set label  sprintf('mean = %.3f', sampleMean) at 1.2*min, 0.8*yMax font " ,20" textcolor rgb "blue" front

#set arrow front from mean, 0 to mean, yMax backhead ls 2

set yrange [0: 0.4]
plot hist1 u 1: 2 with boxes t sprintf('histogram sample size: %d', sampleSize) ls 1, \
hist1 u 1: 3 ls 2 t "triangular dist."
unset yrange

# ------------------------------------------ Right plot

unset label
unset ylabel
stats hist2 u 1
#show variables STATS
intervals = STATS_records

# Import pdf parameters: sampleSize, min, max, mean, stdDev.
load vars2

yMax = 2.0/(max - min)


set label  sprintf('interval size = %.3f', (max - min)*1.0/intervals) at 0.8*max, 0.8*yMax \
 font " ,20" textcolor rgb "0x332222"

set label  sprintf('mean = %.3f', sampleMean) at 1.2*min, 0.8*yMax font " ,20" textcolor rgb "blue" front

#unset arrow
#set arrow from mean, 0 to mean, yMax backhead ls 2

set yrange [0: 0.4]
#set boxwidth (max - min)/intervals
plot hist2 u 1: 2 with boxes t sprintf('histogram sample size: %d', sampleSize) ls 1, \
hist2 u 1: 3 ls 2 t "triangular dist."
unset yrange
