*****************************************
* A3_Attrition.do
	*Table A3:		Differential attrition by treatment assignemnt
	*Last Updated 18 May 2015	
	
	*Tests for differential attrition by treatment assignment

		
***************************************** 

#delimit; 
use "$work/$specdata",clear;

*Data statements: see specification_setup.do;

$keepstatement;
$subgroupt;



/* Panel B: Determinants of attrition */

#delimit ;

**** Covariates *****;

*Replace old tables;
local R "replace";

*Define dependent variables;
local out1 "attrition";
local out2 "proxy";


* Loop over dependent variables;

forval i = 1/2{;


* No covariates;
xi: reg r`out`i''_fup jollibee occupation wage, cluster(bgy);

	sum r`out`i''_fup if jollibee == 0 ;
		local depavg = `r(mean)';


	outreg2  jollibee  using "$output/A3_Attrit_$ST.xls",
		`R' nonote bracket dec(3) adds(mean, `depavg')	;	
local R "append";

*Stratification cell FE only;
xi: reg r`out`i''_fup jollibee occupation wage $sfe, cluster(bgy);
	outreg2  jollibee  using "$output/A3_Attrit_$ST.xls",
		`R' nonote bracket dec(3) adds(mean, 0)	;	

*Covariates and stratification cell FE;
xi: reg r`out`i''_fup jollibee occupation wage $cov1 $sfe, cluster(bgy);
		
	outreg2  jollibee  using "$output/A3_Attrit_$ST.xls",
		`R' nonote bracket dec(3) adds(mean, 0)	;	


};

erase "$output/A3_Attrit_$ST.txt";

