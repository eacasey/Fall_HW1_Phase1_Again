data lrhw3.t_transform;
	set lrhw2.insurance_t_bin;
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

proc freq data=LRHW2.t_transform;
	tables _ALL_;
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

/* For categories with missing category, use reference coding with reference level =0 */ 

/* PROC LOG THAT:
DOES BACKWARD STEPWISE SELECTION
GETS ODDS RATIOS FOR BINARY VARS
OUTPUTS PROBABILITIES IN NEW TABLE */
ods output parameterestimates=dep;
proc logistic data=LRHW3.T_TRANSFORM outmodel= lrhw3.our_training_model plots(only)=(oddsratio ROC);
	CLASS  &main_ordinal BRANCH RES  CC_2(PARAM=REF REF='0') 
		   HMOWN_2(PARAM=REF REF='0') INV_2(PARAM=REF REF='0') ;
	model INS(event='1') = &MAINEFFECTS / 
		selection=backward slstay=.002
		clodds=pl clparm=pl;
	title 'Modeling Purchase of Insurance Product';
	output out = LRHW3.our_model_pred p=phat;
run;

/* 
% Concordant = 80
% Discordant = 20
% Tied = 0
Somers' D = 0.6
Gamma = 0.6
Tau = 0.27
c = 0.8
AUC = 0.8001
*/


proc sort data=LRHW3.our_model_pred;
	by descending INS;
run;
proc ttest data=LRHW3.our_model_pred order=data;
	ods select statistics summarypanel;
	class INS;
	var phat;
run;

/* D statistic is 0.2461*/



/*calculate the best cutoff using Yodens stat*/

/* Significant Variables in our model
DDA	NSF IRA	inv_2 ILS MM cc_2 BRANCH DDABAL_Bin
CHECKS_Bin TELLER_Bin SAVBAL_Bin ATMAMT_Bin CDBAL_Bin*/

proc logistic data=LRHW3.T_TRANSFORM;
	class 
	DDA 
	NSF 
	IRA
	inv_2 (param=ref ref='0')
	ILS 
	MM 
	cc_2 (param=ref ref='0')
	BRANCH (param=effect ref='B9')
	DDABAL_Bin (param=ref ref='1')
	CHECKS_Bin (param=effect ref='4')
	TELLER_Bin (param=effect ref='3')
	SAVBAL_Bin (param=effect ref='7')
	ATMAMT_Bin (param=effect ref='3')
	CDBAL_Bin (param=effect ref='3');
	model INS(event = '1') = DDA	NSF IRA	inv_2 ILS MM cc_2 BRANCH DDABAL_Bin
	CHECKS_Bin TELLER_Bin SAVBAL_Bin ATMAMT_Bin CDBAL_Bin / ctable pprob=0 to 0.98 by 0.01;
	ods output classification = lrhw3.classtable;
run;
quit;

data lrhw3.classtable_youden;
	set lrhw3.classtable;
	youden = sensitivity + specificity - 100;
	drop PPV NPV correct;
run;

proc sort data=lrhw3.classtable_youden;
	by descending youden;
run;

proc print data=lrhw3.classtable_youden (obs=15);
run;
/*46.1564*/ 




/*calculate the best cutoff using Lift curve*/ 

data lrhw3.classtable_lift;
	set lrhw3.classtable;
	F1 = 2 * (PPV*Sensitivity) / (PPV + Sensitivity);
	drop Specificity NPV Correct;
run;

proc sort data=lrhw3.classtable_lift;
	by descending F1;
run;

/*F1 Stat = 65.354665156*/

/*calculate K-S statistic*/

proc logistic data=LRHW3.T_TRANSFORM;
	class 
	DDA 
	NSF 
	IRA
	inv_2 (param=ref ref='0')
	ILS 
	MM 
	cc_2 (param=ref ref='0')
	BRANCH (param=effect ref='B9')
	DDABAL_Bin (param=ref ref='1')
	CHECKS_Bin (param=effect ref='4')
	TELLER_Bin (param=effect ref='3')
	SAVBAL_Bin (param=effect ref='7')
	ATMAMT_Bin (param=effect ref='3')
	CDBAL_Bin (param=effect ref='3');
	model INS(event = '1') = DDA	NSF IRA	inv_2 ILS MM cc_2 BRANCH DDABAL_Bin
	CHECKS_Bin TELLER_Bin SAVBAL_Bin ATMAMT_Bin CDBAL_Bin;
	output out=lrhw3.predprobs p=phat;
run;

proc npar1way data=lrhw3.predprobs d plots=edfplot;
	class INS;
	var phat;
run;

/*value of phat at Max = 0.296560*/
