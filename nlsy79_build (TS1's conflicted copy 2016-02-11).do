*************************************************
*Build for NLSY79 Data for Duration Analysis
*M. Miller, 16W
*************************************************


cd "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Delayed Marriage\Working"

clear
clear matrix
clear mata

set maxvar 8000
set more off

global nlsy = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\NLSY79"
global out  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Dual Career HH\Output\12-09-2015"

insheet using "$nlsy\duration_1_14.csv", case delimit(",")

do "$nlsy\duration_1_14-value-labels.do"

rename Q1_3_A_Y_1979 birth_yr
rename CASEID_1979   id

keep id birth_yr SMSARES_*  

reshape clear
reshape i id birth_yr
reshape j year
reshape xij SMSARES_
reshape long
