#delimit ;
************************************
* Specification Set-Up

*	Sets up specifications to select data files, weighting, etc. 
************************************;


capture program drop specification;
program define specification;
	args datafile sampletype subgroup;



assert "`sampletype'" == "all" | "`sampletype'" == "balance_voucheronly" |  "`sampletype'" == "balance" |  "`sampletype'" == "balance_panel" | "`sampletype'" == "balance_fullpanel";
	
global specdata = "`datafile'";
global restrt "";
global samplet "";
global keepstatement "";
global ST "`sampletype'";


global subgroupt = "keep if `subgroup' == 1";
global SUB "`subgroup'";


if "`sampletype'" == "balance" | "`sampletype'" == "balance_panel" | "`sampletype'" == "balance_fullpanel" | "`sampletype'" == "balance_voucheronly"{;
global samplet "keep if `sampletype' == 1";

};

*sfe: fixed effects include purok-group fixed effects, p_group (stratification cells), and enumerator fixed effects (en_id_BL);

global sfe "i.p_g i.en_id_BL";
global keepstatement "$samplet";

* Output specification;
di _newline _newline %~59s "Specification Setup";
di "Arguments:" _newline _col(10)
			"datafile = `datafile'" _newline _col(10)
			"sampletype = `sampletype'" _newline _col(10)
			"subgroup = `subgroup'";
di "Expressions:" _newline _col(10) "$keepstatement" _newline _col(10) "$samplet" _newline _col(10) "$subgroupt"_newline;
di "Using stratification cell FE, ${sfe}";
	end;
