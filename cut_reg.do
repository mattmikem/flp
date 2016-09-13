capture program drop cut_reg
program cut_reg 

	args var steps yvar xvars xvar_beta ifs options title xtitle
	
	mat R = J(`steps'+1, 5, .)
	quietly sum `var', d
	local min = r(min)
	local max = r(p99)
	local step = (`max' - `min')/`steps' 
	local ii = 1
	
	forvalues i = `min'(`step')`max' {
	
		*disp `i'
		*disp "`xvars'" 
		*disp "`ifs'"
		*disp "`options'"
		quietly xtreg `yvar' `xvars' if `ifs' & `var' >= `i', `options'  
		mat R[`ii',1] = _b[`xvar_beta']
		mat R[`ii',2] = _se[`xvar_beta']
		mat R[`ii',3] = `i'
		*Specific for condo version
		quietly reg `yvar' cond_pct if year == 2010 & `ifs' & `var' >= `i'
		mat R[`ii',4] = _b[cond_pct]
		mat R[`ii',5] = _se[cond_pct]
		local ii = `ii' + 1
		
	}
	
	capture drop R1-R5
	svmat R
	capture drop ci_*
	gen ci_l = R1-2*R2
	gen ci_u = R1+2*R2
	#delimit ;
	twoway (line ci_l ci_u R1 R3, lcolor(blue blue blue) lpattern(dash dash solid)),
	name(`var', replace)
	title("`title'")
	xtitle("`xtitle'")
	ytitle("Effect of Ordinance on Ownership")
	legend(off)
	note("Effect corresponds to estimate with sample restricted to neighborhoods above x-axis value."
	"Includes 95% confidence interval on estimate (dashed line).")
	graphregion(color(white)) bgcolor(white);
	#delimit cr
end

