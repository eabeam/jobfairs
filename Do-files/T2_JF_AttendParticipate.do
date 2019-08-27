
*****************************************
* Table 2:		Impact of Voucher on Job-Fair Attendance
	*Last Updated 16 May 2015	
	
	*Tests for first-stage treatment effects overall and with interaction effects
		
*****************************************

#delimit ;


* Load data files;
use "$work/$specdata",clear;


*Data statements: see specification_setup.do;
$keepstatement;
$subgroupt;

*Define dependent variables;
local M1 "attend1";
local M2 "participate";


local R "replace";

* Loop over dependent variables;
forval m = 1/2{;

* No covariates;
qui xi: reg `M`m'' jollibee wage occupation $sfe ,cluster(bgy);


		sum `M`m'' $aweight if jollibee == 0 ;
			local mean = `r(mean)';
		
		testparm jollibee;
			local firststage = `r(F)';
		
	outreg2  jollibee r_sex  using "$output/T2_JF_$SUB $ST.xls",
		`R'  nonote bracket dec(3)	adds( mean,`mean', jolint1 ,0, firststage,`firststage');

		local R "append";


* With covariates, defined by $cov1		;
qui xi: reg `M`m'' jollibee wage occupation $cov1 $sfe  ,cluster(bgy);

		testparm jollibee;
			local firststage = `r(F)';
		
		
	outreg2  jollibee r_sex using "$output/T2_JF_$SUB $ST.xls",
		`R'  nonote bracket dec(3)	adds( mean,`mean', jolint1,0, firststage,`firststage');

		
*****
* Run regressions, fully interacted with gender, for ALL subgroup;
*****;
if "$SUB" == "all"{;

*No covariates - only treatments and stratification cell FE;
qui xi: reg `M`m'' i.r_sex*jollibee i.r_sex*wage i.r_sex*occupation i.r_sex*i.p_g i.r_sex*i.en_id_BL  ,cluster(bgy);

		sum `M`m'' $aweight if jollibee == 0 ;
			local mean = `r(mean)';
		testparm _Ir_sXjolli_1;
			local pval = `r(p)';

		testparm jollibee;
			local firststage = `r(F)';
			
	outreg2  jollibee r_sex _Ir_sXjolli_1 using "$output/T2_JF_$SUB $ST.xls",
		`R' nonote bracket dec(3)	adds( mean,`mean', jolint1,`pval', firststage,`firststage');

		local R "append";
		
* With covariates, defined by $cov1		;
qui xi: reg `M`m'' i.r_sex*jollibee i.r_sex*wage i.r_sex*occupation i.r_sex*i.p_g i.r_sex*i.en_id_BL  $cov1 r_sexX*   ,cluster(bgy) ;
			
					testparm _Ir_sXjolli_1;

			local pval = `r(p)';
			
		testparm jollibee;
			local firststage = `r(F)';
	
			
			
	outreg2  jollibee r_sex _Ir_sXjolli_1 using "$output/T2_JF_$SUB $ST.xls",
		`R' nonote bracket dec(3)	adds( mean,`mean', jolint1,`pval', firststage,`firststage');
};


};
erase "$output/T2_JF_$SUB $ST.txt";
