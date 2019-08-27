
*****************************************
* Appendix Table 6: Impact of Job-Fair Attendance on Job Search, by Job Search Method
	*Last Updated 16 July 2015	
	
		
*****************************************




#delimit ;




use "$work/$specdata",clear;

*Data statements: see specification_setup.do;
$keepstatement;
$subgroupt;

*Replace old tables;
local R "replace";



**Define dependent variables;

	local M1 "lookfamfr_aprmay2011";
	local M2 "looklocalfamfr_aprmay2011";
	local M3 "lookmnlfamfr_aprmay2011";

	local M4 "lookapp_aprmay2011";
	local M5 "looklocalapp_aprmay2011";
	local M6 "lookmnlapp_aprmay2011";


	*Total # dependent variables;
	local varmax = 6;		

* Loop over dependent variables;
forval m = 1/`varmax'{;


*ITT regressions;
 xi: reg `M`m'' jollibee occupation wage $cov1 $sfe ,cluster(bgy);
		
			sum `M`m''  if jollibee == 0 ;
			local depavg = `r(mean)';

	outreg2  jollibee  using "$output/A6_JS_Method_ITT_$SUB $ST.xls",
		`R'  nonote bracket dec(3) adds(pval,0, mean, `depavg')	;	

*IV regressions;
 xi: ivreg2 `M`m'' (attend1 = jollibee) occupation wage $cov1 $sfe ,cluster(bgy);
		
			sum `M`m'' if jollibee == 0 ;
			local depavg = `r(mean)';

	outreg2  attend1  using "$output/A6_JS_Method_IV_$SUB $ST.xls",
		`R' nonote bracket dec(3) adds(pval, 0, mean, `depavg')	;	
local R "append";


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
				
	outreg2  jollibee jolsexX  using "$output/A6_JS_Method_ITT_$SUB $ST.xls",
		`R'  nonote bracket dec(3) adds(pval,`pval', mean, `depavg')	;		

*IV regressions;
xi: ivreg2 `M`m'' (attend1 attendX = jollibee jolsexX) occupation occsexX wage wagesexX $cov1 r_sexX* i.r_sex*i.p_g i.r_sex*i.en_id_BL , cluster(bgy) partial(r_sexXmis__currpass r_sexXmis__f8omeasure);
		
			sum `M`m''  if jollibee == 0;
				local depavg = `r(mean)';
			testparm attendX ;
				local pval = `r(p)';
				
	outreg2 attend1 attendX using "$output/A6_JS_Method_IV_$SUB $ST.xls",
		`R' nonote bracket pvalue dec(3) adds(pval,`pval', mean, `depavg')	;	
};

};

*Erase .txt files;
erase "$output/A6_JS_Method_ITT_$SUB $ST.txt";
erase "$output/A6_JS_Method_IV_$SUB $ST.txt";
exit;


*AppendixTables - Job search;



/*

local M7 "look_any_surv";
local M8 "looklocal_surv" ;
local M9 "lookmnl_surv";
*/
