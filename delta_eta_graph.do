
set more off


use dec_a_ed_gwg, clear

collapse (sum) N (mean) delta a_eta, by(group year)

reg delta i.group

predict r_delta, resid

reg a_eta i.group

predict r_eta, resid

#delimit ;
twoway (lpoly r_delta year, yaxis(1) lpattern(solid) ytitle("Gap", axis(1))) (lpoly r_eta year if group != 109, yaxis(2) lpattern(dash) ytitle("Kink", axis(2))),
legend(order(1 "Gap (delta)" 2 "Kink (eta)"))
graphregion(color(white)) bgcolor(white);
#delimit cr; 

graph export "$out\delta_eta.png", replace
