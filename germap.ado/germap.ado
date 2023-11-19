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



