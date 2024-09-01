{smcl}
{* *! version 0.1, 1 July 2024}{...}
{cmd:help for mrmed}{right:Geoffrey T. Wodtke}
{hline}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col : {cmd:mrmed} {hline 2}}causal mediation analysis using parametric multiply robust methods{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:mrmed} {varname} {ifin}{cmd:,} type(string) dvar({varname}) mvar({varname}) d({it:real}) dstar({it:real}) 
[cvars({varlist})) {opt nointer:action} {opt cxd} {opt cxm} {reps({it:integer 200}) strata({varname}) cluster({varname}) level(cilevel) seed({it:passthru}) detail]

{phang}{opt varname} - this specifies the outcome variable.

{phang}{opt type(string)} - this specifies which multiply robust estimator to implement. Options are mr1 and mr2. 
For type mr1, both the exposure and mediator must be binary (0/1). For type mr2, only the exposure must be binary (0/1).

{phang}{opt dvar(varname)} - this specifies the treatment (exposure) variable. This variable must be binary (0/1).

{phang}{opt mvar(varname)} - this specifies the mediator variable. This variable must be binary (0/1) for type mr1 robust estimation.
For type mr2, it may be binary, ordinal, or continuous.

{phang}{opt d(real)} - this specifies the reference level of treatment.

{phang}{opt dstar(real)} - this specifies the alternative level of treatment. Together, (d - dstar) defines
the treatment contrast of interest.

{title:Options}

{phang}{opt cvars(varlist)} - this option specifies the list of baseline covariates to be included in the analysis. Categorical 
variables need to be coded as a series of dummy variables before being entered as covariates.

{phang}{opt nointer:action} - this option specifies whether a treatment-mediator interaction is not to be
included in the outcome model (the default assumes an interaction is present).

{phang}{opt cxd} - this option specifies that all two-way interactions between the treatment and baseline covariates are
included in the mediator and outcome models.

{phang}{opt cxm} - this option specifies that all two-way interactions between the mediator and baseline covariates are
included in the outcome model.

{phang}{opt reps(integer 200)} - this option specifies the number of replications for bootstrap resampling (the default is 200).

{phang}{opt strata(varname)} - this option specifies a variable that identifies resampling strata. If this option is specified, 
then bootstrap samples are taken independently within each stratum.

{phang}{opt cluster(varname)} - this option specifies a variable that identifies resampling clusters. If this option is specified,
then the sample drawn during each replication is a bootstrap sample of clusters.

{phang}{opt level(cilevel)} - this option specifies the confidence level for constructing bootstrap confidence intervals. If this 
option is omitted, then the default level of 95% is used.

{phang}{opt seed(passthru)} - this option specifies the seed for bootstrap resampling. If this option is omitted, then a random 
seed is used and the results cannot be replicated. {p_end}

{phang}{opt detail} - this option prints the fitted models used to construct the terms in the multiply robust estimating equations. {p_end}

{title:Description}

{pstd}{cmd:mrmed} performs causal mediation analysis using multiply robust methods. {p_end}

{pstd}For type mr1 estimation, three models are estimated: (1) a logit model for the exposure conditional on baseline covariates (if specified), (2) 
a logit model for the mediator conditional on the exposure and baseline covariates, and (3) a linear regression model for the outcome conditional 
on the exposure, mediator, and baseline covariates (if specified). These models are then used to construct weights and imputations
for a set of multiply robust estimating equations that target the total, natural direct, and natural indirect effects. {p_end}

{pstd}For type mr2 estimation, five models are estimated: (1) a logit model for the exposure conditional on baseline covariates (if specified), (2) another logit
model for the exposure conditional on the mediator and baseline confounders, (3) a linear regression model for the outcome conditional on the exposure, 
mediator, and baseline covariates, (4) a linear regression model for the imputations from model (3) under the reference level of treatment, and (5)
a linear regression model for the imputations from model (3) under the alternative level of treatment. These models are then used to construct weights 
and imputations for another set of multiply robust estimating equations that also target the total, natural direct, and natural indirect effects. Because
type mr2 estimation does not require a model for the mediator, it can be used several different types of mediators (binary, ordinal, or continuous). {p_end}

{pstd}{cmd:mrmed} provides estimates of the the natural direct effect, the natural indirect effect, and the total effect. {p_end}

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use nlsy79.dta} {p_end}

{pstd} type mr1 estimation; percentile bootstrap CIs with default settings: {p_end}
 
{phang2}{cmd:. mrmed std_cesd_age40, type(mr1) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) reps(1000)} {p_end}

{pstd} type mr2 estimation; percentile bootstrap CIs with default settings: {p_end}
 
{phang2}{cmd:. mrmed std_cesd_age40, type(mr2) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) reps(1000)} {p_end}

{pstd} type mr2 estimation; all two-way interactions among the exposure, mediator, and confounders; percentile bootstrap CIs with default settings: {p_end}
 
{phang2}{cmd:. mrmed std_cesd_age40, type(mr2) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) cxd cxm reps(1000)} {p_end}

{title:Saved results}

{pstd}{cmd:mrmed} saves the following results in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}matrix containing direct, indirect and total effect estimates{p_end}


{title:Author}

{pstd}Geoffrey T. Wodtke {break}
Department of Sociology{break}
University of Chicago{p_end}

{phang}Email: wodtke@uchicago.edu


{title:References}

{pstd}Wodtke GT and Zhou X. Causal Mediation Analysis. In preparation. {p_end}

{title:Also see}

{psee}
Help: {manhelp regress R}, {manhelp logit R}, {manhelp bootstrap R}
{p_end}
