/* CREATING MAIN EFFECTS ONLY BINARY LOGISTIC REGRESSION MODEL */

/************************************************************/
*Determining variable types (Arranged in Alphabetical Order);
/************************************************************/

proc freq data=LRHW2.insurance_t_bin;
	tables _ALL_;
run;

/* Identified 4 variables with missing values: CC, CCPURC, HMOWN, INV */

/* Checking all the variables for separation concerns by seeing if any of their levels  */
/* have 0s for either level of the target variables -- Ike Ingle*/

proc freq data=lrhw2.insurance_t_bin;
	tables (_all_)*ins;
run;

/* CASHBK(0 in 2nd level), MMCRED (0 on only in 5th level) */
/* These are only 2 variables with a full on 0 in their initial binned var */

/* Created new variables for each variable with missing values that replace missing values with new missing categories */
/* Do transformation on CASHBK AND MMCRED now to roll up the 2nd level into the first for Number of Cash Back */
/* and the 5th rolevel of Money Market Credits  */

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

/* CHECK TO SEE IF THIS WORKED (IT DID)*/
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
proc logistic data=LRHW2.t_transform plots(only)=(oddsratio);
	CLASS  &main_ordinal BRANCH RES  CC_2(PARAM=REF REF='0') 
		   HMOWN_2(PARAM=REF REF='0') INV_2(PARAM=REF REF='0') ;
	model INS(event='1') = &MAINEFFECTS / 
		selection=backward slstay=.002
		clodds=pl clparm=pl;
	title 'Modeling Purchase of Insurance Product';
run;

/* NEW TABLE FORMATS PROBCHISQ VALUES TO BE ABLE TO RANK MAIN EFFECTS BY THEM */
data dep1;
	set dep;
	format probchisq dollar30.29;
RUN;
/*Running interaction model with the main effects from our first model*/
ods output parameterestimates=dep;
proc logistic data=logreg.insurance_t_rollup;
	class DDABAL_Bin(PARAM=REF REF='1') Checks_Bin Teller_bin savbal_bin atmamt_bin cdbal_bin
	model INS(event='1')= DDA|SAV|ATM|IRA|INV|MM|DDABAL_Bin |Checks_Bin| Teller_bin| savbal_bin| atmamt_bin | cdbal_bin @2 / hierarchy=single 
selection=forward slentry=.002 clodds=pl clparm=pl;
	title 'Testing Interactions using main effects model';
run;
/*Final interaction model with entry significance level of .002
is DDA SAV IRA INVMM DDABAL_Bin CHECKS_bin teller_bin 
savbal_bin dda*savbal_bin ddabal_bin*savbal_bin checks_bin*savbal_bin atmamt_bin cdbal_bin*/

/*Display full p values to compare predictor variables*/
data dep1;
	set dep;
	format probchisq dollar30.29;
RUN;
proc print data=dep1;
run;
