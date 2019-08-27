/* Jobsearch*/ 



* Clean variables 

forval i = 1/18{
tostring a8_wherespec_`i'_FUP,replace
replace a8_wherespec_`i'_FUP = "" if a8_wherespec_`i'_FUP == "."
list a8_where*`i'_FUP if a8_wherespec_`i'_FUP != "" 

replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "BINAN"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "CAVITE"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "BATAAN"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "MAKATI"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "QUEZON CITY"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "PASIG CITY"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "ILOCOS"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "PAMPANGA"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "LA UNION"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "MANILA"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "CAMIGUIN CAGAYAN DE ORO"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "DAVAO"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "ANTIPOLO RIZAL"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "ANTIPOLO"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "BATANGAS"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "LAGUNA"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "BACLARAN"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "PASIG"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "LAGUNA"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "TAGAYTAY"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "6 LAGUNA"
replace a8_where4_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "TONDO"


replace a8_where2_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "IROSIN"
replace a8_where2_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "GUBAT"

replace a8_where5_`i'_FUP = 1 if a8_wherespec_`i'_FUP == "ABROAD"

}





forval i = 1/18{			// Recode all don't knows as missing

forval j = 1/6{
recode a8_where`j'_`i'_FUP 2 = 0
recode a8_where`j'_`i'_FUP . = 0
recode a8_where`j'_`i'_FUP -2 = 0
recode a8_where`j'_`i'_FUP 88 = 0

replace a8_where`j'_`i'_FUP = . if a6_look_`i'_FUP == .

}
recode a9_apply_`i'_FUP -2 = 0
recode a9_apply_`i'_FUP . = 0 if a6_look_`i'_FUP == 0

recode a10_offer_`i'_FUP -2 = 0
recode a10_offer_`i'_FUP . = 0 if a6_look_`i'_FUP == 0

recode a11_hrs_`i'_FUP -2 = 0
recode a11_hrs_`i'_FUP 88 = 0
recode a11_hrs_`i'_FUP 99 = 0
recode a11_hrs_`i'_FUP 98 = 0
recode a11_hrs_`i'_FUP  . = 0 if a6_look_`i'_FUP == 0
}


forval j = 1/6{




forval i = 1/18{
recode a7_how`j'_`i'_FUP 3 = 0

recode a7_how`j'_`i'_FUP 2 = 0
recode a7_how`j'_`i'_FUP -2 = .
recode a7_how`j'_`i'_FUP 88 = .
recode a7_how`j'_`i'_FUP 4 = .

replace a7_how`j'_`i'_FUP = 0 if a6_look_`i'_FUP == 0

assert a7_how`j'_`i'_FUP == 0 | a7_how`j'_`i'_FUP == 1 |a7_how`j'_`i'_FUP  == .
}
}





* Generate monthly panel variables
local P1 "a6_look"		
local P2 "a9_apply"		
local P3 "a10_offer"	
local P4 "a11_hrs"
forval j = 5/10{
local k = `j'-4
local P`j' "a8_where`k'"
}
local P11 "a7_how1"
local P12 "a7_how2"


local O1 "look_any_"
local O2 "apply_"
local O3 "offer_"
local O4 "hrslook_"
local O5 "lookbulan_"
local O6 "looksor_"
local O7 "lookalbay_"
local O8 "lookmnl_"
local O9 "lookofw_"
local O10 "lookother_"

local O11 "lookfamfr_"
local O12 "lookapp_"

*** INSERT LABELS ****

forval i = 1/12{

gen `O`i''2_2012 = `P`i''_1_FUP
gen `O`i''1_2012 = `P`i''_2_FUP
gen `O`i''12_2011 = `P`i''_3_FUP
gen `O`i''11_2011 = `P`i''_4_FUP
gen `O`i''10_2011 = `P`i''_5_FUP
gen `O`i''9_2011 = `P`i''_6_FUP
gen `O`i''8_2011 = `P`i''_7_FUP
gen `O`i''7_2011 = `P`i''_8_FUP
gen `O`i''6_2011 = `P`i''_9_FUP
gen `O`i''5_2011 = `P`i''_10_FUP
gen `O`i''4_2011 = `P`i''_11_FUP
gen `O`i''3_2011 = `P`i''_12_FUP
gen `O`i''2_2011 = `P`i''_13_FUP
gen `O`i''1_2011 = `P`i''_14_FUP
gen `O`i''12_2010 = `P`i''_15_FUP
gen `O`i''11_2010 = `P`i''_16_FUP
gen `O`i''10_2010 = `P`i''_17_FUP
gen `O`i''9_2010 = `P`i''_18_FUP


}


** Missing location **

 gen missinglocation = 0
 forval i = 3/18{
 forval j = 1/6{
 replace missinglocation = 1 if a8_where`j'_`i'_FUP == .
 }
 }
 tab missinglocation
 
 
 
 
 
 * Look in April/May, 2011
 
 foreach var in _any bulan sor albay mnl ofw other famfr app{
di in red "round `var'"
gen look`var'_surv = 0
gen look`var'_aprmay2011 = 0
forval i = 4/12{
replace look`var'_surv = 1 if look`var'_`i'_2011 == 1 
}
replace look`var'_aprmay2011 = 1 if look`var'_4_2011 == 1 | look`var'_5_2011 == 1

replace look`var'_surv = 1 if look`var'_1_2012 == 1
replace look`var'_surv = . if missinglocation == 1
replace look`var'_aprmay2011 = . if missinglocation == 1
}

 
 * Look Local 
 forval i = 4/12{
gen looklocal_`i'_2011 = lookbulan_`i'_2011 == 1 | looksor_`i'_2011 == 1 | lookalbay_`i'_2011 == 1
replace looklocal_`i'_2011 = . if missinglocation == 1
}
gen looklocal_1_2012 = lookbulan_1_2012 == 1 | looksor_1_2012 == 1 | lookalbay_1_2012 == 1
replace looklocal_1_2012 = . if missinglocation == 1

 gen looklocal_aprmay2011 = lookbulan_aprmay2011 == 1 | looksor_aprmay2011 == 1 | lookalbay_aprmay2011 == 1
		replace looklocal_aprmay2011 = . if missinglocation == 1

 
 * Look by method in April/May, 2011
 
gen lookmnlfamfr_aprmay2011 = (lookmnl_4_2011 == 1 & lookfamfr_4_2011 == 1) | (lookmnl_5_2011 == 1 & lookfamfr_5_2011 == 1)
gen looklocalfamfr_aprmay2011 = (looklocal_4_2011 == 1 & lookfamfr_4_2011 == 1) | (looklocal_5_2011 == 1 & lookfamfr_5_2011 == 1)

gen lookmnlapp_aprmay2011 = (lookmnl_4_2011 == 1 & lookapp_4_2011 == 1) | (lookmnl_5_2011 == 1 & lookapp_5_2011 == 1)
gen looklocalapp_aprmay2011 = (looklocal_4_2011 == 1 & lookapp_4_2011 == 1) | (looklocal_5_2011 == 1 & lookapp_5_2011 == 1)

