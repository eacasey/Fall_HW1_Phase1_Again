/* Checking all the variables for separation concerns by seeing if any of their levels  */
/* have 0s for either level of the target variables */

proc freq data=lrhw1.insurance_t_bin;
	tables (_all_)*ins;
run;

/* CASHBK(0 in 2nd level), MMCRED (0 on only in 5th level) */
/* These are only 2 variables with a full on 0 in their initial binned var */
/* Do transformation on them now to roll up the 2nd level into the first for Number of Cash Back */
/* and the 5th level of Money Market Credits  */

data lrhw1.insurance_t_rollup;
	set lrhw1.insurance_t_bin;
 	if cashbk = 2 then cashbk = 1; /* this adjusts for the only 2 obs that had a 2 for cashbk and were both 0's for ins */
	if mmcred = 5 then mmcred = 3; /* this adjusts for only 1 obs w/ a mmcred = 5 and rolls up to 3 since 0 obs = 4*/
run;

/* verify that all separation issues are met now */
proc freq data=lrhw1.insurance_t_rollup;
	tables (cashbk mmcred) * ins;
run;
