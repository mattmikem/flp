**Program for cohorts build - duration analysis

capture program drop cohorts_supp
program cohorts_supp

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

		args id bach stem
		
		local path  = "$nlsy\" + "`stem'" + ".csv"
		local label = "$nlsy\" + "`stem'" + "-value-labels.do"
		
		clear
		
		insheet using "`path'", case delimit(",")

		do "`label'"
		
		rename `id' id
		rename `bach' bach_dum
		
		keep id bach_dum
		
		gen source = "`stem'"
		
		save `stem'_supp, replace

end
