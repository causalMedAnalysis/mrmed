{smcl}
{* *! version 0.1, 1 July 2024}{...}
{cmd:help for mrmed}{right:Geoffrey T. Wodtke}
{hline}

{title:Title}

{p2colset 5 18 18 2}{...}
{p2col : {cmd:mrmed} {hline 2}} causal mediation analysis using parametric multiply robust methods{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 18 2}
{cmd:mrmed} {depvar} {help indepvars:mvars} {ifin}{cmd:,} 
{opt type(string)} 
{opt dvar(varname)} 
{opt d(real)} 
{opt dstar(real)} 
{opt cvars(varlist)} 
{opt nointer:action} 
{opt cxd} 
{opt cxm} 
{opt censor(numlist)}
{opt detail}
[{it:{help bootstrap##options:bootstrap_options}}]

{phang}{opt type(string)} - this specifies which multiply robust estimator to implement. Options are mr1 and mr2. 
For type(mr1), both the exposure and a univariate mediator must be binary (0/1). 
For type(mr2), only the exposure must be binary (0/1), and multiple mediators are permitted.

{phang}{opt depvar} - this specifies the outcome variable.

{phang}{opt mvars} - this specifies the mediator(s), which can be multivariate with type(mr2) robust estimation.

{phang}{opt dvar(varname)} - this specifies the treatment (exposure) variable. This variable must be binary (0/1).

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

{phang}{opt censor} - this option specifies that the inverse probability weights used in the robust estimating equations are censored at their 1st and 99th percentiles.

{phang}{opt censor(numlist)} - this option specifies that the inverse probability weights used in the robust estimating equations are censored at the percentiles supplied in {numlist}. For example,
censor(1 99) censors the weights at their 1st and 99th percentiles.

{phang}{opt detail} - this option prints the fitted models used to construct the nuisance terms in the robust estimating equations.

{phang}{it:{help bootstrap##options:bootstrap_options}} - all {help bootstrap} options are available. {p_end}

{title:Description}

{pstd}{cmd:mrmed} performs causal mediation analysis using multiply robust methods, and it computes inferential statistics using the nonparametric bootstrap. {p_end}

{pstd}For type(mr1) estimation, three models are estimated: (1) a logit model for the exposure conditional on the baseline covariates (if specified), (2) 
a logit model for a single binary mediator conditional on the exposure and baseline covariates, and (3) a linear regression model for the outcome conditional 
on the exposure, the single mediator, and baseline covariates. These models are then used to construct weights and imputations for a set of multiply 
robust estimating equations that target the total, natural direct, and natural indirect effects. {p_end}

{pstd}For type(mr2) estimation, five models are estimated: (1) a logit model for the exposure conditional on baseline covariates (if specified), (2) another logit
model for the exposure conditional on the mediator(s) and baseline confounders, (3) a linear regression model for the outcome conditional on the exposure, 
mediator(s), and baseline covariates, (4) a linear regression model for the imputations from model (3) under the reference level of treatment, and (5)
a linear regression model for the imputations from model (3) under the alternative level of treatment. These models are then used to construct weights 
and imputations for another set of multiply robust estimating equations that also target total and natural effects. Because type(mr2) estimation does not require modeling 
the mediator(s), it can be used with multiple mediators and these variables may be binary, ordinal, or continuous. When a single mediator is specified, type(mr2) 
estimation targets natural direct and indirect effects. When multiple mediators are specified, it targets multivariate natural direct and indirect effects
operating through all mediators considered together. {p_end}

{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use nlsy79.dta} {p_end}

{pstd} type(mr1) estimation, percentile bootstrap CIs: {p_end}
 
{phang2}{cmd:. mrmed std_cesd_age40 ever_unemp_age3539, type(mr1) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) reps(1000)} {p_end}

{pstd} type(mr1) estimation, percentile bootstrap CIs, censoring the weights: {p_end}
 
{phang2}{cmd:. mrmed std_cesd_age40 ever_unemp_age3539, type(mr1) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor(1 99) reps(1000)} {p_end}

{pstd} type(mr2) estimation, percentile bootstrap CIs, censoring the weights: {p_end}
 
{phang2}{cmd:. mrmed std_cesd_age40 ever_unemp_age3539, type(mr2) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor(1 99) reps(1000)} {p_end}

{pstd} type(mr2) estimation, all two-way interactions, percentile bootstrap CIs, censoring the weights: {p_end}
 
{phang2}{cmd:. mrmed std_cesd_age40 ever_unemp_age3539, type(mr2) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) cxd cxm censor(1 99) reps(1000)} {p_end}

{pstd} type(mr2) estimation with multiple mediators, all two-way interactions, percentile bootstrap CIs, censoring the weights: {p_end}
 
{phang2}{cmd:. mrmed std_cesd_age40 ever_unemp_age3539 log_faminc_adj_age3539, type(mr2) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) cxd cxm censor(1 99) reps(1000)} {p_end}

{title:Saved results}

{pstd}{cmd:mrmed} saves the following results in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}matrix containing total, direct, and indirect effect estimates{p_end}


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
