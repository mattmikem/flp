********************************************
*GWG and Gentrification Analysis
*Using both standard and lasso gwg estimates
*M. Miller, 16X
********************************************

cd "L:\Research\Resurgence\Working Files"

clear
clear matrix

set more off

global data = "L:\Research\Resurgence\GIS\Working Files\Output\Test"
global work = "L:\Research\Resurgence\Working Files"  
global reg  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\Regulations\BPEAzip1\FiftyYears_Replication1"
global trct = "L:\Research\Resurgence\Working Files\Shapefiles DTA\"
global out  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Draft"

use ipums_gwg_lasso, clear

*keep metarea group
keep metarea group year

duplicates drop

*joinby group using gwg_wide, unmatched(master)
joinby group year using gwg_lasso_long_alts, unmatched(master)

drop _merge

drop if metarea == .

tostring metarea, gen(cbsa)
replace cbsa = "31100" if cbsa == "31080"

gen gwg_late      = gwg
gen se_late       = se
gen sing_pct_late = sing_pct
gen fem_pct_late  = fem_pct    


decode metarea, gen(metarea_str)
gen state = substr(metarea_str, strpos(metarea_str, ",")+2, 2)

save gwg_lasso_forncdb, replace

**NCDB, add on GWG

*use "$work\resurge_12_10.dta", clear
use "$work\resurge_06_16.dta", clear

*tab _merge
drop _merge

keep geo2010 region division cbsa ua_code ua_name distance cc_2 cc_1 central_city incp* rtp* shrmin* nonfam* mf_rat* pt_walk* own_* mbed3_* mbed4pl_* munit5pl_* hu_age30pl_* marshr* 

drop if ua_code == .

reshape clear
reshape i geo2010 cbsa ua_code ua_name distance cc_2 cc_1 central_city
reshape j year
reshape xij incp rtp shrmin nonfam mf_rat marshr pt_walk own_ mbed3_ mbed4pl_ munit5pl_ hu_age30pl_
reshape long

joinby cbsa using msa1990_cbsa, unmatched(master)
drop _merge
joinby metarea year using gwg_lasso_forncdb, unmatched(master)
drop _merge 
drop *_late
joinby cbsa year using  gwg_lasso_forncdb, unmatched(master)
drop _merge
replace gwg      = gwg_late      if year > 1990
replace se       = se_late       if year > 1990
replace sing_pct = sing_pct_late if year > 1990
replace fem_pct  = fem_pct_late  if year > 1990

joinby ua_code cbsa using top_cbsa, unmatched(master)

drop if _merge == 1
drop _merge

destring geo2010, replace

joinby geo2010 using "$trct\tracts_id.dta", unmatched(master)

drop _merge

**Correct geography across years

#delimit ;
/*
kdensity gwg if year == 1970, 
addplot(kdensity gwg if year == 1980 || 
		kdensity gwg if year == 1990 || 
		kdensity gwg if year == 2000 || 
		kdensity gwg if year == 2010) 
legend(order(1 "1970" 2 "1980" 3 "1990" 4 "2000" 5 "2010") c(2) r(2))
graphregion(color(white)) bgcolor(white)
title("Gender Wage Gap")
xtitle("GWG (women w.r.t men)")
name(gwg_dens, replace);
*/

twoway (lpoly nonfam distance if year == 1980 & distance < 20, lcolor(red) lpattern(solid)) 
       (lpoly nonfam distance if year == 2010 & distance < 20, lcolor(blue) lpattern(solid))
	   (lpoly marshr distance if year == 1980 & distance < 20, lcolor(red) lpattern(dash)) 
       (lpoly marshr distance if year == 2010 & distance < 20, lcolor(blue) lpattern(dash)),
xtitle("Distance to City Center")
ytitle("Pct of HHs")
name(sing_dist, replace)
legend(order(1 "1980 - Single" 2 "2010 - Single" 3 "1980 - Married" 4 "2010 - Married"))
graphregion(color(white)) bgcolor(white)
	   ;
#delimit cr

graph export "$out\sing_dist.png", replace name(sing_dist)

*destring geo2010, gen(trct_num)

bysort geo2010 year: gen count = _N
drop if count > 1



smart_w geo2010 flp_set contiguity row

*w_incp construction

forvalues y = 1970(10)2010 {
capture drop w_sort
gen w_sort = 0
replace w_sort = 1 if year == `y'
gsort -w_sort id
spmat lag double w_incp`y' flp_set incp
}

*w_lincp construction

xtset geo2010 year, delta(10) 

gen l_incp       = L.incp

forvalues y = 1980(10)2010 {
capture drop w_sort
gen w_sort = 0
replace w_sort = 1 if year == `y'
gsort -w_sort id
spmat lag double w_lincp`y' flp_set l_incp
}

egen w_incp  = rowtotal(w_incp*)
egen w_lincp = rowtotal(w_lincp*)

*replace gwg = -1*gwg

**Interactions

gen dist_gwg     = gwg*distance
gen cc_gwg       = cc_2*gwg
gen cen_city_gwg = central_city*gwg

**Lag clean for output

sort geo2010 year

gen d_incp       = D.incp
gen d_rtp        = D.rtp
gen d_gwg        = D.gwg
gen dd_incp      = D.d_incp
gen dd_rtp       = D.d_rtp
gen l_gwg        = L.gwg
gen l_rtp        = L.rtp
gen l_shrmin     = L.shrmin
gen l_pt_walk    = L.pt_walk
gen l_mbed3      = L.mbed3_
gen l_mbed4pl    = L.mbed4pl_
gen l_munit5pl   = L.munit5pl_
gen l_hu_age30pl = L.hu_age30pl_
gen l_sing       = L.sing_pct
gen l_fem        = L.fem_pct

gen dist_dgwg     = d_gwg*distance
gen cc_dgwg       = cc_2*d_gwg
gen cen_city_dgwg = central_city*d_gwg

gen dist_lgwg     = l_gwg*distance
gen cc_lgwg       = cc_2*l_gwg
gen cen_city_lgwg = central_city*l_gwg

global l_xi = "l_shrmin l_pt_walk l_mbed3 l_mbed4pl l_munit5pl l_hu_age30pl"
global l_xr = "l_incp l_shrmin l_pt_walk l_mbed3 l_mbed4pl l_munit5pl l_hu_age30pl"
global xi = "shrmin pt_walk mbed3 mbed4pl munit5pl hu_age30pl"

gen dist_sing      = sing_pct*distance
gen dist_fem       = fem_pct*distance
gen cc_2_sing      = cc_2*sing_pct
gen cc_2_fem       = cc_2*fem_pct 
gen cent_city_sing = sing_pct*central_city
gen cent_city_fem  = fem_pct*central_city

gen dist_lsing      = l_sing*distance
gen dist_lfem       = l_fem*distance
gen cc_2_lsing      = cc_2*l_sing
gen cc_2_lfem       = cc_2*l_fem 
gen cent_city_lsing = l_sing*central_city
gen cent_city_lfem  = l_fem*central_city


label var incp         "Income Percentile"
label var d_incp       "$\Delta$ Income Perc"
label var d_rtp        "$\Delta$ Rent Perc"
label var l_incp       "Inc Perc (Lag)"
label var l_shrmin     "Minority Share (Lag)" 
label var l_pt_walk    "Share Public Transit/Walk" 
label var l_mbed3      "Three Bedrooms (Lag)"
label var l_mbed4pl    "4+ Bedrooms (Lag)"
label var l_munit5pl   "5+ Units (Lag)"
label var l_hu_age30pl "House Age 30+ yrs (Lag)"
label var cc_2         "City Center"
label var central_city "Central City"
label var distance     "Distance (miles)"
label var gwg          "Gender Wage Gap (est)"
label var cc_gwg       "GWG $\times$ City Center"
label var cen_city_gwg "GWG $\times$ Central City"
label var dist_gwg     "GWG $\times$ Distance"
label var d_gwg          "$\Delta$ Gender Wage Gap (est)"
label var cc_dgwg       "$\Delta GWG$ $\times$ City Center"
label var cen_city_dgwg "$\Delta GWG$ $\times$ Central City"
label var dist_dgwg     "$\Delta GWG$ $\times$ Distance"
label var l_gwg         "$Lag Gender Wage Gap (est)"
label var cc_lgwg       "GWG (lag) $\times$ City Center"
label var cen_city_lgwg "GWG (lag) $\times$ Central City"
label var dist_lgwg     "GWG (lag) $\times$ Distance"
label var cc_2_lsing       "Single Perc (lag) $\times$ City Center"
label var cent_city_lsing "Single Perc (lag) $\times$ Central City"
label var dist_lsing     "Single Perc (lag) $\times$ Distance"
label var cc_2_lfem       "Female Perc (lag) $\times$ City Center"
label var cent_city_lfem "Female Perc (lag) $\times$ Central City"
label var dist_lfem     "Female Perc (lag) $\times$ Distance"
label var sing_pct      "Single Pct"
label var fem_pct       "Female Pct"
label var l_sing        "Single Pct (Lag)"
label var l_fem         "Female Pct (Lag)"
label var w_incp        "Spillover Income"
label var w_lincp       "Spillover Income (Lag)"

*Export for Tableau

global out_vars = "geo2010 cbsa ua_code ua_name distance cc_2 cc_1 central_city year mf_rat nonfam incp d_incp rtp d_rtp"

export excel $out_vars using "$out\ncdb_fortableau.xlsx", replace first(var)

xx

destring cbsa, gen(cbsa_num)

xtset cbsa_num

save with_w, replace

eststo: xtreg incp distance l_gwg  dist_lgwg  l_incp w_incp $l_xi i.year, fe vce(robust)
eststo: xtreg incp cc_2 l_gwg  cc_lgwg l_incp w_incp $l_xi i.year, fe vce(robust)
eststo: xtreg incp central_city l_gwg  cen_city_lgwg  l_incp w_incp $l_xi i.year, fe vce(robust)

#delimit ;
esttab using "$out\gwg_l_reg.tex", replace label r2
title("Changes in Income Percentile - GWG")
order(distance dist_lgwg l_gwg cc_2 cc_lgwg central_city cen_city_lgwg l_incp w_incp $l_xi)
keep(distance dist_lgwg l_gwg cc_2 cc_lgwg central_city cen_city_lgwg l_incp w_incp $l_xi)
addn("GWG estimated by lasso procedure for each metro area in each year."
"All specifications include metropolitan area and year fixed effects."
"Cluster-robust standard errors by metro area." 
"Additional controls include specifics on minority share, mode of commuting, number of bedrooms,"
"units per structure, and age of housing stock." 
"Distance is measured from centroid of city center.");
#delimit cr

xtreg incp distance l_gwg  dist_lgwg  l_incp w_incp $l_xi i.year, fe vce(robust)

gen dots_x = .

forvalues y = 1970(10)2010 {
sum gwg if year == `y'
local mgwg = r(mean)
gen gdist = abs(gwg - `mgwg')
replace gdist = . if year != `y'
sort gdist
replace dots_x = gwg if _n == 1 
drop gdist
}

gen dots_y = _b[distance] + _b[dist_lgwg]*dots_x
tostring year, gen(year_str)
gen dots_r = round(dots_x, .01)

tostring dots_r, replace force format("%4.0g")
gen dots_l = year_str + ": " + dots_r 

mat V = e(V)

local _bdl = _b[distance]-2*sqrt(V[1,1])
local _bdu = _b[distance]+2*sqrt(V[1,1])
local _bil = _b[dist_lgwg]-2*sqrt(V[3,3])
local _biu = _b[dist_lgwg]+2*sqrt(V[3,3])

#delimit ;
twoway (function y = _b[distance]+_b[dist_lgwg]*x, range(gwg) lcolor(blue))
(function y = `_bdu' + `_bil'*x, range(gwg) lcolor(blue) lpattern(dash))
(function y = `_bdl' + `_biu'*x, range(gwg) lcolor(blue) lpattern(dash))
(scatter dots_y gwg, mlabel(dots_l) yline(0)),
xtitle("GWG")
ytitle("Distance Effect")
name(dist_eff, replace)
legend(off)
note("Points are located at mean GWG for indicated year.")
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\dist_eff.png", replace name(dist_eff)

clear matrix



*Single Percentage

eststo: xtreg incp distance l_sing  dist_lsing  l_incp w_incp $l_xi i.year, fe vce(robust)
eststo: xtreg incp cc_2 l_sing  cc_2_lsing l_incp w_incp $l_xi i.year, fe vce(robust)
eststo: xtreg incp central_city l_sing  cent_city_lsing  l_incp w_incp $l_xi i.year, fe vce(robust)

#delimit ;
esttab using "$out\sing_l_reg.tex", replace label r2
title("Changes in Income Percentile - Single Perc")
order(l_sing distance dist_lsing cc_2 cc_2_lsing central_city cent_city_lsing l_incp w_incp $l_xi)
keep(l_sing distance dist_lsing cc_2 cc_2_lsing central_city cent_city_lsing l_incp w_incp $l_xi)
addn("`Single Perc' is percentage of single women in metro area with some college."
"All specifications include metropolitan area and year fixed effects."
"Cluster-robust standard errors by metro area." 
"Additional controls include specifics on minority share, mode of commuting, number of bedrooms,"
"units per structure, and age of housing stock." 
"Distance is measured from centroid of city center.");
#delimit cr

clear matrix

*Female Percentage

eststo: xtreg incp distance l_fem  dist_lfem  l_incp w_incp $l_xi i.year, fe vce(robust)
eststo: xtreg incp cc_2 l_fem  cc_2_lfem l_incp w_incp $l_xi i.year, fe vce(robust)
eststo: xtreg incp central_city l_fem  cent_city_lfem  l_incp w_incp $l_xi i.year, fe vce(robust)

#delimit ;
esttab using "$out\fem_l_reg.tex", replace label r2
title("Changes in Income Percentile - Female Perc")
order(l_fem distance dist_lfem cc_2 cc_2_lfem central_city cent_city_lfem l_incp w_incp $l_xi)
keep(l_fem distance dist_lfem cc_2 cc_2_lfem central_city cent_city_lfem l_incp w_incp $l_xi)
addn("`Female Perc' is percentage of women in high prestige employment in metro area."
"All specifications include metropolitan area and year fixed effects."
"Cluster-robust standard errors by metro area." 
"Additional controls include specifics on minority share, mode of commuting, number of bedrooms,"
"units per structure, and age of housing stock." 
"Distance is measured from centroid of city center.");
#delimit cr

clear matrix

xx
eststo: xtreg incp distance l_sing dist_lsing l_incp w_incp $l_xi i.year, fe vce(robust)
eststo: xtreg incp distance l_fem  dist_lfem  l_incp w_incp $l_xi i.year, fe vce(robust)




#delimit ;
esttab using "$out\gwg_l_reg.tex", replace label r2
title("Changes in Income and Rent Percentile - Level GWG")
order(gwg cc_2 cc_gwg central_city cen_city_gwg distance dist_gwg)
keep(gwg cc_2 cc_gwg central_city cen_city_gwg distance dist_gwg)
addn("GWG estimated by lasso procedure for each metro area in each year."
"All specifications include metropolitan area and year fixed effects." 
"Additional controls include specifics on minority share, mode of commuting, number of bedrooms, units per structure, and age of housing stock." 
"Distance is measured from centroid of city center.");
#delimit cr

clear matrix

**Lag

eststo: xi: areg d_incp cc_2 l_gwg cc_lgwg $l_xi i.year, absorb(cbsa)
eststo: xi: areg d_incp central_city l_gwg cen_city_lgwg $l_xi i.year, absorb(cbsa)    
eststo: xi: areg d_incp distance l_gwg dist_lgwg $l_xi i.year, absorb(cbsa)

eststo: xi: areg d_rtp cc_2 l_gwg cc_lgwg $l_xr i.year, absorb(cbsa)
eststo: xi: areg d_rtp central_city l_gwg cen_city_lgwg $l_xr i.year, absorb(cbsa)    
eststo: xi: areg d_rtp distance l_gwg dist_lgwg $l_xr i.year, absorb(cbsa)

#delimit ;
esttab using "$out\lgwg_l_reg.tex", replace label r2
title("Changes in Income and Rent Percentile - Lag GWG")
order(l_gwg cc_2 cc_lgwg central_city cen_city_lgwg distance dist_lgwg)
keep(l_gwg cc_2 cc_lgwg central_city cen_city_lgwg distance dist_lgwg)
addn("GWG estimated by lasso procedure for each metro area in each year."
"All specifications include metropolitan area and year fixed effects." 
"Additional controls include specifics on minority share, mode of commuting, number of bedrooms, units per structure, and age of housing stock." 
"Distance is measured from centroid of city center.");
#delimit cr

clear matrix

**Changes

*gen cc_dgwg_2 = cc_2*d_gwg_2
*gen cc_dgwg_3 = cc_2*d_gwg_3

*global g = "cc_2 d_gwg d_gwg_2 d_gwg_3 cc_dgwg cc_dgwg_2 cc_dgwg_3"

*areg d_incp $g $l_xi i.year, absorb(cbsa)

eststo: xi: areg d_incp cc_2 d_gwg cc_dgwg $l_xi i.year, absorb(cbsa)
eststo: xi: areg d_incp central_city d_gwg cen_city_dgwg $l_xi i.year, absorb(cbsa)    
eststo: xi: areg d_incp distance d_gwg dist_dgwg $l_xi i.year, absorb(cbsa)

eststo: xi: areg d_rtp cc_2 d_gwg cc_dgwg $l_xr i.year, absorb(cbsa)
eststo: xi: areg d_rtp central_city d_gwg cen_city_dgwg $l_xr i.year, absorb(cbsa)    
eststo: xi: areg d_rtp distance d_gwg dist_dgwg $l_xr i.year, absorb(cbsa)

#delimit ;
esttab using "$out\dgwg_l_reg.tex", replace label r2
title("Changes in Income and Rent Percentile - Change in GWG")
order(d_gwg cc_2 cc_dgwg central_city cen_city_dgwg distance dist_dgwg)
keep(d_gwg cc_2 cc_dgwg central_city cen_city_dgwg distance dist_dgwg)
addn("All specifications include metropolitan area and year fixed effects." 
"Additional controls include specifics on minority share, mode of commuting, number of bedrooms, units per structure, and age of housing stock." 
"Distance is measured from centroid of city center.");
#delimit cr

**Income Percentile Shift

collapse (mean) incp d_incp rtp d_rtp gwg , by(cc_2 year ua_code)

twoway (connected d_incp year if cc_2 == 1) (connected d_incp year if cc_2 == 1 & ua_code == 0) (connected d_incp year if cc_2 == 1 & ua_code == 7)


xx

save forthresh, replace

local c = "cc_2"

#delimit ;

kdensity incp if year == 1980 & `c' == 1, 
addplot(kdensity incp if year == 1990 & `c' == 1 || 
		kdensity incp if year == 2000 & `c' == 1 || 
		kdensity incp if year == 2010 & `c' == 1) 
legend(order(1 "1980" 2 "1990" 3 "2000" 4 "2010") c(2) r(2))
graphregion(color(white)) bgcolor(white)
title("Neighborhood Income - City Center")
xtitle("Income Percentile")
name(incp_dens, replace);

graph combine gwg_dens incp_dens, name(mot, replace) 
graphregion(color(white));

#delimit cr 

graph export "$out\mot.pdf", replace name(mot)

xx
gen dist_gwg2010 = dist*gwg2010
gen cc_gwg_2010  = cc_2*gwg2010
gen central_city_gwg_2010 = central_city*gwg2010

gen dincp2010_1990 = incp2010 - incp1990

reg dincp2010_1990 cc_2 gwg2010 cc_gwg_2010, r
reg dincp2010_2000 central_city gwg2000 , r
reg dincp2010_2000 distance gwg2000, r
xx
gen d_incp = D.incp
collapse (mean) d_incp gwg, by(cbsa central_city year)

reg dincp2010_2000 distance gwg2010 dist_gwg2010 spp2000 shrmin2000 pt_walk2010 mbed3_2000 mbed4pl_2000 munit5pl_2000 hu_age30pl_2000, r

