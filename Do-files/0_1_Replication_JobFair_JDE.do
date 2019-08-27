
************************************************
*	Master Pre-replication file
*	Do job fairs matter? Experimental evidence on the impact of job-fair attendance
*	Emily A Beam



*	Last Updated 02 August 2015
*	This file takes the de-identified raw data file, bulandata_public runs cleaning and analysis fiels
**********************************************

/* Guide: 

	Part 1: Input matched_attendance_public, clean data
	
	Part 2: Set up regressions
	
	Part 3: Regression results for paper
	
	Part 4: Regression results for appendix
	
*/



**********************	File paths  *****************

// This section defines the global variabels for file locations

*General path
global path "/Users/emilybeam/GDrive/BulanProject/ImperfectInformation_Philippines/Bulan_DE_Current/!ReplicationFiles/JDE_Replication"


*Location of data -
global files "$path/Data"       // Enter location of Data Entry Folder
global work "$files"

*Location of do-files, output, logs
global dofiles 	"$path/Do-Files"
global output 	"$path/Output"

*
clear all


****************************************************************************
 **********					Part 1: Clean data 					**********
****************************************************************************

// Covariates
*global covbal "r_age r_married  hsplus colgrad _curremp _currpass ever_mnl ever_emp _f8o stronginterest  _totexp income _c12 ofwsearch_base anyfam_ofw  dist_ind "
global covbal "r_age r_married  hsplus colgrad _curremp _currpass  ever_emp _f8o stronginterest  _totexp income _c12 ofwsearch_base anyfam_ofw  dist_ind "
global cov1 "r_sex $covbal mis__currpass mis__f8o "
/* This file starts with bulandata_public.dta*/ 

* Generate covariates and outcome variables 
do "$dofiles/calc_experience.do"
do "$dofiles/1rep_variables.do"



****************************************************************************
 **********				Part 2: Set up regressions				**********
****************************************************************************




// Specification set-up file
/* Sets up specifciation program of format 

specification [DATA FILE] [SAMPLE TYPE] [SUBGROUP]

Data files: 
bulan_public_var: cleaned data file created by 1rep_variables.do

Sample type:

all: full set of baseline respondents, n = 865
balance: full set of baseline respondents, excluding those missing key baseline covariates, n = 860
balance_panel: set of endline respondents + proxy respondents, exluding those misisng key baseline covariates, n = 827
balance_fullpanel: set of endline respondents, excluding those missing key baseline covariates,  n = 685

Subgroup: 
all: men and women
men: men only
women: women only
*/


do "$dofiles/specification_setup.do"


// Covariates
*global covbal "r_age r_married  hsplus colgrad _curremp _currpass ever_mnl ever_emp _f8o stronginterest  _totexp income _c12 ofwsearch_base anyfam_ofw  dist_ind "
global covbal "r_age r_married  hsplus colgrad _curremp _currpass  ever_emp _f8o stronginterest  _totexp income _c12 ofwsearch_base anyfam_ofw  dist_ind "
global cov1 "r_sex $covbal mis__currpass mis__f8o "
*exit
 
****************************************************************************
 **********			Part 3: Regression results for paper		**********
****************************************************************************




/* ALL*/
 *		Set main regression specification
specification bulan_public_var	balance_fullpanel	all		

* 		Table 1		Balance table
do "$dofiles/T1_BalanceGender.do"				// $cov1 	


*		Table 2		Impact on Job-Fair Participation - ITT
do "$dofiles/T2_JF_AttendParticipate.do"


*		Table 3/4		Impact on job-search and employment  - ITT & IV

do "$dofiles/T3_T4_JSEmp.do"

* 		Table 5			Impact on migration  - ITT & IV

do "$dofiles/T5_Migration.do"

*		Table 6			Impact on overseas LM perceptions  - ITT & IV

do "$dofiles/T6_Beliefs.do" 



* beliefs for men
specification bulan_public_var	balance_fullpanel	men		
do "$dofiles/T6_Beliefs.do" 

* beliefs for women
specification bulan_public_var	balance_fullpanel	women		
do "$dofiles/T6_Beliefs.do" 






****************************************************************************
**** Miscellaneous statistics
****************************************************************************
specification bulan_public_var	balance_fullpanel	all		

do "$dofiles/MiscStats_JDE.do"


****************************************************************************
 **********		Part 4: Regression results for appendix			**********
****************************************************************************

****************************************************************************
**** Appendix Table A1: Descriptive Statistics
****************************************************************************

specification bulan_public_var	balance_fullpanel	all		

do "$dofiles/A1_Descriptive_Gender.do"



****************************************************************************
**** Appendix Table A2: Sample Size & Attrition
****************************************************************************

specification bulan_public_var	all	all		
do "$dofiles/A2_SampleSize.do"

****************************************************************************
**** Appendix Table A3: Differential Attrition
****************************************************************************


specification bulan_public_var	all	all		

do "$dofiles/A3_Attrition.do"



****************************************************************************
**** Appendix Table A4: LFS comparison
****************************************************************************


specification bulan_public_var	balance_fullpanel	all		

do "$dofiles/A4_LFS_Statistics.do"


	


****************************************************************************
**** Appendix Table A5: Job-search methods
****************************************************************************


specification bulan_public_var	balance_fullpanel	all	


do "$dofiles/A5_JS_Method.do"



****************************************************************************
**** Appendix Table A6: Alternative migration outcomes
****************************************************************************



specification bulan_public_var	all		all	
do "$dofiles/A6_AltMigration.do"



****************************************************************************
**** Appendix Table A7: Change in Beliefs
****************************************************************************

** Define variables without baseline beliefs, _f8o ** 

global cov2 "r_sex r_age r_married  hsplus colgrad _curremp _currpass  ever_emp stronginterest  _totexp income _c12 ofwsearch_base anyfam_ofw  dist_ind mis__currpass"


foreach gender in all men women{
specification bulan_public_var	balance_fullpanel	`gender'		

do "$dofiles/A7_ChBeliefs.do"
}





****************************************************************************
**** Appendix B: Results with increasing level of covariates
*	Note: Start with balance_panel, then within code runs the with proxy 
*	specifications and the without wage/qualification specifications
****************************************************************************


specification bulan_public_var	balance_panel	all		


*		Table 1		Impact on Job-Fair Participation - ITT

do "$dofiles/A.B.1_JF_AttendParticipate.do"


*		Table 2/3		Impact on job-search and employment  -  IV

do "$dofiles/A.B.2&3_JSEmp.do"


* 		Table B.4			Impact on migration  -  IV

do "$dofiles/A.B.4_Migration.do"


*		Table B.5			Impact on overseas LM perceptions  -  IV

do "$dofiles/A.B.5_Beliefs.do" 

***************************************************************************
**** Appendix C: Results by gender 
*		Note: p-values for pooled interacted models computed in main tables
****************************************************************************




foreach gender in men women{
 *		Set main regression specification
specification bulan_public_var	balance_fullpanel	`gender'

*		Table 2		Impact on Job-Fair Participation - ITT 
do "$dofiles/T2_JF_AttendParticipate.do"


*		Table 3/4		Impact on job-search and employment  - ITT & IV

do "$dofiles/T3_T4_JSEmp.do"

* 		Table 5			Impact on migration  - ITT & IV

do "$dofiles/T5_Migration.do"

*		Table 6			Impact on overseas LM perceptions  - ITT & IV

do "$dofiles/T6_Beliefs.do" 



}




