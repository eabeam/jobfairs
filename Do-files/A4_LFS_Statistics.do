 
*****************************************
* A4_LFS_Statistics.do
	*Table A4: Descriptive statistics, Bulan sample vs. representative Bicol region (2011 LFS) 
	
	*Last Updated 18 May 2015	
	
	*Comparative descriptive statistics of Bulan sample and LFS sample

		
***************************************** 


#delimit;

tempfile temp tempgender tempmerge temp_bulan tempgender_bulan;

***************************************** 
*	LFS data
*****************************************; 


*Use LFS data - bicol region;
use "$work/LFS_cleaned_region5",clear;


* Age restriction: 20-35;
keep if c07_age_ >=20 & c07_age_<=35;



* No overseas workers;
keep if c10_ == 5	;

sum;

**********
** Generate comparable variables	**
**********;

* Gender;
gen r_sex = c06_sex == 2 ;

* Age;
gen r_age = c07_age;

* Married;
gen r_married = c08_m == 2;

* HS or greater, college;

gen hsplus = _c09 >=4;
gen colgrad = _c09 >=6 & _c09 != .;



* Employed (without availability criterion) ;
gen _curremp = cempst1 == 1;

* Urban ;
gen urban = urb2k70 == 1;

*Wages;
 gen dailywage_nz = c27_pbsc; //(pre calculated) ;


save `temp';	
collapse (mean) r_age r_married urban hsplus  colgrad _curremp dailywage_nz  (count) n = reg,by(r_sex);
xpose,varname clear;
rename v1 male_LFS;
rename v2 female_LFS;



save `tempgender';

use `temp',clear;
	
collapse (mean) r_sex r_age r_married urban hsplus  colgrad  _curremp dailywage_nz  (count) n = reg ;

xpose,varname clear;
rename v1 all_LFS;

gen id = 0;
local id = 0;
foreach var in r_sex r_age r_married urban hsplus  colgrad  _curremp dailywage_nz  n{;
replace id = `id' if _varname == "`var'";
local id = `id' + 1;
};


merge 1:1 _varname using `tempgender';
drop _merge;
sort id;

save `tempmerge';

***************************************** 
*	Bulan Data
***************************************** ;

use "$work/$specdata",clear;

*Data statements: see specification_setup.do;

$keepstatement;

* Define Urban (Obtained from NSO at http://www.nscb.gov.ph);

gen urban = 1;

foreach barangay in Z1 Z3 Z5 Z6 Z7 AQ MA OT QU SJ SO TA{;
replace urban = 0 if barangay == "`barangay'";
};

save `temp_bulan';

collapse (mean)  r_age r_married urban hsplus  colgrad  _curremp income  (count) n = resid ,by(r_sex);
xpose,varname clear;
rename v1 male_Bulan;
rename v2 female_Bulan;


save `tempgender_bulan';

use `temp_bulan',clear;

collapse (mean) r_sex r_age r_married urban hsplus  colgrad  _curremp income  (count) n = resid ;
xpose,varname clear;
rename v1 all_Bulan;

gen id = 0;
local id = 0;
foreach var in r_sex r_age r_married urban hsplus  colgrad  _curremp income n{;
replace id = `id' if _varname == "`var'";
local id = `id' + 1;
};

merge 1:1 _varname using `tempgender_bulan';
	assert _merge == 3;
	drop _merge;

merge 1:1 _varname using `tempmerge';
	drop _merge;
sort id;
drop id;

order _varname all_Bulan all_LFS male_Bulan male_LFS female_Bulan female_LFS;

outsheet using "$output/A4_LFS_Statistics_$ST.xls",replace;



