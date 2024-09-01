# mrmed: Causal Mediation Analysis Using Parametric Multiply Robust Methods

`mrmed` is a Stata module designed to perform causal mediation analysis using parametric multiply robust methods.

## Syntax

```stata
mrmed varname, type(string) dvar(varname) mvar(varname) d(real) dstar(real) [options]
```

### Required Arguments

- `varname`: Specifies the outcome variable.
- `type(string)`: Specifies the type of multiply robust estimator. Options are `mr1` and `mr2`. 
  - For `mr1`, both the exposure and mediator must be binary and coded 0/1.
  - For `mr2`, only the exposure must be binary and coded 0/1.
- `dvar(varname)`: Specifies the treatment (exposure) variable, must be binary.
- `mvar(varname)`: Specifies the mediator variable, which must be binary for `mr1` and can be binary, ordinal, or continuous for `mr2`.
- `d(real)`: Reference level of treatment.
- `dstar(real)`: Alternative level of treatment, defines the treatment contrast.

### Options

- `cvars(varlist)`: Baseline covariates to be included in the analysis.
- `nointer`: Specifies excluding treatment-mediator interaction in the outcome model.
- `cxd`: Includes all two-way interactions between the treatment and baseline covariates.
- `cxm`: Includes all two-way interactions between the mediator and baseline covariates.
- `reps(integer)`: Number of replications for bootstrap resampling, default is 200.
- `strata(varname)`: Variable that identifies resampling strata.
- `cluster(varname)`: Variable that identifies resampling clusters.
- `level(cilevel)`: Confidence level for bootstrap confidence intervals, default is 95%.
- `seed(passthru)`: Seed for bootstrap resampling.
- `detail`: Prints fitted models used to construct the nuisance functions.

## Description

`mrmed` utilizes multiple regression models to estimate the causal mediation effects robustly:
- For `mr1`, it estimates:
  1. A logit model for the exposure conditional on baseline covariates.
  2. A logit model for the mediator conditional on the exposure and baseline covariates.
  3. A linear regression model for the outcome conditional on the exposure, mediator, and baseline covariates.
- For `mr2`, it estimates:
  1. A logit model for the exposure conditional on baseline covariates.
  2. A linear regression model for the outcome conditional on the exposure, mediator, and baseline covariates.
  3. A linear regression model for the predicted values from the previous model conditional on the exposure and baseline covariates.

These models are used to construct weights and imputations for robust estimating equations targeting the total, natural direct, and natural indirect effects.

## Examples

```stata
// Load data
use nlsy79.dta

// mr1 estimation with default settings
mrmed std_cesd_age40, type(mr1) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) reps(1000)

// mr2 estimation with default settings
mrmed std_cesd_age40, type(mr2) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) reps(1000)

// mr2 estimation with all two-way interactions
mrmed std_cesd_age40, type(mr2) dvar(att22) mvar(ever_unemp_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) cxd cxm reps(1000)
```

## Saved Results

`mrmed` saves the following results in `e()`:

- **Matrices**:
  - `e(b)`: Matrix containing direct, indirect, and total effect estimates.

## Author

Geoffrey T. Wodtke  
Department of Sociology  
University of Chicago

Email: [wodtke@uchicago.edu](mailto:wodtke@uchicago.edu)

## References

- Wodtke GT, Zhou X, and Elwert F. Causal Mediation Analysis. In preparation.

## Also See

- [regress R](#)
- [logit R](#)
- [bootstrap R](#)
