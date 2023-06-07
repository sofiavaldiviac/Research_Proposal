// ================================================================
// ================================================================
*				Distribution by nationality
// ================================================================
// ================================================================



// ----------------------------------------------------------------
// File Description
// ----------------------------------------------------------------
	// Project: 		Research Ideas - Migration
	// Objective: 		
	// Created:			Jun 6, 2023
	// Last Modified:	Jun 6, 2023 (SV)
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

	}
	
	global figures "$dbox/Figures_Tables"


// ================================================================
*		1. Refugees
// ================================================================

import excel "$dbox/Source/Refugio/Solicitantes_Refugio_WEB.xlsx", sheet("Sheet1") firstrow clear case(lower)
gen n = 1

collapse (count) n_refugees = n, by(año país_de_nacionalidad)

** for simplicity lets make 5 countries now
keep if país_de_nacionalidad == "Venezuela" | país_de_nacionalidad == "Cuba" | país_de_nacionalidad == "Colombia" | país_de_nacionalidad == "Haití" | país_de_nacionalidad == "Siria" | país_de_nacionalidad == "Ucrania" | país_de_nacionalidad == "República Dominicana"

encode país_de_nacionalidad, gen(id)
order id 
drop país_de_nacionalidad


*** (a) preserve the labels...
levelsof id, local(idlabels)      // store the id levels
di `idlabels'
 
foreach x of local idlabels {       
   local idlab_`x' : label id `x'  
   }
 
*** (b) and reshape
reshape wide n_refugees, i(año) j(id)

*** (c) and attach the labels back again to the variables
foreach x of local idlabels {  
  display "`x'"
  lab var n_refugees`x'  "`idlab_`x''"    // label these  
  }
order año n_refugees*

****
graph set window fontface Palatino
ds n_refugees*
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
 local mylab : var lab n_refugees`x'
 local legend `legend' lab(`x' "`mylab'")
}

*** the final graph we want:

graph bar (mean) n_refugees* if año <= 2015, ///
 over(año, label(labsize(small)) axis(lcolor(none))) bargap(-20) `barcolor' ///
  ytitle(N Refugees, size(small)) ylabel(, format(%12.0fc)) ///
  blabel(bar, size(1.7) orientation(vertical) margin(vsmall) format(%12.0fc)) ///
  legend(`legend' col(1) size(vsmall) pos(11) ring(0) region(fcolor(none))) xsize(2) ysize(1)
   graph export "$figures/nationality_2015.png", replace
   
   
graph bar (mean) n_refugees* if año >= 2016 & año <= 2022, ///
 over(año, label(labsize(small)) axis(lcolor(none))) bargap(-20)  ///
  ytitle(N Refugees, size(small)) ylabel(, format(%12.0fc)) ///
  blabel(bar, size(1.7) orientation(vertical) margin(vsmall) format(%12.0fc)) ///
  legend(`legend' col(1) size(vsmall) pos(11) ring(0) region(fcolor(none))) xsize(2) ysize(1)  
   graph export "$figures/nationality_2016_2022.png", replace


// ================================================================
*		2. Temporary 
// ================================================================


** append datasets
import excel "$dbox/Source/Residencias-Definitivas/residencias_definitivas_otorgadas_2000_al_2011.xlsx", sheet("Sheet1") firstrow clear case(lower)

// ================================================================
*		3. Permanent 
// ================================================================










