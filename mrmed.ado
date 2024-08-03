*!TITLE: MRMED - causal mediation analysis using parametric multiply robust methods
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define mrmed, eclass

	version 15	

	syntax varname(numeric) [if][in], ///
		type(string) ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[cvars(varlist numeric)] ///
		[NOINTERaction] ///
		[cxd] ///
		[cxm] ///
		[reps(integer 200)] ///
		[strata(varname numeric)] ///
		[cluster(varname numeric)] ///
		[level(cilevel)] ///
		[seed(passthru)] ///
		[saving(string)] ///
		[detail]

	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}

	
	local mrtypes mr1 mr2
	local nmrtype : list posof "`type'" in mrtypes
	if !`nmrtype' {
		display as error "Error: type must be chosen from: `mrtypes'."
		error 198		
		}
	
	if ("`type'"=="mr1") {
	
		foreach i in `dvar' `mvar' {
			confirm variable `i'
			qui sum `i'
			if r(min) != 0 | r(max) != 1 {
				display as error "{p 0 0 5 0} The variable `i' is not binary and coded 0/1"
				error 198
				}
			}

		if ("`detail'"!="") {
			mrmed_type1 `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
				d(`d') dstar(`dstar') `nointeraction' `cxd' `cxm'
			}
			
		if ("`saving'" != "") {
			bootstrap ///
				ATE=(r(psi`d'`d')-r(psi`dstar'`dstar')) ///
				NDE=(r(psi`dstar'`d')-r(psi`dstar'`dstar')) ///
				NIE=(r(psi`d'`d')-r(psi`dstar'`d')), ///
				reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
				saving(`saving', replace) noheader notable: ///
				mrmed_type1 `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
				d(`d') dstar(`dstar') `nointeraction' `cxd' `cxm'
				}

		if ("`saving'" == "") {
			bootstrap ///			
				ATE=(r(psi`d'`d')-r(psi`dstar'`dstar')) ///
				NDE=(r(psi`dstar'`d')-r(psi`dstar'`dstar')) ///
				NIE=(r(psi`d'`d')-r(psi`dstar'`d')), ///
				reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
				noheader notable: ///
				mrmed_type1 `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
				d(`d') dstar(`dstar') `nointeraction' `cxd' `cxm'
				}
			
		estat bootstrap, p noheader

		}

	if ("`type'"=="mr2") {

		foreach i in `dvar' {
			confirm variable `i'
			qui sum `i'
			if r(min) != 0 | r(max) != 1 {
				display as error "{p 0 0 5 0} The variable `i' is not binary and coded 0/1"
				error 198
				}
			}
				
		if ("`detail'"!="") {
			mrmed_type2 `varlist' if `touse', ///
			dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
			d(`d') dstar(`dstar') `nointeraction' `cxd' `cxm'
			}	
			
		if ("`saving'" != "") {
			bootstrap ///
				ATE=(r(psi`d'`d')-r(psi`dstar'`dstar')) ///
				NDE=(r(psi`dstar'`d')-r(psi`dstar'`dstar')) ///
				NIE=(r(psi`d'`d')-r(psi`dstar'`d')), ///
				reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
				saving(`saving', replace) noheader notable: ///
				mrmed_type2 `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
				d(`d') dstar(`dstar') `nointeraction' `cxd' `cxm'
				}

		if ("`saving'" == "") {
			bootstrap ///			
				ATE=(r(psi`d'`d')-r(psi`dstar'`dstar')) ///
				NDE=(r(psi`dstar'`d')-r(psi`dstar'`dstar')) ///
				NIE=(r(psi`d'`d')-r(psi`dstar'`d')), ///
				reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
				noheader notable: ///
				mrmed_type2 `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
				d(`d') dstar(`dstar') `nointeraction' `cxd' `cxm'
				}
			
		estat bootstrap, p noheader

		}
		
end mrmed
