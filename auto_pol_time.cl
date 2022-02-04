## Programa automatizador do calculo de serie temporal de polarizacao
## Baseado em:
## (1) fonte original escrita por Victor de Souza Magalhaes em 18/06/2011 e  19/10/2011
## 
## (2) adaptacao feita para serie temporal em 09/05/2014 por Karleyne M. G. Silva
##
## (3) versao da fonte (1) por Claudia V. Rodrigues - Dez/2014
#
############
# Modificacoes de dez/2014 na adaptacao feita por Claudia
#
# programar tipo de lamina
# corrigir passos
#
##########################################################

procedure auto_pol_time

string	object				{prompt="Root to output files"}
string	lista="@arq"		{prompt="Image list - use @"}
string	imagem				{prompt="Reference image to register"}
pset    pospars_inpe		{prompt="Good waveplate positions - :e"}
int     nume_lam			{prompt="Total number of images"}
int     nimage=8.           {prompt="Number of images to calculate 1 polarization point. Use: 4, 8 or 16"}
real	deltatheta=0.		{prompt="PA correction to the equatorial reference frame"}
bool	norma=yes			{prompt="Use normalization in polarization calculation - yes/no"}
bool	nova=yes			{prompt="Measurements done using the new drawer (after 2007)"}
real	readnoise=1			{prompt="Readout noise - ADU"}
real	gan=1				{prompt="Gain - e/ADU"}
real	anel=60				{prompt="Annulus - Inner radius of the sky annulus"}
real	danel=10			{prompt="Dannulus - Width of the sky annulus"}
bool	autoabe=yes			{prompt="Automatically define apertures: yes/no"}
int		nab=10				{max=20, prompt="Number of apertures"}
int		passoab=1			{prompt="Aperture step"}
int		deltab=-2			{prompt="Displacement of the first aperture relative to the FWHM"}
string	aberturas			{prompt="Apertures list - max = 20"}
bool	verify=yes			{prompt="Verify daophot parameters - yes/no"}
real	delx=2				{prompt="Maximum x shift to forming pairs"}
real	dely=2				{prompt="Maximum y shift to forming pairs"}
real	delmag=0.5			{prompt="Maximum difference in magnitudes"}
string  desloca='xregister'	{enum="no|xregister|acha_shift", prompt="Method to calculate images shifts"}
string	regiao				{prompt="Image sector to register images"}
int		janela				{prompt="Cross-correlation window size"}
int		tamanho=2048		{prompt="CCD sizes in pixels"}
bool	confirma=yes		{prompt="Verify registering using TVMARK in each image: yes/no"}
int		passo=1				{min=1,max=5, prompt="Start at (1:all;2:pairs;3:reg;4:phot;5:pol)"}
#int		nestrelas			{prompt="Number of stars. Use only if passo > 4"}
bool	circular=no			{prompt="No: half-wave plate; Yes: quarter-wave plate."}
real	zero=0.				{prompt="Zero position of quarter-wave plate"}
string  fileexe             {prompt="pccd execute file (.exe)"}

struct *flist1
struct *flist2

begin

	struct line
	string lixo,dados,lado,lixo2,temp,varima,vtmpfile,namev,arq_coord,wavetype,estat_file
	real lixoreal,fwhm,sigma,shx,shy,retardancia,zero_par
	bool fazclest,faz,coofaz,l2
	int ap,i, next_ap, nestrelas

#### defining apphot e daophot parameters 
	
	faz=yes
	fazclest=yes
	
	if(verify){
		daophot.verify = yes
	}
	else{
		daophot.verify = no
	}
#
	daophot.datapars.epadu = gan
	daophot.datapars.readnoi = readnoise
	daophot.findpars.thresho = 4
	daophot.datapars.datamax = 60000
	daophot.datapars.datamin = 0
	daophot.centerpars.calgori="centroid"
	daophot.fitskypars.annulus = anel
	daophot.fitskypars.dannulus = danel
#	
	apphot.datapars.epadu = gan
	apphot.datapars.readnoi = readnoise
	apphot.findpars.thresho = 4
	apphot.datapars.datamax = 60000
	apphot.datapars.datamin = 0
	apphot.centerpars.calgori="centroid"
	apphot.fitskypars.annulus = anel
	apphot.fitskypars.dannulus = danel
#	
#####
    print("")
    print("=== Calculating some image statistics using the reference image. ===")	
    print("=== You can pick any stars... ===")	
    print("=== In this step, it not necessary to pick up pairs. ===")	
    print("")
    estat_file=imagem//".estat"
	if(access(estat_file)){
		print("CLESTAT already done. Redo? yes/no(default)")
		fazclest=no
		lixo2 = scan(fazclest)
	}
	if (fazclest){
		clestat(imagem,marca=no)
		rename("estat.log",estat_file)
	}
	
	flist1 = estat_file
	lixo = fscan(flist1)
	dados = fscan(flist1,shx,shy)
	lixo = fscan(flist1)
	dados = fscan(flist1,lixoreal,sigma,fwhm)
	
	if(shx > 0) lado="right"
	if(shx < 0) lado="left"
	shx=abs(shx)
	
	# print(lado)
#
###############
## Configuring parameters according to image statistics
##
	daophot.datapars.fwhmpsf = fwhm
	daophot.datapars.sigma = sigma
	apphot.datapars.fwhmpsf = fwhm
	apphot.datapars.sigma = sigma
	print(" Sky  -  Sky_sigma=sqrt(sky)")
	print(datapars.sigma,datapars.fwhmpsf)

	ap=int(fwhm)
	if(autoabe){
#	
##### Setting apertures
####	photpars.apertur=ap-2//","//ap-1//","//ap//","//ap+1//","//ap+2//","//ap+3//","//ap+4//","//ap+5//","//ap+6//","//ap+7
		daophot.photpars.apertur=""
		i=0
		while(i<nab){
			next_ap=ap+deltab+passoab*i
			if(i<(nab-1))daophot.photpars.apertur=daophot.photpars.apertur//next_ap//","
			if(i==(nab-1))daophot.photpars.apertur=daophot.photpars.apertur//next_ap
#			print(next_ap)
#			print(daophot.photpars.apertur)
			i=i+1
		}
#		print(daophot.photpars.apertur)
	}
	if(autoabe==no)	daophot.photpars.apertur = aberturas
	apphot.photpars.apertur=daophot.photpars.apertur
#
#	
#
###  FINDING STARS #####
#
#### inicio - a seguir versao original do auto_pol para encontrar TODAS as estrelas do campo	
#	if(passo==1){
#	    print("")
#		print("=== Finding stars")
#	    print("")
#		if(access(object//".coo")) delete(object//".coo",ver-)
#		daophot.daofind(image=imagem,output=object//".coo")
#	}
###
#####  MAKING PAIRS
###
#	if(passo<3){
#	    print("")
#		print("=== Making pairs of ordinary and extraordinary images")
#	    print("")
#		unlearn ordem3		
#		ordem3(shiftx=shx,shifty=shy,deltax=delx,deltay=dely,deltamag=delmag,pripar=no,side=lado,file_in=object//".coo", file_out=object)
#	}
#	
#### fim da versao original do auto_pol para encontrar TODAS as estrelas do campo
# 
# versao nova - define objetos clicando
#
#
	if(passo<3){
	            faz=yes
                if (access(object//".ord")) faz=no
                if (faz == no) {
                   print("Coordinate file exists. Redo?")
                   lixo2 = scan(faz)
                }
                if (faz) {
                 print(" ")
                 print("******************************* ")
                 print("############################### ")
				 print("Select stars to calculate polarimetry and photometry.")
                 print("Use: variable - first star")
                 print("     flux reference - second star")
                 print("     field stars - third and subsequent stars.")
                 print("############################### ")
                 print("******************************* ")
                 print(" ")
                 delete("temp_clestat.dao",ver-)
                 copy("clestat.dao","temp_clestat.dao")
                 clestat(imagem=imagem,marca=yes)
                 delete(object//".ord",ver-)
                 !sed '/^ *$/d' clestat.dao > tmpdao
                 copy("tmpdao",object//".ord")
                 delete("clestat.dao",ver-)
                 delete("tmpdao",ver-)
                 copy("temp_clestat.dao","clestat.dao")
                 delete("temp_clestat.dao",ver-)
                }
    }
#
###   Achando os deslocamentos entre as imagens com acha shift###
####  AND APLYING THE SHIFTS TO THE COORDINATE FILE
#
	if(passo<4){
#
    if (desloca != 'no') {
    faz=yes
    print("")
    print("=== Finding shifts between images")	
    print("")
	if(access(object//"_acha.shift") || access(object//"_xreg.shift")){
		faz=no
		print("ACHA_SHIFT or XREGISTER already done. Redo? y/no - no (default)")
		lixo2 = scan(faz)
	}
	if(faz){
		if(desloca == 'acha_shift'){
			print(" ")
			print("Running Acha Shift...")
			print(" ")
			if(access(object//"_acha.shift")) delete(object//"_acha.shift",ver-)
			acha_shift(imgref=imagem,images=lista,shifts=object,confirm="no")
			unlearn pccdpack_inpe.ordshift
			ordshift(infile=object//"_acha.shift",coorfil=object//".ord",xside=tamanho,yside=tamanho)
			} else
		if(desloca == 'xregister'){
			print(" ")
			print("Calculing the shifts between images using Xregister")
			print(" ")
			delete(object//"_xreg.shift",ver-)
			unlearn xregister
			xregister(input=lista,referenc=imagem,regions=regiao,shifts=object//"_xreg.shift",\
				databas=no,xwindow=janela,ywindow=janela)
#
			unlearn pccdpack_inpe.ordshift
			pccdpack_inpe.ordshift(infile=object//"_xreg.shift",\
				coorfil=object//".ord",xside=tamanho,yside=tamanho)
		} ## FECHA IF DESLOCA
		nestrelas=ordshift.nobj
	} # FECHA IF FAZ
	} else {
		nestrelas = ordem_inpe.npar
    } # FECHA IF DESLOCA != NO
	} # FECHA IF PASSO < 4
###
#### CONFERINDO DESLOCAMENTO VISUALMENTE ######
#
	if(confirma) {
		tvmark.mark = "circle"
		tvmark.radii = 20
		tvmark.color = 206
        # Create list of input star images in a temporary file
        varima=lista
        vtmpfile = mktemp ("/tmp/tmpvar")
        files (varima, > vtmpfile)
        flist1 = vtmpfile
        #
        varima="@inord"
        vtmpfile = mktemp ("/tmp/tmpvar")
        files (varima, > vtmpfile)
        flist2 = vtmpfile
        arq_coord=" "
# 
#	 	print(" ")
		print("Go to DS9 to check the register.")
		print(" ")
#
        while (fscan(flist1, namev) != EOF) 
        {
		  lixo = fscan(flist2, arq_coord)
		  print(namev,"  ",arq_coord," Type Enter for next image.")
          display(namev,frame=1)
          tvmark(1,arq_coord)          
		  lixo = scan(coofaz)  # le variavel ja usada
        }
        delete(vtmpfile,ver-)
	}
#
###### APERTURE PHOTOMETRY
#		
	if(passo<5){
			print(" ")
			print("=== Performing aperture photometry")
			print(" ")
			unlearn daophot.phot
			unlearn apphot.phot
			delete("*.mag.1",ver-)
			if (desloca != 'no') {
			daophot.phot(image=lista, coords="@inord", output="default")
			} else
			daophot.phot(image=lista, coords=object//".ord", output="default")			
	} # close if passo < 5
#	
#### CALCULATING THE POLARIMETRY
##	
	if(passo<6){
		print(" ")
		print("=== Performing polarimetry")
		print(" ")
#
##### creating dat files
#
#		delete("dat.*",ver-)
		delete("list_mag",ver-)
		!ls *.mag.1>list_mag
		unlearn pccdpack_inpe.cria_dat
		pccdpack_inpe.cria_dat(varim="@list_mag", outdat="dat", interva = nimage)
# 
#### finding out the number of stars
#
		tstat("dat.001",2)
		nestrelas=tstat.nrows/(nimage*2)
		print(nestrelas)
		#
#
###### setting the parameters to calculate polarimetry
#
		if (circular) {
			wavetype="quarter"
			retardancia=90.
			zero_par=zero
			l2=n0
			} 
			else {
			wavetype="half"
			retardancia=180.
			zero_par=0.
			l2=yes
		}	
		pccdpack_inpe.pccdgen_inpe.wavetyp=wavetype	
		pccdpack_inpe.pccd_var.l2=l2	
		pccdpack_inpe.pccdgen_inpe.retar=retardancia	
		pccdpack_inpe.pccdgen_inpe.nhw=nimage
		pccdpack_inpe.pccdgen_inpe.nap=nab	
		pccdpack_inpe.pccdgen_inpe.calc="c"	
		pccdpack_inpe.pccdgen_inpe.readnoi=readnoise
		pccdpack_inpe.pccdgen_inpe.ganho=gan	
		pccdpack_inpe.pccdgen_inpe.deltath=deltatheta
		pccdpack_inpe.pccd_var.delta_theta=deltatheta		
		pccdpack_inpe.pccdgen_inpe.norm=norma	
		pccdpack_inpe.pccdgen_inpe.new_mod=nova	
		pccdpack_inpe.pccdgen_inpe.zero=zero_par	
		pccdpack_inpe.pccd_var.plate_zero=zero_par	
		pccdpack_inpe.pccdgen_inpe.nstars=nestrelas	
		pccdpack_inpe.pccdgen_inpe.fileexe=fileexe
        nt=num_lam-nimage+1  #encontrar quantos dats foram criados
		pccd_var(begindat=1,enddat=nt,indat="dat",outlog=object,macrol=yes)
#
		print("Checking the aperture having the smallest P error")
		macrol_inpe(file_in=object//".log", file_out=object, minimun="full")
		print("See results using select task")
    }
	
	#temp=mktemp("tmp$auto_pol")
	#lpar auto_pol | page > auto.par
	#delete(temp, ver-)
	#!say "Job Done"
	#beep
end