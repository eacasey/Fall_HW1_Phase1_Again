/*
Name: Jacob Hyman
Date: 08/09/2020
Goal:
	1. Report and interpret the following probability metrics for your model on training data.
		o Concordancepercentage.

	2. Discrimination slope – provide the coefficient of discrimination as well as a visual
	representation through histograms.

	3. Report and interpret the following classification metrics for your model on training data.
		o VisuallyshowtheROCcurve.

	4. (HINT: Although this is one of the only times I will allow SAS output in a report,
	make sure the axes and title are well labeled.)
		o K-S Statistic. The Bank currently uses the K-S statistic to choose the threshold for
		classification but are open to other methods as long as they are documented in the
		report and defended.*/



libname lrhw3 "/home/u42027047/Fall_LogisticRegression/HW/HW3/data";

proc contents data=lrhw3.insurance_t_bin;
run;

/* Create logistic regression model using backwards elimination of all variables 
(all variables are now catagorical) on the training data set.

This block gives the ROC Curve and summary statistics (C, Percent Concordant, ect.) 
for the training data set.*/

proc logistic data=lrhw3.insurance_t_bin outmodel= logitmodel plots(only) = (oddsratio ROC);
	class
	CCPURC (param=ref ref='0') 
	MMCRED (param=ref ref='0')
	CC (param=ref ref='0') 
	CASHBK (param=ref ref='0')
	ACCTAGE_BIN (param=ref ref='1')
	ATMAMT_Bin (param=ref ref='1')
	CCBAL_Bin (param=ref ref='1')
	CDBAL_Bin (param=ref ref='1')
	INVBAL_Bin (param=ref ref='1')
	LOCBAL_Bin (param=ref ref='1')
	MTGBAL_Bin (param=ref ref='1')
	POSAMT_Bin (param=ref ref='1')
	POS_Bin (param=ref ref='1')
	SAVBAL_Bin (param=ref ref='1')
	DEPAMT_Bin (param=effect ref='1')
	DDABAL_Bin (param=effect ref='1')
	AGE_Bin (param=effect ref='1')
	CHECKS_Bin (param=effect ref='1')
	CRSCORE_Bin (param=effect ref='1')
	HMVAL_Bin (param=effect ref='1')
	INCOME_Bin (param=effect ref='1')
	PHONE_Bin (param=effect ref='1')
	TELLER_Bin (param=effect ref='1')
	BRANCH (param=effect ref='B1')
	RES (param=effect ref='R');
	model INS(event = '1') = MMCRED CCPURC CC CASHBK 
	ACCTAGE_BIN ATMAMT_Bin CCBAL_Bin CDBAL_Bin INVBAL_Bin LOCBAL_Bin MTGBAL_Bin POSAMT_Bin POS_Bin SAVBAL_Bin
	DEPAMT_Bin DDABAL_Bin AGE_Bin CHECKS_Bin CRSCORE_Bin HMVAL_Bin INCOME_Bin PHONE_Bin TELLER_Bin
	BRANCH RES
	/ selection = backward slstay=0.02 clodds=pl clparm=pl;
	output out=work.pred p=p;
run;

/*
percent concordant = 79.1
percent discordant = 20.9
percent tied = 0
Somers' D = 0.582
Gamma = 0.582
Tau-a = 0.267
c = 0.791
AUC = 0.7909
*/


/*generate coefficient of discrimination for training data*/
proc sort data=work.pred;
	by descending INS;
run;
proc ttest data=work.pred order=data;
	ods select statistics summarypanel;
	class INS;
	var p;
run;
/*D = 0.2349*/

/*uses the training model to predict the validation model)
provides "from" and "into" (F_INS and I_INS).
"from" is the actual INS, "into" is what SAS predicted based on 0.5 cutoff
also gives P_0 and P_1, which are the probabilities of 1's and zeros*/
proc logistic inmodel=work.logitmodel plots(only)=ROC;
	score data=lrhw3.insurance_v_bin out=valid_fit fitstat;
run;
proc logistic inmodel=work.logitmodel plots(only)=ROC;
	score data=lrhw3.insurance_v_bin out=valid_fit;
run;
* AUC = 0.770624;

/*calculates the best cutoff from training set*/
/*how do you calculate best cutoff with your selection model?*/ 

proc logistic data=lrhw3.insurance_t_bin plots(only) = (oddsratio);
	class
	CCPURC (param=ref ref='0') 
	MMCRED (param=ref ref='0')
	CC (param=ref ref='0') 
	CASHBK (param=ref ref='0')
	ACCTAGE_BIN (param=ref ref='1')
	ATMAMT_Bin (param=ref ref='1')
	CCBAL_Bin (param=ref ref='1')
	CDBAL_Bin (param=ref ref='1')
	INVBAL_Bin (param=ref ref='1')
	LOCBAL_Bin (param=ref ref='1')
	MTGBAL_Bin (param=ref ref='1')
	POSAMT_Bin (param=ref ref='1')
	POS_Bin (param=ref ref='1')
	SAVBAL_Bin (param=ref ref='1')
	DEPAMT_Bin (param=effect ref='1')
	DDABAL_Bin (param=effect ref='1')
	AGE_Bin (param=effect ref='1')
	CHECKS_Bin (param=effect ref='1')
	CRSCORE_Bin (param=effect ref='1')
	HMVAL_Bin (param=effect ref='1')
	INCOME_Bin (param=effect ref='1')
	PHONE_Bin (param=effect ref='1')
	TELLER_Bin (param=effect ref='1')
	BRANCH (param=effect ref='B1')
	RES (param=effect ref='R');
	model INS(event = '1') = MMCRED CCPURC CC CASHBK 
	ACCTAGE_BIN ATMAMT_Bin CCBAL_Bin CDBAL_Bin INVBAL_Bin LOCBAL_Bin MTGBAL_Bin POSAMT_Bin POS_Bin SAVBAL_Bin
	DEPAMT_Bin DDABAL_Bin AGE_Bin CHECKS_Bin CRSCORE_Bin HMVAL_Bin INCOME_Bin PHONE_Bin TELLER_Bin
	BRANCH RES
	/ ctable pprob=0 to 0.98 by 0.01;
	ods output classification = classtable;
run;
quit;

data classtable;
	set work.classtable;
	youden = sensitivity + specificity - 100;
	drop PPV NPV correct;
run;

proc sort data=work.classtable;
	by descending youden;
run;

proc print data=classtable (obs=15);
run;

/*0.300 is best probability cutoff based on youdens index*/
