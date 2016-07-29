{smcl}
{* *! version 1.0 18 Feb 2016}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Help svy" "help svy"}{...}
{vieweralsosee "Help proportion" "help proportion"}{...}
{vieweralsosee "Help cii" "help cii"}{...}
{viewerjumpto "Syntax" "svyp##syntax"}{...}
{viewerjumpto "Description" "svyp##description"}{...}
{viewerjumpto "Options" "svyp##options"}{...}
{viewerjumpto "Stored Results" "svyp##results"}{...}
{viewerjumpto "Examples" "svyp##examples"}{...}
{viewerjumpto "Author" "svyp##author"}{...}
{viewerjumpto "References" "svyp##references"}{...}
{viewerjumpto "Related Commands" "svyp##related"}{...}
{title:Title}

{phang}
{bf:svyp} {hline 2} This command is a wrapper for Stata's {helpb svy proportion}
 command.{p_end}
 
{pmore2} It handles the special case where a variable encodes a binary outcome using 
 the values 0, 1, or missing.{p_end}
 
{pmore2} It estimates the proportion of the population represented by respondents coded 1.{p_end}

{pmore2} Its features include options to calculate not only the default logit 
confidence interval (CI), but also modified Wilson and modified Clopper-Pearson 
CIs.{p_end}

{pmore2} If the sample proportion is 0% or 100% then it reports CI limits 
that are calculated using Stata's {helpb cii} command.{p_end}
 
{pmore2} It returns numerous outputs, described below.{p_end}


{marker syntax}{...}
{title:Syntax}

{cmdab:svyp} {help varname} [{help if}] [, {help svyp##level:level}(real 95) {help svyp##method:method}(string)]

{pstd}varname is a variable that takes only the values 0 or 1 or missing.{p_end}
{p 8 17 2}

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Helpfile Sections}
{pmore}{help svyp##description:Description} {p_end}
{pmore}{help svyp##options:Options}{p_end}
{pmore}{help svyp##results:Stored Results}{p_end}
{pmore}{help svyp##examples:Examples}{p_end}
{pmore}{help svyp##author:Author}{p_end}
{pmore}{help svyp##references:References}{p_end}
{pmore}{help svyp##related:Related Commands}{p_end}

{marker description}{...}
{title:Description}

{pstd}We commonly estimate the proportion of 1's in a svyset dataset variable
and want to capture the weighted proportion as well as the 95% CI
and the 90% CI and sometimes an arbitrary user-specified% CI using the 
level(##.##) option.{p_end}

{pstd}The svy: proportion command does not report a CI when the sample
proportion is 0 or 1; this command does.{p_end}

{pstd}The svy: proportion command doesn't allow values of the level()
option to fall between 0 and 10; this command does.{p_end}

{pstd}The svy: proportion command uses the logit method of estimating CIs.
This command also calculates the modified Wilson and modified Clopper-Pearson 
CIs, as suggested in Korn and Graubard ({help svyp##1998:1998}) for situations where the estimated 
proportion is near 0 or 1.{p_end}

{pstd}(Those are not unanimously endorsed, but are reasonable 
choices.) In particular, the modified Clopper-Pearson has been reviewed
by several authors and found to always be conservative in that it yields
wide intervals, but by golly they cover the true population prevalence 
100*(1-alpha/2)% of the time. Other more narrow intervals may cover 
it {it:on average} that often, but may not be guaranteed to cover it as 
reliably.{p_end}

{pstd}This program first checks to see if the sample proportion is 0 or 1, 
in which case it uses the (unmodified) Clopper-Pearson calculation for the 
CI, via Stata's cii command. (Because the ICC is arguably very near 0 if 
the proportion is 0 or 1; this is probably not a horrible idea.){p_end}

{pstd}{browse "http://www.pmean.com/01/zeroevents.html"}{p_end}
{pstd}{browse "http://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval"}{p_end}
{pstd}{browse "http://www.stata.com/statalist/archive/2004-09/msg00176.html"}{p_end}

{pstd} To run this program, you will need to install the svyp package.{p_end}
{pstd} You may acquire the files from the Stata SSC Archive (type ssc install 
{cmd:svyp} from the Stata command line) or visit the 
{browse "http://biostatglobal.com": Biostat Global Consulting website} 
to find a link to a {bf:GitHub repository}. {p_end}
	
{hline}
{marker options}{...}
{title:Options} 
{marker level}
{dlgtab:level} 
{p 150 0 0}({it:{back:back to previous section}}) {p_end}
{pstd} {bf:level} - Confidence Interval({bf:CI}) level. Must be a numeric value between 00.01 and 99.99. {p_end}

{pmore}{bf: NOTE The default value is 95.}

{marker method}
{dlgtab:method} 
{p 150 0 0}({it:{back:back to previous section}}) {p_end}
{pstd} {bf:method} - Indicates the method in which the Confidence Interval({bf:CI}) will be calculated. {p_end}
{pmore2}There are only three valid options: {p_end}

{pmore3} 1. Logit {p_end}
{pmore3} 2. Wilson {p_end}
{pmore3} 3. Clopper {p_end}

{pmore} {bf:NOTE The default is Logit.}{p_end}

{hline}
{marker results}{...}
{title:Stored Results} 
{p 150 0 0}({it:{back:back to previous section}}) {p_end}
{pstd}If the sample proportion is 0 or 1, the {cmd:svyp} command returns the following scalars: {p_end}
{p2colset 16 35 75 2}
{p2col:r(svyp)}the estimated population prevalence of 1s {p_end}
{p2col:r(lb95)}lower bound of the 95% unmodified Clopper-Pearson CI {p_end}
{p2col:r(ub95)}upper bound of the 95% unmodified Clopper-Pearson CI {p_end}
{p2col:r(lb90)}lower bound of the 90% unmodified Clopper-Pearson CI {p_end}
{p2col:r(ub90)}upper bound of the 90% unmodified Clopper-Pearson CI {p_end}
{p2col:r(lblvl)}lower bound of user-specified% unmodified Clopper-Pearson CI (specify level(##.##)) {p_end}
{p2col:r(ublvl)}upper bound of user-specified% unmodified Clopper-Pearson CI {p_end}
{p2colset 16 35 75 2}
{p2col:r(df)}r(N)-1 {p_end}
{p2col:r(deff)}1 {p_end}
{p2col:r(N)}Number of 0's & 1's in the sample proportion calculation {p_end}
{p2col:r(clusters)}Number of clusters {p_end}

{pstd}If the sample proportion falls between 0 and 1, the program uses svy: 
proportion to calculate the point estimate and it calculates CI bounds using 
three methods: Logit, modified Clopper-Pearson, and modified Wilson. {p_end}

{pstd}{bf:NOTE The {cmd:svyp} command returns results for all three methods.} {p_end}

{pstd}If the sample proportion is between 0 and 1 then the program returns 21 scalar values: {p_end}
{p2colset 16 35 75 2}
{p2col:r(svyp)}the estimated population proportion of 1s {p_end}
{p2col:r(lb95)}95% CI lower bound using the requested method (default=logit) {p_end}
{p2col:r(ub95)}95% CI upper bound using the requested method {p_end}
{p2col:r(lb90)}90% CI lower bound using the requested method {p_end}
{p2col:r(ub90)}90% CI upper bound using the requested method {p_end}
{p2col:r(lblvl)}lower bound of user-specified% CI (specify level(##.##)) {p_end}
{p2col:r(ublvl)}upper bound of user-specified% CI {p_end}

{pstd}{bf:NOTE These six scalars will have the same values as six of those reported below.} {p_end}

{pstd}The logit estimates are reported if the user does not specify a 
method. If the user specifies Clopper or Wilson then the corresponding 
estimates will be reported in these scalars.{p_end}

{pstd}NOTE The requested output is provided twice for backward 
compatibility with programs that use an earlier version of the svyp 
program.{p_end}

{p2colset 16 35 75 2} 
{p2col:r(lb95_logit)}Logit estimate {p_end}
{p2col:r(ub95_logit)}Logit estimate {p_end}
{p2col:r(lb90_logit)}Logit estimate {p_end} 
{p2col:r(ub90_logit)}Logit estimate {p_end}
{p2col:r(lblvl_logit)}Logit estimate {p_end}
{p2col:r(ublvl_logit)}Logit estimate {p_end}

{p2colset 16 35 75 2}
{p2col:r(lb95_wilson)}Modified Wilson estimate {p_end}
{p2col:r(ub95_wilson)}Modified Wilson estimate {p_end}
{p2col:r(lb90_wilson)}Modified Wilson estimate {p_end} 
{p2col:r(ub90_wilson)}Modified Wilson estimate {p_end}
{p2col:r(lblvl_wilson)}Modified Wilson estimate {p_end}
{p2col:r(ublvl_wilson)}Modified Wilson estimate {p_end}

{p2colset 16 35 75 2}
{p2col:r(lb95_cp)}Modified Clopper-Pearson estimate {p_end}
{p2col:r(ub95_cp)}Modified Clopper-Pearson estimate {p_end}
{p2col:r(lb90_cp)}Modified Clopper-Pearson estimate {p_end}
{p2col:r(ub90_cp)}Modified Clopper-Pearson estimate {p_end}
{p2col:r(lblvl_cp)}Modified Clopper-Pearson estimate {p_end}
{p2col:r(ublvl_cp)}Modified Clopper-Pearson estimate {p_end}

{p2colset 16 35 75 2}	
{p2col:r(level)}The value of level that the user specified {p_end}
{p2col:r(df)}Degrees of freedom {p_end}
{p2col:r(deff)}Design Effect {p_end}
{p2col:r(N)}Number of 0s & 1s in the sample proportion calculation {p_end}
{p2col:r(clusters)}Number of clusters {p_end}
{p2col:r(Nwtd)}Sum of weights for observations used in the calculation {p_end}

{pstd} The program returns one macro, listing the method used to populate lb95, ub95, lb90, ub90, lblvl and ublvl {p_end}
{p2colset 16 35 75 2}
{p2col:r(method)}Logit or Wilson or Clopper, if the sample proportion is between 0 and 1 {p_end}
{p2col:r(method)}Clopper-Pearson assuming DEFF=1; ignoring sample design , if the sample proportion is 0 or 1{p_end}

{pstd} {bf:NOTE If the user does not specify level, it is set to 95 and r(lblvl)=r(lb95) and r(ublvl)=r(ub95) r(lb95_wilson)=r(lblvl_wilson), and so on.}

{hline}

{marker examples}{...}
{title:Examples}
{p 150 0 0}({it:{back:back to previous section}}) {p_end}
{marker author}
{title:Author}
{p}

Dale Rhoda, Biostat Global Consulting

Email: {browse "mailto:Dale.Rhoda@biostatglobal.com":Dale.Rhoda@biostatglobal.com}

Website: {browse "http://biostatglobal.com": http://biostatglobal.com} 

{hline}

{marker references}{...}
{title:References}
{p 150 0 0}({it:{back:back to previous section}}) {p_end}
{marker 1998}{...}
{pmore}Korn, E. L. and Graubard, B. I. (1998), "Confidence Intervals for Proportions With Small Expected Number of Positive Counts Estimated From Survey Data," Survey Methodology, 24, 193-201.

{pmore}Curtin, L. R., Kruszon-Moran, D., Carroll, M., and Li, X. (2006), "Estimation and Analytic Issues for Rare Events in NHANES," Proceedings of the Survey Research Methods Section, ASA, 2893-2903.  

{pmore}http://support.sas.com/documentation/cdl/en/statug/63962/HTML/default/viewer.htm#statug_surveyfreq_a0000000252.htm

{marker related}{...}
{title:Related commands}
{p 150 0 0}({it:{back:back to previous section}}) {p_end}
{help svy} 
{help proportion} 
{help cii} 

