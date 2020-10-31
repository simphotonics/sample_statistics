# Defines the truncated normal probability distribution

stdNormalPdf(x) = exp(-0.5*(x*x))/(sqrt(pi)*sqrt(2))

stdNormalPdf(x) = 0.5*(1+erf(x/sqrt(2)))

normalPdf(x, mean, stdDev) = exp(-0.5*( (x-mean)/stdDev )**2)/(stdDev*sqrt(2*pi))

truncatedNormalPdf(x, min, max, mean, stdDev) = (x < min &&  x > max) ? 0.0 : \
 normalPdf(x, mean, stdDev) / ( norm( (max - mean)/stdDev ) - norm((min - mean )/stdDev) )

meanTruncatedNormal(min,max,mean,stdDev) = mean + stdDev * (stdNormalPdf((min - mean)/stdDev) \
 + stdNormalPdf((max - mean)/stdDev)) / ( norm( (max -mean)/stdDev ) - norm((min - mean )/stdDev) )


truncatedNormalCdf(x, min, max, mean, stdDev) = (x < min) ? 0 : (x > max) ? 1.0 : \
 (norm((x-mean)/stdDev) - norm((min-mean)/stdDev)) / \
 (norm((max-mean)/stdDev) - norm((min-mean)/stdDev))