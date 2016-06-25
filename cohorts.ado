**Program for cohorts build - duration analysis

capture program drop cohorts
program cohorts

**Program gathers and standardized set of variables across different cohorts (and datasets)
**Source: various iterations of NLSY

**Marry and CC variables must be consistently defined across datasets. 

**Inputs: id - unique individual identifier
**		  birth_yr - birth year
**        educ - highest grade completed variable 
**		  marry - marital status variable.
**        cc - central city status variable
**        stem - prefix from download

**Outputs: generates standardied dataset 

		args id birth_yr marry cc educ sex stem
		
		local path  = "$nlsy\" + "`stem'" + ".csv"
		local label = "$nlsy\" + "`stem'" + "-value-labels.do"
		
		clear
		
		insheet using "`path'", case delimit(",")

		do "`label'"

		rename `birth_yr' birth_yr
		rename `id'       id
		
		keep id birth_yr `cc'*  `marry'* `educ'* `sex'

		reshape clear
		reshape i id birth_yr `sex'
		reshape j year
		reshape xij `cc' `marry' `educ'
		reshape long
		
		replace birth_yr = 1900 + birth_yr if birth_yr < 1900

		gen age = year - birth_yr

		gen marrst = 0
		replace marrst = 1 if `marry' == 1
		replace marrst = . if `marry' < 0
		gen evermarr = 0
		replace evermarr = 1 if `marry' > 0
		replace evermarr = . if `marry' < 0
		
		gen cc = 0
		replace cc = 1 if `cc' == 3
		replace cc = . if `cc' < 0 | `cc' == 4

		gen source = "`stem'"
		
		rename `educ' educ
		rename `sex'  sex

		keep id birth_yr sex year marrst evermarr cc educ source 
		
		save `stem', replace
**/	
end		
