* This file illustrates the use of the Stata threshold regression commands 
* It replicates some of the empirical work from B. Hansen (2000, Econometrica)

clear all
clear mata
clear matrix
set more off
use DurlaufJohnson

******** Test for Thresholds *********

* Test for Threshold in initial GDP

thresholdtest GDP_Growth log_GDP InvGDP Pop_Growth school, q(GDP) trim_per(0.15) rep(5000)
graph rename test1

* Test for Threshold in literacy rate

thresholdtest GDP_Growth log_GDP InvGDP Pop_Growth school, q(literacy) trim_per(0.15) rep(5000)
graph rename test2

******** Threshold Estimation Based on initial GDP *********

thresholdreg GDP_Growth log_GDP InvGDP Pop_Growth school, q(GDP) h(1)
graph rename estimate1

******** Second Sample Split *********

drop if GDP<=863

* Test for Threshold in initial GDP

thresholdtest GDP_Growth log_GDP InvGDP Pop_Growth school, q(GDP) trim_per(0.15) rep(5000)
graph rename test3

* Test for Threshold in literacy rate

thresholdtest GDP_Growth log_GDP InvGDP Pop_Growth school, q(literacy) trim_per(0.15) rep(5000)
graph rename test4

******** Threshold Estimation (second split) Based on literacy rate *********

thresholdreg GDP_Growth log_GDP InvGDP Pop_Growth school, q(literacy) h(1)
graph rename estimate2
