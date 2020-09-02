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


data lrhw2.t_transform;
	set lrhw2.insurance_t_bin;
 	if cashbk = 2 then cashbk = 1; /* this adjusts for the only 2 obs that had a 2 for cashbk and were both 0's for ins */
	if mmcred = 5 then mmcred = 3; /* this adjusts for only 1 obs w/ a mmcred = 5 and rolls up to 3 since 0 obs = 4*/
run;

/* Created new variables for each that replace missing values with new missing categories */
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


/* CREATE MACRO VARIABLE OF ALL VARIABLES THAT ARE BEING CONSIDERED TO GO INTO THE MODEL */
%LET main_binary = DDA CASHBK DIRDEP NSF SAV ATM CD IRA LOC INV ILS MM MTG CC SDB HMOWN MOVED; 
%LET main_nominal = BRANCH RES ;
%LET main_ordinal =  MMCRED CCPURC DDABAL_BIN ACCTAGE_BIN DEPAMT_BIN CHECKS_BIN NSFAMT_BIN PHONE_BIN TELLER_BIN
		     SAVBAL_BIN ATMAMT_BIN POS_BIN POSAMT_BIN CDBAL_BIN IRABAL_BIN LOCBAL_BIN INVBAL_BIN
 		     ILSBAL_BIN MMBAL_BIN MTGBAL_BIN CCBAL_BIN INCOME_BIN LORES_BIN HMVAL_BIN AGE_BIN CRSCORE_BIN;

/* PROC LOG THAT:
DOES BACKWARD STEPWISE SELECTION  how is it stepwsie if it's just backward selection???
GETS ODDS RATIOS FOR BINARY VARS
OUTPUTS PROBABILITIES IN NEW TABLE */
ods output parameterestimates=dep;
proc logistic data=LRHW2.t_transform plots(only)=(oddsratio);
	CLASS BRANCH RES;
	model INS(event='1') = &main_binary &main_ordinal &main_nominal / 
		selection=backward slstay=.002
		clodds=pl clparm=pl;
	title 'Modeling Purchase of Insurance Product';
run;

/* NEW TABLE FORMATS PROBCHISQ VALUES TO BE ABLE TO RANK MAIN EFFECTS BY THEM */
data dep1;
	set dep;
	format probchisq dollar30.29;
RUN;
