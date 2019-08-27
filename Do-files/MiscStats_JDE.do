/* Miscellaneous Statistics 

		This section provides calculations of some of the statistics cited
			in the text that are not linked to the tables 
			
			*/ 
			
			
use "$work/$specdata",clear


/* Section 2.1, paragraph 2:
	Although 84 percent of respondents were working or had worked in the past, 
	51 percent of those with work experience had never submitted a resume nor interviewed for a job.
	*/ 
	
tab ever_emp if balance_fullpanel

gen formal_apply = b15resume_BL > 0 | b16interview_BL > 0
	replace formal_apply = . if b15resume_BL == 99 | b16interview == 99
tab formal_apply if ever_emp & balance_fullpanel



/* Section 2.2, paragraph 4
	"Nearly half (46 percent) of those who visited a recruitment agency booth visited the BPO firm. "
	Share of respondents that participated in fair who also visited BPO 
	Note: SL indicates BPO firm*/ 

	foreach firm in AT EQ FA GP SL{
	recode visit1`firm' . = 0
	}
 tab visit1SL if visit1AT | visit1EQ | visit1FA | visit1GP | visit1SL
 
 /* Section 2.2, paragraph 4
	Only 2 respondents report working as call center agends during time between job fair and endline survey. 
	No respondents report working in SEO or as copywriters
	*/ 
	
	
	* Cycle through four jobs listed, list those that are currently employed at job
forval i = 1/4{
list resid bgy if regex(jobname_`i',"CALL") & jobend_yy_`i' == 88
}


* Cycle through four jobs listed, list those that are currently employed at job
forval i = 1/4{
list resid bgy if regex(jobname_`i',"SEARCH") | regex(jobname_`i',"COPY") & jobend_yy_`i' == 88
}
	
/* Section 3.1, paragraph 1: 
	50 percent of respondents had worked in Manila in the past
	*/ 
	
	tab ever_mnl if mis_ever_mnl == 0 & balance_fullpanel
	
 /* Section 3.4, paragraph 3
	*/ 
	
tab attend1 if jollibee	
	


/* Section 3.6, paragraph 4 footnote
I explore this more specifically using results from a brief survey in May 2012 
with 102 randomly selected respondents, of whom 31 are voucher treatment group members. 
Fourteen out of the 31 respondents report receiving the voucher at the job fair, 
and no one traded or gave away the voucher

*/ 

tab raffle_survey			// 96 respondents

tab  jollibee respondent_type if raffle_survey == 3	// 31 jollibee respondents
tab e3_howused_RAF if jollibee & respondent_type == 1	// 14 


		
 /* Share of job-seekers that look informally (family and friends) vs. formally */ 
 
 tab lookfamfr_surv if look_any_surv & balance_fullpanel
  tab lookapp_surv if look_any_surv & balance_fullpanel
  
  exit
xi: ivreg2 lookmnlfamfr_aprmay2011 (attend1 = jollibee) wage occupation $cov1 i.p_g i.en_id_BL if balance_fullpanel,cluster(bgy)
xi: ivreg2 lookmnlapp_aprmay2011 (attend1 = jollibee) wage occupation $cov1 i.p_g i.en_id_BL if balance_fullpanel,cluster(bgy)



******************************************
*	Statistics based on other data sets
******************************************

/* Section 3.5, paragraph 1
	87% of those friends whom respondents see every day live within the same barangay, and 
		62% live within the same neighborhood */ 
#delimit ;		
use "$work/matched_jobfair5",clear;
keep resid bgy purok barangay friend*;
rename friend*_BL friend*;
foreach var in  last {;
forval i = 1/9{;
rename friend_`var'_0`i' friend_`var'_`i';
};
};
tostring  friend_purok*,replace;

reshape long 
	friend_first_ 	friend_last_ 	friend_brgy_ 	friend_purok_ 	friend_rel_ 	friend_textsent_
	friend_textrec_	friend_talk_	friend_visit_	friend_ofw_		friend_applyofw_
,i(resid) j(friend_id);

#delimit cr

drop if friend_first_ == ""

drop friend_first friend_last

*** See every day 

gen evday = friend_talk >= 7 & friend_talk != 99 & friend_talk != .

** Drop with missing barangay

drop if friend_brgy_ == "-2" | friend_brgy_ == "2" | friend_brgy_ == "99" | friend_brgy_ == "9999"

gen samebgy = barangay == friend_brgy

tab samebgy if evday



** Same purok

forval i = 1/9{
replace friend_purok = "`i'" if friend_purok == "0`i'"
}


**** Clean purok 
replace friend_purok = "" if friend_purok == "-2" | friend_purok == "-3" | friend_purok == "-4" | friend_purok == "-5" | friend_purok == "99"

** Quirino

replace friend_purok = "P1-P5" if friend_brgy == "QU" & (friend_purok == "1" | friend_purok == "2" | friend_purok == "3" | friend_purok ==  "4" | friend_purok == "5")
replace friend_purok = "P6-P7" if friend_brgy == "QU" & (friend_purok == "6" | friend_purok == "7" )
replace friend_purok = "P8-P9" if friend_brgy == "QU" & (friend_purok == "8" | friend_purok == "9" )


** Z2
replace friend_purok = "LUKBAN 2" if friend_purok == "LU2"
replace friend_purok = "LUKBAN 1" if friend_purok == "LU1"
		
		
		
gen samepurok = purok == friend_purok & barangay == friend_brgy 
	replace samepurok = . if friend_purok == ""
	
	
	
tab samepurok if ev & barangay != "Z2"		// Omit zone 2 because of lots of coding errors (purok missing)
	
	
	
		exit
	**************************************	
	* Following stats require identifiable datasets - available upon request
	/*
	**************************************
/* Section 3.3, paragraph 2
	Survey response rate of 53%
	*/ 
	
	
	use "$work/log_data_all",clear
		gen survey1 = _outcome == 1
			tab survey1
			
/* Section 3.4, paragraph 1
	Overall attendance was 767, and survey respondents made up 29 percent of all attendees */ 
	
	use "$work/name_match2",clear			/* Use cleaned sample */	/*  used to be $output/name_match2*/ 

	tab jf		// 770
	
	tab resp if jf	// 24.94  
	
/* Section 3.4, footnote
		56 percent of non-respondents hear about fair through radio advertisements, 17 percent through flier, and 25 percent through a friend 
		*/ 
		
	use "$work/jobfair1",clear	
		
	tab radio_ex if survres == 0
	tab flier_ex if survres == 0
	tab friend_ex if survres == 0
		
		
/* Section 3.4 paragraph 3 
	130 respondents (47%) redeemed vouchers at fair , 9 didn't redeem
*/ 

use "$work/matched_jobfair5",clear

gen jollibee = treatment == "A-Jol" | treatment == "Occ-Jol" | treatment == "Wage-Jol"
gen jv = jol_voucher != "" 
tab jv if jollibee

tab attend1 jv if jollibee



*/

		
