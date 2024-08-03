*!TITLE: MRMED - causal mediation analysis using parametric multiply robust methods
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define mrmed_type2, rclass
	
	version 15	

	syntax varname(numeric) [if][in], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[cvars(varlist numeric)] ///
		[NOINTERaction] ///
		[cxd] ///
		[cxm]
	
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
		}
			
	local yvar `varlist'
	
	if ("`nointeraction'" == "") {
		tempvar inter
		qui gen `inter' = `dvar' * `mvar' if `touse'
		}

	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			tempvar `dvar'X`c'
			qui gen ``dvar'X`c'' = `dvar' * `c' if `touse'
			local cxd_vars `cxd_vars'  ``dvar'X`c''
			}
		}

	if ("`cxm'"!="") {	
		foreach c in `cvars' {
			tempvar `mvar'X`c'
			qui gen ``mvar'X`c'' = `mvar' * `c' if `touse'
			local cxm_vars `cxm_vars'  ``mvar'X`c''
			}
		}
		
	tempvar dvar_orig mvar_orig
	qui gen `dvar_orig' = `dvar'
	
	logit `dvar' `cvars' 
	
	tempvar phat_D1_C pi`d'_C pi`dstar'_C
	qui predict `phat_D1_C' if `touse', pr
	qui gen `pi`d'_C' = `phat_D1_C'*`d' + (1-`phat_D1_C')*(1-`d') if `touse'
	qui gen `pi`dstar'_C' = `phat_D1_C'*`dstar' + (1-`phat_D1_C')*(1-`dstar') if `touse'
		
	logit `dvar' `mvar' `cvars' `cxm_vars'
	
	tempvar phat_D1_CM pi`d'_CM pi`dstar'_CM
	qui predict `phat_D1_CM' if `touse', pr
	qui gen `pi`d'_CM' = `phat_D1_CM'*`d' + (1-`phat_D1_CM')*(1-`d') if `touse'
	qui gen `pi`dstar'_CM' = `phat_D1_CM'*`dstar' + (1-`phat_D1_CM')*(1-`dstar') if `touse'
		
	reg `yvar' `dvar' `mvar' `cvars' `inter' `cxd_vars' `cxm_vars' if `touse'
	
	qui replace `dvar' = `dstar' if `touse'
	if ("`nointeraction'" == "") {
		qui replace `inter' = `dvar' * `mvar' if `touse'
		}
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}			
	tempvar mu`dstar'_CM
	qui predict `mu`dstar'_CM' if `touse'
	
	qui replace `dvar' = `d' if `touse'
	if ("`nointeraction'" == "") {
		qui replace `inter' = `dvar' * `mvar' if `touse'
		}
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}	
	tempvar mu`d'_CM
	qui predict `mu`d'_CM' if `touse'
	
	qui replace `dvar' = `dvar_orig' if `touse'
	if ("`nointeraction'" == "") {
		qui replace `inter' = `dvar' * `mvar' if `touse'
		}
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}	
	
	reg `mu`d'_CM' `dvar' `cvars' `cxd_vars' if `touse'
	di "Model for mu`d'(C,M) given D and C"
	di ""
	
	qui replace `dvar' = `d' if `touse'
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}	
	
	tempvar nu`d'Ofmu`d'_C
	qui predict `nu`d'Ofmu`d'_C' if `touse'

	qui replace `dvar' = `dstar' if `touse'
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}	
	tempvar nu`dstar'Ofmu`d'_C
	qui predict `nu`dstar'Ofmu`d'_C' if `touse'

	qui replace `dvar' = `dvar_orig' if `touse'
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}	

	
	reg `mu`dstar'_CM' `dvar' `cvars' `cxd_vars' if `touse'
	di "Model for mu`dstar'(C,M) given D and C"
	di ""
	
	qui replace `dvar' = `dstar' if `touse'
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}	
	tempvar nu`dstar'Ofmu`dstar'_C
	qui predict `nu`dstar'Ofmu`dstar'_C' if `touse'

	qui replace `dvar' = `dvar_orig' if `touse'
	if ("`cxd'"!="") {	
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			}
		}	
	
	tempvar ipw`dstar'C ipw`d'C ipw`dstar'`d'CM
	
	qui gen `ipw`d'C' = 0 if `touse'
	qui replace `ipw`d'C' = 1/`pi`d'_C' if `dvar'==`d' & `touse'
	qui centile `ipw`d'C' if `ipw`d'C'!=. & `dvar'==`d' & `touse', c(1 99) 
	qui replace `ipw`d'C'=r(c_1) if `ipw`d'C'<r(c_1) & `ipw`d'C'!=. & `dvar'==`d' & `touse'
	qui replace `ipw`d'C'=r(c_2) if `ipw`d'C'>r(c_2) & `ipw`d'C'!=. & `dvar'==`d' & `touse'
		
	qui gen `ipw`dstar'C' = 0 if `touse'
	qui replace `ipw`dstar'C' = 1/`pi`dstar'_C' if `dvar'==`dstar' & `touse'
	qui centile `ipw`dstar'C' if `ipw`dstar'C'!=. & `dvar'==`dstar' & `touse', c(1 99) 
	qui replace `ipw`dstar'C'=r(c_1) if `ipw`dstar'C'<r(c_1) & `ipw`dstar'C'!=. & `dvar'==`dstar' & `touse'
	qui replace `ipw`dstar'C'=r(c_2) if `ipw`dstar'C'>r(c_2) & `ipw`dstar'C'!=. & `dvar'==`dstar' & `touse'
	
	qui gen `ipw`dstar'`d'CM' = 0 if `touse'
	qui replace `ipw`dstar'`d'CM' = (1/`pi`dstar'_C')*(`pi`dstar'_CM'/`pi`d'_CM') if `dvar'==`d' & `touse'
	qui centile `ipw`dstar'`d'CM' if `ipw`dstar'`d'CM'!=. & `dvar'==`d' & `touse', c(1 99) 
	qui replace `ipw`dstar'`d'CM'=r(c_1) if `ipw`dstar'`d'CM'<r(c_1) & `ipw`dstar'`d'CM'!=. & `dvar'==`d' & `touse'
	qui replace `ipw`dstar'`d'CM'=r(c_2) if `ipw`dstar'`d'CM'>r(c_2) & `ipw`dstar'`d'CM'!=. & `dvar'==`d' & `touse'
		
	tempvar dr`d'`d'_summand
	qui gen `dr`d'`d'_summand' = `ipw`d'C'*(`yvar' - `mu`d'_CM') ///
		+ `ipw`d'C'*(`mu`d'_CM' - `nu`d'Ofmu`d'_C') ///
		+ `nu`d'Ofmu`d'_C'
		
	tempvar dr`dstar'`dstar'_summand
	qui gen `dr`dstar'`dstar'_summand' = `ipw`dstar'C'*(`yvar' - `mu`dstar'_CM') ///
		+ `ipw`dstar'C'*(`mu`dstar'_CM' - `nu`dstar'Ofmu`dstar'_C') ///
		+ `nu`dstar'Ofmu`dstar'_C'

	tempvar dr`dstar'`d'_summand
	qui gen `dr`dstar'`d'_summand' = `ipw`dstar'`d'CM'*(`yvar' - `mu`d'_CM') ///
		+ `ipw`dstar'C'*(`mu`d'_CM' - `nu`dstar'Ofmu`d'_C') ///
		+ `nu`dstar'Ofmu`d'_C'
			
	qui reg `dr`d'`d'_summand'
	return scalar psi`d'`d' = _b[_cons]
	
	qui reg `dr`dstar'`dstar'_summand'
	return scalar psi`dstar'`dstar' = _b[_cons]

	qui reg `dr`dstar'`d'_summand'
	return scalar psi`dstar'`d' = _b[_cons]

end mrmed_type2
