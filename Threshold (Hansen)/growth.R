##  growth.R
## 
##  Performs empirical work reported in
## 
##  "Sample Splitting and Threshold Estimation"
## 
##  Written by
## 
##  Bruce E. Hansen
##  Department of Economics
##  Social Science Building
##  University of Wisconsin
##  Madison, WI 53706-1393
##  behansen@wisc.edu
##  http://www.ssc.wisc.edu/~bhansen/

# Load procedures and data #                  

source("Z:\\thr_est.R")
source("Z:\\thr_het.R")
data <- read.table("z:\\dur_john.dat")

# Exclude missing variables and oil states #

k <- ncol(data)
indx <- as.matrix(1-(data[,5]== -999))%*%matrix(c(1),1,k)
data <- as.matrix(data[indx>0])
data <- matrix(data,nrow=nrow(data)/k,ncol=k)
indx <- as.matrix(1-(data[,6]== -999))%*%matrix(c(1),1,k)
data <- as.matrix(data[indx>0])
data <- matrix(data,nrow=nrow(data)/k,ncol=k)
indx <- as.matrix(1-(data[,10]== -999))%*%matrix(c(1),1,k)
data <- as.matrix(data[indx>0])
data <- matrix(data,nrow=nrow(data)/k,ncol=k)
indx <- as.matrix(1-(data[,11]== -999))%*%matrix(c(1),1,k)
data <- as.matrix(data[indx>0])
data <- matrix(data,nrow=nrow(data)/k,ncol=k)
indx <- as.matrix(data[,2]== 1)%*%matrix(c(1),1,k)
data <- as.matrix(data[indx>0])
data <- matrix(data,nrow=nrow(data)/k,ncol=k)

# Make data transformations #

diff <- log(data[,6])-log(data[,5])
q <- data[,5]
gdp60 <- log(q)
iony <- log(data[,9]/100)
pgro <- log(data[,8]/100+.05)
sch <- log((data[,10])/100)
lit <- data[,11]
dat <- cbind(diff,gdp60,iony,pgro,sch,q,lit)

# Program switches #                         

rep <- 1000
h   <- 1
na  <- rbind("GNP_Gwth","GDP_1960","Inv/GDP","Pop_Gwth","School","GDP_1960","Literacy")
dum <- rbind(2,3,4,5)

for (j in 1:1){
cat ("Testing for a First Sample Split, Using Output", "\n")
cat ("\n")
out <- thr_het(dat,1,dum,6,0.15,rep);
cat ("\n")
cat ("\n")
cat ("Testing for a First Sample Split, Using Literacy Rate", "\n")
cat ("\n")
out <- thr_het(dat,1,dum,7,0.15,rep);

# Estimate First Sample Split, Using Output as Threshold #

qhat1 <- thr_est(dat,na,1,dum,6,h)


# Second Level #

k <- ncol(dat)
indx <- as.matrix((q > qhat1)%*%matrix(c(1),1,k))
dati <- as.matrix(dat[indx>0])
dati <- matrix(dati,nrow=nrow(dati)/k,ncol=k)
cat ("Sub-Sample, Incomes over 863", "\n")
cat ("Testing for a Second Sample Split, Using Output", "\n")
cat ("\n")
out <- thr_het(dati,1,dum,6,0.15,rep)
cat ("\n")
cat ("\n")
cat ("Testing for a Second Sample Split, Using Literacy Rate", "\n")
cat ("\n")
out <- thr_het(dati,1,dum,7,0.15,rep)
cat ("\n")
cat ("\n")

# Estimate Second Sample Split, Using Literacy Rate as Threshold #

qhat2 <- thr_est(dati,na,1,dum,7,h)


# Third Level #

i1 <- ((lit <= qhat2)%*%matrix(c(1),1,k))*indx
i2 <- ((lit >  qhat2)%*%matrix(c(1),1,k))*indx
dat1 <- as.matrix(dat[i1>0])
dat1 <- matrix(dat1,nrow=nrow(dat1)/k,ncol=k)
dat2 <- as.matrix(dat[i2>0])
dat2 <- matrix(dat2,nrow=nrow(dat2)/k,ncol=k)
cat ("Sub-Sample, Incomes over 863, Literacy Under 45", "\n")
cat ("Testing for a Third Sample Split, Using Output", "\n")
cat ("\n")
out <- thr_het(dat1,1,dum,6,0.15,rep)
cat ("\n")
cat ("\n")
cat ("Testing for a Third Sample Split, Using Literacy Rate", "\n")
cat ("\n")
out <- thr_het(dat1,1,dum,7,0.15,rep)
cat ("\n")
cat ("\n")
cat ("Sub-Sample, Incomes over 863, Literacy Over 45", "\n")
cat ("Testing for a Third Sample Split, Using Output", "\n")
cat ("\n")
out <- thr_het(dat2,1,dum,6,0.15,rep)
cat ("\n")
cat ("\n")
cat ("Testing for a Third Sample Split, Using Literacy Rate", "\n")
cat ("\n")
out <- thr_het(dat2,1,dum,7,0.15,rep)
cat ("\n")
cat ("\n")

}
save.image(file = "growthout.RData")


