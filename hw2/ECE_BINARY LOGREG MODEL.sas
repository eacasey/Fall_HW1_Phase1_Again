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
 	if cashbk = 2 then cashbk = 1; /* this adjusts for the only 2 obs that had a 2 for cashbk and were both 0's for ins
	if mmcred = 5 then mmcred = 3; /* this adjusts for only 1 obs w/ a mmcred = 5 and rolls up to 3 since 0 obs = 4
run;

/* MACRO FOR BINARY VARIABLES */
%LET MAINEFFECTS = ATM DDA DIRDEP NSF SAV CD IRA LOC INV_2 ILS MM MTG
CC_2 SDB HMOWN_2 MOVED INAREA NSFAMT_BIN IRABAL_BIN ILSBAL_BIN  
MMBAL_BIN LORES_BIN;

/* PROC LOG THAT GETS ODDS RATIOS FOR BINARY VARS  */
proc logistic data=LRHW2.t_transform plots(only)=(oddsratio);
	model INS(event='1') = &MAINEFFECTS / 
		selection=backward slstay=.002
		clodds=pl clparm=pl;
	title 'Modeling Purchase of Insurance Product';
run;

/* MACRO FOR BINARY VARIABLES (EXCLUDING THE VARIABLES WITH IMPUTED VALUES) */
%LET MAINEFFECTSNOMISS = ATM DDA DIRDEP NSF SAV CD IRA 
SDB  MOVED INAREA NSFAMT_BIN IRABAL_BIN ILSBAL_BIN  
MMBAL_BIN LORES_BIN LOC ILS MM MTG;

/* PROC LOG THAT GETS ODDS RATIOS FOR VARS (EXCLUDING THE VARIABLES WITH IMPUTED VALUES) */
proc logistic data=LRHW2.t_transform plots(only)=(oddsratio);
	model INS(event='1') = &MAINEFFECTSNOMISS / 
		selection=backward slstay=.002
		clodds=pl clparm=pl;
	title 'Modeling Purchase of Insurance Product';
run;
