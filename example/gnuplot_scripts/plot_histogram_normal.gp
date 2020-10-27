reset

# Apply graph settings.
load 'histogram_settings.gp'

# Import normal probability distribution function.
load 'normal.gp'

# Set histogram data file.
file = '../plots/normal_random_sample.hist'
stats file u 1
show variables STATS

# Fit pdf parameters
n = STATS_records
min = STATS_min
max = STATS_max
# Sample mean
mean = 10.168769294545003
# Sample standard deviation
stdDev = 5.370025848202738

set fit quiet
fit normal(x,mean,stdDev) file u 1:2 via stdDev, mean

set label  sprintf('mean = %.4f', mean) at 0.9*mean, 1.05*normal(mean, mean, stdDev) font " ,16" textcolor rgb "blue"
set label  sprintf('interval size = %.4f', (max - min)/n) at 0.6*max, 0.5*normal(mean, mean, stdDev) font " ,16" textcolor rgb "0x332222"

set arrow from mean, 0 to mean, normal(mean, mean, stdDev) backhead ls 2

plot file u 1: 2 with boxes t 'histogram' ls 1, \
file u 1: (normal($1, mean, stdDev)) ls 2 t "norm. prob. dist."
