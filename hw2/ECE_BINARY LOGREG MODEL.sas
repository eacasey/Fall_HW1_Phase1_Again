/* ETHAN-COLE 9/1/20 */
/* CREATING MAIN EFFECTS ONLY BINARY LOGISTIC REGRESSION MODEL */
/* PICKING UP IMMEDIATELY AFTER ELLIE AND IKE'S ADJUSTMENTS FOR MISSING */
/* VALUES AND SEPARATION CONCERNS */

data lrhw2.t_transform;
	set LRHW2.insurance_t_bin;
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

data lrhw2.t_transform;
	set lrhw2.insurance_t_bin;
 	if cashbk = 2 then cashbk = 1; /* this adjusts for the only 2 obs that had a 2 for cashbk and were both 0's for ins */
	if mmcred = 5 then mmcred = 3; /* this adjusts for only 1 obs w/ a mmcred = 5 and rolls up to 3 since 0 obs = 4*/
run;


%LET MAINEFFECTS = DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV ILS
MM MMCRED MTG CC CCPURC SDB HMOWN MOVED INAREA INS BRANCH RES DDABAL_BIN
ACCTAGE_BIN DEPAMT_BIN CHECKS_BIN NSFAMT_BIN PHONE_BIN TELLER_BIN
SAVBAL_BIN ATMAMT_BIN POS_BIN POSAMT_BIN CDBAL_BIN IRABAL_BIN LOCBAL_BIN
INVBAL_BIN ILSBAL_BIN MMBAL_BIN MTGBAL_BIN CCBAL_BIN INCOME_BIN LORES_BIN
HMVAL_BIN AGE_BIN CRSCORE_BIN;

/* PROC LOG THAT GETS ODDS RATIOS FOR BINARY VARS  */
proc logistic data=LRHW2.t_transform plots(only)=(oddsratio);
/* 	CLASS BRANCH RES; */
	model INS(event='1') = &MAINEFFECTS / 
		selection=backward slstay=.002
		clodds=pl clparm=pl;
	title 'Modeling Purchase of Insurance Product';
run;
