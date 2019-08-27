/* This file uses bulandata_public and creates relevant variables needed for analysis


Required packages:
	vincenty: calculation of distances using GPS coordinates

	Last updated 15 May 2015 by Emily Beam*/ 


use "$work/bulandata_public",clear



******************************************************************************************
*		Preliminary Data Cleaning
******************************************************************************************

*do "$dofiles/jobsearch1.do"

do "$dofiles/calc_experience.do" 		// Generates _totexp
calc_experience						// Calculate work experience
do "$dofiles/jobsearch1.do"
***********************************
// Generate Work Experience
***********************************
/*tostring b3occ_desc_o*,replace

recode b14pasttotalyears_1_BL 90 = 9

forval i = 1/4{
replace b3occ_o_`i' = . if b3occ_o_`i' == 999 & (b3occ_desc_o_`i' == "9999" | b3occ_desc_o_`i' == "")
replace b3occ_desc_o_`i' = "" if b3occ_desc_o_`i' == "9999"
recode b4days_o_`i' 99 = .
	replace b4days_o_`i' = . if b3occ_o_`i' == .
recode b5hours_o_`i' 99 = .
	replace b5hours_o_`i' = . if b3occ_o_`i' == .
recode b6earning_o_`i' 9999 = .
	replace b6earning_o_`i' = . if b3occ_o_`i' == . & b3occ_desc_o_`i' == ""
recode b7years_o_`i' 99=.
	replace b7years_o_`i' = . if b3occ_o_`i' == .
}


*/

*calc_experience


/*
tokenize `"bday_yyyy bday_dd bday_mm"'
while "`1'" != ""{
gen r`1'_fup = .

forval i = 1/10{
replace r`1'_fup = `1'_`i'_FUP if s4_pid_FUP == `i'

}
macro shift
}
*/
******************************************************************************************
*		Generate Treatment Variables 
******************************************************************************************
gen jollibee = treatment == "A-Jol" | treatment == "Occ-Jol" | treatment == "Wage-Jol"
gen occupation = treatment == "Occ" | treatment == "Occ-Jol"
gen wage = treatment == "Wage" | treatment == "Wage-Jol"
gen control = treatment == "A-Jol" | treatment == "Control"

gen wageXjollibee = wage*jollibee
gen occXjollibee = occupation*jollibee


******************************************************************************************
*		Generate Covariates 
******************************************************************************************
*global cov1 "r_sex r_age r_married  hsplus colgrad _curremp _currpass ever_mnl ever_emp _f8o stronginterest  
*		_totexp income _c12 ofwsearch_base anyfam_ofw  dist_ind mis_currpass mis_f8o";

**
*Respondent gender		r_sex
**
assert r_sex != .
sum r_sex

gen men = r_sex == 0
gen women = r_sex == 1
gen all	 = 1
		* Missing flag:	r_sex
		gen mis_r_sex = r_sex == .
**
*Respondent age			r_age
**
assert r_age != .
sum r_age 

		* Missing flag:	r_age
		gen mis_r_age = r_age == .
		
**
*Respondent married		r_married
**
tab a3mar
gen r_married = a3mar == 1 | a3mar == 2		// Married or "domestic partners"

		* Missing flag:	r_married
		gen mis_r_married = a3mar == 99 | a3mar == .

**
*Respondent education	hsplus colgrad
**
tab r_ed,mi

gen hsplus = r_ed >= 10 & r_ed != .

gen colgrad = r_ed == 15


	* Missing flag:	r_ed
		gen mis_r_ed = r_ed == .
		
**
*Respondent current employment status	_curremp
**
tab jobstatus1,mi						// 0 = never employed , 1 = currently employed, 2 = past employed
gen _curremp = jobstatus1 == 1			// 13 May - jobstatus1 undefined

		* Missing flag:	_curremp
		gen mis__curremp = jobstatus1 == .
		***** FLAG HERE - NOT CORRECT	*****
		
**		
*Respondent currently has passport	_currpass
**
tab d11validpass,mi
gen _currpass = d11validpass == 1


		* Missing flag: _currpass 
			gen mis__currpass = d11validpass == 9 

**
*Respondent ever worked in Manila	ever_mnl
**
tab r_mnl,mi							// 1 = currently in manila, 2 = ever in manila, 3 = never in manila, . = missing
gen ever_mnl = r_mnl == 2


		* Missing flag: r_mnl 
			gen mis_ever_mnl = r_mnl == .		// High incidence of missing because not asked in all survey versions

**
*Respondent ever employed	ever_emp
**
gen ever_emp = b2work_past == 1
	replace ever_emp = 1 if _curremp == 1 
	replace ever_emp = 1 if b12pastocc_o_1_BL != . 
	
	replace ever_emp = 0 if _curremp == 0 & b11 == 0 &   b12pastocc_o_1_BL  == .
	replace ever_emp = 0 if _curremp == 0 & jobstatus1 == 0 & jobstatus2 == 0 & jobstatus3 == 0 &  b12pastocc_o_1_BL  == .
	
	
	
		* Missing flag: ever_emp 
			**** FLAG HERE gen mis_r_mnl = d11validpass == 9 
			gen mis_ever_emp = ever_emp == .

**			
*Likelihood offered work abroad, if applied (baseline)	_f8o
**
tab f8offerjob_BL,mi
assert f8offerjob_BL !=.

gen _f8omeasure = f8offerjob_BL 
	replace _f8omeasure = 0 if f8offerjob_BL  < 0
	replace _f8omeasure = _f8omeasure/100
		* Missing _f8o flag
			gen mis__f8omeasure = f8offerjob_BL  < 0

**
*Strong interest in working abroad	stronginterest
**
tab c1interest
gen stronginterest = c1interest == 1
		
		
		* Missing flag: stronginterest 
			gen mis_stronginterest = c1interest == 9
			
**			
*Total years experience		_totexp
**
sum _totexp
		* Missing flag: _totexx 
			gen mis__totexp = _totexp == .

**		
*Monthly HH income			income
**
assert a12income_lm_BL != .

gen income = a12income_lm_BL 
	replace income = . if a12income_lm_BL < 0 | a12income_lm_BL == 9999

	replace income = income/1000
	replace income = 40 if income > 40	& income != .		// trimming
	
*Impute income	
egen medincome = median(income),by(bgy)
replace income = medincome if income == .	
	drop medincome
	
	*Missing flag: income
	gen mis_income = a12income_lm_BL < 0 | a12income_lm_BL == 9999

**	
*Plan to apply for work abroad in next 5 years _c12
**
gen _c12plan = c12plan == 1

	*Missing flag:		_c12plan 
	gen mis__c12plan = c12plan == 9

**	
*Ever looked for work abroad	ofwsearch_base
**
gen ofwsearch_base = 0
gen mis_csum = 0


	/* Clean BL search variables */ 

	foreach var in c2visitra c4internet c5friendapply c6jobfair_ever  c9applyother {
	
	gen _`var' = `var'_BL
		recode _`var' 2 = 0 
		
		}
	gen _c10applyother_spec = c10applyother_spec_BL
	
		/* Clean "Other" search methods */ 
				
			replace c10 = "" if c9 == 0 & c10 == "9999" 
			
			replace _c2visitra  = 1 if regex(_c10applyother_spec,"AGENCY") |  regex(_c10applyother_spec,"WALK") 
				replace _c9 = 0 if regex(_c10applyother_spec,"AGENCY") |  regex(_c10applyother_spec,"WALK") 
				replace _c10applyother_spec = "" if regex(c10applyother_spec,"AGENCY") |  regex(_c10applyother_spec,"WALK") 
		
			replace _c5friendapply = 1 if regex(c10applyother_spec,"FRIEND") | regex(c10applyother_spec,"RELATIVE") 
				replace _c9 = 0 if regex(c10applyother_spec,"FRIEND")| regex(c10applyother_spec,"RELATIVE") 
				replace _c10applyother_spec = "" if regex(_c10applyother_spec,"FRIEND")| regex(_c10applyother_spec,"RELATIVE") 
	
			replace _c4internet = 1 if regex(_c10applyother_spec,"INTERNET") 
				replace _c9 = 0 if _c10applyother_spec == "INTERNET"
				replace _c10applyother_spec = "" if c10 == "INTERNET" 
				replace _c10applyother_spec = "PESO BULAN" if c10 == "INTERNET/PESO BULAN"
	
	*Attended job fair ever = 1 if attended job in last 12 months == 1
	replace _c6 = 1 if c7 > 1 & c7 <=10

foreach var in c2visitra c4internet c5friendapply c6jobfair_ever  c9applyother{
	gen mis_`var' = `var' == 9 | `var' == .
		recode _`var' 9 = 0
		recode _`var' . = 0
	replace ofwsearch_base = 1 if _`var' == 1
	replace mis_csum = mis_csum + 1 if mis_`var' == 1
	drop mis_`var'
		}

		*Missing flag: ofwsearch_base
			gen mis_ofwsearch_base = mis_csum == 5			// Only one missing all values.  Interpret the others as straight zeros. 
				drop mis_csum	
		
**
*Any family members ever worked abraod		anyfam_ofw
**
	gen anyfam_ofw = e8_famofw > 0
	
			*Missing flag: anyfam_ofw
		*PUT HERE
		*
			gen mis_anyfam_ofw = anyfam_ofw == .
			
**			
*Distance from job fair						dist_ind
**
sum dist_ind			// Calculated in pre-replication files to protect confidentiality
						// When dist_ind missing, imputed based on barangay average distance

		*Missing flag: dist_ind
			gen mis_dist_ind = dist_ind == .		
		

******************************************************************************************
*		Generate balance - nonmissing
******************************************************************************************

* Note non-essential with missing flags
	tab mis__c12
	tab mis__currpass
	tab mis__f8o
	tab mis_income
	*tab mis_r_ed
	tab mis_ever_mnl
*Determine balance equal to 1 if non-missing values for essential variables
#delimit ;
gen balance = 1;
tokenize `"	r_sex 	r_age 	r_married	r_ed	_curremp		ever_emp		
			stronginterest	_totexp		ofwsearch_base	anyfam_ofw  	dist_ind"';

while "`1'"!=""{;
replace balance = 0 if mis_`1' == 1;
macro shift;
};

tab balance;
outsheet resid  pid r_sex 	r_age 	r_married	r_ed	_curremp		ever_emp		
			stronginterest	_totexp	 	ofwsearch_base 			
			anyfam_ofw  	dist_ind mis_* if balance == 0 using "$output/no_balance_`c(current_date)'.xls",replace;

*exit; 

#delimit cr
******************************************************************************************
*		Generate Outcome variables 
******************************************************************************************

***** Table 2: First Stage *****

gen apply = r_any
	replace apply = 0 if apply == .


gen  participate = apply
	replace participate = 1 if p_visit == 1 
	replace participate = 1 if p_any1 == 1 
	
gen prescreen = fa_hire == 1 | sl_hire == 1 | ath_hire == 1 | ls_hire == 1 | gp_hire == 1 | eq_hire == 1	
	
	
replace apply = 1 if prescreen == 1 
replace participate = 1 if prescreen == 1


***  Table 3: Job Search
	// From jobsearch1.do
sum look_any_aprmay2011
sum looklocal_aprmay2011
sum lookmnl_aprmay2011

gen offermnl_surv = 0
gen offerlocal_surv = 0
gen lookmnlfamfr_surv = 0
gen looklocalfamfr_surv = 0
gen lookmnlapp_surv = 0
gen looklocalapp_surv = 0
foreach x in mnl local{
forval j = 4/12{
replace offer`x'_surv = offer`x'_surv + 1 if look`x'_`j'_2011 == 1 & offer_`j'_2011 == 1
replace look`x'famfr_surv = 1 if look`x'_`j'_2011 == 1 & lookfamfr_`j'_2011 == 1
replace look`x'app_surv = 1 if look`x'_`j'_2011 == 1 & lookapp_`j'_2011 == 1

}

replace offer`x'_surv = offer`x'_surv + 1 if look`x'_1_2012== 1 & offer_1_2012 == 1
gen offer`x'any_surv = offer`x'_surv >=1
}
gen offerany_surv = offermnl_s + offerlocal_s

foreach var in any mnl local{
gen b_offer`var'_surv = offer`var'_surv>0
}


*** Table 4: Employment

/* Generate binary variables*/
gen rwork_fup = rworkstat_fup != 5
gen rformal_fup = rworkstat_fup == 1
gen rinformal_fup = rworkstat_fup == 2
gen rselffarm_fup = rworkstat_fup == 3 | rworkstat_fup == 4


	tokenize `" work formal informal selffarm  "'
	while "`1'" != ""{
	replace r`1'_fup = . if rworkstat_fup == . | rworkstat_fup == -2
	macro shift
	
	}
*** Table 5:  Labor market perceptions, migration


/* Generate fuph4_offer */ 

gen fuph4_offer = h4_offer_FUP
		recode fuph4_offer 888 = .
		recode fuph4_offer -2 = .
		replace fuph4_offer = fuph4_offer/100
/* Generate fuph5_deploy */ 

gen fuph5_deploy = h5_deploy_FUP
		recode fuph5_deploy 888 = .
		recode fuph5_deploy -2 = .
		replace fuph5_deploy = fuph5_deploy/100
/* Generate _e11 */ 


gen _e11 = e11_likewage_FUP
		recode _e11 -2 = .
		recode _e11 -1 = .
		recode _e11 8888 = .
	replace _e11 = _e11/1000

/* Generate _e10 */ 
	
gen _e10 = e10_minwag_FUP 
		replace _e10 = . if e10_min < 0
		replace _e10 = _e10/1000

*replace _e11 = . if _e10 == .		// 1 change
*replace _e10 = . if _e11 == .		// 9 changes

/* Generate strong_fup */ 

gen strong_fup = e1_interest_FUP == 1 
		replace strong_fup = . if e1_interest_FUP == . | e1_interest_FUP == 88

*** Table 6: Migration steps


/* Generate lookofw_surv */ 
	// From jobsearch1.do

	sum lookofw_surv
	************************
************************
/* Generate planofw_6mo  */


*Respondent
gen _planofw6mo = 0
*Loop over family members
		forval i = 1/10{
*Loop over methods of search
		forval j = 1/9{
		replace _planofw6mo = 1 if b3b_steps_ofw_who`i'_`j'_FUP == 1 & pid == `i'
		}
		}
	
************************
************************
/* Generate pass_fup */ 

gen pass_fup = e13_passcurr == 1
	replace pass_fup = . if e13_passcurr == -2

	
******************************************************************************************
*	Generate baseline covariates for T5_Beliefs only
******************************************************************************************
* Note that missing values are not recoded to zeros (to be consistent with change in beliefs table)

/* Generate _f9 */ 
gen _f9measure = f9g
	replace _f9measure = . if f9g < 0
	replace _f9measure = _f9measure/100
	
	*gen flag_f9 = _f9measure == .
	*	recode _f9measure . = 0

/* Generate _c15 */
	gen _c15 = c15s/1000
		replace _c15 = . if _c15 == 0
		replace _c15 = 100 if _c15 >100 & _c15 != . 
		replace _c15 = . if c15s < 0 | c15s == 9999
		
	*gen flag_c15 = _c15 == .
	*	recode _c15 . = 0
		
/* Generate _c14 */
	gen _c14 = c14s/1000
		replace _c14 = . if _c14 == 0
		replace _c14 = 100 if _c14 >100 & _c14 != .
		replace _c14 = . if c14s < 0 | c14s == 9999
	
	*gen flag_c14 = _c14 == .
	*	recode _c14 . = 0
		

******************************************************************************************
*		Generate balance_panel and balance_fullpanel
******************************************************************************************

	gen balance_panel = balance == 1 & full_FUP != . & rformal_f != . & lookmnl_aprmay2 != .
		replace balance_panel = 0 if look_any_aprmay2011 == .
		replace balance_panel = 0 if rwork_fup == .

	gen balance_fullpanel = balance_panel == 1 & full_FUP == 1
		replace balance_fullpanel = 0 if fuph4_offer == . | fuph5_deploy == . | strong_fup == . 
	

	gen balance_voucheronly = balance_fullpanel
		replace balance_voucheronly = 0 if occupation == 1 | wage == 1
*****************************************************************************************
*		Baseline
*****************************************************************************************


*use "$work/matched_jobfair_eb" ,clear


forval i = 1/8{
replace d1salary_`i' = . if d1salary_`i' <=0 | d1salary_`i' == 9999 | d1salary_`i' == 999999
replace d2qualified_`i' = . if d2qualified_`i' <1 | d2qualified_`i' > 5
replace d3ed_`i' = . if d3ed_`i' < 1 | d3ed_`i' >5
replace d4exp_`i' = 2 if d4exp_`i' == 0
replace d4exp_`i' = . if d4exp_`i' < 1 | d4exp_`i' >2
replace d5yrsexp_`i' = 0 if d4exp_`i' == 2
replace d5yrsexp_`i' = . if d5yrsexp_`i' < 0 | d5yrsexp_`i' == 9 | d5yrsexp_`i' == 99
}
local m "3"
local n "4"

foreach j in new exp{
forval i = 1/9{

replace d1`m'salary_`j'_`i' = . if d1`m'salary_`j'_`i' < 0 | d1`m'salary_`j'_`i' == 9999 | d1`m'salary_`j'_`i' == 999999
replace d1`n'jobs_`j'_`i' = . if d1`n'jobs_`j'_`i' < 0 | d1`n'jobs_`j'_`i' == 99 | d1`n'jobs_`j'_`i' == 999
}
local m "5"
local n "6"
}




gen ch_own = 0
forval i = 1/8{
replace ch_own = ch_own + 1 if chres_`i'_BL == 1
}

gen ch_any = ch_own > 0
/*

gen edcat = .
replace edcat = 0 if r_ed <10
replace edcat = 1 if r_ed == 10
replace edcat = 2 if r_ed >=11 & r_ed <=14
replace edcat = 3 if r_ed == 15
replace edcat = 4 if r_ed > 15





gen interested = c1interest == 1 | c1interest == 2
	*replace interested = . if c1interest == 0 | c1interest == 9
	*replace strong = . if c1interest == 0 | c1interest == 9
	
	
	
	*/
	
*****************************************************************************************
*		Endline
*****************************************************************************************

		


*calc_experience		/* Runs do "$table_select/calc_experience.do" program */ 

				/* Calc-experience generates some income variables, also alwayspass?!? */ 


/* Income */
/*
gen hhincome_fup = d2_income_hh_FUP
gen indincome_fup = d1_income_resp

foreach var of varlist hhincome_fup indincome_fup{
recode `var' -2 = .
recode `var' 888888 = .
recode `var' 8888 = .
recode `var' -1 = .

replace `var' = 60000 if `var' > 60000 & `var' != . // Topcoding
}
replace hhincome_fup = hhincome_fup/1000
replace indincome_fup = indincome_fup/1000
*/
/*
replace indincome_base = indincome_base/1000
gen hhincome_dif = hhincome_fup - income
gen indincome_dif = indincome_fup-indincome_base

gen indincome_difz = indincome_dif
replace indincome_difz = indincome_fup if indincome_base == .
*/

*gen neverwork_fup = a0_nojob == 1



/*

gen likely_ofwfup = e11_like
recode likely_ofwfup 888888 = .
recode likely_ofwfup -2 = .
replace likely_ofwfup = 100000 if likely_ofwfup > 100000 & likely_ofwfup != .
replace likely_ofwfup = likely_ofwfup/1000

gen likelysalofw_dif = likely_ofwfup - _c15
*/
/* Generate respondent outcome variables */

/* Variables: 
	hhenroll_`i'fup
	hhed_`i'fup
	hhworkstat_`i'fup
	hhlook_`i'fup
	hhavail_`i'fup
	hhcurr_`i'fup
	hhofw_`i'fup
	hh_mnl_`i'fup
	*/

/*
tokenize `"_first _middle _last _suffix"'
while "`1'" != ""{
gen r`1'_fup = ""
forval i = 1/10{
qui tostring hh`1'_`i'_FUP,replace
replace r`1'_fup = hh`1'_`i'_FUP if s4_pid_FUP == `i'

}
macro shift
}
*/






*list full_FUP resid  r_sex s4_pidFUP r_first_fup r_last_fup rsex_fup  if r_sex != rsex_fup & full_FUP != .

recode e2_ra -2 = .
recode e2_ra 4 = .
recode e2_ra 88 = .
recode e2_ra 2 = 0

recode e4_app -2 = .
recode e4_app 88 = .
recode e4_app 2 = 0


/*
gen _a18renroll = a18_enr == 1
replace _a18renroll = . if a18_enr == . | a18_enr == 88


gen _a18currenroll = a20c_start_yyyy_1 == 2011 | a20c_start_yyyy_2 == 2012
replace _a18currenroll = . if a18_enr == . | a18_enr == 88

gen _a19plan = a19_e == 1
replace _a19plan = . if a19_e == . | a19_e == 88

gen _a19plan2012 = a19_e == 1 & a20c_start_yyyy_1 == 2012
replace _a19plan2012 = . if a19_e == . | a19_e == 88
*/
/*
forval i = 1/9{
rename a6_look_0`i'fup a6_look_`i'fup
}*/

/*
gen anylook_fup = 0 if full_FUP != .
gen anylook_mo = 0 if full_FUP != .
gen anylook8mo_fup = 0 if full_FUP != .
gen anylook8mo_mofup = 0 if full_FUP != .

forval i = 1/18{
gen a6_look_`i'fup = a6_look_`i'_FUP
recode a6_look_`i'fup 22 = 2
recode a6_look_`i'fup 2 = 0
recode a6_look_`i'fup 3 = 0

recode a6_look_`i'fup -2 = .
recode a6_look_`i'fup 88 = .
assert a6_look_`i'fup == 1 | a6_look_`i'fup == 0 | a6_look_`i'fup == .

replace anylook_fup = 1 if a6_look_`i'fup == 1
replace anylook_mo = anylook_mo + 1 if a6_look_`i'fup == 1

}


forval i = 3/11{
replace anylook8mo_fup = 1 if a6_look_`i'fup == 1
replace anylook8mo_mofup = anylook8mo_mofup + 1 if a6_look_`i'fup == 1
}



	*/

********************************************
	
	/* Change in beliefs */
********************************************


gen ch_offer = fuph4_offer - _f8o		// Change likelihood offered job if applied
	replace ch_offer = . if mis__f8omeasure

gen ch_deploy = fuph5_deploy - _f9			// Change likelihood deploy if offered
	
gen ch_likewage = _e11 - _c15
	
gen ch_minwage = _e10 - _c14



gen newpass_fup = e13_passcurr == 1 & _currpass == 0

	

gen minofw_fup = e10_m
recode minofw_fup 888888 = .
recode minofw_fup -2 = .
recode minofw_fup 0 = .

replace minofw_fup = minofw_fup/1000
*gen minofw_dif = minofw_fup - _c14

*xi: reg minofw_dif jollibee wage occupation i.p_g [pw=sampwgt],cluster(bgy)




tokenize `"mnl ofw"'
while "`1'" != ""{
gen r`1'curr_fup = r`1'_fup == 1
	replace r`1'curr_fup = . if (r`1'_fup == -2 | r`1'_fup == 88)
gen r`1'past_fup = r`1'_fup == 2
	replace r`1'past_fup = . if (r`1'_fup == -2 | r`1'_fup == 88)
gen r`1'never_fup = r`1'_fup == 3
	replace r`1'never_fup = . if (r`1'_fup == -2 | r`1'_fup == 88)
macro shift

}

gen rmnlmigfirst_fup = 1 if r_mnl == 3 & rmnlcurr_fup == 1
	replace rmnlmigfirst_fup = 0 if r_mnl == 3 & rmnlcurr_fup == 0

tokenize `"enroll avail curr look"'
while "`1'" != ""{
recode r`1'_fup 88 = .
recode r`1'_fup 2 = 0
recode r`1'_fup -2 = .
macro shift
}


gen renrollnew_fup = renroll_fup == 1 & r_enroll == 0
	
*gen rempnew_fup = _curremp == 0 & rcurremp_fup == 1

replace rmnlcurr = 0 if resid == 19 & full_FUP == 1			// Change to not in manila because full survey completed
#delimit ;
/*
gen _e11 = e11_like;
recode _e11 -2 = .;
recode _e11 -1 = .;
recode _e11 8888 = .;
replace _e11 = _e11/1000;
gen _e10 = e10_min;
replace _e10 = . if e10_min < 0;
replace _e10 = _e10/1000;
gen strong_fup = e1_interest_FUP == 1 ;
replace strong_fup = . if e1_interest_FUP == . | e1_interest_FUP == 88;

gen interest_fup = e1_interest_FUP == 1 | e1_interest_FUP == 2;
replace interest_fup = . if e1_interest_FUP == . | e1_interest_FUP == 88;

gen indexq_womenfup = (f2qualified_1 + f2qualified_2 + f2qualified_5 + f2qualified_6)/4 if r_sex == 1;
gen indexq_menfup = (f2qualified_3 + f2qualified_4 + f2qualified_5 + f2qualified_6)/4 if r_sex == 0;

gen maxindexqfup= max(f2qualified_1, f2qualified_2, f2qualified_3, f2qualified_4, f2qualified_5, f2qualified_6);

*/
gen rmnlever_fup = rmnl_fup == 1 | rmnl_fup == 2 | r_mnl == 2 | r_mnl == 1;
	replace rmnlever_fup = . if (rmnl_fup == -2 | rmnl_fup == 88 | rmnl_fup == .) & r_mnl == 3;
#delimit cr

/*
gen _f8omeasure = f8o
	replace _f8omeasure = 0 if f8o < 0
	replace _f8omeasure = 0 if _f8omeasure == .
	
gen f8miss = f8o < 0
	replace f8miss = 1 if f8o == .

gen _f9measure = f9g
	replace _f9measure = 0 if f9g < 0
	replace _f9measure = 0 if f9g == .
	
replace f9miss = 1 if f9g < 0 | f9g == .

*/


****************
*	Additional outcome variables ******
*		02 July 2014 
*		Migration ******'
****************

* e2_rafup		0/1  3 missing
* e4_app_internet 0/2	
* e5_app_famfr
* e6_app_jf (exclude)
* e7_app_jf12mo (exclude)
* e8_app_oth
gen ofwsearch_missing = 1
gen ofwsearch = 0

foreach var in e2_ra_FUP e4_app_internet e5_app_famfr e8_app_oth{

recode `var' -2 = .
recode `var' 2 = 0
recode `var' 88 = .
	replace ofwsearch = 1 if `var' == 1
	replace ofwsearch_missing = 0 if `var' != .
	}
	
	#delimit ;
gen ofwsearch_any = ofwsearch == 1 | c7_jobfair_12mo == 1;
replace ofwsearch_any = . if ofwsearch == .;
replace newpass = . if e13_p == .;
gen newra = e2_ra == 1 & c2visitra == 2;
	 replace newra = . if e2_ra == . & c2visitra == 1;

	 
foreach val in bulan phil {;
gen plan`val'_6mo = b2_plan_`val'_FUP == 1;
	replace plan`val'_6mo = . if b2_plan_`val'_FUP == .;

	};
	/*
gen planenroll_6mo = a19_enroll_plan == 1;
	replace planenroll_6mo = . if a19_enroll_plan == . | a19_enroll_plan == 88;
	
/*gen searchplan_ofw = planofw_6mo == 1 | lookofw_surv == 1;
gen searchplan_mnl = planphil_6mo == 1 | lookmnl_surv == 1;
gen searchplan_bulan = planbulan_6mo == 1 | looklocal_surv == 1;
*/;


gen enrollplan_base = a8enroll == 1;

gen enrollorplan = planenroll_6mo == 1 | _a18r == 1;
*	egen qualcat2 = cut(mineduexp_share_sum_2d), group(3);
*		egen qualcat3 = cut(mineduexp_share_sum_3d), group(3);
	*/
	
	/*****************
	Interaction terms */;
	
foreach covlist of varlist $cov1  {;
			gen r_sexX`covlist' = r_sex*`covlist';
		};
	drop r_sexXr_sex;
	gen attendX = attend1 * r_sex;
	gen jolsexX = r_sex*jollibee;
	gen occsexX = r_sex*occupation;
	gen wagesexX = r_sex*wage;

*	foreach covlist of varlist _f9 _c15 _c14 flag_f9 flag_c15 flag_c14 {;
	foreach covlist of varlist _f9 _c15 _c14  {;

	gen __r_sexX`covlist' = r_sex*`covlist';
	};

	
	
	
	******************************************
	******************************************;
	#delimit cr
	
	rename attrition rattrition_fup
rename refused rrefused_fup
gen rproxy_fup = rproxy__FUP
replace rproxy_fup = . if rattrition_fup == 1
gen rproxy_mis = rproxy_fup == .

gen curr_manila = .
	replace curr_manila = 1 if rmnlcurr_fup == 1
	replace curr_manila = 0 if rmnlcurr_fup == 0
	replace curr_manila = 1 if outcome == "RESPONDENT IS IN MANILA"
	replace curr_manila = 0 if outcome == "REFUSED"
	replace curr_manila = 0 if outcome == "RESPONDENT IS IN ANOTHER PLACE WITHIN BULAN; Unlocated."
	replace curr_manila = 1 if notes == "Refused, household don't cooperate, Respondent is in  Manila."
	replace curr_manila = 1 if notes == "Respondent is in Manila, will back on Sunday; refused due to time consuming."
	replace curr_manila = 1 if notes == "Other factors prevented survey. Migrated in Manila together with family."
	replace curr_manila = 1 if notes == "No one at home (return); Respondent went to Manila, wife went to Masbate; Respondent is in Antipolo Rizal, CP # 09102323223, sister's cp # 09382701682."

gen curr_away = curr_manila
	replace curr_away = 1 if outcome_code == 10
	replace curr_away = 1 if notes == "Other factors prevented survey; Respondent transferred in Legaspi."
	replace curr_away = 1 if rcurr_fup == 0
	
	
	rename curr_manila rcurr_manila_fup
	rename curr_away rcurr_away_fup


	
	save "$work/bulan_public_var",replace
	
