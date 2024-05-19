
    print ('      +------------------------------------------------------------+')
    print ('      |             PCCDPACK - INPE - Version 2024-05              |')
    print ('      +------------------------------------------------------------+')
    print (' ')

	language
	print ('language')
	#bool motd = no
	st4gem
	print ('st4gem')
	graphics
	print ('graphics')
	stplot
	print ('stplot')
	digiphot
	print ('digiphot')
	digiphot.daophot
	daophot
	print ('daophot')
	#apphot
	#print ('apphot')
	fitting
	print ('fitting')
#	ctio
#	print ('ctio')
	astutil
	print ('astutil')
#	gasp
#	print ('gasp')
	apphot
	print ('apphot')
#		
	set     pccdpack_inpe          = "/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/"
	set		inpe_fortran		   = "pccdpack_inpe$fortran/"
#
	package pccdpack_inpe
#
### Rotinas cl ###
#
	task	acha_shift		= "pccdpack_inpe$acha_shift.cl"
	task	auto_pol		= "pccdpack_inpe$auto_pol.cl"	
	task	clestat			= "pccdpack_inpe$clestat.cl"
	task	coords_real		= "pccdpack_inpe$coords_real.cl"
	task	cria_dat		= "pccdpack_inpe$cria_dat.cl"
	task	disp_var		= "pccdpack_inpe$disp_var.cl"
	task	fintab_sopol	= "pccdpack_inpe$fintab_sopol.cl"
	task	graf_inpe		= "pccdpack_inpe$graf_inpe.cl"
#	task	grafv_inpe		= "pccdpack_inpe$grafv_inpe.cl"
	task	iv_prep			= "pccdpack_inpe$iv_prep.cl"
	task	macrol_inpe		= "pccdpack_inpe$macrol_inpe.cl"
	task	mapa_combina	= "pccdpack_inpe$mapa_combina.cl"
	task	multi_soma		= "pccdpack_inpe$multi_soma.cl"
	task	ordem_inpe		= "pccdpack_inpe$ordem_inpe.cl"
	task	ordem3			= "pccdpack_inpe$ordem3.cl"
	task	ordshift		= "pccdpack_inpe$ordshift.cl"
	task	plota_luz		= "pccdpack_inpe$plota_luz.cl"
	task	plota_pol		= "pccdpack_inpe$plota_pol.cl"
	task	phot_pol		= "pccdpack_inpe$phot_pol.cl"
	task	padrao_pol		= "pccdpack_inpe$padrao_pol.cl"
	task	pccdgen_inpe	= "pccdpack_inpe$pccdgen_inpe.cl"
	task	pccd_var		= "pccdpack_inpe$pccd_var.cl"
	task	refer_inpe		= "pccdpack_inpe$refer_inpe.cl"
	task	select_inpe		= "pccdpack_inpe$select_inpe.cl"
	task	soma_iv			= "pccdpack_inpe$soma_iv.cl"
	task	sel_ftb			= "pccdpack_inpe$sel_ftb.cl"
	task	time_pol		= "pccdpack_inpe$time_pol.cl"	
	task	zerofind_inpe	= "pccdpack_inpe$zerofind_inpe.cl"
	
### Parameter set ###

	task	pospars_inpe	= "pccdpack_inpe$pospars_inpe"
	
### Rotinas em fortran ###
	
	task	$coords_padrao	= "$/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/fortran/coords_padrao.e $(*)"
	task	$estat_cl		= "$/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/fortran/estat_cl.e $(*)"
	task	$ordem_ie		= "$/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/fortran/ordem_ie.e $(*)"
	task    $combina_pol	= "$/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/fortran/combina_pol.e $(*)"
	task	$polmed			= "$/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/fortran/polmed.e $(*)"
	task    $phot_pol_e     = "$/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/fortran/phot_pol_e.e $(*)"
	task	$limpa_mapa		= "$/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/fortran/limpa_mapa.e $(*)"
	
	pccdgen_inpe.fileexe = "/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/fortran/pccd4000gen15_inpe.e"

	clbye()
end
