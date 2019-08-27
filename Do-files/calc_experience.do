cap program drop calc_experience
program define calc_experience



// Move up if blank 
forval i = 1/8{
local j = `i' + 1
 list resid barangay b12* if b12pastocc_o_`i'_BL == . & b12pastocc_o_`j'_BL != .
 }
 
foreach var in b3occ b3occ_desc b4days b5hours b6earning b7years{
rename `var'_o_1 `var'_2
rename `var'_o_2 `var'_3
rename `var'_o_3 `var'_4
rename `var'_o_4 `var'_5

}
 gen b3occ_desc_1 = b3occ_d_BL 
gen b6earning_1 =  b6wage_1_BL 
gen b7years_1 =  b7exp_1_BL 

/* Clean current job variables */ 
tostring b3occ_desc*,replace


forval i = 1/5{

replace b3occ_`i' = . if (b3occ_`i' == 999 | b3occ_`i' == 9999) & (b3occ_desc_`i' == "9999" | b3occ_desc_`i' == "")
replace b3occ_`i' = . if b3occ_`i' == 988 | b3occ_`i' == 977 | b3occ_`i' == 966		// NOT OCCUPATIONS

replace b3occ_desc_`i' = "" if b3occ_desc_`i' == "9999" | b3occ_desc_`i' == "999" | b3occ_desc_`i' == "."
replace b3occ_`i' = . if b3occ_`i' <=100 & b3occ_desc_`i' == ""

assert b3occ_`i' !=. if b3occ_desc_`i' != ""

recode b4days_`i' 99 = .
recode b4days_`i' -2 = .

	replace b4days_`i' = . if b3occ_`i' == .
recode b5hours_`i' 99 = .
recode b5hours_`i' -2 = .

	replace b5hours_`i' = . if b3occ_`i' == .
recode b6earning_`i' 9999 = .
recode b6earning_`i' -2 = .

	replace b6earning_`i' = . if b3occ_`i' == . 
recode b7years_`i' 99=.
recode b7years_`i' -2=.

	replace b7years_`i' = . if b3occ_`i' == .

	
}


forval i = 4/5{
foreach var in b3occ b3occ_desc b4days b5hours b6earning b7years{

qui gen TEMP=.
qui replace TEMP=1 if !missing(`var'_`i')
qui egen TEMPSUM=sum(TEMP)
if TEMPSUM==0 {
di "dropping `var'_`i'"

qui drop `var'_`i'
}
qui drop TEMP TEMPSUM
}
}

/* Check order of variables - no out of order blanks */ 

forval i = 1/2{
local j = `i' + 1
assert b3occ_`i' != . if b3occ_`j' != .
}

/* Clean past job variables */ 

tostring b12pastocc_desc*,replace



forval i = 1/10{
gen b12pastocc_`i' = b12pastocc_o_`i'_BL 
replace b12pastocc_desc_`i'_BL = "" if b12pastocc_desc_`i'_BL == "."
replace b12pastocc_desc_`i'_BL = "" if b12pastocc_desc_`i'_BL == "9999" | b12pastocc_desc_`i'_BL == "0"
replace b12pastocc_`i' = . if (b12pastocc_`i' == 999 | b12pastocc_`i' == 9999) & b12pastocc_desc_`i'_BL == ""
replace b12pastocc_`i' = . if b12pastocc_`i' == 988 | b12pastocc_`i' == 977 | b12pastocc_`i' == 966		// NOT OCCUPATIONS
replace b12pastocc_`i' = . if b12pastocc_`i' <=100 & b12pastocc_desc_`i'_BL == ""

replace b12pastocc_`i' = 999 if b12pastocc_desc_`i'_BL != "" & b12pastocc_`i' == .

recode b13pastyearleft_`i'_BL 9999 = .
}

replace b14pasttotalyears_1_BL = 9 if b14pasttotalyears_1_BL == 90

forval i = 1/8{
local j = `i' + 1
di "count i = `i'"
 list resid barangay b12* b13* b14* b15* if b12pastocc_`i' == . & b12pastocc_`j' != .
 }

forval i = 1/9{
local j = `i' + 1
assert b12pastocc_`i' != . if b12pastocc_`j' != .
}

forval i = 1/10{
recode b13pastyearleft_`i'_BL -2 = .
recode b14pasttotalyears_`i'_BL 99 = .
}

forval i = 7/10{
foreach var in b12pastocc b12pastocc_desc b13pastyearleft b14totalyears{

qui gen TEMP=.
 qui cap replace TEMP=1 if !missing(`var'_`i')
qui egen TEMPSUM=sum(TEMP)
if TEMPSUM==0 {
di "dropping `var'_`i'"

qui cap drop `var'_`i'
}
qui drop TEMP TEMPSUM
}
}


******************************
/* Harmonize current and past job variables */ 


// Count the maximum number of nonmissing jobs
/*
gen totjob = 0
gen totjobcur = 0
gen totjobpast = 0
forval i = 1/3{
replace totjob = totjob + 1 if b3occ_`i' != .
replace totjobcur = totjobcur + 1 if b3occ_`i' != .
}
forval i = 1/6{
replace totjob = totjob + 1 if b12pastocc_o_`i'_BL != .
replace totjobpast = totjobpast + 1 if b12pastocc_o_`i'_BL != .

}
tab totjob 				// The maximum number of jobs is 6
tab  totjobpast totjobcur

*/


forval i = 1/3{
gen job`i' = b3occ_`i'
gen jobstatus`i' = job`i' != .
gen jobso`i' = "b3occ_`i'" if job`i' !=.
}
forval i = 4/6{
gen job`i' = .
gen jobstatus`i' = 0
gen jobso`i' = ""
}

forval k = 1/6{	
		
forval i = 1/`k'{			
	replace job`k' = b12pastocc_o_`i'_BL if job`k' == . &   jobso1 != "b12pastocc_o_`i'" & jobso2 != "b12pastocc_o_`i'" & jobso3 != "b12pastocc_o_`i'" & jobso4 != "b12pastocc_o_`i'" & jobso5 != "b12pastocc_o_`i'"
	replace jobso`k' = "b12pastocc_o_`i'" if job`k' == b12pastocc_o_`i'_BL & b12pastocc_o_`i'_BL != . & jobso`k' == ""


}	
}		
		
	forval i = 1/6{
	replace jobstatus`i' = 2 if substr(jobso`i',1,3) == "b12"
	}

	
***********************************
// Generate other job characteristic variables based on job classifications
***********************************


	*replace b_employed = 1 if b3occ_1 != . & b3occ_1 > 100 & b11 > 0	// bad code because some reporting past jobs

// Data cleaning

replace job2 = . if resid == 887 & job1 == 504	// job listed twice



/* Data cleaning - Current jobs 1 - 3 */ 


forval i = 1/3{
gen jobdays`i' = .
gen jobhours`i' = .
gen jobearning`i' = .

}

forval i = 1/6{
gen jobdesc`i'= ""
gen jobyears`i' = .
gen jobleft`i' = .
gen jobstart`i' = .
}

forval i = 1/3{
forval j = 1/3{
replace jobdesc`i' = b3occ_desc_`j' if jobso`i' == "b3occ_`j'"
replace jobdays`i' = b4days_`j' if jobso`i' == "b3occ_`j'"
replace jobhours`i' = b5hours_`j' if jobso`i' == "b3occ_`j'"
replace jobearning`i' = b6earning_`j' if jobso`i' == "b3occ_`j'"
replace jobyears`i' = b7years_`j' if jobso`i' == "b3occ_`j'"

}
}



/* Data cleaning - Former jobs 1 - 6 */ 


forval i = 1/6{

forval j = 1/6{
replace jobdesc`i' = b12pastocc_desc_`j'_BL if jobso`i' == "b12pastocc_o_`j'"
replace jobleft`i' = b13pastyearleft_`j'_BL if jobso`i' == "b12pastocc_o_`j'"
replace jobyears`i' = b14pasttotalyears_`j'_BL if jobso`i' == "b12pastocc_o_`j'"
replace jobstart`i' = jobleft`i' - jobyears`i'
	replace jobstart`i' = 2011 - jobyears`i' if jobstatus`i' == 1
}
}

forval i = 1/6{

tab jobleft`i'
tab jobyears`i'
 tab jobstart`i'
 }
 forval i = 1/3{ 
 tab jobdays`i'
 tab jobearning`i'
 tab jobhours`i'

}

gen totexp = 0
gen totexp_frac = 0

forval i = 1/6{
replace totexp = totexp + jobyears`i' if job`i' != .  & jobyears`i' != .
replace totexp_frac = totexp_frac + 1 if jobyears`i' == 0 & job`i' >100 & job`i' !=.
}
gen _totexp = totexp				
gen mis_totexp = totexp == .
recode _totexp . = 0


/* I assume a fraction is equivalent to 4 months of work. If so, one fraction rounds down, two rounds up.
3 rounds down, and 4 rounds down */
	replace _totexp = _totexp + 1 if totexp_frac == 2 | totexp_frac == 3 | totexp_frac == 4

// Address Outliers
list jobleft1 jobyears1 if totexp >=20

gen _totexp_max = max(jobyears1, jobyears2, jobyears3, jobyears4, jobyears5, jobyears6)
gen _totexp_miss = _totexp_max == .
replace _totexp_max = 0 if _totexp_max == .





/* Update years  - Make so years is at least 0.5 if zero */ 

forval i = 1/6{
replace jobyears`i' = .5 if jobyears`i' == 0 & job`i' != .
}





#delimit cr
end
