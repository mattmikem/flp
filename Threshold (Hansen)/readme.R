readme.R

These files are distributed to replicate the empirical
work reported in

"Sample Splitting and Threshold Estimation"

written by:

Bruce E. Hansen
Department of Economics
Social Science Building
University of Wisconsin
Madison, WI 53706-1393
behansen@wisc.edu
http://www.ssc.wisc.edu/~bhansen/


The files are

thr_est.R
thr_test.R
thr_het.R
dur_john.dat
dj_readme.R
growth.R


(1)  thr_est.R
This is a R procedure.  It computes estimates and confidence
intervals for threshold models.  The procedure takes the form

qhat <- thr_est(dat,names,yi,xi,qi,h)


(2)  thr_test.R
This is a R procedure.
It computes a test for a threshold in linear regression
under homoskedasticity.  The procedure takes the form

output <- thr_test(dat,yi,xi,qi,trim_per,rep)
output$f_test
output$p_value

(3)  thr_het.R
This is a R procedure.
It computes a test for a threshold in linear regression
under heteroskedasticity.  The procedure takes the form

output <- thr_het(dat,yi,xi,qi,trim_per,rep)
output$f_test
output$p_value


(4)  dur_john.dat
This is a data file, with 121 observations and 11 variables.
It is the data distributed by Durlauf and Johnson (JAE, 1995) to
document their empirical work.  See the following file.


(5)  dj_readme.R
This is the dj_readme.R file distributed by Durlauf-Johnson to document
the data in the previous file.


(6)  growth.R
This is a R program.
It loads the data dur_john.dat, the procedures thr_est.R and
thr_het.R, and estimates the sample split models.


