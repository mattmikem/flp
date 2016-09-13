capture program drop cut_reg_eq
program cut_reg_eq

	version 12

	args var yvar xvars xvar_beta source options title xtitle
	
	quietly sum `var', d
	local min = r(min)
	local max = r(max)
	mat R = J(`max'-`min'+1, 3, .)
	local ii = 1
	
	forvalues i = `min'(1)`max' {
	
	sum mu if source == "`source'" & `var' == `i'
	if r(N) > 0 {
	
		*disp `i'
		*disp "`xvars'" 
		*disp "`ifs'"
		*disp "`options'"
		quietly reg `yvar' `xvars' [w=N] if source == "`source'" & `var' == `i', r 
		mat R[`ii',1] = _b[`xvar_beta']
		mat R[`ii',2] = _se[`xvar_beta']
		mat R[`ii',3] = `i'
		*Specific for condo version
		local ii = `ii' + 1
	}
	
	else {
	local ii = `ii' + 1
	}
	
	
	}
	
	capture drop R3
	capture drop R1`source' R2`source'
	svmat R
	rename R1 R1`source'
	rename R2 R2`source'
	*capture drop ci_*
	gen ci_l`source' = R1`source'-2*R2`source'
	gen ci_u`source' = R1`source'+2*R2`source'

end
