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
/*46.1564 = youden stat
0.290 = youden cutoff*/ 




/*calculate the best cutoff using Lift curve*/ 

data lrhw3.classtable_lift;
	set lrhw3.classtable;
	F1 = 2 * (PPV*Sensitivity) / (PPV + Sensitivity);
	drop Specificity NPV Correct;
run;

proc sort data=lrhw3.classtable_lift;
	by descending F1;
run;

/*F1 Stat = 65.354665156
F1 cuttoff = 0.290 */

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




/*
So far..
Youden = 46.1564
F1 = 65.354665156
KS = 0.296560
ROC = 
*/

/*compare ROC curves*/
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
	model INS(event = '1') = DDA NSF IRA inv_2 ILS MM cc_2 BRANCH DDABAL_Bin
	CHECKS_Bin TELLER_Bin SAVBAL_Bin ATMAMT_Bin CDBAL_Bin / clodds=pl clparm=pl;
	ROC 'omit DDA' NSF IRA inv_2 ILS MM cc_2 BRANCH DDABAL_Bin
	CHECKS_Bin TELLER_Bin SAVBAL_Bin ATMAMT_Bin CDBAL_Bin;
	* add other curves;
	roccontrast / estimate = allpairs;
run;

/*create a confusion matrix with different thresholds*/

data lrhw3.v_transform;
	set lrhw2.insurance_v_bin;
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

proc logistic inmodel=lrhw3.our_training_model;
	score data=lrhw3.v_transform out=lrhw3.valid_fit;
run;

data lrhw3.compare_cutoffs;
	set lrhw3.valid_fit;
	keep Actual Predicted P_0 P_1 Youden_cutoff F1_cutoff KS_cutoff;
	Actual = F_INS;
	Predicted = I_INS;
	Youden_cutoff = 0.290;
	F1_cutoff = 0.290;
	KS_cutoff = 0.296560;
run;

data lrhw3.youden_F1_matrix;
	set lrhw3.compare_cutoffs;
	keep TP TN FP FN;
	cutoff = Youden_cutoff;
	TP = 0;
	TN = 0;
	FP = 0;
	FN = 0;
	if P_1 > cutoff and Actual = 1 then TP = 1;
	else if P_1 > cutoff and Actual = 0 then FP = 1;
	else if P_1 < cutoff and Actual = 0 then TN = 1;
	else if P_1 < cutoff and Actual = 1 then FN = 1;
run;

data lrhw3.KS_matrix;
	set lrhw3.compare_cutoffs;
	keep TP TN FP FN;
	cutoff = KS_cutoff;
	TP = 0;
	TN = 0;
	FP = 0;
	FN = 0;
	if P_1 > cutoff and Actual = 1 then TP = 1;
	else if P_1 > cutoff and Actual = 0 then FP = 1;
	else if P_1 < cutoff and Actual = 0 then TN = 1;
	else if P_1 < cutoff and Actual = 1 then FN = 1;
run;

proc export data=lrhw3.youden_F1_matrix
outfile = '/home/u42027047/Fall_LogisticRegression/HW/HW3/outfiles/lrhw3.youden_F1_matrix.csv'
dbms=csv replace;
run;

proc export data=lrhw3.KS_matrix
outfile = '/home/u42027047/Fall_LogisticRegression/HW/HW3/outfiles/lrhw3.KS_matrix.csv'
dbms=csv replace;
run;	

data lrhw3.matrix_05;
	set lrhw3.compare_cutoffs;
	keep TP TN FP FN;
	cutoff = 0.5;
	TP = 0;
	TN = 0;
	FP = 0;
	FN = 0;
	if P_1 > cutoff and Actual = 1 then TP = 1;
	else if P_1 > cutoff and Actual = 0 then FP = 1;
	else if P_1 < cutoff and Actual = 0 then TN = 1;
	else if P_1 < cutoff and Actual = 1 then FN = 1;
run;
proc export data=lrhw3.matrix_05
outfile = '/home/u42027047/Fall_LogisticRegression/HW/HW3/outfiles/lrhw3.matrix_05.csv'
dbms=csv replace;
run;

data lrhw3.matrix_08;
	set lrhw3.compare_cutoffs;
	keep TP TN FP FN;
	cutoff = 0.8;
	TP = 0;
	TN = 0;
	FP = 0;
	FN = 0;
	if P_1 > cutoff and Actual = 1 then TP = 1;
	else if P_1 > cutoff and Actual = 0 then FP = 1;
	else if P_1 < cutoff and Actual = 0 then TN = 1;
	else if P_1 < cutoff and Actual = 1 then FN = 1;
run;
proc export data=lrhw3.matrix_08
outfile = '/home/u42027047/Fall_LogisticRegression/HW/HW3/outfiles/lrhw3.matrix_08.csv'
dbms=csv replace;
run;




