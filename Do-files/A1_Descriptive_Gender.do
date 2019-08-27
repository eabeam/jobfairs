*****************************************
* A1_Descriptive_Gender.do
	*Table A1:		Descriptive Statistics
	*Last Updated 18 May 2015	
	
	*Runs descriptive statisitcs - mean & sd - separately by gender

		
***************************************** 

#delimit;

tempfile temp tempdata;

use "$work/$specdata",clear;


*Data statements: see specification_setup.do;

$keepstatement;

save `temp',replace;

tab r_sex;


keep r_sex $covbal wage jollibee occupation wageX occX men women;

save `tempdata', replace;

*****************************
*	Compute summary means for tables
*****************************;


*Define subgroups;
local O1 "";					// All
local O2 "keep if r_sex == 0"; 	// Men
local O3 "keep if  r_sex == 1";	// Women

local P1 "all";
local P2 "men";
local P3 "women";

* Loop over 3 subgroups;

forval i = 1/3{;
	*Loop over each covariate;

	foreach var in r_sex $covbal {;
		use `tempdata', clear;
	*Restrict data	based on subgroups (above);
		`O`i'';
	* Collapse means & sd;
		collapse (mean) mean`P`i'' = `var' (sd) sd`P`i'' = `var' ;
	* Generate names;	
			gen str15 var = "`var'";
	
	tempfile temp`var';
	save `temp`var'', replace ;
};

use `tempr_sex', clear;
foreach var in $covbal {;
	append using `temp`var'';
	};
	egen id = seq();
	
	tempfile means_`P`i'';
	save  `means_`P`i''';
};


*Merge across all subgroups;



use `means_all';
forval i = 2/3{;
	merge 1:1 id using `means_`P`i''';
		assert _merge == 3;
		drop _merge;
};

drop id; 
*Output Balance Means;

outsheet var meanall sdall meanmen sdmen meanwomen sdwomen using "$output/A1_Descriptive_Gender_$ST.xls",replace;

 

exit;

