Enclosed are Stata files to implement threshold regression and testing.
The primary references are
Hansen, Bruce E. (1996) "Inference when a nuisance parameter is not identified under the null hypothesis," Econometrica.
Hansen, Bruce E. (2000) "Sample splitting and threshold estimation," Econometrica.


There are 5 files in this directory:
thresholdreg.ado
thresholdtest.ado
Hansen2000.do
DurlaufJohnson.dta
readme.txt

Put the files thresholdreg.ado and thresholdtest.ado in your STATA working directory.


***************************************************************************

 (1) threshololdreg.ado

 Stata command "thresholdreg" computes estimates and confidence intervals for threshold models. 

 In Stata, You run it by typing:

 "thresholdreg y x, q(z) h(ind)"

example: thresholdreg y x1 x2, q(z) h(1)


  The inputs are:
  y = dependent variable
  x = independent variables
  z = threshold variable
  ind = heteroskedasticity indicator
      Set ind=0 to impose homoskedasticity assumption
      Set ind=1 to use White-correction for heteroskedasticity (default if option omitted)

The program estimates a threshold regression, prints the results to the screen.
The program also plots a graph of the likelihood ratio process in the threshold, useful for threshold confidence interval construction.


*******************************************************************************

 (2) thresholdtest.ado

 Stata command "thresholdtest" computes a test for a threshold in linear 
 regression allowing for heteroskedasticity.  

 In Stata, you run it by typing

 "thresholdtest y x, q(z) trim_per(p) rep(R)"


  The inputs are:
  y = dependent variable
  x = independent variables
  z = threshold variable
  p = percentage of sample to trim from ends, e.g. p = .15 (default value if option omitted)
  R = number of bootstrap, e.g., R=5000 (default value if option omitted)


**************************************************************************

 (3) Hansen2000.do
To illustrate we have provided a do file "main.do" which replicates the work reported in 
Hansen, Bruce E. (2000) "Sample splitting and threshold estimation," Econometrica.

To run, type "do Hansen2000"

**************************************************************************

 (4) DurlaufJohnson.dta
 This is a data file.
 It is the data used by Hansen (2000) taken from Durlauf and Johnson (1995)


