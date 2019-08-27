
*****************************************
* Table 8_1_Beliefs_june6
	*Last Updated  2014 1 July
	
* 	Treatment heterogeneity - beliefs 
*****************************************;

#delimit ;


use "$work/$specdata",clear;

*Data statements: see specification_setup.do;
$keepstatement;
$subgroupt;
*Replace old tables;
local R "replace";

*Generate interaction terms (for ALL subgroup);

local M1 "rcurr_away";
local M2 "rcurr_manila";
local M3 "rofwcurr_fup";





*Total # dependent variables;
	local varmax = 3;		




* Loop over dependent variables;

forval m = 1/`varmax'{;

*ITT regressions;

	xi: reg `M`m'' jollibee wage occupation $cov1 $sfe  ,cluster(bgy);

		sum `M`m'' if jollibee == 0 ;
			local jol_intpval = `r(mean)';
			
		outreg2  jollibee using "$output/A4_Migration_ITT_$SUB $ST.xls",
			`R'  nonote bracket dec(3)		adds(pval,0, jolint1, `jol_intpval');
	outreg2  jollibee using "$output/A4_Migration_ITT_IV_$SUB $ST.xls",
			`R'  nonote bracket dec(3)		adds(pval,0, jolint1, `jol_intpval');
		
*IV regressions;

	xi: ivreg2 `M`m'' (attend1 = jollibee) wage occupation $cov1 $sfe  ,cluster(bgy);

		sum `M`m'' if jollibee == 0 ;
			local jol_intpval = `r(mean)';
			
		outreg2  attend1 using "$output/A4_Migration_IV_$SUB $ST.xls",
			`R' nonote bracket dec(3)		adds(pval,0, jolint1, `jol_intpval');

	local R "append";

	outreg2  attend1 using "$output/A4_Migration_ITT_IV_$SUB $ST.xls",
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
				
		outreg2 jollibee jolsexX using "$output/A4_Migration_ITT_$SUB $ST.xls",
			`R' drop(_win _Ip*) nonote bracket pvalue dec(3) adds(pval,`pval', mean, `depavg')	;	
		outreg2 jollibee jolsexX using "$output/A4_Migration_ITT_IV_$SUB $ST.xls",
			`R' drop(_win _Ip*) nonote bracket pvalue dec(3) adds(pval,`pval', mean, `depavg')	;	
	
*IV regressions;

		xi: ivreg2 `M`m'' (attend1 attendX = jollibee jolsexX) occupation occsexX wage wagesexX $cov1 r_sexX* i.r_sex*i.p_g i.r_sex*i.en_id_BL, cluster(bgy) partial(r_sexXmis__currpass r_sexXmis__f8omeasure);
		
			sum `M`m'' if jollibee == 0 ;
				local depavg = `r(mean)';
			testparm attendX ;
				local pval = `r(p)';
				
		outreg2 attend1 attendX using "$output/A4_Migration_IV_$SUB $ST.xls",
			`R' drop(_win _Ip*) nonote bracket pvalue dec(3) adds(pval,`pval', mean, `depavg')	;	
		outreg2 attend1 attendX  using "$output/A4_Migration_ITT_IV_$SUB $ST.xls",
			`R' drop(_win _Ip*) nonote bracket pvalue dec(3) adds(pval,`pval', mean, `depavg')	;	
	};

};

erase "$output/A4_Migration_ITT_$SUB $ST.txt";
erase "$output/A4_Migration_IV_$SUB $ST.txt";
erase "$output/A4_Migration_ITT_IV_$SUB $ST.txt";
