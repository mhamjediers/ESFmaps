**********************************
*** written by Maik Hamjediers ***
***** last update 07.12.2015 *****
**********************************

cap program drop berlinmap

program berlinmap
version 12

syntax varlist(numeric) [if], by(varname)  [ WIDE PERCENT NOLABEL NOLEGEND mcolor(string asis) title(string) CLNR(integer 1) PW(varname)]

local  mcolor  =  cond("`mcolor'" ==  "",  `"Greys"',  "`mcolor'") 
local  clnr  =  cond(`clnr' ==  1,  4,  `clnr') 

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
quietly: reshape long `varlist', i(id) j(bezirke)
drop id
if "`percent'" == "percent" {
quietly: replace `varlist' = round(`varlist'*100,.01)
format %15.4g `varlist'
}
if "`percent'" != "percent" {
quietly: replace `varlist' = round(`varlist',.01)
format %15.4g `varlist'
}
rename bezirke id
}

if "`wide'" != "wide" {
if "`pw'" == "" {
collapse `varlist', by(`by')
}
if "`pw'" != "" {
collapse `varlist' [pw=`pw'] , by(`by')
}
cap drop id
gen id = `by'
if "`percent'" == "percent" {
quietly: replace `varlist' = round(`varlist' * 100,.01)
format %15.4g `varlist'
}
if "`percent'" != "percent" {
quietly: replace `varlist' = round(`varlist',.01)
format %15.4g `varlist'
}
}


local p : sysdir PERSONAL
local path `"`p'"' 


if "`nolegend'" != "nolegend" {
if "`nolabel'" != "nolabel" {
spmap `varlist' using "`path'\uscoord.dta", id(id) cln(`clnr') ///
fcolor(`mcolor') osize(thin)    ///
      title(`title' ,size(*0.9))         ///
      legstyle(3) legend(pos(2) title(`legendtitle', size(small)))     ///
      plotregion(color(white)) graphregion(color(white))  ///
	  label(data("`path'\labelcoord.dta") x(_X) y(_Y) l(_LABEL) le(19) size(vsmall) co(gs0))
}	  
if "`nolabel'" == "nolabel" {	  
spmap `varlist' using "`path'\uscoord.dta", id(id) cln(`clnr') ///
fcolor(`mcolor') osize(thin)    ///
      title(`title' ,size(*0.9))         ///
      legstyle(3) legend(pos(2) title(`legendtitle', size(small)))     ///
      plotregion(color(white)) graphregion(color(white))
}
}

display

if "`nolegend'" == "nolegend" {
if "`nolabel'" != "nolabel" {
spmap `varlist' using "`path'\uscoord.dta", id(id) cln(`clnr') ///
fcolor(`mcolor') osize(thin)    ///
      title(`title' ,size(*0.9))         ///
      legend(off)   legenda(off)    ///
      plotregion(color(white)) graphregion(color(white))  ///
	  label(data("`path'\labelcoord.dta") x(_X) y(_Y) l(_LABEL) le(19) size(vsmall) co(gs0))
}	  
if "`nolabel'" == "nolabel" {	  
spmap `varlist' using "`path'\uscoord.dta", id(id) cln(`clnr') ///
fcolor(`mcolor') osize(thin)    ///
      title(`title' ,size(*0.9))         ///
      legend(off)  legenda(off)    ///
      plotregion(color(white)) graphregion(color(white))
}
}
restore

end

exit



