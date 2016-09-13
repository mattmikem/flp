********************************************
*MF Ratio Graphs (< 5 miles)

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


/*
use ipums_withcbsa, clear

keep cbsa group
*keep metarea group year

duplicates drop

*joinby group using gwg_wide, unmatched(master)
*joinby group year using gwg_lasso_long_alts, unmatched(master)

*rename delta gwg

*drop _merge

*drop if metarea == .

*tostring metarea, gen(cbsa)
*replace cbsa = "31100" if cbsa == "31080"

*gen gwg_late      = gwg
*gen se_late       = se
*gen sing_pct_late = sing_pct
*gen fem_pct_late  = fem_pct    
*gen a_eta_late = a_eta
*gen b_eta_late = b_eta

*decode metarea, gen(metarea_str)
*gen state = substr(metarea_str, strpos(metarea_str, ",")+2, 2)

*save gwg_lasso_forncdb, replace
save cbsa_group, replace
*/
**NCDB, add on GWG

*use "$work\resurge_12_10.dta", clear
use "$work\resurge_09_16.dta", clear

keep geo2010 zcta5 region division cbsa ua_code ua_name distance cc_2 cc_1 central_city pop* educ_b* incp* rtp* shrmin* nonfam* mf_rat* pt_walk* own_* mbed3_* mbed4pl_* munit5pl_* hu_age30pl_* marshr* 

drop if ua_code == .

reshape clear
reshape i geo2010 zcta5 division cbsa ua_code ua_name distance cc_2 cc_1 central_city
reshape j year
reshape xij incp rtp educ_b shrmin nonfam mf_rat marshr pt_walk own_ mbed3_ mbed4pl_ munit5pl_ hu_age30pl_ pop
reshape long

joinby cbsa using cbsa_group, unmatched(master)
drop _merge
joinby group year using gwg_lasso_long_alts, unmatched(master)
drop _merge
/*
joinby cbsa using msa1990_cbsa, unmatched(master)
drop _merge
joinby metarea year using gwg_lasso_forncdb, unmatched(master)
drop _merge 
drop *_late
joinby cbsa year using  gwg_lasso_forncdb, unmatched(master)
drop _merge
replace gwg      = gwg_late      if year > 1990
*replace se       = se_late       if year > 1990
replace sing_pct = sing_pct_late if year > 1990
replace fem_pct  = fem_pct_late  if year > 1990
replace a_eta    = a_eta_late    if year > 1990
replace b_eta    = b_eta_late    if year > 1990
*/

joinby ua_code cbsa using top_cbsa, unmatched(master)

drop if _merge == 1
drop _merge

destring geo2010, replace

joinby geo2010 using "$trct\tracts_id.dta", unmatched(master)

drop _merge

local nptype = "lowess"

#delimit ;
twoway (`nptype' mf_rat distance if year == 1980 & distance < 5, lpattern(solid) lcolor(black)) 
(`nptype' mf_rat distance if year == 2010 & distance < 5, lpattern(dash) lcolor(black)),
title("Male-Female Ratio by Distance to City Center")
xtitle("Dist to CC (miles)")
ytitle("Male-Female Ratio")
legend(order(1 "1980" 2 "2010"))
name(mf_plot, replace)
note("Male-female ratio for population 16-34.")
graphregion(color(white)) bgcolor(white);
#delimit cr


#delimit ;
twoway (`nptype' mf_rat distance if year == 1980 & distance < 5 & ua_code == 7, lpattern(solid) lcolor(blue)) 
(`nptype' mf_rat distance if year == 2010 & distance < 5 & ua_code == 7, lpattern(dash) lcolor(blue)),
title("Male-Female Ratio by Distance to City Center")
xtitle("Dist to CC (miles)")
ytitle("Male-Female Ratio")
legend(order(1 "1980 - Washington, DC" 2 "2010 - Washington, DC"))
name(mf_plot_dc, replace)
note("Male-female ratio for population 16-34.")
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ;
twoway (`nptype' mf_rat distance if year == 1980 & distance < 5 & ua_code == 0, lpattern(solid) lcolor(green)) 
(`nptype' mf_rat distance if year == 2010 & distance < 5 & ua_code == 0, lpattern(dash) lcolor(green)),
title("Male-Female Ratio by Distance to City Center")
xtitle("Dist to CC (miles)")
ytitle("Male-Female Ratio")
legend(order(1 "1980 - New York, NY" 2 "2010 - New York, NY"))
name(mf_plot_ny, replace)
note("Male-female ratio for population 16-34.")
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\mf_plot.png", replace name(mf_plot)
graph export "$out\mf_plot_dc.png", replace name(mf_plot_dc)
graph export "$out\mf_plot_ny.png", replace name(mf_plot_ny)
