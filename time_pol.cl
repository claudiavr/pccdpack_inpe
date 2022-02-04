## Programa automatizador do calculo de serie temporal de polarizacao
## Baseado em:
## (1) fonte original escrita por Victor de Souza Magalhaes em 18/06/2011 e  19/10/2011
## 
## (2) adaptacao feita para serie temporal em 09/05/2014 por Karleyne M. G. Silva
##
## (3) adaptacao por Claudia V. Rodrigues - Dez/2014
#
############
# Modificacoes de dez/2014 na adaptacao feita por Claudia
#
# programar tipo de lamina
# corrigir passos
#
##########################################################
## March/2015 - CVR
## - list of mag files is now created using the same order of the list of images
## - coordinate files are always created, even if the shift is not redone
##
##########################################################
## April/2015 - CVR
## - pospars was removed as a free parameter. It is set according to nimage parameter
##########################################################
## May/2015 - CVR
## Apertures should be greater or equal than 1
##
##########################################################
##
## August/2015 - CVR
## * If coordinate file exists, tvmark the objects.
## * Task is aborted, if we got error from pccd_var.
## * Task is aborted, if we got error from macrol_inpe.
##
##########################################################
##

procedure time_pol

string	object				{prompt="Root to output files"}
string	lista="@arq"		{prompt="Image list - use @"}
string	imagem				{prompt="Reference image to register"}
#pset    pospars_inpe		{prompt="Good waveplate positions - :e"}
#int     nume_lam			{prompt="Total number of images"}
int     nimage=8            {prompt="Number of images to calculate 1 polarization point. Use: 4, 8 or 16"}
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
int		tamanho=1024		{prompt="CCD sizes in pixels"}
bool	confirma=yes		{prompt="Verify registering using TVMARK in each image: yes/no"}
int		passo=1				{min=1,max=5, prompt="Start at (1:all;2:pairs;3:reg;4:phot;5:pol)"}
bool	circular=no			{prompt="No: half-wave plate; Yes: quarter-wave plate."}
real	zero=0.				{prompt="Zero position of quarter-wave plate"}
bool	polarimetry=yes		{prompt="If yes calculates the polarimetry"}
bool	photometry=yes		{prompt="If yes calculates the photometry"}
bool	erro=no				{prompt="Leave it no."}
string  fileexe="/Users/claudiarodrigues/pccdpack_fortran_alias/pccd4000gen15_inpe.e"  {prompt="pccd execute file (.exe)"}

struct *flist1
struct *flist2
struct *flist3

begin

	string lixo,dados,lado,lixo2,temp,varima,vtmpfile,namev,arq_coord,wavetype,estat_file
	string ordfile,outfile,arqshift,arqout,filenorm
	real lixoreal,fwhm,sigma,shx,shy,retardancia,zero_par
	bool fazclest,faz,coofaz,l2
	int ap,i, next_ap, nestrelas,nume_lam,nt,j
	struct line
#
##### checking parameters
#
if ((nimage!=4) && (nimage!=8) && (nimage!=16)) {
	print ("nimage is ",nimage)
 	error(1,"#images in a datfile is not 4 8 or 16")
}
#
##### configuring internal parameters
# 
	ordfile=object//".ord"	
#
#### finding out the number of images in the lista file
#
    varima=lista
    vtmpfile = mktemp ("/tmp/tmpvar")
    files (varima, > vtmpfile)
    flist1 = vtmpfile
    nume_lam=0
    while (fscan(flist1, namev) != EOF) {
		nume_lam=nume_lam+1
    }
	if (nume_lam > 2000) {
	  print(" ")
      print("  Number of images larger than 2000! ")
	  print("  You need to change variable dimensions at: ")
	  print("  phot_pol_e.f, plota_luz, and plota_pol.")
	  print(" ")
	  goto erro
	}	    
    delete(vtmpfile,ver-)
#
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
# defining tasks parameters
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
	pccdpack_inpe.pospars_inpe.pos_1=yes	
	pccdpack_inpe.pospars_inpe.pos_2=yes	
	pccdpack_inpe.pospars_inpe.pos_3=yes	
	pccdpack_inpe.pospars_inpe.pos_4=yes
	pccdpack_inpe.pospars_inpe.pos_5=no
	pccdpack_inpe.pospars_inpe.pos_6=no
	pccdpack_inpe.pospars_inpe.pos_7=no
	pccdpack_inpe.pospars_inpe.pos_8=no
	pccdpack_inpe.pospars_inpe.pos_9=no
	pccdpack_inpe.pospars_inpe.pos_10=no
	pccdpack_inpe.pospars_inpe.pos_11=no
	pccdpack_inpe.pospars_inpe.pos_12=no
	pccdpack_inpe.pospars_inpe.pos_13=no
	pccdpack_inpe.pospars_inpe.pos_14=no
	pccdpack_inpe.pospars_inpe.pos_15=no
	pccdpack_inpe.pospars_inpe.pos_16=no
	switch (nimage) {
            case 8: {
				pccdpack_inpe.pospars_inpe.pos_5=yes
				pccdpack_inpe.pospars_inpe.pos_6=yes
				pccdpack_inpe.pospars_inpe.pos_7=yes
				pccdpack_inpe.pospars_inpe.pos_8=yes
				}
            case 16: {
				pccdpack_inpe.pospars_inpe.pos_5=yes
				pccdpack_inpe.pospars_inpe.pos_6=yes
				pccdpack_inpe.pospars_inpe.pos_7=yes
				pccdpack_inpe.pospars_inpe.pos_8=yes
				pccdpack_inpe.pospars_inpe.pos_9=yes
				pccdpack_inpe.pospars_inpe.pos_10=yes
				pccdpack_inpe.pospars_inpe.pos_11=yes
				pccdpack_inpe.pospars_inpe.pos_12=yes
				pccdpack_inpe.pospars_inpe.pos_13=yes
				pccdpack_inpe.pospars_inpe.pos_14=yes
				pccdpack_inpe.pospars_inpe.pos_15=yes
				pccdpack_inpe.pospars_inpe.pos_16=yes
				}
    }
#lpar pccdpack_inpe.pospars_inpe
#	
#####
    estat_file=imagem//".estat"
	if(passo<3){
    	print("")
    	print("=== Calculating some image statistics using the reference image. ===")	
    	print("=== You can pick up any stars... ===")	
    	print("")
    	print("Checking if CLESTAT already done. Looking for file: ",estat_file)
    	print("")
		if(access(estat_file)){
			print("CLESTAT already done. Redo? yes/no(default)")
			fazclest=no
			lixo2 = scan(fazclest)
		}
		if (fazclest){
			clestat(imagem,marca=no)
			rename("estat.log",estat_file)
		}
	} ## fecha if (passo < 3) 
#	
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
			if (next_ap<1) next_ap=1
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
# define objetos clicando
#
#
	if(passo<3){
	            faz=yes
    			print("")
    			print("Checking if coordinates file exists: ",ordfile)
    			print("")
                if (access(ordfile)) faz=no
                if (faz == no) {                
				   display(image=imagem, frame=1)
		           tvmark(1,ordfile,number=yes,txsize=4,mark="circle",radii=20,color = 206)                
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
                 #delete("temp_clestat.dao",ver-)
                 #copy("clestat.dao","temp_clestat.dao")
                 clestat(imagem=imagem,marca=yes)
                 delete(ordfile,ver-)
                 !sed '/^ *$/d' clestat.dao > tmpdao
                 copy("tmpdao",ordfile)
                 delete("clestat.dao",ver-)
                 delete("tmpdao",ver-)
                 #copy("temp_clestat.dao","clestat.dao")
                 #delete("temp_clestat.dao",ver-)
                }
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
    print("=== Finding shifts between images and creating coordinate files")	
    print("")
    print("")
    print("Checking if shift file exists: ",arqshift)
    print("")
	if(access(arqshift)){
#	if(access(object//"_acha.shift") || access(object//"_xreg.shift")){
		faz=no
		print("ACHA_SHIFT or XREGISTER already done. Redo? y/no - no (default)")
		lixo2 = scan(faz)
	}
	if(faz){
		if(desloca == 'acha_shift'){
			print(" ")
			print("Running Acha Shift...")
			print(" ")
			if(access(arqshift)) delete(arqshift,ver-)
			acha_shift(imgref=imagem,images=lista,shifts=object,confirm=no)
			} else
		if(desloca == 'xregister'){
			print(" ")
			print("Calculing the shifts between images using Xregister")
			print(" ")
			if (access(arqshift)) delete(arqshift,ver-)
			unlearn xregister
			xregister.databasefmt=no
			xregister.xwindow=janela
			xregister.ywindow=janela			
			xregister(input=lista,referenc=imagem,regions=regiao,shifts=arqshift)
		} ## FECHA IF DESLOCA
		nestrelas=ordshift.nobj
	} # FECHA IF FAZ
	unlearn pccdpack_inpe.ordshift
	pccdpack_inpe.ordshift(infile=arqshift,coorfil=ordfile,xside=tamanho,yside=tamanho)	
	} else {
		nestrelas = ordem_inpe.npar
    } # FECHA IF DESLOCA != NO
###
#### CONFERINDO DESLOCAMENTO VISUALMENTE ######
#

	if(confirma) {
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
          tvmark(1,arq_coord,number=yes,txsize=4,mark="circle",radii=20,color = 206)          
		  lixo = scan(coofaz)  # le variavel ja usada
        }
        delete("/tmp/tmpvar*",ver-)
	}
	} # FECHA IF PASSO < 4
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
			daophot.phot(image=lista, coords=ordfile, output="default")			
	} # close if passo < 5
#	
#### CALCULATING THE POLARIMETRY
##	
	if(passo<6 && polarimetry==yes){
		print(" ")
		print("=== Performing polarimetry")
		print(" ")
#
##### creating dat files
#
#		delete("dat.*",ver-)
		delete("list_mag",ver-)
#		!ls *.mag.1>list_mag
#####   criando list_mag na mesma ordem do arquivo de imagens
#
    	varima=lista
    	vtmpfile = mktemp ("/tmp/tmpvar")
    	files (varima, > vtmpfile)
    	flist1 = vtmpfile
    	while (fscan(flist1, namev) != EOF) 
        {
		  print(namev,".mag.1",>>"list_mag")
        }
        delete(vtmpfile,ver-)
		unlearn pccdpack_inpe.cria_dat
		pccdpack_inpe.cria_dat(varim="@list_mag", outdat="dat", interva = nimage)
# 
#### finding out the number of stars
#
		tstat("dat.001",2,outtabl="llixo")
		nestrelas=tstat.nrows/(nimage*2)
#		print(nestrelas)
		delete("llixo.tab",ver-)		
		#
#
###### setting the parameters to calculate polarimetry
#
		if (circular) {
			wavetype="quarter"
			retardancia=90.
			zero_par=zero
			l2=no
			} 
			else {
			wavetype="half"
			retardancia=180.
			zero_par=0.
			l2=yes
		}	
		pccdpack_inpe.pccdgen_inpe.wavetyp=wavetype	
		pccdpack_inpe.pccdgen_inpe.retar=retardancia	
		pccdpack_inpe.pccdgen_inpe.nhw=nimage
		pccdpack_inpe.pccdgen_inpe.nap=nab	
		pccdpack_inpe.pccdgen_inpe.calc="c"	
		pccdpack_inpe.pccdgen_inpe.readnoi=readnoise
		pccdpack_inpe.pccdgen_inpe.ganho=gan	
		pccdpack_inpe.pccdgen_inpe.deltath=deltatheta
		pccdpack_inpe.pccdgen_inpe.norm=norma	
		pccdpack_inpe.pccdgen_inpe.new_mod=nova
		pccdpack_inpe.pccdgen_inpe.zero=zero_par	
		pccdpack_inpe.pccdgen_inpe.nstars=nestrelas	
		pccdpack_inpe.pccdgen_inpe.fileexe=fileexe
		pccdpack_inpe.pccd_var.l2=l2	
		pccdpack_inpe.pccd_var.delta_theta=deltatheta		
		pccdpack_inpe.pccd_var.nova=nova		
		pccdpack_inpe.pccd_var.plate_zero=zero_par	
		macrol_inpe.minimun="full"
        nt=nume_lam-nimage+1  #encontrar quantos dats foram criados
        filenorm="convergencia.txt"
 		if  (access (filenorm)) del(filenorm,ver-)
		touch("tmp$"//filenorm)
		pccd_var(begindat=1,enddat=nt,indat="dat",outlog=object,macr=yes)
 	    if (access("tmp$"//filenorm)) rename("tmp$"//filenorm,filenorm)
		erro=pccd_var.erro
	    if (erro == yes) {
	    	error (1," Error in pccdgen_var execution.")
 	    }
		
#
# 
#### finding out the number of images in the lista file
#
    arqout=object//".out"
    flist3=arqout
    print(arqout)
    i=0
    while (fscan (flist3, line) != EOF) {
    #print(line)
      i=i+1
#      print(i)
      if (i==1) {
#        print("entrei")
        for (j=1; j<=nestrelas; j+=1) {
#        	print(j)
            if (j < 10)
			  outfile = object//".0"//j//".out"
			  else
			  outfile = object//"."//j//".out"
			if (access(outfile)) delete(outfile,ver-)
			print(line, > outfile)
	    }
	    }
	    else
	    {
	    j=(i-1) - nestrelas*((i-1) / nestrelas)
	    if (j ==0) j=nestrelas
#	    print(i,j)
        if (j < 10)
			  outfile = object//".0"//j//".out"
			  else
			  outfile = object//"."//j//".out"	  
		print(line, >> outfile)  
	    }
      }
      print("")
	  print("================================================================")	
	  print("The polarimetric results are found in the files ",object,".*.out")
	  print("run plota_pol to see the graphs.")
	  print("================================================================")	
	  print("")
	}
#
#
#### CALCULATING THE PHOTOMETRY
##	
	if(passo<6 && photometry==yes){
		print(" ")
		print("=== Performing photometry")
		print(" ")
#
##### creating .pht and .luz files
#
		if (access(object//".pht")) delete(object//".pht",ver-)
        txdump.headers=no
        txdump.parameters=yes
 		txdump(textfiles="*.mag.1",fields="image, msky, nsky, rapert, sum, area", \
 			expr="yes", > object//".pht")
#
		tstat(object//".pht",2,outtabl="llixo")
		nestrelas=tstat.nrows/(nume_lam*2)
#		print(nestrelas)
		delete("llixo.tab",ver-)		
        unlearn phot_pol		
        pccdpack_inpe.phot_pol(file_in = object//".pht", file_out = object//".luz", \
          nstars = nestrelas , nhw = nume_lam, nap= nab, comp=2, star_out=0 , ganho= gan) 
      	print("")
	  	print("===========================================================")	
	  	print("The photometry is found in the file ",object,".luz")
	  	print("run plota_luz to see the graphs.")
	  	print("===========================================================")	
	  	print("")

     }

	end
	
	