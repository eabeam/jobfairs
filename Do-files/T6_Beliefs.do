
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

*ITT regressions;

xi: reg `M`m'' jollibee occupation wage $cov1 _f9 _c15 _c14 $sfe ,cluster(bgy) ;
		
			sum `M`m''  if jollibee == 0 ;
			local depavg = `r(mean)';

	
	outreg2 jollibee using "$output/T5_Beliefs_ITT_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	
		local R "append";

*IV regressions;

xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage $cov1 _f9 _c15 _c14 $sfe ,cluster(bgy);
		
			sum `M`m''  if jollibee == 0 ;
			local depavg = `r(mean)';

	outreg2 attend1 using "$output/T5_Beliefs_ITT_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	


};
	
	
*****
* Run regressions, fully interacted with gender, for ALL subgroup;
*****;
if "$SUB" == "all"{;

	forval m = 1/`varmax'{;

*ITT regressions;
		xi: reg `M`m'' jollibee jolsexX occupation occsexX wage wagesexX $cov1 _f9 _c15 _c14 r_sexX* __r_sexX* i.r_sex*i.p_g i.r_sex*i.en_id_BL, cluster(bgy) ;
		
			sum `M`m''  if jollibee == 0 ;
				local depavg = `r(mean)';
				
			testparm jolsexX ;
				local pval = `r(p)';
				

	outreg2  jollibee jolsexX using "$output/T5_Beliefs_ITT_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, `pval', mean, `depavg')	;		
*IV regressions;		
		xi: ivreg2 `M`m'' (attend1 attendX = jollibee jolsexX) occupation occsexX wage wagesexX $cov1 _f9 _c15 _c14 r_sexX* __r_sexX* i.r_sex*i.p_g i.r_sex*i.en_id_BL, cluster(bgy) partial(r_sexXmis__currpass r_sexXmis__f8omeasure);
		
			sum `M`m'' if jollibee == 0 ;
				local depavg = `r(mean)';
			testparm attendX ;
				local pval = `r(p)';
				
	
	outreg2 attend1 attendX using "$output/T5_Beliefs_ITT_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, `pval', mean, `depavg')	;	
};

};


erase "$output/T5_Beliefs_ITT_IV_$SUB $ST.txt";

exit;


