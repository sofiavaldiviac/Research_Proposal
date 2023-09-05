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
		global git "/Users/svaldiv/Documents/GitHub/Research_Proposal/1_Migration"

	}
	
	global figures "$git/Figures_Tables"


// ================================================================
*		1. Open matriculation data
// ================================================================

// for now let's see with 2019
import delimited "$dbox/Source/Matricula_Integrados/20191028_Matrícula_unica_2019_20190430_PUBL.CSV", clear

// keep only the immigrants
keep if cod_nac_alu == "E"

// for merge
ren rbd rbd_enrolled_2019


// ================================================================
*		2. Merge with SAE
// ================================================================

preserve
    import delimited "/Users/svaldiv/Dropbox/CHI_School_Search/1_Data/2_Admin School Data/src/SAE/2019/C1_Postulaciones_etapa_regular_2019_Admisión_2020_PUBL.csv", clear
    tempfile sae
    save `sae'
restore

merge 1:m mrun using `sae', keep(1 3) nogen
ren rbd rbd_applied

// ================================================================
*		3. Merge assignment
// ================================================================


preserve
    import delimited "/Users/svaldiv/Dropbox/CHI_School_Search/1_Data/2_Admin School Data/src/SAE/2019/D1_Resultados_etapa_regular_2019_Admisión_2020_PUBL.csv", clear
    tempfile d1
    save `d1'
restore

merge m:1 mrun using `d1', keep(1 3) 

keep if _merge == 3

drop if pais_origen_alu == 6


save "/Users/svaldiv/Desktop/check_sae_migration.dta", replace

bys rbd_applied: egen total_applied = count(mrun) if preferencia_postulante == 1
bys rbd_admitido_regular: egen total_admitido = count(mrun) if preferencia_postulante == 1 & assign_to_applied == 1

destring rbd_admitido cod_curso_admitido rbd_admitido_post_resp cod_curso_admitido_post_resp respuesta_postulante_post_lista_, replace

gen rbd_admitido_regular = rbd_admitido
replace rbd_admitido_regular = rbd_admitido_post_resp if !mi(rbd_admitido_post_resp)


gen respuesta_postulante_regular = respuesta_postulante
replace respuesta_postulante_regular = respuesta_postulante_post_lista_ if !mi(respuesta_postulante_post_lista_)
drop rbd_admitido rbd_admitido_post_resp

gen assign_to_applied = rbd_admitido_regular == rbd_applied