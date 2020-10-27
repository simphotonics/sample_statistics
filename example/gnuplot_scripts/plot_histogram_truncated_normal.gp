reset

# Apply graph settings
load 'histogram_settings.gp'

# Import pdf
load 'truncated_normal_pdf.gp'

file = '../plots/truncated_normal.hist'

stats file u 1
show variables STATS

# Fit pdf parameters
 n = STATS_records
 min = 1.0
 max = 9.0

 # Sample mean
 mean = 10.0;
 stdDev = 5.0

 # set fit errorscaling
 fit truncatedNormalPdf(x,min,max,mean,stdDev) file u 1:2 via mean, stdDev

set label

set label  sprintf('interval size = %.4f', (max - min)/n) at 1.5*min, 0.95*truncatedNormalPdf(mean, min, max, mean, stdDev) \
 font " ,16" textcolor rgb "0x332222"

set label  sprintf('mean = %.4f', mean) at 0.8*mean, 1.12*truncatedNormalPdf(mean, min, max, mean, stdDev) \
 font " ,16" textcolor rgb "blue"

set arrow from mean, 0 to mean, truncatedNormalPdf(mean, min, max, mean, stdDev) backhead ls 2

plot file u 1: 2 with boxes t 'histogram' ls 1, \
file u 1: (truncatedNormalPdf($1, min, max, mean, stdDev)) ls 2 t "truncated norm. prob. dist."
