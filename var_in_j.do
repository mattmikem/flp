**Variable gen within metro for lasso

*Urban 

replace urban = urban - 1

*Metro 

replace metro = 0 if metro == .

tab metro, gen(met_stat)
*tab metro if year == $y & group == $j, gen(met_stat)

*Marital Status
/*
tab marst if year == $y & group == $j, gen(marst_)

*Times Married

tab marrno, gen(marrno_)

*Divorced in Year

replace divinyr = 0 if divinyr == 1
replace divinyr = 1 if divinyr == 2

*Fertility in Year

replace fertyr = 0 if fertyr == 1
replace fertyr = 1 if fertyr == 2
*/
*Race

tab race, gen(race_)
*tab race if year == $y & group == $j, gen(race_)

*Hispanic

tab hispan, gen(hisp_)
*tab hispan if year == $y & group == $j, gen(hisp_)


*Birthplace

*tab bpl, gen(bpl_)	
*tab bpl if year == $y & group == $j, gen(bpl_)	

*Degree Field

*tab degfield, gen(degfield_)

*Occupation and Industry

gen occ_gen = ""
replace occ_gen =  "Management in Business, Science, and Arts" if occ2010 >=10 & occ2010<=430
replace occ_gen =  "Business Operations Specialists " if occ2010 >=500 & occ2010<=730
replace occ_gen =  "Financial Specialists " if occ2010 >=800 & occ2010<=950
replace occ_gen =  "Computer and Mathematical " if occ2010 >=1000 & occ2010<=1240
replace occ_gen =  "Architecture and Engineering " if occ2010 >=1300 & occ2010<=1540
replace occ_gen =  "Technicians " if occ2010 >=1550 & occ2010<=1560
replace occ_gen =  "Life, Physical, and Social Science " if occ2010 >=1600 & occ2010<=1980
replace occ_gen =  "Community and Social Services " if occ2010 >=2000 & occ2010<=2060
replace occ_gen =  "Legal " if occ2010 >=2100 & occ2010<=2150
replace occ_gen =  "Education, Training, and Library " if occ2010 >=2200 & occ2010<=2550
replace occ_gen =  "Arts, Design, Entertainment, Sports, and Media " if occ2010 >=2600 & occ2010<=2920
replace occ_gen =  "Healthcare Practitioners and Technicians " if occ2010 >=3000 & occ2010<=3540
replace occ_gen =  "Healthcare Support " if occ2010 >=3600 & occ2010<=3650
replace occ_gen =  "Protective Service " if occ2010 >=3700 & occ2010<=3950
replace occ_gen =  "Food Preparation and Serving " if occ2010 >=4000 & occ2010<=4150
replace occ_gen =  "Building and Grounds Cleaning and Maintenance " if occ2010 >=4200 & occ2010<=4250
replace occ_gen =  "Personal Care and Service " if occ2010 >=4300 & occ2010<=4650
replace occ_gen =  "Sales and Related " if occ2010 >=4700 & occ2010<=4965
replace occ_gen =  "Office and Administrative Support " if occ2010 >=5000 & occ2010<=5940
replace occ_gen =  "Farming, Fisheries, and Forestry " if occ2010 >=6005 & occ2010<=6130
replace occ_gen =  "Construction " if occ2010 >=6200 & occ2010<=6765
replace occ_gen =  "Extraction " if occ2010 >=6800 & occ2010<=6940
replace occ_gen =  "Installation, Maintenance, and Repair " if occ2010 >=7000 & occ2010<=7630
replace occ_gen =  "Production " if occ2010 >=7700 & occ2010<=8965
replace occ_gen =  "Transportation and Material Moving " if occ2010 >=9000 & occ2010<=9750
replace occ_gen =  "Military " if occ2010 >=9800 & occ2010<=9830
replace occ_gen =  "No Occupation " if occ2010 >=9920 & occ2010<=10000

replace occ_gen = trim(occ_gen)

tab occ_gen, gen(occx_)
*tab occ_gen if year == $y & group == $j, gen(occ_)

**Industry

gen ind_gen = ""
replace ind_gen =  "N/A" if ind1950 < 1
replace ind_gen =  "Agriculture" if ind1950 >=105 & ind1950<=126
replace ind_gen =  "Mining" if ind1950 >=206 & ind1950<=239
replace ind_gen =  "Construction" if ind1950 == 246
replace ind_gen =  "Manufacturing (Durable)" if ind1950 >=306 & ind1950<=399
replace ind_gen =  "Manufacturing (Non-Durable)" if ind1950 >=406 & ind1950<=499
replace ind_gen =  "Transportation" if ind1950 >=506 & ind1950<=568
replace ind_gen =  "Telecommunications" if ind1950 >=578 & ind1950<=579
replace ind_gen =  "Utilities" if ind1950 >=581 & ind1950<=598
replace ind_gen =  "Wholesale Trade" if ind1950 >=606 & ind1950<=627
replace ind_gen =  "Retail Trade" if ind1950 >=636 & ind1950<=699
replace ind_gen =  "Finance and Real Estate" if ind1950 >=716 & ind1950<=756
replace ind_gen =  "Business and Repair Services" if ind1950 >=806 & ind1950<=817
replace ind_gen =  "Personal Services" if ind1950 >=826 & ind1950<=849
replace ind_gen =  "Entertainment" if ind1950 >=856 & ind1950<=859
replace ind_gen =  "Professional Services" if ind1950 >=868 & ind1950<=899
replace ind_gen =  "Public Administration" if ind1950 >=906 & ind1950<=987
replace ind_gen =  "Other" if ind1950 >=991

replace ind_gen = trim(ind_gen)

tab ind_gen , gen(indx_)
*tab ind_gen if year == $y & group == $j, gen(ind_)

*tab ind, gen(indx_)

*Transportation Type and time

tab tranwork, gen(tranwork_)
*tab tranwork if year == $y & group == $j, gen(tranwork_)

	