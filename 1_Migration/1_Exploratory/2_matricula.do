// ================================================================
// ================================================================
*				Exploring Enrollment
// ================================================================
// ================================================================



// ----------------------------------------------------------------
// File Description
// ----------------------------------------------------------------
	// Project: 		Research Ideas - Migration
	// Objective: 		
	// Created:			Jun 16, 2023
	// Last Modified:	Jun 16, 2023 (SV)
// ----------------------------------------------------------------
// Settings
// ----------------------------------------------------------------
	set more off
	clear all
	set more off
	*set matsize 3000
	*set maxvar 8000
	graph set window fontface Palatino
	*ssc inst grstyle
	*colorpalette "#e0f3db" "#bae4bc" "#7bccc4" "#43a2ca" "#0868ac"
	set_defaults graphics
	grstyle set color YlGnBu, n(10)
	net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
	set scheme cleanplots, perm
	adoupdate palettes colrspace
	*colorpalette lin brands
	net install palettes, replace from("https://raw.githubusercontent.com/benjann/palettes/master/")
	net install colrspace, replace from("https://raw.githubusercontent.com/benjann/colrspace/master/")

// ----------------------------------------------------------------	
// Set roots
// ----------------------------------------------------------------

	
	if "`c(username)'"=="svaldiv" {
		global dbox "/Users/svaldiv/Dropbox/Research Ideas/1_Migration"
		global git "/Users/svaldiv/Documents/GitHub/Research_Proposal/1_Migration"

	}
	
	global figures "$git/Figures_Tables"


// ================================================================
*		1. Load one year and explore
// ================================================================

* mrun_ipe desde el 2018

*import delimited using "/Users/svaldiv/Dropbox/Research Ideas/1_Migration/Source/Matricula_Integrados/20140808_matricula_unica_2013_20130430_PUBL.csv", clear

import delimited using "$dbox/Source/Matricula_Integrados/20200921_Matrícula_unica_2020_20200430_PUBL_MRUN.CSV", clear

// cod_nac_alu = nacionalidad de los estudiantes
    // is this the correct variable to use to consider migrant students?
encode cod_nac_alu, gen(migrant) 
recode migrant (1 = 0) (3 = 0) (2 = 1)
_strip_labels migrant

// browse migrant students - country
count if mrun_ipe == " " & migrant == 1 // 130,042 migrant students without mrun_ipe (?)
ta pais_origen_alu if migrant == 1 // majority is venezuela from another country
count if pais_origen_alu == 6 & migrant == 1 // 89,965 students from Chile but foreign? 
    // is this if they're born in Chile but international parents? how to tell


// browse migrant students - region of school
ta nom_reg_rbd_a if migrant == 1 // santiago and antofagasta are the most common regions
ta cod_reg_alu if migrant == 1 // santiago and antofagasta are the most common regions

// ================================================================
*		2. Graph by region
// ================================================================

// bar graph of migrant by region -- for graphing purposes graph 1- 7 8-13

label define region 1 "Tarapacá" 2 "Antofagasta" 3 "Atacama" 4 "Coquimbo" 5 "Valparaíso" 6 "O'Higgins" 7 "Maule" 8 "Biobío" 9 "Araucanía" 10 "Los Lagos" 11 "Aysén" 12 "Magallanes" 13 "Metropolitana" 14 "Los Ríos" 15 "AyP" 16 "Ñuble"
label values cod_reg_alu region

// collapse by country of origin and region of residence
ta pais_origen_alu if migrant == 1
ta pais_origen_alu if migrant == 0
gen n = 1
keep if migrant == 1
collapse (count) n_students = n, by(cod_reg_alu pais_origen_alu)

// save for easy manipulation
*save "/Users/svaldiv/Dropbox/Research Ideas/1_Migration/Worked/Enrollment/enrollment_migrant_region.dta", replace

drop if cod_reg_alu == 0 // those with no info
drop if pais_origen_alu == 0 // those with no info

// for simplicity let's make for 6 countries
ta pais_origen_alu
// Chile = 6, Venezuela = 27, Bolivia = 4, Colombia = 8, Peru = 22, Haiti = 16
keep if inlist(pais_origen_alu,6,27,4,8,22,16)

recode pais_origen_alu (6 = 1) (27 = 2) (4 = 3) (8 = 4) (22 = 5) (16 = 6)
tostring pais_origen_alu, replace 
replace pais_origen_alu = "Chile" if pais_origen_alu == "1"
replace pais_origen_alu = "Venezuela" if pais_origen_alu == "2"
replace pais_origen_alu = "Bolivia" if pais_origen_alu == "3"
replace pais_origen_alu = "Colombia" if pais_origen_alu == "4"
replace pais_origen_alu = "Peru" if pais_origen_alu == "5"
replace pais_origen_alu = "Haití" if pais_origen_alu == "6"

encode pais_origen_alu, gen(id)
order id 
drop pais_origen_alu


*** (a) preserve the labels...
levelsof id, local(idlabels)      // store the id levels
di `idlabels'
 
foreach x of local idlabels {       
   local idlab_`x' : label id `x'  
   }
 
*** (b) and reshape
reshape wide n_students, i(cod_reg_alu) j(id)

*** (c) and attach the labels back again to the variables
foreach x of local idlabels {  
  display "`x'"
  lab var n_students`x'  "`idlab_`x''"    // label these  
  }
order cod_reg_alu n_students*

****
graph set window fontface Palatino
ds n_students*
local items : word count `r(varlist)'
display `items'


local colors = `items' + 1
*colorpalette viridis, nograph
*colorpalette "253 253 150" "255 197   1" "255 152   1" "  3 125  80" "  2  75  48", n(`colors')
colorpalette lin fruits

foreach x of numlist 1/`items' {
 

*** here the code for bar colors
 local barcolor `barcolor' bar(`x', fcolor("`r(p`x')'") lcolor(black) lwidth(*0.1)) `///' 
 
 
 
*** here the code for legend
*foreach x of numlist 1/`items' {
 local mylab : var lab n_students`x'
 local legend `legend' lab(`x' "`mylab'")
}

*** the final graph we want:
/*
** in N   
graph bar (mean) n_students* if (cod_reg_alu >= 1 & cod_reg_alu <= 7) | cod_reg_alu == 15 , ///
 over(cod_reg_alu, label(labsize(small)) axis(lcolor(none))) bargap(-20)  ///
  ytitle(N Students, size(small)) ylabel(0(1700) 8500, labsize(small) format(%12.0fc)) ///
  blabel(bar, size(1.5) orientation(vertical) margin(vsmall) format(%12.0fc)) ysc(r(0(1700)8500)) ///
  legend(`legend' col(1) size(vsmall) pos(11) ring(0) region(fcolor(none))) xsize(2) ysize(1)  
   graph export "$figures/Enrollment/migrant_region_1_8_2020.png", replace

graph bar (mean) n_students* if cod_reg_alu >= 8 & cod_reg_alu != 13 & cod_reg_alu != 15, ///
 over(cod_reg_alu, label(labsize(small)) axis(lcolor(none))) bargap(-20)  ///
  ytitle(N Students, size(small)) ylabel(0(1700) 8500, labsize(small) format(%12.0fc)) ///
  blabel(bar, size(1.5) orientation(vertical) margin(vsmall) format(%12.0fc)) ysc(r(0(1700)8500)) ///
  legend(`legend' col(1) size(vsmall) pos(11) ring(0) region(fcolor(none))) xsize(2) ysize(1)  
   graph export "$figures/Enrollment/migrant_region_9_16_not13_2020.png", replace   

graph bar (mean) n_students* if cod_reg_alu == 13, ///
 over(cod_reg_alu, label(labsize(small)) axis(lcolor(none))) bargap(-20)  ///
  ytitle(N Students, size(small)) ylabel(0(11000) 55000, labsize(small) format(%12.0fc)) ///
  blabel(bar, size(1.5) orientation(vertical) margin(vsmall) format(%12.0fc)) ysc(r(0(11000)55000)) ///
  legend(`legend' col(1) size(vsmall) pos(11) ring(0) region(fcolor(none))) xsize(2) ysize(1)  
   graph export "$figures/Enrollment/migrant_region_13_2020.png", replace   
*/
** in percentages

graph bar (mean) n_students* if (cod_reg_alu >= 1 & cod_reg_alu <= 7) | cod_reg_alu == 15 , ///
 over(cod_reg_alu, label(labsize(small)) axis(lcolor(none))) bargap(-20)  ///
  ytitle("% Students", size(small)) ylabel(0(20) 100, labsize(small) format(%12.0fc)) ///
  blabel(bar, size(1.5) orientation(vertical) margin(vsmall) format(%12.0fc)) ysc(r(0(20)100)) ///
  legend(`legend' col(1) size(vsmall) pos(11) ring(0) region(fcolor(none))) xsize(2) ysize(1) asyvars percentages   
   graph export "$figures/Enrollment/migrant_region_1_8_percent_2020.png", replace

graph bar (mean) n_students* if cod_reg_alu >= 8 & cod_reg_alu != 15, ///
 over(cod_reg_alu, label(labsize(small)) axis(lcolor(none))) bargap(-20)  ///
  ytitle("% Students", size(small)) ylabel(0(20) 100, labsize(small) format(%12.0fc)) ///
  blabel(bar, size(1.5) orientation(vertical) margin(vsmall) format(%12.0fc)) ysc(r(0(20)100)) ///
  legend(`legend' col(1) size(vsmall) pos(11) ring(0) region(fcolor(none))) xsize(2) ysize(1) asyvars percentages 
   graph export "$figures/Enrollment/migrant_region_9_16_percent_2020.png", replace  
