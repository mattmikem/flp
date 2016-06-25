* This file illustrates the use of the Stata threshold regression commands 
* It replicates some of the empirical work from B. Hansen (2000, Econometrica)

clear all
clear mata
clear matrix
set more off
use forthresh

keep if year > 1970

foreach v of varlist d_incp cc_2 gwg cc_gwg {
drop if `v' == .
}

tab year, gen(y)

keep if year == 2000

thresholdtest d_incp cc_2 gwg cc_gwg, q(gwg)
graph rename test1

thresholdreg d_incp cc_2 gwg cc_gwg, q(gwg)
graph rename est1

