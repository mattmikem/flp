# delimit ;
set more off;

clear all ;
set maxvar 20000 ;
set matsize 11000 ;

capture log close ;
log using JEPAbortion.txt , replace text ;

insheet using levitt_ex.dat ;

* Drop DC, Alaska, and Hawaii ;
*drop if statenum == 9 | statenum == 2 | statenum == 12 ;
* Drop DC ;
drop if statenum == 9 ;

* Drop years not used ;
drop if year < 85 | year > 97 ;

* Normalized trend variable ;
gen trend = (year - 85)/12 ;

tsset statenum year ;

* Estimate baseline model in first-differences ;
xi: reg D.lpc_viol D.efaviol D.xx* i.year , cluster(statenum) ;
xi: reg D.lpc_prop D.efaprop D.xx* i.year , cluster(statenum) ;
xi: reg D.lpc_murd D.efamurd D.xx* i.year , cluster(statenum) ;

* Generate variables for LASSO ;
replace xxincome = xxincome/100 ;
replace xxpover = xxpover/100 ;
replace xxafdc15 = xxafdc15/10000 ;
replace xxbeer = xxbeer/100 ;

local tdums = "_Iyear_87 _Iyear_88 _Iyear_89 _Iyear_90 _Iyear_91 _Iyear_92 _Iyear_93 _Iyear_94 _Iyear_95 _Iyear_96 _Iyear_97" ;
local xx = "xxprison xxpolice xxunemp xxincome xxpover xxafdc15 xxgunlaw xxbeer" ;

* Differences ;
local Dxx ;
foreach x of local xx { ;
	gen D`x' = D.`x' ;
	local tempname = "D`x'" ;
	local Dxx : list Dxx | tempname ;
} ;

* Squared Differences
local Dxx2 ;
foreach x of local Dxx { ;
	gen `x'2 = `x'^2 ;
	local tempname = "`x'2" ;
	local Dxx2 : list Dxx2 | tempname ;
} ;

* Difference Interactions
local DxxInt ;
local nxx : word count `Dxx' ;
forvalues ii = 1/`nxx' { ;
	local start = `ii'+1 ;
	forvalues jj = `start'/`nxx' { ;
		local temp1 : word `ii' of `Dxx' ;
		local temp2 : word `jj' of `Dxx' ;
		gen `temp1'X`temp2' = `temp1'*`temp2' ;
		local tempname = "`temp1'X`temp2'" ;
		local DxxInt : list DxxInt | tempname ;
	} ;
} ;		

* Lags ;
local Lxx ;
foreach x of local xx { ;
	gen L`x' = L.`x' ;
	local tempname = "L`x'" ;
	local Lxx : list Lxx | tempname ;
} ;

* Squared Lags
local Lxx2 ;
foreach x of local Lxx { ;
	gen `x'2 = `x'^2 ;
	local tempname = "`x'2" ;
	local Lxx2 : list Lxx2 | tempname ;
} ;

* Means ;
local Mxx ;
foreach x of local xx { ;
	by statenum: egen M`x' = mean(`x') ;
	local tempname = "M`x'" ;
	local Mxx : list Mxx | tempname ;
} ;

* Squared Means ;
local Mxx2 ;
foreach x of local Mxx { ;
	gen `x'2 = `x'^2 ;
	local tempname = "`x'2" ;
	local Mxx2 : list Mxx2 | tempname ;
} ;

* Initial Levels ;
local xx0 ;
foreach x of local xx { ;
	by statenum: gen `x'0 = `x'[1] ;
	local tempname = "`x'0" ;
	local xx0 : list xx0 | tempname ;
} ;

* Squared Initial Levels ;
local xx02 ;
foreach x of local xx0 { ;
	gen `x'2 = `x'^2 ;
	local tempname = "`x'2" ;
	local xx02 : list xx02 | tempname ;
} ;

* Initial Differences ;
local Dxx0 ;
foreach x of local Dxx { ;
	by statenum: gen `x'0 = `x'[2] ;
	local tempname = "`x'0" ;
	local xx0 : list xx0 | tempname ;
} ;

* Squared Initial Differences ;
local Dxx02 ;
foreach x of local Dxx0 { ;
	gen `x'2 = `x'^2 ;
	local tempname = "`x'2" ;
	local Dxx02 : list Dxx02 | tempname ;
} ;

* Interactions with trends ;
local biglist : list Dxx | Dxx2 ;
local biglist : list biglist | DxxInt ;
local biglist : list biglist | Lxx ;
local biglist : list biglist | Lxx2 ;
local biglist : list biglist | Mxx ;
local biglist : list biglist | Mxx2 ;
local biglist : list biglist | xx0 ;
local biglist : list biglist | xx02 ;
local biglist : list biglist | Dxx0 ;
local biglist : list biglist | Dxx02 ;

local IntT ;
local nxx : word count `biglist' ;
foreach x of local biglist { ;
	gen `x'Xt = `x'*trend ;
	gen `x'Xt2 = `x'*(trend^2) ;
	local tempname = "`x'Xt `x'Xt2" ;
	local IntT : list IntT | tempname ;
} ;
	
local shared : list biglist | IntT ;

* Violence specific controls ;
gen Dviol = D.efaviol ;
by statenum: gen viol0 = efaviol[1] ;
by statenum: gen Dviol0 = Dviol[2] ;
gen viol02 = viol0^2 ;
gen Dviol02 = Dviol0^2 ;
gen viol0Xt = viol0*trend ;
gen viol0Xt2 = viol0*(trend^2) ;
gen viol02Xt = viol02*trend ;
gen viol02Xt2 = viol02*(trend^2) ;
gen Dviol0Xt = Dviol0*trend ;
gen Dviol0Xt2 = Dviol0*(trend^2) ;
gen Dviol02Xt = Dviol02*trend ;
gen Dviol02Xt2 = Dviol02*(trend^2) ;

local contviol = "viol0 viol0Xt viol0Xt2 viol02 viol02Xt viol02Xt2 
			Dviol0 Dviol0Xt Dviol0Xt2 Dviol02 Dviol02Xt Dviol02Xt2" ;

local AllViol : list contviol | shared ;
			
* Property specifc controls ;
gen Dprop = D.efaprop ;
by statenum: gen prop0 = efaprop[1] ;
by statenum: gen Dprop0 = Dprop[2] ;
gen prop02 = prop0^2 ;
gen Dprop02 = Dprop0^2 ;
gen prop0Xt = prop0*trend ;
gen prop0Xt2 = prop0*(trend^2) ;
gen prop02Xt = prop02*trend ;
gen prop02Xt2 = prop02*(trend^2) ;
gen Dprop0Xt = Dprop0*trend ;
gen Dprop0Xt2 = Dprop0*(trend^2) ;
gen Dprop02Xt = Dprop02*trend ;
gen Dprop02Xt2 = Dprop02*(trend^2) ;

local contprop = "prop0 prop0Xt prop0Xt2 prop02 prop02Xt prop02Xt2 
			Dprop0 Dprop0Xt Dprop0Xt2 Dprop02 Dprop02Xt Dprop02Xt2" ;
			
local AllProp : list contprop | shared ;

* Murder specific controls ;
gen Dmurd = D.efamurd ;
by statenum: gen murd0 = efamurd[1] ;
by statenum: gen Dmurd0 = Dmurd[2] ;
gen murd02 = murd0^2 ;
gen Dmurd02 = Dmurd0^2 ;
gen murd0Xt = murd0*trend ;
gen murd0Xt2 = murd0*(trend^2) ;
gen murd02Xt = murd02*trend ;
gen murd02Xt2 = murd02*(trend^2) ;
gen Dmurd0Xt = Dmurd0*trend ;
gen Dmurd0Xt2 = Dmurd0*(trend^2) ;
gen Dmurd02Xt = Dmurd02*trend ;
gen Dmurd02Xt2 = Dmurd02*(trend^2) ;

local contmurd = "murd0 murd0Xt murd0Xt2 murd02 murd02Xt murd02Xt2 
			Dmurd0 Dmurd0Xt Dmurd0Xt2 Dmurd02 Dmurd02Xt Dmurd02Xt2" ;
			
local AllMurd : list contmurd | shared ;

* Differenced outcomes ;
gen Dyviol = D.lpc_viol ;
gen Dyprop = D.lpc_prop ;
gen Dymurd = D.lpc_murd ;			
			
drop if trend == 0 ;

* Regression using everything ;
reg Dyviol Dviol `AllViol' `tdums' , cluster(statenum) ;
reg Dyprop Dprop `AllProp' `tdums' , cluster(statenum) ;
reg Dymurd Dmurd `AllMurd' `tdums' , cluster(statenum) ;

* Note that Stata and MATLAB results differ presumably due to how Stata
* implicitly regularizes the inverse involved in OLS ;

* Variable selection ;

* Violence Outcome ;
lassoShooting Dyviol `AllViol' , controls(`tdums') lasiter(100) verbose(0) fdisplay(0) ;
local yvSel `r(selected)' ;
di "`yvSel'" ;

* Violence Abortion ;
lassoShooting Dviol `AllViol' , controls(`tdums') lasiter(100) verbose(0) fdisplay(0) ;
local xvSel `r(selected)' ;
di "`xvSel'" ;

* Get union of selected instruments ;
local vDS : list yvSel | xvSel ;

* Violence equation with selected controls ;
reg Dyviol Dviol `vDS' `tdums' , cluster(statenum) ;


* Property Outcome ;
lassoShooting Dyprop `AllProp' , controls(`tdums') lasiter(100) verbose(0) fdisplay(0) ;
local ypSel `r(selected)' ;
di "`ypSel'" ;

* Property Abortion ;
lassoShooting Dprop `AllProp' , controls(`tdums') lasiter(100) verbose(0) fdisplay(0) ;
local xpSel `r(selected)' ;
di "`xpSel'" ;

* Get union of selected instruments ;
local pDS : list ypSel | xpSel ;

* Property equation with selected controls ;
reg Dyprop Dprop `pDS' `tdums' , cluster(statenum) ;


* Murder Outcome ;
lassoShooting Dymurd `AllMurd' , controls(`tdums') lasiter(100) verbose(0) fdisplay(0) ;
local ymSel `r(selected)' ;
di "`ymSel'" ;

* Murder Abortion ;
lassoShooting Dmurd `AllMurd' , controls(`tdums') lasiter(100) verbose(0) fdisplay(0) ;
local xmSel `r(selected)' ;
di "`xmSel'" ;

* Get union of selected instruments ;
local mDS : list ymSel | xmSel ;

* Property equation with selected controls ;
reg Dymurd Dmurd `mDS' `tdums' , cluster(statenum) ;



log close ;

