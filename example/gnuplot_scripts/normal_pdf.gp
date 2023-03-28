# Defines the truncated normal probability distribution

stdNormalPdf(x) = exp(-0.5*(x*x))/(sqrt(pi)*sqrt(2))

stdNormalCdf(x) = 0.5*(1+erf(x/sqrt(2)))

normalPdf(x, mean, stdDev) = exp(-0.5*( (x-mean)/stdDev )**2)/(stdDev*sqrt(2*pi))

truncatedNormalPdf(x, min, max, mean, stdDev) = (x < min || x > max) ? 0.0 : \
 normalPdf(x, mean, stdDev) / ( norm( (max - mean)/stdDev ) - norm((min - mean )/stdDev) )

meanTruncatedNormal(min,max,mean,stdDev) = mean + stdDev * (stdNormalPdf((min - mean)/stdDev) \
 - stdNormalPdf((max - mean)/stdDev)) / ( norm( (max -mean)/stdDev ) - norm((min - mean )/stdDev) + 1e-20 )


 stdDevTruncatedNormal(min,max,mean,stdDev) = stdDev*         \
  sqrt(1 +                                                    \
    ( (min-mean)/stdDev*stdNormalPdf((min-mean)/stdDev)       \
    - (max-mean)/stdDev*stdNormalPdf((max-mean)/stdDev)       \
    )/( norm((max-mean)/stdDev) - norm((min-mean)/stdDev)  + 1e-20) - \
    (                                                         \
      ( stdNormalPdf((min-mean)/stdDev)                       \
      - stdNormalPdf((max-mean)/stdDev)                       \
      )/                                                      \
      ( norm((max-mean)/stdDev) - norm((min-mean)/stdDev) + 1e-20 )   \
    )**2                                                      \
   )

truncatedNormalCdf(x, min, max, mean, stdDev) = (x < min) ? 0 : (x > max) ? 1.0 : \
 (norm((x-mean)/stdDev) - norm((min-mean)/stdDev)) / \
 (norm((max-mean)/stdDev) - norm((min-mean)/stdDev))



 energy(mean, stdDev, min, max, meanTr, stdDevTr) =           \
  log(stdDevTr**2 - stdDev**2*(                               \
  1 +                                                         \
    ( (min-mean)/stdDev*stdNormalPdf((min-mean)/stdDev)       \
    - (max-mean)/stdDev*stdNormalPdf((max-mean)/stdDev)       \
    )/( norm((max-mean)/stdDev) - norm((min-mean)/stdDev)  + 1e-30) - \
    (                                                         \
      ( stdNormalPdf((min-mean)/stdDev)                       \
      - stdNormalPdf((max-mean)/stdDev)                       \
      )/                                                      \
      ( norm((max-mean)/stdDev) - norm((min-mean)/stdDev) + 1e-30 )   \
    )**2                                                      \
   )**2 + (meanTr**2 -                                        \
   (mean + stdDev * (stdNormalPdf((min - mean)/stdDev)        \
 - stdNormalPdf((max - mean)/stdDev)) / ( norm( (max -mean)/stdDev ) \
 - norm((min - mean )/stdDev) + 1e-20 ))**2 )**2 + 1e-40)


z(x,y) = (x ==y) ? 1 : (stdNormalPdf(x) - stdNormalPdf(y))/(stdNormalCdf(y) - stdNormalCdf(x))