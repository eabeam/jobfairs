
*****************************************
* T6_Migration.do
*	Table 6:	Impact of Job-Fair Attendance on Migration
	*Last Updated 17 May 2015	
	
	*ITT effects of voucher and IV effects of job-fair attendance on migration
		
*****************************************


#delimit ;


use "$work/$specdata",clear;

*Data statements: see specification_setup.do;
$keepstatement;
$subgroupt;

*Replace old tables;
local R "replace";



**Define dependent variables;
local M1 "lookofw_surv";
local M2 "_planofw6mo";
local M3 "pass_fup";


*Total # dependent variables;
	local varmax = 3;		



* Loop over dependent variables;

forval m = 1/`varmax'{;

*ITT regressions;

	xi: reg `M`m'' jollibee wage occupation $cov1 $sfe  ,cluster(bgy);

		sum `M`m'' if jollibee == 0 ;
			local jol_intpval = `r(mean)';
			
	outreg2  jollibee using "$output/T6_Migration_ITT_IV_$SUB $ST.xls",
			`R'  nonote bracket dec(3)		adds(pval,0, jolint1, `jol_intpval');
			local R "append";

*IV regressions;

	xi: ivreg2 `M`m'' (attend1 = jollibee) wage occupation $cov1 $sfe  ,cluster(bgy);

		sum `M`m'' if jollibee == 0 ;
			local jol_intpval = `r(mean)';


	outreg2  attend1 using "$output/T6_Migration_ITT_IV_$SUB $ST.xls",
			`R'  nonote bracket dec(3)		adds(pval,0, jolint1, `jol_intpval');
};


	
*****
* Run regressions, fully interacted with gender, for ALL subgroup;
*****;				
if "$SUB" == "all"{;

	forval m = 1/`varmax'{;
	
*ITT regressions;

		xi: reg `M`m'' jollibee jolsexX occupation occsexX wage wagesexX $cov1 r_sexX* i.r_sex*i.p_g i.r_sex*i.en_id_BL, cluster(bgy);
		
			sum `M`m'' if jollibee == 0 ;
				local depavg = `r(mean)';
			testparm jolsexX ;
				local pval = `r(p)';
				

		outreg2 jollibee jolsexX using "$output/T6_Migration_ITT_IV_$SUB $ST.xls",
			`R' nonote bracket  dec(3) adds(pval,`pval', mean, `depavg')	;	
	
*IV regressions;

		xi: ivreg2 `M`m'' (attend1 attendX = jollibee jolsexX) occupation occsexX wage wagesexX $cov1 r_sexX* i.r_sex*i.p_g i.r_sex*i.en_id_BL, cluster(bgy) partial(r_sexXmis__currpass r_sexXmis__f8omeasure);
		
			sum `M`m'' if jollibee == 0 ;
				local depavg = `r(mean)';
			testparm attendX ;
				local pval = `r(p)';
				

		outreg2 attend1 attendX  using "$output/T6_Migration_ITT_IV_$SUB $ST.xls",
			`R'  nonote bracket  dec(3) adds(pval,`pval', mean, `depavg')	;	
	};

};


erase "$output/T6_Migration_ITT_IV_$SUB $ST.txt";

exit;


