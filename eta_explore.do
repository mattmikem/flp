mat A = J(5,6,.)

local i = 0

*keep if group == 1

forvalues y = 1970(10)2010 {

local i = `i' + 1

quietly lassoShooting lwage $x_lasso if emarry == 0 & group == 1 & year == `y', lasiter(100) verbose(0) fdisplay(0)
local ysel `r(selected)'
quietly lassoShooting female $x_lasso if emarry == 0 & group == 1 & year == `y' , lasiter(100) verbose(0) fdisplay(0)
local xsel `r(selected)'

local ssel : list xsel | ysel

reg lwage female `ssel' if emarry == 0 & group == 1 & year == `y', r

capture mat A[`i',1] = _b[exp]
capture mat A[`i',2] = _b[exp2]

quietly lassoShooting lwage $x_lasso if emarry == 1 & group == 1 & year == `y', lasiter(100) verbose(0) fdisplay(0)
local ysel `r(selected)'
*quietly lassoShooting female $x_lasso if emarry == 1 & group == 1 & year == `y', lasiter(100) verbose(0) fdisplay(0)
*local xsel `r(selected)'

local msel : list xsel | ysel

reg lwage `msel' if female == 1 & emarry == 1 & group == 1 & year == `y', r

capture mat A[`i',3] = _b[exp]
capture mat A[`i',4] = _b[exp2]

mat A[`i',5] = A[`i',3]/A[`i',1]
mat A[`i',6] = A[`i',4]/A[`i',2]

}

svmat A

/*
quietly lassoShooting emarry $x_lasso, lasiter(100) verbose(0) fdisplay(0)
local msel `r(selected)' 
local xysel : list xsel | ysel
local mysel : list xysel | msel
