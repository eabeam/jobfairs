****************************************
* A2_SampleSize.do
	*Table A2:		Sample Size and Attritoin
	*Last Updated 18 May 2015	
	
	*Descriptive statistics on sample size and attrition

		
***************************************** 


#delimit; 
use "$work/$specdata",clear;

*Data statements: see specification_setup.do;

$keepstatement;
$subgroupt;

* Follow-up rates;
tab full_F,mi;


* Attrition rates;
tab rattrition;

*Refusal rate;
tab rrefused;

*Other outcomes;
tab outcome if rattrition == 1 & rrefused == 0;




