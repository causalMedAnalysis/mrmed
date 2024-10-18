# mrmed: A Stata Module for Causal Mediation Analysis using Parametric Multiply Robust Methods

## Overview

`mrmed` is a Stata module that performs causal mediation analysis using parametric multiply robust methods. It supports two different types of robust estimation (`mr1` and `mr2`), which are described below.

## Syntax

```stata
mrmed depvar mvars [if] [in], type(string) dvar(varname) d(real) dstar(real) [options]
```

### Required Arguments

- `type(string)`: Specifies which multiply robust estimator to implement. Options are `mr1` and `mr2`.
  - For `type(mr1)`: both the exposure and a univariate mediator must be binary (0/1).
  - For `type(mr2)`: only the exposure must be binary (0/1), and multiple mediators are allowed.
- `depvar`: Specifies the outcome variable.
- `mvars`: Specifies the mediator(s), which can be multivariate when using `type(mr2)`.
- `dvar(varname)`: Specifies the treatment (exposure) variable, which must be binary (0/1).
- `d(real)`: Specifies the reference level of treatment.
- `dstar(real)`: Specifies the alternative level of treatment. Together, (d - dstar) defines the treatment contrast of interest.

### Options

- `cvars(varlist)`: Specifies the list of baseline covariates to include in the analysis. Categorical variables must be coded as dummy variables.
- `nointeraction`: Specifies whether a treatment-mediator interaction is not included in the outcome model. By default, interactions are included.
- `cxd`: Includes all two-way interactions between the treatment and baseline covariates in the mediator and outcome models.
- `cxm`: Includes all two-way interactions between the mediators and baseline covariates in the outcome model.
- `censor(numlist)`: Specifies that the inverse probability weights used in the robust estimating equations are censored at the percentiles provided in `numlist'.
- `reps(integer 200)`: Specifies the number of bootstrap replications (default is 200).
- `detail`: Prints the fitted models used to construct the nuisance terms in the robust estimating equations.
- `bootstrap_options`: All `bootstrap` options are available.

## Description

`mrmed` performs causal mediation analysis using multiply robust methods, and it computes inferential statistics using the nonparametric bootstrap. 

For `type(mr1)` estimation, three models are estimated: 
1. A logit model for the exposure conditional on the baseline covariates (if specified).
2. A logit model for a single binary mediator conditional on the exposure and baseline covariates.
3. A linear regression model for the outcome conditional on the exposure, the single mediator, and baseline covariates.

These models are then used to construct weights and imputations for a set of multiply robust estimating equations that target the total, natural direct, and natural indirect effects.

For `type(mr2)` estimation, five models are estimated:
1. A logit model for the exposure conditional on baseline covariates (if specified).
2. Another logit model for the exposure conditional on the mediator(s) and baseline confounders.
3. A linear regression model for the outcome conditional on the exposure, mediator(s), and baseline covariates.
4. A linear regression model for the imputations from model (3) under the reference level of treatment.
5. A linear regression model for the imputations from model (3) under the alternative level of treatment.

These models are then used to construct weights and imputations for another set of multiply robust estimating equations that also target total and natural effects. Because `type(mr2)` estimation does not require modeling the distribution of the mediator(s), it can be used with multiple mediators and these variables may be binary, ordinal, or continuous. When a single mediator is specified, `type(mr2)` estimation targets natural direct and indirect effects. When multiple mediators are specified, it targets multivariate natural direct and indirect effects operating through all mediators considered together.

## Examples

### Example 1: type(mr1) estimation, percentile bootstrap CIs

```stata
. use nlsy79.dta
. mrmed std_cesd_age40 ever_unemp_age3539, type(mr1) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) reps(1000)
```

### Example 2: type(mr1) estimation, percentile bootstrap CIs, censoring the weights

```stata
. mrmed std_cesd_age40 ever_unemp_age3539, type(mr1) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor(1 99) reps(1000)
```

### Example 3: type(mr2) estimation, percentile bootstrap CIs, censoring the weights

```stata
. mrmed std_cesd_age40 ever_unemp_age3539, type(mr2) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) censor(1 99) reps(1000)
```

### Example 4: type(mr2) estimation, all two-way interactions, percentile bootstrap CIs, censoring the weights

```stata
. mrmed std_cesd_age40 ever_unemp_age3539, type(mr2) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) cxd cxm censor(1 99) reps(1000)
```

### Example 5: type(mr2) estimation with multiple mediators, all two-way interactions, percentile bootstrap CIs, censoring the weights

```stata
. mrmed std_cesd_age40 ever_unemp_age3539 log_faminc_adj_age3539, type(mr2) dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) cxd cxm censor(1 99) reps(1000)
```

## Saved Results

The following results are saved in `e()`:

- **Matrices:**
  - `e(b)`: Matrix containing total, direct, and indirect effect estimates.

## Author

**Geoffrey T. Wodtke**  
Department of Sociology  
University of Chicago  
Email: [wodtke@uchicago.edu](mailto:wodtke@uchicago.edu)

## References

- Wodtke GT and Zhou X. *Causal Mediation Analysis*. In preparation.

## See Also

- Stata manual: [regress](https://www.stata.com/manuals/rregress.pdf), [logit](https://www.stata.com/manuals/rlogit.pdf), [bootstrap](https://www.stata.com/manuals/rbootstrap.pdf)
