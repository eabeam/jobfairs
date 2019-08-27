
*****************************************
* Tables 3 and 4:		Impact of Job-Fair Attendance on Job Search and Employment
	*Last Updated 16 May 2015	
	
	*ITT effects of voucher and IV effects of job-fair attendance on JS and Emp
	*	outcomes
		
*****************************************




#delimit ;




use "$work/$specdata",clear;

*Data statements: see specification_setup.do;
$keepstatement;
$subgroupt;

*Replace old tables;
local R "replace";




**Define dependent variables;

	* Table 3: Job Search;

	local M1 "look_any_aprmay2011";
	local M2 "looklocal_aprmay2011";
	local M3 "lookmnl_aprmay2011";
	local M4 "b_offerany_surv";
	local M5 "b_offerlocal_surv";
	local M6 "b_offermnl_surv";
	

	*Table 4: Employment; 
	local M7 "rwork_fup";
	local M8 "rformal_fup";
	local M9 "rinformal_fup";
	local M10 "rselffarm_fup";
	
	*Total # dependent variables;
	local varmax = 10;		
* Loop over dependent variables;
forval m = 1/`varmax'{;


****************************************************************************
*	Specification 1: No covariates, no proxy respondents
****************************************************************************;

		
xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage if balance_fullpanel == 1  ,cluster(bgy);
		
			sum `M`m'' if jollibee == 0 & balance_fullpanel == 1;
				local depavg = `r(mean)';

	outreg2  attend1  using "$output/A_C_2_3_WorkStatus_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	

	local R "append";


****************************************************************************
*	Specification 2: With covariates and fixed effects, no proxy respondents 
* 	SAME AS MAIN TABLES 
****************************************************************************;

xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage $cov1 $sfe if balance_fullpanel == 1  ,cluster(bgy);
		
			sum `M`m'' if jollibee == 0 & balance_fullpanel == 1;
				local depavg = `r(mean)';

	outreg2  attend1  using "$output/A_C_2_3_WorkStatus_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	


****************************************************************************
*	Specification 3: Including proxy respondents
****************************************************************************;		

xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage $cov1 $sfe   ,cluster(bgy);
		
			sum `M`m'' if jollibee == 0 ;
				local depavg = `r(mean)';

	outreg2  attend1  using "$output/A_C_2_3_WorkStatus_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	
		
****************************************************************************
*	Specification 4: Including proxy respondents, excluding wage and qualification treatments
****************************************************************************;		

xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage $cov1 $sfe if wage == 0 & occupation == 0  ,cluster(bgy);
		
			sum `M`m'' if  wage == 0 & occupation == 0 ;
				local depavg = `r(mean)';

	outreg2  attend1  using "$output/A_C_2_3_WorkStatus_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	

};





*Erase .txt files;
erase "$output/A_C_2_3_WorkStatus_IV_$SUB $ST.txt";
exit;

