
*****************************************
* A.C.1		ROBUSTNESS: Impact of Voucher on Job-Fair Attendance
	*Last Updated 03 July 22015
	
	*Tests for first-stage treatment effects overall and with interaction effects
		
*****************************************

#delimit ;


* Load data files;
use "$work/$specdata",clear;


*Data statements: see specification_setup.do;
*	Note: For Appendix Tables C, runs through restrictive specifications;
$keepstatement;
$subgroupt;



*Define dependent variables;
local M1 "attend1";
local M2 "participate";


local R "replace";

* Loop over dependent variables;
forval m = 1/2{;

****************************************************************************
*	Specification 1: No covariates, no proxy respondents
****************************************************************************;

qui xi: reg `M`m'' jollibee wage occupation if balance_fullpanel == 1 ,cluster(bgy);
		

		sum `M`m'' $aweight if jollibee==0 & balance_fullpanel == 1;
			local mean = `r(mean)';
		
		testparm jollibee;
			local firststage = `r(F)';
		
	outreg2  jollibee  using "$output/A_C_1_JF_$SUB $ST.xls",
		`R'  nonote bracket dec(3)	adds( mean,`mean', jolint1 ,0, firststage,`firststage');

		local R "append";

****************************************************************************
*	Specification 2: With covariates and fixed effects, no proxy respondents 
* 	SAME AS MAIN TABLES 
****************************************************************************;

qui xi: reg `M`m'' jollibee wage occupation $cov1 $sfe if balance_fullpanel == 1 ,cluster(bgy);

		
		sum `M`m'' $aweight if jollibee==0 & balance_fullpanel == 1;
			local mean = `r(mean)';
			
		testparm jollibee;
			local firststage = `r(F)';
		
		
	outreg2  jollibee r_sex using "$output/A_C_1_JF_$SUB $ST.xls",
		`R'  nonote bracket dec(3)	adds( mean,`mean', jolint1,0, firststage,`firststage');

****************************************************************************
*	Specification 3: Including proxy respondents
****************************************************************************;		

qui xi: reg `M`m'' jollibee wage occupation $cov1 $sfe   ,cluster(bgy);

		sum `M`m'' $aweight if jollibee==0 ;
			local mean = `r(mean)';
			
		testparm jollibee;
			local firststage = `r(F)';
		
		
	outreg2  jollibee r_sex using "$output/A_C_1_JF_$SUB $ST.xls",
		`R'  nonote bracket dec(3)	adds( mean,`mean', jolint1,0, firststage,`firststage');
		
****************************************************************************
*	Specification 4: Including proxy respondents, excluding wage and qualification treatments
****************************************************************************;		

qui xi: reg `M`m'' jollibee wage occupation $cov1 $sfe  if wage == 0 & occupation == 0 ,cluster(bgy);

		sum `M`m'' $aweight if jollibee == 0 & wage == 0 & occupation == 0 ;
			local mean = `r(mean)';
			
		testparm jollibee;
			local firststage = `r(F)';
		
		
	outreg2  jollibee r_sex using "$output/A_C_1_JF_$SUB $ST.xls",
		`R'  nonote bracket dec(3)	adds( mean,`mean', jolint1,0, firststage,`firststage');

		
		};




erase "$output/A_C_1_JF_$SUB $ST.txt";
