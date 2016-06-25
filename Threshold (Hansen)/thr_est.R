##  thr_est.R
##  
##  written by:
##  
##  Bruce E. Hansen
##  Department of Economics
##  Social Science Building
##  University of Wisconsin
##  Madison, WI 53706-1393
##  behansen@wisc.edu
##  http://www.ssc.wisc.edu/~bhansen/
##  
##  
##  This is a R procedure.  It computes estimates and confidence
##  intervals for threshold models.  The procedure takes the form
##  
##    qhat <- thr_est(dat,names,yi,xi,qi,h)
##    
##  The inputs are:
##    dat     = data matrix (nxk)
##    names   = variable names (kx1), corresponding to dat matrix
##    yi      = index of dependent (y) variable, e.g.: yi <- 1
##    xi      = indexes of independent (x) variables, e.g.: xi <- c(2,3)
##    qi      = index of threshold (q) variable, e.g.: qi <- 4;
##    h       = heteroskedasticity indicator
##              Set h=0 to impose homoskedasticity assumption
##              Set h=1 to use White-correction for heteroskedasticity
##  
##  Outputs:
##    qhat    = LS estimate of threshold
##  
##  The remaining outputs are printed to the screen.
##
##  Notes:
##    (1)  Do not include a constant in the independent variables;
##         the program automatically adds an intercept to the regression.
##  
##    (2)  There are four other control parameters, governing the choice
##         of confidence level, the nonparametric method used to compute
##         the nuisance parameter in the event of heteroskedastic, and
##         whether to print the graph of the likelihood.  These controls
##         are listed at the beginning of the procedure code.
##  
##   
##  Example:
##  If the nxk matrix "dat" contains the dependent variable in the first
##  column, the independent variables in the second through tenth columns,
##  and the threshold variable in the fifth.  If the error is homoskedastic:
##  
##      xi <- c(2,3,4,5,6,7,8,9,10)
##      qhat <- thr_est(dat,names,1,xi,5,0)
##  
##  while if the error is (possibly) heteroskedatic,
##  replace the second line with
##
##      qhat <- thr_est(dat,names,1,xi,5,1)
##
############################################################################

thr_est <- function(dat,names,yi,xi,qi,h){

# Control Parameters, can be modified if desired  #

conf1 <- .95  # Confidence Level for Confidence Regions  
conf2 <- .8   # Confidence Level for first step of two-step
              # Confidence Regions for regression parameters 
nonpar <- 2   # Indicator for non-parametric method used to
              # estimate nuisance scale in the presence of
              # heteroskedasticity (only relevant if h=1).
              # Set nonpar=1 to estimate regressions using
              # a quadratic.
              # Set nonpar=2 to estimate regressions using
              # an Epanechnikov kernel with automatic bandwidth. 
graph <- 1    # Set _graph=1 for the program to produce the graph
              # of the concentrated likelihood in gamma.
              # Set _graph=0 to not view the graph.     


if ((h != 0)*(h != 1)){
    cat (" You have entered h = ", h, "\n", 
         "This number must be either 0 (homoskedastic case) or 1 (heteoskedastic)", "\n", 
         "The program will either crash or produce invalid results", "\n") 
}
if ((nonpar != 1)*(nonpar != 2)*(h==1)){
    cat(" You have entered nonpar = ", nonpar, "\n",
        "This number should be either 1 (quadratic regression)", "\n",
        "or 2 (kernel regression)", "\n",
        "The program will employ the quadratic regression method", "\n", "\n")
}

n <- nrow(dat)
q <- dat[,qi]
qs <- order(q)
q <- q[qs]
y <- as.matrix(dat[qs,yi])
x <- cbind(matrix(c(1),n,1),dat[qs,xi])
k <- ncol(x)
yname <- names[yi]
qname <- names[qi]
xname <- rbind("Constant",as.matrix(names[xi]))

mi <- solve(t(x)%*%x)
beta <- mi%*%(t(x)%*%y)
e <- y-x%*%beta
ee <- t(e)%*%e
sig <- ee/(n-k)
xe <- x*(e%*%matrix(c(1),1,k))
if (h==0) {se <- sqrt(diag(mi)*sig)
}else{ se <- sqrt(diag(mi%*%t(xe)%*%xe%*%mi))}
vy <- sum((y - mean(y))^2)
r_2 <- 1-ee/vy

qs <- unique(q)
qn <- length(qs)
sn <- matrix(c(0),qn,1)  

irb <- matrix(c(0),n,1)
mm <- matrix(c(0),k,k)
sume <- matrix(c(0),k,1)
ci <- 0

r <- 1 
while (r<=qn){
  irf <- (q <= qs[r])
  ir <- irf - irb
  irb <- irf
  ci <- ci + sum(ir)
  xir <- as.matrix(x[ir%*%matrix(c(1),1,k)>0])
  xir <- matrix(xir,nrow=nrow(xir)/k,ncol=k)
  mm <- mm + t(xir)%*%xir
  xeir <- as.matrix(xe[ir%*%matrix(c(1),1,k)>0])
  xeir <- matrix(xeir,nrow=nrow(xeir)/k,ncol=k)
  sume <- sume + colSums(xeir)
  mmi <- mm - mm%*%mi%*%mm
  if ((ci > k+1)*(ci < (n-k-1))){
      sn[r] <- ee - t(sume)%*%solve(mmi)%*%sume
  }else{ sn[r] <- ee}
  r <- r+1
}

rmin <- which.min(sn)
smin <- sn[rmin]
qhat <- qs[rmin]
sighat <- smin/n

i1 <- (q <= qhat)
i2 <- (1-i1)>0
x1 <- as.matrix(x[i1%*%matrix(c(1),1,k)>0])
x1 <- matrix(x1,nrow=nrow(x1)/k,ncol=k)
y1 <- as.matrix(y[i1])
x2 <- as.matrix(x[i2%*%matrix(c(1),1,k)>0])
x2 <- matrix(x2,nrow=nrow(x2)/k,ncol=k)
y2 <- as.matrix(y[i2])
mi1 <- solve(t(x1)%*%x1)
mi2 <- solve(t(x2)%*%x2)
beta1 <- mi1%*%(t(x1)%*%y1)
beta2 <- mi2%*%(t(x2)%*%y2)
e1 <- y1 - x1%*%beta1
e2 <- y2 - x2%*%beta2
ej <- rbind(e1,e2)
n1 <- nrow(y1)
n2 <- nrow(y2)
ee1 <- t(e1)%*%e1
ee2 <- t(e2)%*%e2
sig1 <- ee1/(n1-k)
sig2 <- ee2/(n2-k)
sig_jt <- (ee1+ee2)/(n-k*2)
if (h==0){
    se1 <- sqrt(diag(mi1)*sig_jt)
    se2 <- sqrt(diag(mi2)*sig_jt)
}else{
    xe1 <- x1*(e1%*%matrix(c(1),1,k))
    xe2 <- x2*(e2%*%matrix(c(1),1,k))
    se1 <- sqrt(diag(mi1%*%t(xe1)%*%xe1%*%mi1))
    se2 <- sqrt(diag(mi2%*%t(xe2)%*%xe2%*%mi2))
}
vy1 <- sum((y1 - mean(y1))^2)
vy2 <- sum((y2 - mean(y2))^2)
r2_1 <- 1 - ee1/vy1
r2_2 <- 1 - ee2/vy2
r2_joint <- 1 - (ee1+ee2)/vy

if (h==0) lr <- (sn-smin)/sighat
if (h==1){
    r1 <- (x%*%(beta1-beta2))^2
    r2 <- r1*(ej^2)
    qx <- cbind(q^0,q^1,q^2)
    qh <- cbind(qhat^0,qhat^1,qhat^2) 
    m1 <- qr.solve(qx,r1)
    m2 <- qr.solve(qx,r2)
    g1 <- qh%*%m1
    g2 <- qh%*%m2
    if (nonpar==2){
        sigq <- sqrt(mean((q-mean(q))^2))
        hband <- 2.344*sigq/(n^(.2))
        u <- (qhat-q)/hband
        u2 <- u^2
        f <- mean((1-u2)*(u2<=1))*(.75/hband)
        df <- -mean(-u*(u2<=1))*(1.5/(hband^2))
        eps <- r1 - qx%*%m1
        sige <- (t(eps)%*%eps)/(n-3)
        hband <- sige/(4*f*((m1[3]+(m1[2]+2*m1[3]*qhat)*df/f)^2))
        u2 <- ((qhat-q)/hband)^2
        kh <- ((1-u2)*.75/hband)*(u2<=1)
        g1 <- mean(kh*r1)
        g2 <- mean(kh*r2)
    }
    eta2 <- g2/g1
    lr <- (sn-smin)/eta2
}
c1 <- -2*log(1-sqrt(conf1))
c2 <- -2*log(1-sqrt(conf2))
lr1 <- (lr >= c1)
lr2 <- (lr >= c2)
if (max(lr1)==1){
    qhat1 <- qs[which.min(lr1)]
    qhat2 <- qs[qn+1-which.min(rev(lr1))]
}else{
    qhat1 <- qs[1]
    qhat2 <- qs[qn]
}
z <- which.max((pnorm(seq(.01,3,by=.01))*2-1) >= conf1)/100;
beta1l <- beta1 - se1*z
beta1u <- beta1 + se1*z
beta2l <- beta2 - se2*z
beta2u <- beta2 + se2*z
r <- 1 
while (r<=qn){
  if (lr2[r]==0){
      i1 <- (q <= qs[r])
      x1 <- as.matrix(x[i1%*%matrix(c(1),1,k)>0])
      x1 <- matrix(x1,nrow=nrow(x1)/k,ncol=k)
      y1 <- y[i1]
      if (qr(t(x1)%*%x1)$rank==ncol(t(x1)%*%x1)){
          mi1 <- solve(t(x1)%*%x1)
          b1 <- mi1%*%(t(x1)%*%y1)
          e1 <- y1 - x1%*%b1
          if (h==0){
              ser1 <- as.matrix(sqrt(diag(mi1)*(t(e1)%*%e1)/(nrow(y1)-k)))
          }else{
              xe1 <- x1*(e1%*%matrix(c(1),1,k))
              ser1 <- as.matrix(sqrt(diag(mi1%*%t(xe1)%*%xe1%*%mi1)))
          }
          beta1l <- apply((rbind(t(beta1l),t(b1 - ser1*z))),2,min)
          beta1u <- apply((rbind(t(beta1u),t(b1 + ser1*z))),2,max)
      }
      i2 <- (1-i1)>0
      x2 <- as.matrix(x[i2%*%matrix(c(1),1,k)>0])
      x2 <- matrix(x2,nrow=nrow(x2)/k,ncol=k)
      y2 <- y[i2]          
      if (qr(t(x2)%*%x2)$rank==ncol(t(x2)%*%x2)){
          mi2 <- solve(t(x2)%*%x2)
          b2 <- mi2%*%(t(x2)%*%y2)
          e2 <- y2 - x2%*%b2
          if (h==0){
              ser2 <- as.matrix(sqrt(diag(mi2)*(t(e2)%*%e2)/(nrow(y2)-k)))
          }else{
              xe2 <- x2*(e2%*%matrix(c(1),1,k))
              ser2 <- as.matrix(sqrt(diag(mi2%*%t(xe2)%*%xe2%*%mi2)))
          }
          beta2l <- apply((rbind(t(beta2l),t(b2 - ser2*z))),2,min)
          beta2u <- apply((rbind(t(beta2u),t(b2 + ser2*z))),2,max)
      }
  }
  r <- r+1
}

het_test <- function(e,x){
          e2 <- e^2
          x2 <- x^2
          v <- e2 - x2%*%qr.solve(x2,e2)
          e2 <- e2 - colMeans(e2)
          te <- nrow(e)%*%(1-(t(v)%*%v)/(t(e2)%*%e2))
          out <- 1-pchisq(te,ncol(x))
          out
          }

cat("Global OLS Estimation, Without Threshold", "\n")
cat("\n")
cat("Dependent Variable:     ", yname, "\n")
if (h==1) cat("Heteroskedasticity Correction Used", "\n")
if (h==0) cat("OLS Standard Errors Reported", "\n")
cat("\n")
cat("Variable ", "    ", "Estimate  ", "    ", "St Error", "\n")
cat("----------------------------------------", "\n")
tbeta <- format(beta, nsmall=4)
tse <- format(se, nsmall=4) 
for (j in 1:k){cat(xname[j], "    ", tbeta[j], "    ", tse[j], "\n")}
cat("\n")
cat("Observations:                      ", n, "\n")
cat("Degrees of Freedom:                ", (n-k), "\n")
cat("Sum of Squared Errors:             ", ee, "\n")
cat("Residual Variance:                 ", sig, "\n")
cat("R-squared:                         ", r_2, "\n")
cat("Heteroskedasticity Test (P-Value): ", het_test(e,x), "\n")
cat("\n")    
cat("\n")
cat("****************************************************", "\n")
cat("\n")    
cat("\n")
cat("Threshold Estimation", "\n")
cat("\n")
cat("Threshold Variable:                ", qname, "\n")
cat("Threshold Estimate:                ", qhat, "\n")
tqhat1 <- format(qhat1, nsmall=4)
tqhat2 <- format(qhat2, nsmall=4) 
tit <- paste(c("["),tqhat1,", ",tqhat2,c("]"),sep="")
cat(conf1, "Confidence Interval:          ", tit, "\n")
cat("Sum of Squared Errors:             ", (ee1+ee2), "\n")
cat("Residual Variance:                 ", sig_jt, "\n")
cat("Joint R-squared:                   ", r2_joint, "\n")
cat("Heteroskedasticity Test (P-Value): ", het_test(ej,x), "\n")
cat("\n")    
cat("\n")
cat("****************************************************", "\n")
cat("\n")    
cat("\n")
tit <- paste(qname,"<=",format(qhat,nsmall=6),sep="")
cat("Regime 1:", tit, "\n")
cat("\n")
cat("Parameter Estimates", "\n")
cat("Variable ", "    ", "Estimate  ", "    ", "St Error", "\n")
cat("----------------------------------------", "\n")
tbeta1 <- format(beta1, nsmall=4)
tse1 <- format(se1, nsmall=4) 
for (j in 1:k){cat(xname[j], "    ", tbeta1[j], "    ", tse1[j], "\n")}
cat("\n")
cat(conf1, "Confidence Regions for Parameters", "\n")
cat("Variable ", "    ", "Low         ", "    ", "High", "\n")
cat("----------------------------------------", "\n")
tbeta1l <- format(beta1l, nsmall=4)
tbeta1u <- format(beta1u, nsmall=4) 
for (j in 1:k){cat(xname[j], "    ", tbeta1l[j], "    ", tbeta1u[j], "\n")}
cat("\n")
cat("Observations:                      ", n1, "\n")
cat("Degrees of Freedom:                ", (n1-k), "\n")
cat("Sum of Squared Errors:             ", ee1, "\n")
cat("Residual Variance:                 ", sig1, "\n")
cat("R-squared:                         ", r2_1, "\n")
cat("\n")    
cat("\n")
cat("****************************************************", "\n")
cat("\n")    
cat("\n")
tit <- paste(qname,">",format(qhat,nsmall=6),sep="")
cat("Regime 2:", tit, "\n")
cat("\n")
cat("Parameter Estimates", "\n")
cat("Variable ", "    ", "Estimate  ", "    ", "St Error", "\n")
cat("----------------------------------------", "\n")
tbeta2 <- format(beta2, nsmall=4)
tse2 <- format(se2, nsmall=4) 
for (j in 1:k){cat(xname[j], "    ", tbeta2[j], "    ", tse2[j], "\n")}
cat("\n")
cat(conf1, "Confidence Regions for Parameters", "\n")
cat("Variable ", "    ", "Low         ", "    ", "High", "\n")
cat("----------------------------------------", "\n")
tbeta2l <- format(beta2l, nsmall=4)
tbeta2u <- format(beta2u, nsmall=4) 
for (j in 1:k){cat(xname[j], "    ", tbeta2l[j], "    ", tbeta2u[j], "\n")}
cat("\n")
cat("Observations:                      ", n2, "\n")
cat("Degrees of Freedom:                ", (n2-k), "\n")
cat("Sum of Squared Errors:             ", ee2, "\n")
cat("Residual Variance:                 ", sig2, "\n")
cat("R-squared:                         ", r2_2, "\n")

if (graph==1){
    x11()
    xxlim <- range(qs)
    yylim <- range(rbind(lr,c1))
    clr <- matrix(c(1),qn,1)*c1
    plot(qs,lr,lty=1,col=1,xlim=xxlim,ylim=yylim,type="l",ann=0)
    lines(qs,clr,lty=2,col=2)     
    xxlab <- paste(c("Threshold Variable: "),qname,sep="")
    title(main="Confidence Interval Construction for Threshold",
          xlab=xxlab,ylab="Likelihood Ratio Sequence in gamma")
    tit <- paste(conf1*100,c("% Critical"),sep="")
    legend("bottomright",c("LRn(gamma)",tit),lty=c(1,2),col=c(1,2))
}
qhat
}


