## Programa automatizador do calculo de polarizacao para multiplos objetos
## Programa reescrito em 18/06/2011
## Agora pega parametros do clestat
## Versao 2.1 - 19/10/2011
##
####### Claudia V. Rodrigues - Oct/2014 #####
#
# Textos para usuarios traduzidos para ingles
#
############
# Comentarios
#
# Esta fixo para lamina de meia-onda
#
####################################################
## March/2015 - CVR
## list of mag files is now created using the same order of the list of images
## - coordinate files are always created, even if the shift is not redone
######################################################
## September/2015 - CVR
## Task ordshift is run twice. In the first time, the border objects are removed from
## the input ord file. And in the second the, coorde* files are created using this corrected
## input ord file.
##
######################################################
## September/2022 - CVR/IL
## It was removed the parameters of the call of pccdgen_inpe routine related to the 
## waveplate configuration: waveplate type, etc...
######################################################
procedure auto_pol

string	object				{prompt="Root to output files"}
string	lista="@arq"		{prompt="Image list - use @"}
string	imagem				{prompt="Reference image to register"}
pset    pospars_inpe		{prompt="Good waveplate positions - :e"}
int     nume_lam=16			{prompt="Number of images in the datfile (max. 16)"}
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
#bool	registro=yes		{prompt="Use Xregister (yes) or acha_shift (no) to calculate the shift between images"}
string	regiao				{prompt="Image sector to register images"}
int		janela				{prompt="Cross-correlation window size"}
int		tamanho=2048		{prompt="CCD sizes in pixels"}
#bool	acha				{prompt="Usa o acha_shift para encontrar o deslocamento entre as imagens?"}
bool	confirma=yes		{prompt="Verify registering using TVMARK in each image: yes/no"}
int		passo=1				{min=1,max=5, prompt="Start at (1:all;2:pairs;3:reg;4:phot;5:pol)"}
#bool	faz=yes				{prompt="Faz acha_shift (se ja houver um _acha.shift, pode colocar no)"}
#int		nestrelas			{prompt="Number of stars. Use only if passo > 4"}

struct *flist1
struct *flist2

begin

	struct line
	string lixo,dados,lado,lixo2,temp,varima,vtmpfile,namev,arq_coord
	string arqshift
	real lixoreal,fwhm,sigma,shx,shy
	bool fazclest,faz,coofaz
	int ap,i, next_ap, nestrelas

#### defining parameters 
	
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
#	daophot.datapars.datamax = 60000
#	daophot.datapars.datamin = 0
	daophot.centerpars.calgori="centroid"
	daophot.fitskypars.annulus = anel
	daophot.fitskypars.dannulus = danel
#	
	apphot.datapars.epadu = gan
	apphot.datapars.readnoi = readnoise
	apphot.findpars.thresho = 4
#	apphot.datapars.datamax = 60000
#	apphot.datapars.datamin = 0
	apphot.centerpars.calgori="centroid"	
	apphot.fitskypars.annulus = anel
	apphot.fitskypars.dannulus = danel
#	
#####
    print("")
    print("=== Calculating some image statistics")	
    print("")
	if(access("estat.log")){
		print("CLESTAT already done. Redo? yes/no(default)")
		fazclest=no
		lixo2 = scan(fazclest)
	}
	if (fazclest){
		clestat(imagem)
	}
	
	flist1 = "estat.log"
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
	if(passo==1){
	    print("")
		print("=== Finding stars")
	    print("")
	    fazclest=yes
	    if(access(object//".coo")) {
			print("coo file exists. Redo? yes/no(default)")
			fazclest=no
			lixo2 = scan(fazclest)		
		}
	    if (fazclest){
		   if(access(object//".coo")) delete(object//".coo",ver-)
		   daophot.daofind(image=imagem,output=object//".coo")
		}
	}
###
#####  MAKING PAIRS
###
	if(passo<3){
	    print("")
		print("=== Making pairs of ordinary and extraordinary images")
	    print("")
		unlearn ordem3		
		ordem3(shiftx=shx,shifty=shy,deltax=delx,deltay=dely,deltamag=delmag,pripar=no,side=lado,file_in=object//".coo", file_out=object)
	}
#	
###   Achando os deslocamentos entre as imagens com acha shift###
####  AND APLYING THE SHIFTS TO THE COORDINATE FILE
#
	if(passo<4){
#
    if (desloca != 'no') {
    if(desloca == 'acha_shift') arqshift=object//"_acha.shift"
	if(desloca == 'xregister') arqshift=object//"_xreg.shift"
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
			acha_shift(imgref=imagem,images=lista,shifts=object,confirm=no)
			} else
		if(desloca == 'xregister'){
			print(" ")
			print("Calculing the shifts between images using Xregister")
			print(" ")
			delete(object//"_xreg.shift",ver-)
			unlearn xregister
			xregister(input=lista,referenc=imagem,regions=regiao,shifts=object//"_xreg.shift",databas=no,xwindow=janela,ywindow=janela)
#
		} ## FECHA IF DESLOCA
		nestrelas=ordshift.nobj
	} # FECHA IF FAZ
	unlearn pccdpack_inpe.ordshift
    pccdpack_inpe.ordshift(infile=arqshift,coorfil=object//".ord",xside=tamanho,yside=tamanho)
    pccdpack_inpe.ordshift(infile=arqshift,coorfil=object//".ord",xside=tamanho,yside=tamanho)
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
	
	if(passo<6){
		print(" ")
		print("=== Performing polarimetry")
		print(" ")
#		print(" nestrelas",nestrelas)		
		if(access("dat.001")) delete("dat.001",ver-)
		if(access("list_mag")) delete("list_mag",ver-)
		# criando list_mag na mesma ordem do arquivo de imagens
#
    	varima=lista
    	vtmpfile = mktemp ("/tmp/tmpvar")
    	files (varima, > vtmpfile)
    	flist1 = vtmpfile
    	while (fscan(flist1, namev) != EOF) 
        {
		  print(namev,".mag.1",>>"list_mag")
        }
		unlearn pccdpack_inpe.cria_dat
		pccdpack_inpe.cria_dat(varim="@list_mag", outdat="dat", interva = nume_lam)
		tstat("dat.001",3)
		nestrelas=tstat.nrows/(nume_lam*2)
#		auto_pol.nestrelas=tstat.nrows/(nume_lam*2)
#pccdgen_inpe(filename="dat.001",nstars=nestrelas,wavetyp="half",retar=180.,nhw=nume_lam,nap=nab,calc="c",readnoi=readnoise,ganho=gan,deltath=deltatheta, norm=norma, new_mod=nova, zero=0., fileout=object//".log")
pccdgen_inpe(filename="dat.001",nstars=nestrelas,nhw=nume_lam,nap=nab,readnoi=readnoise,ganho=gan,deltath=deltatheta, norm=norma, new_mod=nova, fileout=object//".log")
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
