
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


*ITT regressions;
 xi: reg `M`m'' jollibee occupation wage $cov1 $sfe ,cluster(bgy);
		
			sum `M`m''  if jollibee == 0 ;
			local depavg = `r(mean)';

	outreg2  jollibee  using "$output/T34_ITT_IV_WorkStatus_$SUB $ST.xls",
		`R'  nonote bracket dec(3) adds(pval,0, mean, `depavg')	;	
local R "append";

*IV regressions;
 xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage $cov1 $sfe ,cluster(bgy);
		
			sum `M`m'' if jollibee == 0 ;
			local depavg = `r(mean)';

	outreg2  attend1  using "$output/T34_ITT_IV_WorkStatus_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	


};

*****
* Run regressions, fully interacted with gender, for ALL subgroup;
*****;
if "$SUB" == "all"{;
forval m = 1/`varmax'{;

*ITT regressions;
xi: reg `M`m'' jollibee jolsexX occupation occsexX wage  wagesexX $cov1 r_sexX* i.r_sex*i.p_g i.r_sex*i.en_id_BL , cluster(bgy);
		
			sum `M`m''  if jollibee == 0;
				local depavg = `r(mean)';
			testparm jolsexX ;
				local pval = `r(p)';
				
	outreg2  jollibee jolsexX  using "$output/T34_ITT_IV_WorkStatus_$SUB $ST.xls",
		`R'  nonote bracket dec(3) adds(pval,`pval', mean, `depavg')	;		

*IV regressions;
xi: ivreg2 `M`m'' (attend1 attendX = jollibee jolsexX) occupation occsexX wage wagesexX $cov1 r_sexX* i.r_sex*i.p_g i.r_sex*i.en_id_BL , cluster(bgy) partial(r_sexXmis__currpass r_sexXmis__f8omeasure);
		
			sum `M`m''  if jollibee == 0;
				local depavg = `r(mean)';
			testparm attendX ;
				local pval = `r(p)';
				
	outreg2 attend1 attendX using "$output/T34_ITT_IV_WorkStatus_$SUB $ST.xls",
		`R' nonote bracket  dec(3) adds(pval,`pval', mean, `depavg')	;	
};

};

*Erase .txt files;
erase "$output/T34_ITT_IV_WorkStatus_$SUB $ST.txt";
exit;


*AppendixTables - Job search;



/*

local M7 "look_any_surv";
local M8 "looklocal_surv" ;
local M9 "lookmnl_surv";
*/
