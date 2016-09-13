********************************************
*Simple motivating figures
*Using both standard and lasso gwg estimates
*M. Miller, 16S
********************************************

cd "L:\Research\Resurgence\Working Files"

clear
clear matrix

set more off

global data = "L:\Research\Resurgence\GIS\Working Files\Output\Test"
global work = "L:\Research\Resurgence\Working Files"  
global reg  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\Regulations\BPEAzip1\FiftyYears_Replication1"
global out  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Draft"

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
joinby group year using gwg_lasso_long_alts_mot, unmatched(master)
drop _merge

joinby ua_code cbsa using top_cbsa, unmatched(master)

drop if _merge == 1
drop _merge

destring geo2010, replace

joinby geo2010 using "$trct\tracts_id.dta", unmatched(master)

drop _merge

*destring geo2010, gen(trct_num)

bysort geo2010 year: gen count = _N
drop if count > 1

xtset geo2010 year, delta(10) 

**Lag clean for output

gen gwg = ov_gwg
drop ov_

gen d_incp       = D.incp
gen d_rtp        = D.rtp
gen d_gwg        = D.gwg

**Income Percentile Shift

preserve

collapse (sum) pop (mean) incp d_incp rtp d_rtp gwg sing_pct fem_pct [w=pop], by(cc_2 year ua_code ua_name)

save by_ua, replace

restore

collapse (sum) pop (mean) incp d_incp rtp d_rtp gwg sing_pct fem_pct [w=pop], by(cc_2 year)

gen ua_name = "US"

append using by_ua

**FIGURES

label var incp "Mean Income Percentile (pop weighted)" 
label var gwg  "Gender Wage Gap"
label var sing_pct "Pct Single Among College Ed Women" 


#delimit ;

*National Trends;

twoway (connected incp year if cc_2 == 1 & ua_code == ., yaxis(1) lcolor(black) mcolor(black) lpattern(solid)) 
(connected gwg year if cc_2 == 1 & ua_code == ., yaxis(2) lcolor(black) mcolor(black) lpattern(dash)),
name(us_trend_gwg, replace)
legend(label(1 "CC Income") label(2 "GWG")) 
subtitle("US National Trends")
graphregion(color(white)) bgcolor(white);

twoway (connected incp year if cc_2 == 1 & ua_code == ., yaxis(1) lcolor(black) mcolor(black) lpattern(solid)) 
(connected sing_pct year if cc_2 == 1 & ua_code == ., yaxis(2) lcolor(black) mcolor(black) lpattern(dash)),
name(us_trend_sing, replace)
legend(label(1 "CC Income") label(2 "Pct Single"))
subtitle("US National Trends")
note("Percent single among women 22-35 with some college education.")
graphregion(color(white)) bgcolor(white);

twoway (connected d_incp year if cc_2 == 1 & ua_code == ., yaxis(1) lcolor(black) mcolor(black) lpattern(solid)) 
(connected sing_pct year if cc_2 == 1 & ua_code == ., yaxis(2) lcolor(black) mcolor(black) lpattern(dash)),
 name(us_dtrend_sing, replace)
legend(label(1 "Change CC Income") label(2 "Perc Single"))
title("Gentrification and Percent Single") 
subtitle("US National Trends")
note("Percent single among women 18-35 with some college education.")
graphregion(color(white)) bgcolor(white);


twoway (connected incp year if cc_2 == 1 & ua_code == ., yaxis(1) lcolor(black) mcolor(black) lpattern(solid)) 
(connected fem_pct year if cc_2 == 1 & ua_code == ., yaxis(2) lcolor(black) mcolor(black) lpattern(dash)),
 name(us_trend_fem, replace)
legend(label(1 "CC Income") label(2 "Pct Employment Female"))
title("Gentrification and Percent Female in HP Employment") 
subtitle("National Trends")
graphregion(color(white)) bgcolor(white);
#delimit cr 

*graph export "$out\us_trend_gwgsing.png", replace name(us_trend_gwg)
*graph export "$out\us_trend_gwg.png", replace name(us_trend_gwg)
*graph export "$out\us_trend_sing.png", replace name(us_trend_sing)
*graph export "$out\us_dtrend_sing.png", replace name(us_dtrend_sing)
*graph export "$out\us_trend_gwg.pdf", replace name(us_trend_gwg)
*graph export "$out\us_trend_sing.pdf", replace name(us_trend_sing)
*graph export "$out\us_trend_fem.png", replace name(us_trend_fem)

*title("Gentrification and Pct Single among College Ed Women") 

*City Specific Trends 

keep if ua_code < 75

#delimit ; 
twoway 
(connected incp year if cc_2 == 1 & ua_code == 0, lcolor(blue) mcolor(blue) lpattern(solid) yaxis(1)) 
(connected incp year if cc_2 == 1 & ua_code == 2, lcolor(green) mcolor(green) lpattern(solid) yaxis(1)) 
(connected gwg year if cc_2 == 1 & ua_code == 0, lcolor(blue) mcolor(blue) lpattern(dash) yaxis(2)) 
(connected gwg year if cc_2 == 1 & ua_code == 2, lcolor(green) mcolor(green) lpattern(dash) yaxis(2)), 
name(trend_city_c_gwg, replace)
legend(label(1 "NY - Inc") label(2 "CHI - Inc") label(3 "NY - gwg") label(4 "CHI - gwg"))
title("Gentrification and Gender Wage Gap")
subtitle("New York, NY and Chicago, IL")
graphregion(color(white)) bgcolor(white);
#delimit cr


#delimit ; 
twoway 
(connected incp year if cc_2 == 1 & ua_code == 0, lcolor(blue) mcolor(blue) lpattern(solid) yaxis(1)) 
(connected incp year if cc_2 == 1 & ua_code == 2, lcolor(green) mcolor(green) lpattern(solid) yaxis(1)) 
(connected sing_pct year if cc_2 == 1 & ua_code == 0, lcolor(blue) mcolor(blue) lpattern(dash) yaxis(2)) 
(connected sing_pct year if cc_2 == 1 & ua_code == 2, lcolor(green) mcolor(green) lpattern(dash) yaxis(2)), 
name(trend_city_c_sing, replace)
legend(label(1 "NY - Inc") label(2 "CHI - Inc") label(3 "NY - sing pct") label(4 "CHI - sing pct")) 
title("Gentrification and Percent Single")
subtitle("New York, NY and Chicago, IL")
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ; 
twoway 
(connected incp year if cc_2 == 1 & ua_code == 0, lcolor(blue) mcolor(blue) lpattern(solid) yaxis(1)) 
(connected incp year if cc_2 == 1 & ua_code == 2, lcolor(green) mcolor(green) lpattern(solid) yaxis(1)) 
(connected fem_pct year if cc_2 == 1 & ua_code == 0, lcolor(blue) mcolor(blue) lpattern(dash) yaxis(2)) 
(connected fem_pct year if cc_2 == 1 & ua_code == 2, lcolor(green) mcolor(green) lpattern(dash) yaxis(2)), 
name(trend_city_c_fem, replace)
legend(label(1 "NY - Inc") label(2 "CHI - Inc") label(3 "NY - fem pct") label(4 "CHI - fem pct")) 
title("Gentrification and Percent Female")
subtitle("New York, NY and Chicago, IL")
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ; 
twoway 
(connected incp year if cc_2 == 1 & ua_code == 1, lcolor(red) mcolor(red) lpattern(solid) yaxis(1)) 
(connected incp year if cc_2 == 1 & ua_code == 3, lcolor(orange) mcolor(orange) lpattern(solid) yaxis(1)) 
(connected gwg year if cc_2 == 1 & ua_code == 1, lcolor(red) mcolor(red) lpattern(dash) yaxis(2)) 
(connected gwg year if cc_2 == 1 & ua_code == 3, lcolor(orange) mcolor(orange) lpattern(dash) yaxis(2)), 
name(trend_city_dc_gwg, replace)
legend(label(1 "LA - Inc") label(2 "HOUS - Inc") label(3 "LA - gwg") label(4 "HOUS - gwg"))
title("Gentrification and Gender Wage Gap")
subtitle("Los Angeles, CA and Houston, TX")
graphregion(color(white)) bgcolor(white);
#delimit cr


#delimit ; 
twoway 
(connected incp year if cc_2 == 1 & ua_code == 1, lcolor(red) mcolor(red) lpattern(solid) yaxis(1)) 
(connected incp year if cc_2 == 1 & ua_code == 3, lcolor(orange) mcolor(orange) lpattern(solid) yaxis(1)) 
(connected sing_pct year if cc_2 == 1 & ua_code == 1, lcolor(red) mcolor(red) lpattern(dash) yaxis(2)) 
(connected sing_pct year if cc_2 == 1 & ua_code == 3, lcolor(orange) mcolor(orange) lpattern(dash) yaxis(2)), 
name(trend_city_dc_sing, replace)
legend(label(1 "LA - Inc") label(2 "HOUS - Inc") label(3 "LA - sing pct") label(4 "HOUS - sing pct")) 
title("Gentrification and Percent Single")
subtitle("Los Angeles, CA and Houston, TX")
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ; 
twoway 
(connected incp year if cc_2 == 1 & ua_code == 1, lcolor(red) mcolor(red) lpattern(solid) yaxis(1)) 
(connected incp year if cc_2 == 1 & ua_code == 3, lcolor(orange) mcolor(orange) lpattern(solid) yaxis(1)) 
(connected fem_pct year if cc_2 == 1 & ua_code == 1, lcolor(red) mcolor(red) lpattern(dash) yaxis(2)) 
(connected fem_pct year if cc_2 == 1 & ua_code == 3, lcolor(orange) mcolor(orange) lpattern(dash) yaxis(2)), 
name(trend_city_dc_fem, replace)
legend(label(1 "LA - Inc") label(2 "HOUS - Inc") label(3 "LA - fem pct") label(4 "HOUS - fem pct")) 
title("Gentrification and Percent Female")
subtitle("Los Angeles, CA and Houston, TX")
graphregion(color(white)) bgcolor(white);
#delimit cr

/*
graph export "$out\trend_city_c_gwg.png", replace name(trend_city_c_gwg)
graph export "$out\trend_city_c_sing.png", replace name(trend_city_c_sing)
graph export "$out\trend_city_c_fem.png", replace name(trend_city_c_fem)
graph export "$out\trend_city_dc_gwg.png", replace name(trend_city_dc_gwg)
graph export "$out\trend_city_dc_sing.png", replace name(trend_city_dc_sing)
graph export "$out\trend_city_dc_fem.png", replace name(trend_city_dc_fem)

graph export "$out\trend_city_c_gwg.pdf", replace name(trend_city_c_gwg)
graph export "$out\trend_city_c_sing.pdf", replace name(trend_city_c_sing)
graph export "$out\trend_city_c_fem.pdf", replace name(trend_city_c_fem)
graph export "$out\trend_city_dc_gwg.pdf", replace name(trend_city_dc_gwg)
graph export "$out\trend_city_dc_sing.pdf", replace name(trend_city_dc_sing)
graph export "$out\trend_city_dc_fem.pdf", replace name(trend_city_dc_fem)
*/
gen ua_name_g = ""
replace ua_name_g = ua_name if ua_code < 15

*Gender Wage Gaps and CC Income Percentile Over time;
#delimit ;
twoway 
(scatter incp gwg if year == 1980 & cc_2 == 1, mcolor(red) mlabel(ua_name_g))
(scatter incp gwg if year == 2010 & cc_2 == 1, mcolor(blue) mlabel(ua_name_g))
(lfit    incp gwg [w=pop] if year == 1980 & cc_2 == 1, lcolor(red))
(lfit    incp gwg [w=pop] if year == 2010 & cc_2 == 1, lcolor(blue)),
name(gwg_incp, replace)
subtitle("Cross-Sections, 1980 and 2010")
legend(label(1 "1980") label(2 "2010") label(3 "1980 - pop weighted fit") label(4 "2010 - pop weighted fit"))
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ;
twoway 
(scatter incp sing_pct if year == 1980 & cc_2 == 1, mcolor(red) mlabel(ua_name_g))
(scatter incp sing_pct if year == 2010 & cc_2 == 1, mcolor(blue) mlabel(ua_name_g))
(lfit    incp sing_pct [w=pop] if year == 1980 & cc_2 == 1, lcolor(red))
(lfit    incp sing_pct [w=pop] if year == 2010 & cc_2 == 1, lcolor(blue)),
name(sing_incp, replace)
title("City Center Income and Single Pct")
subtitle("Cross-Sections, 1980 and 2010")
legend(label(1 "1980") label(2 "2010") label(3 "1980 - pop weighted fit") label(4 "2010 - pop weighted fit"))
graphregion(color(white)) bgcolor(white);
#delimit cr

/*
#delimit ;
twoway 
(scatter incp fem_pct if year == 1980 & cc_2 == 1, mcolor(red) mlabel(ua_code))
(scatter incp fem_pct if year == 2010 & cc_2 == 1, mcolor(blue) mlabel(ua_code))
(lfit    incp fem_pct [w=pop] if year == 1980 & cc_2 == 1, lcolor(red))
(lfit    incp fem_pct [w=pop] if year == 2010 & cc_2 == 1, lcolor(blue)),
name(fem_incp, replace)
title("City Center Income and Female Pct")
subtitle("Cross-Sections, 1980 and 2010")
legend(label(1 "1980") label(2 "2010") label(3 "1980 - pop weighted fit") label(4 "2010 - pop weighted fit"))
note("Labelled by code of population rank, e.g. 0 is NY, 1 is LA, 2 is Chicago.")
graphregion(color(white)) bgcolor(white);
#delimit cr
*/
/*
graph export "$out\sing_incp.png", replace name(sing_incp)
graph export "$out\gwg_incp.png", replace name(gwg_incp)
graph export "$out\fem_incp.png", replace name(fem_incp)

graph export "$out\sing_incp.pdf", replace name(sing_incp)
graph export "$out\gwg_incp.pdf", replace name(gwg_incp)
graph export "$out\fem_incp.pdf", replace name(fem_incp)
*/

/*
**By change in Income Percentile

#delimit ;
twoway 
(scatter d_incp gwg if year == 1980 & cc_2 == 1, mcolor(red) mlabel(ua_code))
(scatter d_incp gwg if year == 2010 & cc_2 == 1, mcolor(blue) mlabel(ua_code))
(lfit    d_incp gwg [w=pop] if year == 1980 & cc_2 == 1, lcolor(red))
(lfit    d_incp gwg [w=pop] if year == 2010 & cc_2 == 1, lcolor(blue)),
name(gwg_dincp, replace)
title("City Center Income and GWG")
subtitle("Cross-Sections, 1980 and 2010")
legend(label(1 "1980") label(2 "2010") label(3 "1980 - pop weighted fit") label(4 "2010 - pop weighted fit"))
note("Labelled by code of population rank, e.g. 0 is NY, 1 is LA, 2 is Chicago.")
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ;
twoway 
(scatter d_incp sing_pct if year == 1980 & cc_2 == 1, mcolor(red) mlabel(ua_code))
(scatter d_incp sing_pct if year == 2010 & cc_2 == 1, mcolor(blue) mlabel(ua_code))
(lfit    d_incp sing_pct [w=pop] if year == 1980 & cc_2 == 1, lcolor(red))
(lfit    d_incp sing_pct [w=pop] if year == 2010 & cc_2 == 1, lcolor(blue)),
name(sing_dincp, replace)
title("City Center Income and Single Pct")
subtitle("Cross-Sections, 1980 and 2010")
legend(label(1 "1980") label(2 "2010") label(3 "1980 - pop weighted fit") label(4 "2010 - pop weighted fit"))
note("Labelled by code of population rank, e.g. 0 is NY, 1 is LA, 2 is Chicago.")
graphregion(color(white)) bgcolor(white);
#delimit cr


#delimit ;
twoway 
(scatter d_incp fem_pct if year == 1980 & cc_2 == 1, mcolor(red) mlabel(ua_code))
(scatter d_incp fem_pct if year == 2010 & cc_2 == 1, mcolor(blue) mlabel(ua_code))
(lfit    d_incp fem_pct [w=pop] if year == 1980 & cc_2 == 1, lcolor(red))
(lfit    d_incp fem_pct [w=pop] if year == 2010 & cc_2 == 1, lcolor(blue)),
name(sing_incp, replace)
title("City Center Income and Female Pct")
subtitle("Cross-Sections, 1980 and 2010")
legend(label(1 "1980") label(2 "2010") label(3 "1980 - pop weighted fit") label(4 "2010 - pop weighted fit"))
note("Labelled by code of population rank, e.g. 0 is NY, 1 is LA, 2 is Chicago.")
graphregion(color(white)) bgcolor(white);
#delimit cr 


