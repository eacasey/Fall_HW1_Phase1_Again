/* Fri., August 28, 2020 */
/* HW1 Phase 2 */

/* Ellie Casey */

libname hw_data '/opt/sas/home/eacasey/sasuser.viya/Logistic_Reg_Labarr/HW1_Phase2';

/************************************************************/
*Determining variable types (Arranged in Alphabetical Order);
/************************************************************/
proc freq data=hw_data.insurance_t_bin;
	tables acctage_bin;
run;
/* 3 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables age_bin;
run;
/* 4 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables atm;
run;
/* atm = binary */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables atmamt_bin;
run;
/* 3 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables branch;
run;
/* branch = nominal  */
/* no missing values */

proc freq data=hw_data.insurance_t_bin;
	tables cashbk;
run;
/* cashbk = ordinal  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables cc;
run;
/*cc = binary */
/* 1075 missing values */

proc freq data=hw_data.insurance_t_bin;
	tables ccbal_bin;
run;
/*3 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables ccpurc;
run;
/*ccpurc = nominal */
/* 1075 missing values */

proc freq data=hw_data.insurance_t_bin;
	tables cd;
run;
/*cd = binary */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables cdbal_bin;
run;
/*3 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables checks_bin;
run;
/* 4 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables crscore_bin;
run;
/* 4 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables dda;
run;
/* dda = binary */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables ddabal_bin;
run;
/* 8 levels now */
/* No missing values */

/* ????????????? */
proc freq data=hw_data.insurance_t_bin;
	tables dep;
run;
/* dep = continuous */

proc freq data=hw_data.insurance_t_bin;
	tables depamt_bin;
run;
/* 5 levels now */
/* No Missing values */

proc freq data=hw_data.insurance_t_bin;
	tables dirdep;
run;
/* dirdep = binary */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables hmown;
run;
/* hmown = binary  */
/* 1463 missing values */

proc freq data=hw_data.insurance_t_bin;
	tables hmval_bin;
run;
/* 5 levels now  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables ils;
run;
/* ils = binary  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables ilsbal_bin;
run;
/* 2 levels now  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables inarea;
run;
/* inarea = binary  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables income_bin;
run;
/* 3 levels now  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables ins;
run;
/* ins = binary  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables inv;
run;
/* inv = binary  */
/* 1075 missing values */

proc freq data=hw_data.insurance_t_bin;
	tables invbal_bin;
run;
/* 3 levels now  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables ira;
run;
/* ira = binary  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables irabal_bin;
run;
/* 2 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables loc;
run;
/* loc = binary  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables locbal_bin;
run;
/* 3 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables lores_bin;
run;
/* 2 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables mm;
run;
/* mm = binary  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables mmbal_bin;
run;
/* 2 levels now  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables mmcred;
run;
/* mmcred = ordinal  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables moved;
run;
/* moved = binary  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables mtg;
run;
/* mtg = binary  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables mtgbal_bin;
run;
/* 3 levels now  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables nsf;
run;
/* nsf = binary  */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables nsfamt_bin;
run;
/* 2 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables phone_bin;
run;
/* 4 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables pos_bin;
run;
/* 3 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables posamt_bin;
run;
/* 3 levels now */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables res;
run;
/* res = nominal */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables sav;
run;
/* sav = binary */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables savbal_bin;
run;
/* 7 levels now*/
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables sdb;
run;
/* sdb = binary */
/* No missing values */

proc freq data=hw_data.insurance_t_bin;
	tables teller_bin;
run;
/* 3 levels now */
/* No missing values */

/************************************************************/
*For any variable with missing values, change the data;
*to include a missing category instead of a missing value;
*for the categorical variable;
/************************************************************/


data t_bin_nomissing;
	set hw_data.insurance_t_bin;
	if cc = "." then cc_2=2; *2 = missing category;
	else cc_2=cc;
	if ccpurc = "." then ccpurc_2=5; *5 is missing category;
	else ccpurc_2=ccpurc;
	if hmown="." then hmown_2 =2; *2 is missing category;
	else hmown_2=hmown;
	if inv="." then inv_2=2; *2 is missing category;
	else inv_2=inv;
run;

