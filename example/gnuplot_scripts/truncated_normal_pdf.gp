# Returns the truncated normal probability distribution
phi(x) = 0.5*(1 + erf(x/sqrt(2)))
truncatedNormalPdf(x,a,b,mu,sigma) = (x > a &&  x < b) ?  \
exp(-0.5*((x-mu)/sigma)**2) / ((sigma*sqrt(pi)*sqrt(2)) * ( phi( (b-mu)/sigma ) - phi((a - mu )/sigma) )) : 0