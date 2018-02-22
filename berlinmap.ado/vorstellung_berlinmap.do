clear

use "M:\ESF I+II\07_Daten\ESF_20151205_completed.dta", clear

replace bezi1 = . if bezi1 < 0
gen age = 2015-gebja if gebja > 0 & gebja != .

berlinmap age, by(bezi1) pw(weight)

*Grundbefehl
berlinmap age, by(bezi1)

*Ausdifferenzierung der Skala
berlinmap age, by(bezi1) clnr(9)

*Änderung der Farben
berlinmap age, by(bezi1) clnr(9) mcolor(Blues)
berlinmap age, by(bezi1) clnr(9) mcolor(BuRd)


*Wo leben die Jungen?
foreach num of numlist 1 (1) 12 {
gen youth_`num' = age < 40 & bezi1 == `num'
}
*Anhand der Option wide lassen sich auch diese Variablen für jeden Bezirk plotten
berlinmap youth_*, by(bezi1) mcolor(Blues) wide clnr(9)

*Angaben sind Prozent; Anpassung der Legende
berlinmap youth_*, by(bezi1) mcolor(Blues) wide percent clnr(9)

*Titel hinzufügen
berlinmap youth_*, by(bezi1) mcolor(Blues) wide percent title(Verteilung der unter 50 Jährigen über Berlin)


*Gegenüberstellung der Zufriedenheit mit Wohnumgebung, nach Alter
gen zufriedenheit = sat3
berlinmap zufriedenheit if age <= 50, by(bezi1) mcolor(Blues) title (50 Jahre oder jünger) clnr(5)

*Hinzufügen von Gewichtung
berlinmap zufriedenheit if age <= 50, by(bezi1) mcolor(Blues) title (50 Jahre oder jünger) clnr(5) pw(weight)
*Abspeichern des Graphen
graph save jung.gph, replace

*Zweiter Graph mal ohne label, da sie ja klar sein dürften
berlinmap zufriedenheit if age > 50, by(bezi1) nolabel mcolor(Blues) title (Älter als 50 Jahre) clnr(5) pw(weight)
graph save alt.gph, replace

*Kombinieren mit graph combine
graph combine jung.gph alt.gph, title("Zufriedenheit mit Wohnumgebung nach Bezirk und Alter") 

*Note noch hinzufügen
graph combine jung.gph alt.gph, title("Zufriedenheit mit Wohnumgebung nach Bezirk und Alter") note("Zufriedenheit auf einer Skala von 0 = sehr unzufrieden bis 10 = sehr zufrieden")
