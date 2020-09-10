/* Get training dataset */
data lrhw1.t_transform;
	set lrhw1.insurance_t_bin;
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

/* * For consistency we perform the same imputations that we performed on training set of adding missingness category and rolling up for  */
/* fixing separation issues on the validation set here */
/* Get Validation dataset */
data lrhw1.v_transform;
	set lrhw1.insurance_v_bin;
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

/* Trying to access previous model here by recreating through same code as before but w outmodel statement for later use */
proc logistic data=LRHW1.t_transform outmodel=train_model plots(only)=(oddsratio);
	CLASS  &main_ordinal BRANCH RES  CC_2(PARAM=REF REF='0') 
		   HMOWN_2(PARAM=REF REF='0') INV_2(PARAM=REF REF='0') ;
	model INS(event='1') = &MAINEFFECTS / 
		selection=backward slstay=.002
		clodds=pl clparm=pl ctable pprob=0 to 0.98 by 0.01;
	ods output classification= classtable;
	title 'Modeling Purchase of Insurance Product';
run;
/* the variables cc_2 and level b8 have no p val in the analysis of max likelihood effects, does this matter? */

/* Check Youden Index */
data youden;
	set classtable;
	youden = sensitivity + specificity - 100;
	drop ppv npv correct;
run;

proc sort data=youden;
	by descending youden;
run;
/* Youden's index found that .29 was best cutoff */
/* Think F1 score is a better metric for this problem though 
if going to use a balanced metric so check that too */
data F1;
	set classtable;
	F1 = 2*(PPV*Sensitivity)/(PPV + Sensitivity);
	drop specificity npv correct;
run;

proc sort data=f1;
	by descending F1;
run;

/* well bad news for me is that f1 agrees w Youden that .29 is best cut off so for now just going to */
/* Create a scored dataset to use to create the validation's confusion matrix */

/* Scoring function */
proc logistic inmodel=work.train_model;
	score data=lrhw1.v_transform out=score outroc=roc;
run;

/* using scored dataset create prediction and actual columns for easy confusion matrix creation */
data youden_cutoff;
	set score;
	actual = f_ins;
	if p_1 > 0.29 then predicted = 1;
	else predicted =0;
run;

/* Create confusion matrix for youden/f1 value*/
proc freq data=new_cutoff;
	tables actual*predicted;
run;
/* Current Model Stats on valid set with a .29 cutoff */
/* accuracy = 69.11% */
/* Sensitivity/Recall(TPR) = 77.63% */
/* 1 - specificity(FPR) = 35.46% */
/* Precision (PPV) = 54.03% */

/* Really not sure this is the best model can do both for general accuracy andso going to check both lift curves and create an estimated cost */
/* where False Positives are double the cost of a false negative so cost = 2(FP) + 1(FN) 
this would only really apply in the case of a salesperson being more heavily involved with selling to the model's recommendations
but this provides a good contrasting example of merits of maybe using both cut offs but for different marketing activities*/
data cost;
	set classtable;
	cost = (2*IncorrectEvents) + IncorrectNonevents;
run;

proc sort data= cost;
	by cost;
run;
/* This method says that a cut off of .76 minimizes the estimated cost variable */

data strict_cutoff;
	set score;
	actual = f_ins;
	if p_1 > 0.76 then predicted = 1;
	else predicted = 0;
run;

proc freq data = strict_cutoff;
	tables actual*predicted;
run;
/* Current Model Stats on valid set with a .76 cutoff */
/* accuracy = 67.89% */
/* Sensitivity/Recall(TPR) = 14.92% */
/* 1 - specificity(FPR) = 3.69% */
/* Precision (PPV) = 68.52% */

/* dropping cut off vals down to 0.6 results in a lot more positive results for not much extra cost in how often predicted values are 1's */
/* notice the TPR OF 35.71 compared to only about 15% for a .76 cutoff so depending on how costly the marketing either of these cutoffs coudl make sense */
/* for a higher threshold "priority" or followup type list that is used by the salespeople to prioritize their prospecting time */
/* Current Model Stats on valid set with a .6 cutoff */
/* accuracy = 71.52% */
/* Sensitivity/Recall(TPR) = 35.71% */
/* 1 - specificity(FPR) = 9.26% */
/* Precision (PPV) = 67.43% */

/* Work on lift now */

/* First need to find true pop proportion of 1's in total dataset */
proc freq data=lrhw1.insurance_v_bin;
	tables ins;
run;
/* 742 yes and 2124 total */

proc freq data=lrhw1.insurance_t_bin;
	tables ins;
run;
/* 2918 yes 8495 total */
/* total pop prop of 1's is equal to: 0.34467 */

/* Create lift chart */
data roc; 
	set roc; 
	cutoff = _PROB_; 
	specif = 1-_1MSPEC_; 
	depth=(_POS_+_FALPOS_)/2124*100; *enter validation set total sample here tho instead since roc dataset created off score set;
	precision=_POS_/(_POS_+_FALPOS_); 
	acc=_POS_+_NEG_; 
	lift=precision/0.34467; *enter pop prop of 1's here;
run;

/* Create visualization and remove depth observations at such rare occurrences where it is messing up graph */
proc sgplot data=roc;  
	where depth > 0.20;
	series y=lift x=depth; 
	refline 1.0 / axis=y; 
	title1 "Lift Chart for Validation Data"; 
	xaxis label="Depth (%)";
	yaxis label="Lift";
run; 
quit;

/* based on this looks like around 20-25% depth is around where the lift hits it's elbow point of sorts */
/* use to find quantiles of p_vals to create new cutoff point from lift chart at top 25% of p-vals */
proc univariate data=score;
	var p_1;
run;
/* The 3rd quantile was = to a p_1 val of 0.5289499 */

data lift_cutoff;
	set score;
	actual = f_ins;
	if p_1 > 0.5289499 then predicted = 1;
	else predicted = 0;
run;

/* Confusion matrix for lift cutoff */
proc freq data = lift_cutoff;
	tables actual*predicted;
run;

/* Since no real estimates available for false negs/pos's going to just show the lift suggested one and the Youden/F1 */
/* to demonstrate potential differences in quality of prediction vs quantity that might matter depending on marekting costs */