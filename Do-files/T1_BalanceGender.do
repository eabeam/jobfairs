*****************************************
* T1_BalanceGender.do
	*Table 1:		Balancing tests
	*Last Updated 16 May 2015	
	
	*Runs balance tests separately by gender

		
***************************************** 


#delimit ;
tempfile temp tempdata;

use "$work/$specdata",clear;


*Data statements: see specification_setup.do;
$keepstatement;


save `temp';


* Keep only necessary variables -- $covbal is covariates minus r_sex;
keep  r_sex $covbal _totexp wage jollibee occupation wageX occX men women
;

save `tempdata', replace;

*****************************
*	Compute summary means for tables
*****************************;

*Define subgroups;
local O1 "keep if jollibee == 0";	// All
local O2 "keep if jollibee == 0 & r_sex == 0"; // Men
local O3 "keep if jollibee == 0 & r_sex == 1";	// Women
local O4 "keep if jollibee == 1";	// All
local O5 "keep if jollibee == 1 & r_sex == 0"; // Men
local O6 "keep if jollibee == 1 & r_sex == 1";	// Women


local P1 "ctrl_all";
local P2 "ctrl_men";
local P3 "ctrl_women";

local P4 "jol_all";
local P5 "jol_men";
local P6 "jol_women";

* Loop over 6 subgroups;

forval i = 1/6{;
	
	*Loop over each covariate;
	foreach var in r_sex $covbal {;
		use `tempdata', clear;
	*Restrict data	based on subgroups (above);
			`O`i'';
	*Collapse means;
		collapse (mean) mean`P`i'' = `var' ;
	*Generate names	;
		gen str15 var = "`var'";
		
		tempfile temp`var';
		save `temp`var'' ;
	};


	
*Append variable means into one subgroup file;
use `tempr_sex', clear;

foreach var in $covbal {;
	append using `temp`var'';
	*order var;
	*list;	
	};
	egen id = seq();
	tempfile means_`P`i'';
	save  `means_`P`i''';
};

* Merge across all subgroups;
use `means_ctrl_all',clear;

forval i = 2/6{;
	di "merging with `P`i''";
	merge 1:1 id using `means_`P`i''';
		assert _merge == 3;
		drop _merge;
};

drop id; 
*Output Balance Means;
outsheet using "$output/T1_balancegender $ST.xls",replace;


*****************************
*	Compute p-values for balance tests
*****************************;


*Define three specifications - all, men, women;
local O1 "";
local O2 "if r_sex == 0";
local O3 "if r_sex ==1";

local OO1 "all";
local OO2 "men";
local OO3 "women";

* Loop over three specifications;
forval i = 1/3{;

	use `temp',clear   ;

	foreach var in r_sex $covbal  {;

		reg `var' jollibee $pweight `O`i'',cluster(bgy);
			testparm jollibee;
			gen pval_`var' = `r(p)';
		};

collapse (mean) pval*;

xpose,varname clear ;
rename v1 men;
tempfile fpvalues_`OO`i'';
save `fpvalues_`OO`i''',replace;
};


	
	
*Append p-values;
use `fpvalues_all',clear;
egen id = seq();
append using `fpvalues_men';
append using `fpvalues_women';

sort id;
outsheet  using "$output/T1_pvaluesgender_$ST.xls",replace;


*****************************
*	Check overall balance
*****************************;


use `temp',clear; 

*All;
xi: reg jollibee r_sex $covbal  ,cluster(bgy);    
testparm r_sex $covbal;

*Men;
xi: reg jollibee r_sex $covbal  if r_sex == 0,cluster(bgy);    
testparm r_sex $covbal;

*Women;
xi: reg jollibee r_sex $covbal if r_sex  == 1,cluster(bgy) ;    
testparm r_sex $covbal;

* Gen sample sizes;
tab jollibee ;
tab jollibee r_sex;

exit;
