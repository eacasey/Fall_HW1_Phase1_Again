/* Ellie Casey */
/* K-S Statistic Code */
/* Built off of Ethan-Cole's Code */
/* Thurs., Sept. 10, 2020 */

/* ******************************************************************************** */
/* Setting up data for analysis & calculations */
libname lrhw3 '/opt/sas/home/eacasey/sasuser.viya/Logistic_Reg_Labarr/HW1_Phase3';

data lrhw3.t_transform;
	set LRHW3.insurance_t_bin;
	if cc = . then cc_2=2; *2 = missing category;
	else cc_2=cc;
	if ccpurc = . then ccpurc_2=5; *5 is missing category;
	else ccpurc_2=ccpurc;
	if hmown="." then hmown_2 =2; *2 is missing category;
	else hmown_2=hmown;
	if inv="." then inv_2=2; *2 is missing category;
	else inv_2=inv;
	if cashbk = 2 then cashbk = 1; /* this adjusts for the only 2 obs that had a 2 for cashbk and were both 0's for ins */
	if mmcred = 5 then mmcred = 3; /* this adjusts for only 1 obs w/ a mmcred = 5 and rolls up to 3 since 0 obs = 4*/
run;

/* CREATE MACRO VARIABLE OF ALL VARIABLES THAT ARE BEING CONSIDERED TO GO INTO THE MODEL */
%LET MAINEFFECTS = DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV_2 ILS
MM MMCRED MTG CC_2 CCPURC_2 SDB HMOWN_2 MOVED INAREA BRANCH RES DDABAL_BIN
ACCTAGE_BIN DEPAMT_BIN CHECKS_BIN NSFAMT_BIN PHONE_BIN TELLER_BIN
SAVBAL_BIN ATMAMT_BIN POS_BIN POSAMT_BIN CDBAL_BIN IRABAL_BIN LOCBAL_BIN
INVBAL_BIN ILSBAL_BIN MMBAL_BIN MTGBAL_BIN CCBAL_BIN INCOME_BIN LORES_BIN
HMVAL_BIN AGE_BIN CRSCORE_BIN;

/* CREATE MACRO VARIABLE FOR VARIABLES THAT WILL GO INTO THE CLASS STATEMENT */
%LET main_ordinal =  MMCRED CCPURC_2(PARAM=REF REF='0') DDABAL_BIN(PARAM=REF REF='1') ACCTAGE_BIN DEPAMT_BIN CHECKS_BIN NSFAMT_BIN PHONE_BIN TELLER_BIN
		     SAVBAL_BIN ATMAMT_BIN POS_BIN POSAMT_BIN CDBAL_BIN IRABAL_BIN LOCBAL_BIN INVBAL_BIN
 		     ILSBAL_BIN MMBAL_BIN MTGBAL_BIN CCBAL_BIN INCOME_BIN LORES_BIN HMVAL_BIN AGE_BIN CRSCORE_BIN;

/* ******************************************************************************** */
/* Running regression */

proc logistic data=LRHW3.t_transform noprint;
	CLASS &main_ordinal BRANCH RES  CC_2(PARAM=REF REF='0') 
		   HMOWN_2(PARAM=REF REF='0') INV_2(PARAM=REF REF='0');
	model INS(event='1') = &MAINEFFECTS;
	output out = predprobs p = phat;
run;

proc npar1way data = predprobs d plot = edfplot;
	CLASS INS; *dependent variable here;
	var phat;
run;

/* k-s statistic = 0.4778 */
/* Value of phat at Maximum = 0.288265 */


