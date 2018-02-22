**********************************
*** written by Maik Hamjediers ***
***** last update 10.10.2017 *****
**********************************

cap program drop germap

program germap

syntax varlist(numeric) [if], by(varname)  [ WIDE PERCENT NOLABEL NOLEGEND mcolor(string asis) title(string) LABSize(real .8) CLM(string) CLNR(integer 4) PW(varname)]

local  mcolor  =  cond("`mcolor'" ==  "",  `"Greys"',  "`mcolor'") 
local  clm     =  cond("`clm'" ==  "",  `"q"',  "`clm'") 

if "`percent'" == "percent" {
local legendtitle "Werte in %"
}
else {
local legendtitle "Durchschnitt"
}


preserve

if "`if'" != "" {
quietly: keep `if'
}

if "`wide'" == "wide" {
gettoken first varlist : varlist
local varlist = substr("`first'",1,strlen("`first'")-1)
if "`pw'" == "" {
collapse `varlist'*
}
if "`pw'" != "" {
collapse `varlist'* [pw=`pw']
}
cap drop id
quietly: gen id = _n
quietly: reshape long `varlist', i(id) j(`by')
drop id
if "`percent'" == "percent" {
quietly: replace `varlist' = round(`varlist'*100,.01)
format %15.4g `varlist'
}
if "`percent'" != "percent" {
quietly: replace `varlist' = round(`varlist',.01)
format %15.4g `varlist'
}
}

if "`wide'" != "wide" {
if "`pw'" == "" {
collapse `varlist', by(`by')
}
if "`pw'" != "" {
collapse `varlist' [pw=`pw'] , by(`by')
}
cap drop id
if "`percent'" == "percent" {
quietly: replace `varlist' = round(`varlist' * 100,.01)
format %15.4g `varlist'
}
if "`percent'" != "percent" {
quietly: replace `varlist' = round(`varlist',.01)
format %15.4g `varlist'
}
}

quietly: foreach l of num 1 (1) 16 {
	count if `by' == `l'
	if `r(N)' == 0 {
		sort `by'
		expand 2 if _n == 1, gen(new)	
		gsort `by' -new
		replace `varlist' = . if new == 1
		replace `by' = `l' if new == 1
		drop new
	}
}	


quietly: recode `by' (1 = 6) (2 = 20) (3 = 10) (4 = 8) (5 = 1) (6 = 4) ///
	(7 = 9) (8 = 19) (9 = 11) (10 = 3) (11 = 2) (12 = 13) (13 = 18) ///
	(14 = 16) (15 = 17) (16 = 21)
quietly: expand 2 if inlist(`by', 1, 6, 19, 11, 17), gen(new)
quietly: replace `by' = 15 if new == 1 & `by' == 1
quietly: replace `by' = 12 if new == 1 & `by' == 6
quietly: replace `by' = 7 if new == 1 & `by' == 19
quietly: replace `by' = 14 if new == 1 & `by' == 11
quietly: replace `by' = 5 if new == 1 & `by' == 17
quietly: drop new


local p : sysdir PERSONAL
local path `"`p'"' 

if "`nolegend'" != "nolegend" {
if "`nolabel'" != "nolabel" {
spmap `varlist' using "`path'\ger_coords.dta", id(`by') cln(`clnr') clm(`clm') ///
fcolor(`mcolor') osize(thin)  ndoc(black) ndlabel("Keine Daten")  ///
      title(`title' ,size(*0.9))         ///
      legstyle(2) legend(pos(4) bm(0 -12 0 0) title(`legendtitle', size(small) m(5 0 0 0)))     ///
      plotregion(color(white)) graphregion(color(white) m(0 12 0 0))  ///
	  label(d("`path'/ger_data.dta") x(xlab) y(ylab) l(label) le(23) size(*`labsize') co(gs0))
}	  
if "`nolabel'" == "nolabel" {	  
spmap `varlist' using "`path'\ger_coords.dta", id(`by') cln(`clnr') clm(`clm') ///
fcolor(`mcolor') osize(thin) ndoc(black) ndlabel("Keine Daten")   ///
      title(`title' ,size(*0.9))         ///
      legstyle(3) legend(pos(4) bm(0 -12 0 0) title(`legendtitle', size(small) m(5 0 0 0)))     ///
      plotregion(color(white)) graphregion(color(white) m(0 12 0 0))
}
}

if "`nolegend'" == "nolegend" {
if "`nolabel'" != "nolabel" {
spmap `varlist' using "`path'\ger_coords.dta", id(`by') cln(`clnr') clm(`clm') ///
fcolor(`mcolor') osize(thin)  ndoc(black) ndlabel("Keine Daten")  ///
      title(`title' ,size(*0.9))         ///
      legend(off)   legenda(off)    ///
      plotregion(color(white)) graphregion(color(white))  ///
	  label(d("`path'/ger_data.dta") x(xlab) y(ylab) l(label) le(23) size(*`labsize') co(gs0))
}	  
if "`nolabel'" == "nolabel" {	  
spmap `varlist' using "`path'\ger_coords.dta", id(`by') cln(`clnr') clm(`clm') ///
fcolor(`mcolor') osize(thin)  ndoc(black) ndlabel("Keine Daten")  ///
      title(`title' ,size(*0.9))         ///
      legend(off)  legenda(off)    ///
      plotregion(color(white)) graphregion(color(white))
}
}
restore

end

exit



