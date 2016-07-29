*! svyp version 1.12 - Biostat Global Consulting - 2016-07-06
*******************************************************************************
* Change log
* 				Updated
*				version
* Date 			number 	Name				What Changed
* 2015-12-21	1.10	MK Trimner		added global set for VCP
*										global VCP svyp
*
*										put all errors to vcqi_log_comment
*
* 2016-01-15	1.11	D. Rhoda		Changed >=99.99 to >99.99 in error trap
* 										Added code for VCQI error trapping
*										so the program exits if not using VCQI
* 										and calls vcqi_halt_immediately if 
*  										the user is running VCQI
*
* 2016-07-06	1.12	Dale Rhoda		Added version statement
*										(I'm sure it could be earlier than 14
*         								 but not sure how much earlier...)
*
*******************************************************************************

********************************************************************************
*  We commonly estimate the proportion of 1's in a svyset dataset variable
*  and want to capture the weighted proportion as well as the 95% CI
*  and the 90% CI and sometimes an arbitrary user-specified% CI using the 
*  level(##.##) option.
*
*  The svy: proportion command chokes on the CI when the sample
*  proportion is 0 or 1, so this command handles those situations
*  gracefully.
* 
*  The svy: proportion command also doesn't allow values of the level()
*  option to fall between 0 and 10; this command does.
*
*  Also, the svy: proportion command uses the logit method of estimating CIs
*  which is less fashionable than following the guidance of Korn and Graubard
*  1998 and calculating a modified Wilson or modified Clopper-Pearson CIs when
*  the estimated proportion is near 0 or 1.
*  (Noting, that those are not unanimously endorsed, but are reasonable 
*   choices.)  In particular, the modified Clopper-Pearson has been reviewed
*  by several authors and found to always be conservative in that it yields
*  wide intervals, but by golly they cover the true population prevalence 
*  100*(1-alpha/2)% of the time.  Other more narrow intervals may cover 
*  it *on average* that often, but may not be guaranteed to cover it as 
*  reliably.
*
*  This program first checks to see if the sample proportion is 1 or 0, 
*  in which case it uses the (unmodified) Clopper-Pearson calculation for the 
*  CI, via Stata's cii command.  (Because the ICC is arguably very near 0 if 
*  the proportion is 0 or 1; this is probably not a horrible idea.)
*
*  http://www.pmean.com/01/zeroevents.html
*  http://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval
*  http://www.stata.com/statalist/archive/2004-09/msg00176.html
*
*  If the sample proportion is 0 or 1, the command returns the following 
*  scalars:
*
*           r(svyp)  = the estimated population prevalence of 1s 
*        	r(lb95)  = lower bound of the 95% Logit CI
*           r(ub95)  = upper bound of the 95% Logit CI
*           r(lb90)  = lower bound of the 90% Logit CI
*           r(ub90)  = upper bound of the 90% Logit CI
*           r(lblvl) = lower bound of user-specified% Logit CI (specify level(##.##))
*           r(ublvl) = upper bound of user-specified% Logit CI 
*		
*              r(df) =  r(N)-1
*            r(deff) =  1
*               r(N) =  Number of 0's & 1's in the sample proportion calculation
*
*  The command has two options:
*     -method(logit, wilson, clopper) where logit is the default
*     -level(##.##) where the level is between 00.01 and 99.99;
*                   95 is the default
*
*  If the sample proportion falls between 0 and 1, the program uses
*  svy: proportion to calculate the estimate and it estimates the CI 
*  bounds using three methods: Logit, modified Clopper-Pearson, and 
*  modified Wilson.  It returns results for all three.
*
*  If the sample proportion is between 0 and 1 then the program returns 
*  21 scalar values:
*
*           r(svyp)  = the estimated population prevalence of 1s 
*
*        	r(lb95)  = 95% CI lower bound using the requested method (default=logit)
*           r(ub95)  = 95% CI upper bound using the requested method
*           r(lb90)  = 90% CI lower bound using the requested method
*           r(ub90)  = 90% CI upper bound using the requested method
*           r(lblvl) = lower bound of user-specified% CI (specify level(##.##))
*           r(ublvl) = upper bound of user-specified% CI 
*
*    Note that these six scalars will have the same values as six of those
*    reported below.  If the user does not specify a method, then they will
*    be the default logit estimates.  If the user specified Clopper or Wilson
*    then the corrsponding estimates will be reported in these scalars.  The
*    reason to provide the requested output twice is for backward compatibility
*    with our programs that use an earlier version of the svyp program.
*
*      r(lb95_logit) =  Logit estimate
*      r(ub95_logit) =  Logit estimate  
*      r(lb90_logit) =  Logit estimate  
*      r(ub90_logit) =  Logit estimate 
*     r(lblvl_logit) =  Logit estimate 
*     r(ublvl_logit) =  Logit estimate
*
*     r(lb95_wilson) =  Modified Wilson estimate
*     r(ub95_wilson) =  Modified Wilson estimate  
*     r(lb90_wilson) =  Modified Wilson estimate  
*     r(ub90_wilson) =  Modified Wilson estimate 
*    r(lblvl_wilson) =  Modified Wilson estimate 
*    r(ublvl_wilson) =  Modified Wilson estimate
*	
*         r(lb95_cp) =  Modified Clopper-Pearson estimate
*         r(ub95_cp) =  Modified Clopper-Pearson estimate
*         r(lb90_cp) =  Modified Clopper-Pearson estimate
*         r(ub90_cp) =  Modified Clopper-Pearson estimate
*        r(lblvl_cp) =  Modified Clopper-Pearson estimate
*        r(ublvl_cp) =  Modified Clopper-Pearson estimate
*		
*           r(level) =  The value of level that the user specified
*              r(df) =  Degrees of freedom
*            r(deff) =  Design Effect
*               r(N) =  Number of 0's & 1's in the sample proportion calculation
*            r(Nwtd) =  Sum of weights for observations used in the calculation
*
*  The program returns one macro, listing the method used to populate
*  lb95, ub95, lb90, ub90, lblvl and ublvl
*
*	 r(method) = Logit, or
*                Wilson, or
*                Clopper, or (if sample proportion is 0 or 1:)
*                Clopper-Pearson assuming DEFF=1; ignoring sample design
*
*  If the user does not specify level, it is set to 95 and r(lblvl)=r(lb95) 
*  and r(ublvl)=r(ub95) r(lb95_wilson)=r(lblvl_wilson), and so on.
*
*  Biostat Global Consulting
*
*  Version 1.01 - 2014-11-01 Fixed a problem to allow spaces in string in [if]
*               -            Turned on one line of output; quietly works, too
*
*          1.02 - 2015-02-22 Added level option
*
*          1.03 - 2015-02-23 Added options for calculating modified Wilson or
*                            modified Clopper-Pearson intervals, consistent
*                            with Korn & Graubard 1998, Curtin et al. 2006, 
*                            and the SAS 9.3 documentation for PROC SURVEYFREQ
*
*                            I have only coded the option where the sample size
*                            *IS* adjusted for degrees of freedom (using the
*                            scalar named nestar); it would
*                            be simple to add an option where this is not true
*                            (similar to the ADJUST=NO option in SURVEYFREQ)
*
*                 Korn, E. L. and Graubard, B. I. (1998), "Confidence Intervals 
*                 for Proportions With Small Expected Number of Positive Counts 
*                 Estimated From Survey Data," Survey Methodology, 24, 193-201.
*
*                 Curtin, L. R., Kruszon-Moran, D., Carroll, M., and Li, X. 
*                 (2006), "Estimation and Analytic Issues for Rare Events in 
*                 NHANES," Proceedings of the Survey Research Methods Section, 
*                 ASA, 2893-2903.  
*
*                 http://support.sas.com/documentation/cdl/en/statug/63962/HTML/default/viewer.htm#statug_surveyfreq_a0000000252.htm
*
*          1.04 - 2015-03-12 moved `if' into subpop option
*
*          1.05 - 2015-03-13 Fixed Clopper F calculations
*
*          1.06 - Provide all estimates simultaneously and uses tempnames
*                 for scalars instead of hardcoded names (which could 
*                 easily get confused with variable names)
*
*          1.07 - Provide r(level) and r(Nwtd) as outputs
*
*          1.08 - Edited comments at top of program
*
*          1.09 - Added r(clusters) as an output
*
********************************************************************************

program svyp, rclass

	version 14.0
	syntax varlist (min=1 max=1 numeric) [if] [, level(real 95) method(string)]
	
	local v `varlist'
	
	* we need the local macro `if' to be populated in the code
	* so load it up if it is empty
	if `"`if'"' == "" local if `"if 1==1 "'

	* and load up the local macro ifand
	local ifand `if' &
	
	* establish temporary names for the following scalars
	* note that the program cleans up after itself and 
	* drops tempname scalars when the program exits
	
	tempname bigN smallN1 smallN0 smallNm phat DEFF df_N df_strata df_cluster 
	tempname ne ao2 nestar df
	tempname lb_F95 ub_F95 lb_F90 ub_F90 lb_F ub_F
	tempname terma95 terma90 terma termb95 termb90 termb termc95 termc90 termc
	tempname kappa95 kappa90 kappa
	tempname ublvl lblvl ub90 lb90 ub95 lb95 svyp t se yl yu
	tempname lb95_logit ub95_logit lb90_logit ub90_logit lblvl_logit ublvl_logit
	tempname lb95_cp ub95_cp lb90_cp ub90_cp lblvl_cp ublvl_cp
	tempname lb95_wilson ub95_wilson lb90_wilson ub90_wilson 
	tempname lblvl_wilson ublvl_wilson	
	tempname Nwtd

	* count observations
	qui count `if'
	scalar `bigN' = r(N)

	* count 1's
	qui count `ifand' `v' == 1
	scalar `smallN1' = r(N)
	
	* count 0's
	qui count `ifand' `v' == 0
	scalar `smallN0' = r(N)
	
	* count missing data
	qui count `ifand' missing(`v')
	scalar `smallNm' = r(N)
	
	* quit if all values of v are missing
	if `smallNm' == `bigN' {
		display as error "All values of `v' are missing.  Proportion calculation is not meaningful."
		if "VCQI_LOGOPEN" == "1" {
			vcqi_log_comment svyp 1 Error "All values of `v' are missing.  Proportion calculation is not meaningful."
			vcqi_halt_immediately
		}
		else exit 99
	}
	
	* quit if there are values of v that are not 0, 1, or missing
	if `smallN1' + `smallN0' + `smallNm' != `bigN' {
		display as error "To use the svyp command, the variable `v' should contain only 0's, 1's, and missing values."
		if "VCQI_LOGOPEN" == "1" {
			vcqi_log_comment svyp 1 Error "To use the svyp command, the variable `v' should contain only 0's, 1's, and missing values."
			vcqi_halt_immediately
		}
		else exit 99
	}

	
	* quit if the value of level is not meaningful;
	* be sure to trim level to two digits after decimal.
	local level = substr("`level'",1,5)
	

	if `level' <= 0 | `level' >99.99 {
		display as error "The value of level is `level'; it must be between 0 and 100."
		if "$VCQI_LOGOPEN" == "1" {
			vcqi_log_comment svyp 1 Error "The value of level is `level'; it must be between 0 and 100."	
			vcqi_halt_immediately
		}
		else exit 99
	}
	
	* load up method if empty
	if `"`method'"' == "" local method Logit
		
	* make sure method is valid
	local method = proper("`method'")
	if ! inlist("`method'","Logit","Wilson","Clopper","Clopper-Pearson") {
		display as error "The method option must be either Logit, Wilson, Clopper, or Clopper-Pearson."
		if "$VCQI_LOGOPEN" == "1" {
			vcqi_log_comment svyp 1 Error "The method option must be either Logit, Wilson, Clopper, or Clopper-Pearson."
			vcqi_halt_immediately
		}
		else exit 99
	}

	* If the sample proportion is 0 or 1 then we 
	* calculate the ucb or lcb (respectively) 
	* using the exact clopper-pearson method via the cii command.
	*
	* Note that when the sample proportion is 0 or 1, we treat
	* the sample as if DEFF = 1 and the limits can be calculated 
	* as if it were a simple random sample

	if `smallN0' == 0 | `smallN1' == 0 {

		qui ciifix `bigN' `smallN1', exact
		scalar `lb95' = r(lb)
		scalar `ub95' = r(ub)

		qui ciifix `bigN' `smallN1', exact level(90)
		scalar `lb90' = r(lb)
		scalar `ub90' = r(ub)

		qui ciifix `bigN' `smallN1', exact level(`level')
		scalar `lblvl'= r(lb)
		scalar `ublvl'= r(ub)		
		
		if `smallN1' == 0 {
			scalar `svyp' = 0
		}
		else {
			scalar `svyp' = 1
		}
		
		* populate the items to return to the user
		local method 
		
		* number of clusters in the calculation
		qui: svyset
		local cluster = r(su1)

		if "`cluster'" == "." local cluster
		
		* count the number of clusters involved in the prevalence estimation
		
		if "`cluster'" != "" {
			qui: tab `cluster' `if' & `v' != .
			scalar `df_cluster' = r(r)	
		}
		else scalar `df_cluster' = 0
		
		return scalar clusters = `df_cluster'		
		
		qui svy, subpop(`if') : total `v' 
		matrix out =e(_N_subp)
		scalar `Nwtd' = out[1,1]
		return scalar Nwtd = `Nwtd'
				
		* return the number of 0's and 1's in the calculation
		return scalar N = `smallN1' + `smallN0'
				
		return local method = "Clopper-Pearson assuming DEFF=1; ignoring sample design"
		return scalar deff = 1
		return scalar df   = `smallN1' + `smallN0' - 1
		return scalar level = `level'
		
		return scalar ublvl= `ublvl'
		return scalar lblvl= `lblvl'
		return scalar ub90 = `ub90'
		return scalar lb90 = `lb90'
		return scalar ub95 = `ub95'
		return scalar lb95 = `lb95'
		return scalar svyp = `svyp'

		di "svyp: " string(`svyp',"%5.3f") "  (" string(`lb95',"%5.3f") "-" string(`ub95',"%5.3f") ")  LCB: " string(`lb90',"%5.3f") " UCB: " string(`ub90',"%5.3f") "  `method'"
	
	}
	else {

		****************************************
		* 
		* Basic calculations of building blocks
		*
		****************************************

		qui svy, subpop(`if') : proportion `v' 

		matrix out = r(table)
		scalar `phat' = out[1,2]
		scalar `se'   = out[2,2]
		
		matrix out = e(_N_subp)
		scalar `Nwtd' = out[1,2]
		
		qui: estat effects, srssubpop
		matrix out = r(deffsub)
		scalar `DEFF' = out[1,2]
		
		qui: count `if' & `v' != .
		scalar `df_N' = r(N)
			
		* effective sample size
		scalar `ne' = `df_N'/`DEFF'
		
		* obtain name of cluster and strata variables for first stage of sampling
		qui: svyset
		local strata  = r(strata1)
		local cluster = r(su1)

		if "`strata'" == "." local strata
		if "`cluster'" == "." local cluster
		
		* count the number of strata and clusters involved in the prevalence estimation
		if "`strata'" != "" {
			qui: tab `strata' `if' & `v' != .
			scalar `df_strata' = r(r)
		}
		else scalar `df_strata' = 0
		
		if "`cluster'" != "" {
			qui: tab `cluster' `if' & `v' != .
			scalar `df_cluster' = r(r)	
		}
		else scalar `df_cluster' = 0
		
		* if strata and clusters then df = # clusters - # strata
		if "`strata'" != "" & "`cluster'" != "" {
			scalar `df' = `df_cluster' - `df_strata'
		}
		* if no clusters, then df = N - # strata
		if "`strata'" != "" & "`cluster'" == "" {
			scalar `df' = `df_N' - `df_strata'
		}
		* if not stratified, then df = # clusters - 1
		if "`strata'" == "" & "`cluster'" != "" {
			scalar `df' = `df_cluster' - 1
		}
		* if no clusters or strata, then df = N - 1
		if "`strata'" == "" & "`cluster'" == "" {
			scalar `df' = `df_N' - 1
		}
		
		* alpha over 2
		scalar `ao2' = (100-`level')/100/2
		
		* df adjusted sample size
		scalar `nestar' = `ne' * (invt(`=`df_N'-1',`ao2')/invt(`df',`ao2'))^2
		
		* truncate nestar to df_N if for some reason the DEFF was smaller than 1
		if `nestar' > `df_N' scalar `nestar' = `df_N'
	
		* Calculate confidence limits using all three methods
	
		*******************
		* Logit
		*******************
	
		* use default Stata calculation
			
		qui svy, subpop(`if'): proportion `v'
		matrix out = r(table)
		matrix out = out[1..6,2]
		scalar `svyp' = out[1,1]
		scalar `lb95_logit' = out[5,1]
		scalar `ub95_logit' = out[6,1]

		qui svy, subpop(`if'): proportion `v', level(90)
		matrix out = r(table)
		matrix out = out[1..6,2]
		scalar `lb90_logit' = out[5,1]
		scalar `ub90_logit' = out[6,1]
		
		* Use the formula from SAS documentation, Agresti (2002) and 
		* Korn and Graubard (1998) as described in the SAS SURVEYFREQ help. 
		* (This allows values of 'LEVEL' below 10)

		scalar `t'     = invt(`df',`ao2')
		scalar `yl'    = log(`phat'/(1-`phat')) + `t'*`se'/(`phat'*(1-`phat'))
		scalar `yu'    = log(`phat'/(1-`phat')) - `t'*`se'/(`phat'*(1-`phat'))
		scalar `lblvl_logit' = exp(`yl') / ( 1 + exp(`yl'))
		scalar `ublvl_logit' = exp(`yu') / ( 1 + exp(`yu'))		

		*******************
		* Clopper-Pearson 
		*******************
	
		* code up the equations from the SAS SURVEYFREQ documentation
		
		scalar `lb_F95' = invF(`=(2*`phat'*`nestar')'    ,`=(2*(`nestar'-`phat'*`nestar'+1))',`=1-.975')
		scalar `ub_F95' = invF(`=(2*(`phat'*`nestar'+1))',`=(2*(`nestar'-`phat'*`nestar'))'  ,0.975)
		
		scalar `lb95_cp' = 1/( 1+ ((`nestar' - `phat'*`nestar' + 1) /  (`phat'*`nestar'*`lb_F95'))    )
		scalar `ub95_cp' = 1/( 1+ ((`nestar' - `phat'*`nestar')     / ((`phat'*`nestar'+1)*`ub_F95')) )
		
		scalar `lb_F90' = invF(`=(2*`phat'*`nestar')'    ,`=(2*(`nestar'-`phat'*`nestar'+1))',`=1-0.95')
		scalar `ub_F90' = invF(`=(2*(`phat'*`nestar'+1))',`=(2*(`nestar'-`phat'*`nestar'))'  ,0.95)

		scalar `lb90_cp' = 1/( 1+ (`nestar' - `phat'*`nestar' + 1) /  (`phat'*`nestar'*`lb_F90')    )
		scalar `ub90_cp' = 1/( 1+ (`nestar' - `phat'*`nestar')     / ((`phat'*`nestar'+1)*`ub_F90') )
		
		scalar `lb_F' = invF(`=(2*`phat'*`nestar')'    ,`=(2*(`nestar'-`phat'*`nestar'+1))',`ao2')
		scalar `ub_F' = invF(`=(2*(`phat'*`nestar'+1))',`=(2*(`nestar'-`phat'*`nestar'))'  ,`=1-`ao2'')

		scalar `lblvl_cp'= 1/( 1+ (`nestar' - `phat'*`nestar' + 1) /  (`phat'*`nestar'*`lb_F' )    )
		scalar `ublvl_cp'= 1/( 1+ (`nestar' - `phat'*`nestar')     / ((`phat'*`nestar'+1)*`ub_F' ) )
		
	
		*******************
		* Wilson
		*******************
				
		scalar `kappa95' = invnormal(0.025)
		scalar `kappa90' = invnormal(0.050)
		scalar `kappa'   = invnormal(`ao2')
			
		* using the equation from Curtin 2006 as it seems clearer than the 
		* one in the SAS documentation for SURVEYFREQ
		*
		* each bound is a function of three terms
		*
		
		scalar `terma95' = 1/(1+((`kappa95'^2)/`nestar'))
		scalar `termb95' = (`phat'+ (`kappa95'^2)/(2*`nestar'))
		scalar `termc95' = (`kappa95'/sqrt(`nestar'))*sqrt((`phat'*(1-`phat')+((`kappa95'^2)/(4*`nestar'))))
		
		scalar `lb95_wilson'  = `terma95'*(`termb95'+`termc95')
		scalar `ub95_wilson'  = `terma95'*(`termb95'-`termc95')

		scalar `terma90' = 1/(1+((`kappa90'^2)/`nestar'))
		scalar `termb90' = (`phat'+ (`kappa90'^2)/(2*`nestar'))
		scalar `termc90' = (`kappa90'/sqrt(`nestar'))*sqrt((`phat'*(1-`phat')+((`kappa90'^2)/(4*`nestar'))))
		
		scalar `lb90_wilson'  = `terma90'*(`termb90'+`termc90')
		scalar `ub90_wilson'  = `terma90'*(`termb90'-`termc90')

		scalar `terma' = 1/(1+((`kappa'^2)/`nestar'))
		scalar `termb' = (`phat'+ (`kappa'^2)/(2*`nestar'))
		scalar `termc' = (`kappa'/sqrt(`nestar'))*sqrt((`phat'*(1-`phat')+((`kappa'^2)/(4*`nestar'))))
		
		scalar `lblvl_wilson'  = `terma'*(`termb'+`termc')
		scalar `ublvl_wilson'  = `terma'*(`termb'-`termc')
	
		* populate items to return to the user
		return scalar clusters = `df_cluster'
		
		* weighted N
		return scalar Nwtd = `Nwtd'
		
		* return the number of 0's and 1's in the calculation
		return scalar N = `smallN1' + `smallN0'		
		
		return local method = "`method'"
		return scalar deff = `DEFF'
		return scalar df   = `df'
		return scalar level = `level'

		return scalar ublvl_cp = `ublvl_cp'
		return scalar lblvl_cp = `lblvl_cp'
		return scalar ub90_cp = `ub90_cp'
		return scalar lb90_cp = `lb90_cp'
		return scalar ub95_cp = `ub95_cp'
		return scalar lb95_cp = `lb95_cp'

		return scalar ublvl_wilson = `ublvl_wilson'
		return scalar lblvl_wilson = `lblvl_wilson'
		return scalar ub90_wilson = `ub90_wilson'
		return scalar lb90_wilson = `lb90_wilson'
		return scalar ub95_wilson = `ub95_wilson'
		return scalar lb95_wilson = `lb95_wilson'
		
		return scalar ublvl_logit = `ublvl_logit'
		return scalar lblvl_logit = `lblvl_logit'
		return scalar ub90_logit  = `ub90_logit'
		return scalar lb90_logit  = `lb90_logit'
		return scalar ub95_logit  = `ub95_logit'
		return scalar lb95_logit  = `lb95_logit'
		
		* populate the unlabeled return scalars
				
		if "`method'" == "Logit" {
			scalar `ublvl' = `ublvl_logit'
			scalar `lblvl' = `lblvl_logit'
			scalar `ub90'  = `ub90_logit'
			scalar `lb90'  = `lb90_logit'
			scalar `ub95'  = `ub95_logit'
			scalar `lb95'  = `lb95_logit'
		}
		else if "`method'" == "Wilson" {
			scalar `ublvl' = `ublvl_wilson'
			scalar `lblvl' = `lblvl_wilson'
			scalar `ub90' = `ub90_wilson'
			scalar `lb90' = `lb90_wilson'
			scalar `ub95' = `ub95_wilson'
			scalar `lb95' = `lb95_wilson'
		}
		else if inlist("`method'","Clopper","Clopper-Pearson") {
			scalar `ublvl' = `ublvl_cp'
			scalar `lblvl' = `lblvl_cp'
			scalar `ub90' = `ub90_cp'
			scalar `lb90' = `lb90_cp'
			scalar `ub95' = `ub95_cp'
			scalar `lb95' = `lb95_cp'
		}
		
		return scalar ublvl = `ublvl'
		return scalar lblvl = `lblvl'
		return scalar ub90  = `ub90'
		return scalar lb90  = `lb90'
		return scalar ub95  = `ub95'
		return scalar lb95  = `lb95'
		
		return scalar svyp = `svyp'
	
		* Screen output (suppressed if svyp called 'quietly')
		
		
		if `level' == 95 {
			di "svyp: " string(`svyp',"%5.3f") "  (" string(`lb95',"%5.3f") "-" string(`ub95',"%5.3f") ")  LCB: " string(`lb90',"%5.3f") " UCB: " string(`ub90',"%5.3f") "  `method'"
		}
		else {
			di "svyp: "       string(`svyp' ,"%5.3f") "  ("            string(`lb95' ,"%5.3f") "-" string(`ub95',"%5.3f") ///
			")  LCB: "        string(`lb90' ,"%5.3f") " UCB: "         string(`ub90' ,"%5.3f") ///
			"   LCB_`level':" string(`lblvl',"%5.3f") " UCB_`level': " string(`ublvl',"%5.3f") "  `method'"
		}

	}	

end
