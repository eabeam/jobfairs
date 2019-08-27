
*****************************************
* T5_beliefs.do
*	Table 5:		Impact of Job-Fair Attendance on Beliefs
	*Last Updated 17 May 2015	
	
	*ITT effects of voucher and IV effects of job-fair attendance on beliefs
		
*****************************************

#delimit ;

use "$work/$specdata",clear;

*Data statements: see specification_setup.do;
$keepstatement;
$subgroupt;

*Replace old tables;
local R "replace";


*Generate interaction terms (for ALL subgroup);



**Define dependent variables;
local M1 "fuph4_offer";
local M2 "fuph5_deploy";
local M3 "_e11";
local M4 "_e10";
local M5 "strong_fup";

*Total # dependent variables;
	local varmax = 5;		



* Loop over dependent variables;

forval m = 1/`varmax'{;


****************************************************************************
*	Specification 1: No covariates, no proxy respondents
****************************************************************************;

		
xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage if balance_fullpanel == 1  ,cluster(bgy);
		
			sum `M`m'' if jollibee == 0 & balance_fullpanel == 1;
				local depavg = `r(mean)';

	outreg2  attend1  using "$output/A_C_4_Beliefs_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	

	local R "append";


****************************************************************************
*	Specification 2: With covariates and fixed effects, no proxy respondents 
* 	SAME AS MAIN TABLES 
****************************************************************************;

xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage $cov1 $sfe  _f9 _c15 _c14 if balance_fullpanel == 1  ,cluster(bgy);
		
			sum `M`m'' if jollibee == 0 & balance_fullpanel == 1;
				local depavg = `r(mean)';

	outreg2  attend1  using "$output/A_C_4_Beliefs_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	

/* *** SKIP
****************************************************************************
*	Specification 3: Including proxy respondents
****************************************************************************;		

xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage $cov1 $sfe  _f9 _c15 _c14  ,cluster(bgy);
		
			sum `M`m'' if jollibee == 0 ;
				local depavg = `r(mean)';

	outreg2  attend1  using "$output/A_C_4_Beliefs_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	
*/		
****************************************************************************
*	Specification 4: Including proxy respondents, excluding wage and qualification treatments
****************************************************************************;		

xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage $cov1 $sfe  _f9 _c15 _c14 if wage == 0 & occupation == 0  ,cluster(bgy);
		
			sum `M`m'' if  wage == 0 & occupation == 0 ;
				local depavg = `r(mean)';

	outreg2  attend1  using "$output/A_C_4_Beliefs_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	
		



};
	

erase "$output/A_C_4_Beliefs_IV_$SUB $ST.txt";

exit;


