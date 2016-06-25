# delimit ;
set more off;

clear all ;
set maxvar 20000 ;
set matsize 11000 ;

capture log close ;
log using CSHomePrice.txt , replace text ;

* Import data.  Data was precleaned in MATLAB. ;

import excel using CSExampleData.xlsx , first ;

* IV Results using Democrat baseline instrument ;
ivreg CSIndex (NumProCase = Z1xD) , noconstant robust first ;
* Need to scale standard error by sqrt((n-1)/(n-1-nControl)) to account for partialing ;
* out the controls to get things to line up with usual degrees of freedom ;
* correction done in Stata (and in MATLAB) for robust standard errors. ;
scalar se_Dem = .3798*sqrt(182/(182-72)) ;
scalar list se_Dem ;

* Instrument selection ;
lassoShooting NumProCase Z* , lasiter(100) verbose(0) fdisplay(0);
local zSel `r(selected)' ;

di "`zSel'" ;

* IV with selected instruments ;
ivreg CSIndex (NumProCase = `zSel') , noconstant robust first ;
scalar se_Sel = .0240*sqrt(182/(182-72)) ;
scalar list se_Sel ;

log close ;
