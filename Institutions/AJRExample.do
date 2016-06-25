# delimit ;
set more off;

clear all ;
set maxvar 20000 ;
set matsize 11000 ;

capture log close ;
log using JEPInstitutions.txt , replace text ;

insheet using acemoglu_col_notext.txt ;

gen lnmort = log(mort) ;
gen lat2 = latitude^2 ;
gen lat3 = latitude^3 ;
gen lat_c08 = (latitude - .08)*(latitude - .08 > 0) ;
gen lat2_c08 = ((latitude - .08)*(latitude - .08 > 0))^2 ;
gen lat3_c08 = ((latitude - .08)*(latitude - .08 > 0))^3 ;
gen lat_c16 = (latitude - .16)*(latitude - .16 > 0) ;
gen lat2_c16 = ((latitude - .16)*(latitude - .16 > 0))^2 ;
gen lat3_c16 = ((latitude - .16)*(latitude - .16 > 0))^3 ;
gen lat_c24 = (latitude - .24)*(latitude - .24 > 0) ;
gen lat2_c24 = ((latitude - .24)*(latitude - .24 > 0))^2 ;
gen lat3_c24 = ((latitude - .24)*(latitude - .24 > 0))^3 ;

local controls = "africa asia namer samer latitude lat2 lat3 
	lat_c08 lat2_c08 lat3_c08 lat_c16 lat2_c16 lat3_c16 
	lat_c24 lat2_c24 lat3_c24" ;

* Baseline with just latitude ;
ivreg gdp (exprop = lnmort) latitude , robust first ;
	
* Include all controls ;
* ivreg gdp (exprop = lnmort) `controls' , robust first;
* Note:  The results from the all controls IV as above differ from MATLAB... ;
* Stata is probably doing some regularization internally since you get the ;
* same result if you do the IV "by hand" in Stata as you do in MATLAB.  This ;
* discrepancy may be worth further exploration. We'll go with MATLAB ;
* results for now. ;
quietly reg gdp `controls' ;
predict rgdp , resid ;
quietly reg exprop `controls' ;
predict rexp , resid ;
quietly reg lnmort `controls' ;
predict rmor , resid ;
ivreg rgdp (rexp = rmor) , robust first noconstant;
* Need to scale standard error by sqrt(63/(64-18)) to account for partialing ;
* out the controls to get things to line up with usual degrees of freedom ;
* correction done in Stata (and in MATLAB) for robust standard errors. ;
scalar se_all = .684*sqrt(63/(64-18)) ;
scalar list se_all ;

* Variable selection ;
* Outcome reduced form ;
lassoShooting gdp `controls' , lasiter(100) verbose(0) fdisplay(0) ;
local gdpSel `r(selected)' ;
di "`gdpSel'" ;

* Endogenous variable reduced form ;
lassoShooting exprop `controls' , lasiter(100) verbose(0) fdisplay(0) ;
local expSel `r(selected)' ;
di "`expSel'" ;

* Instrument reduced form ;
lassoShooting lnmort `controls' , lasiter(100) verbose(0) fdisplay(0) ;
local morSel `r(selected)' ;
di "`morSel'" ;

* Get union of selected instruments ;
local xTS : list gdpSel | expSel ;
local xTS : list xTS | morSel ; 

* Run final IV regression including selected controls ;
ivreg gdp (exprop = lnmort) `xTS' , robust first ;

log close ;


