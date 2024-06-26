## Programa automatizador do calculo de polarizacao para estrelas padroes
## Programa reescrito em 17/06/2011
## Versao 2.0
##
## Julho/2014 - Claudia V. Rodrigues
## - Incluida opcao de polarimetria circular
## - modificado modo de escolher o metodo do calculo do deslocamento de imagens
## - os deletes estao forcados a nao pedir verificacao
## - acertei pequenos problemas na secao de configuracao das aberturas
## - inclui opcao que permite conferencia dos deslocamentos (display + tvmark de todos
##      os arquivos)
##
## October/2014
## description of the parameters in English
## messages translated to English
##
## March/2015 - CVR
## list of mag files is now created using the same order of the list of images
##
##
procedure padrao_pol

string	object="HD_"		{prompt="Object name = root of the images to be created"}
string	lista="@list_obj"	{prompt="Input image list"}
string	imagem				{prompt="Reference image to registering procedure"}
pset    pospars_inpe		{prompt="Number of retarder positions (=# of iamges) :e"}
int     nume_lam=16			{prompt="Number of retarder position in the datafile (max. 16)"}
real	readnoise=1			{prompt="Readout noise - ADU"}
real	gan=1				{prompt="Gain - e-/ADU"}
real	anel=60				{prompt="Internal radius of sky ring"}
real	danel=10			{prompt="Width of the sky ring"}
bool	autoabe=yes			{prompt="Are apertures automatically defined?"}
int		nab=20				{max=20, prompt="Number of apertures"}
int		passoab=1			{prompt="Aperture step"}
int		deltab=-2			{prompt="First aperture displacement relative to FWHM"}
string	aberturas			{prompt="Aperture list - max = 20"}
string  desloca='xregister'	{enum="no|xregister|acha_shift", prompt="Method to calculate images shifts"}
#bool	registro=no			{prompt="Usa o Xregister para calcular o deslocamento entre as imagens?"}
string	regiao='[200:300,200:300]'			{prompt="Region to crosscorrelate the images (if desloca=xregister)"}
int		janela=20			{prompt="Size of the correlation window (if desloca=xregister)"}
#bool	acha=no				{prompt="Use acha_shift to find register images?"}
#bool	confirma=no			{prompt="Check each image using TVMARK when using acha_shift?(if desloca = acha_shift)"}
bool	confirma=no			{prompt="Show TVMARK of each file."}
int		tamanho=1024		{prompt="CCCD size in pixels"}
bool	verify=yes			{prompt="Verify daophot parameters?"}
real	deltatheta=0.		{prompt="Correction of polarization position angle"}
bool	nova=yes			{prompt="Are you using the new polarimetric drawer? (after 2007)"}
bool	norma=yes			{prompt="Consider normalization in pccdgen?"}
bool	circular=no			{prompt="No: half-wave plate; Yes: quarter-wave plate."}
real	zero=0.				{prompt="Zero position of quarter-wave plate"}

struct	*flist1
struct	*flist2

begin
	
	bool coofaz,faz
	real x1,y1,ceu1,sig1,fwhm1,x2,y2,ceu2,sig2,fwhm2,fwhm,retardancia,zero_par
	string temp2,temp3,queijo,linedata1,wavetype,arq_coord,varima,vtmpfile,namev
	struct line1,lixo,dados,lixo2
	int i,ap,next_ap
	
	faz=yes
	coofaz=yes

#######
# CVR - A configuracao abaixo dos parametros do daophot esta correta. Pode ser verificado
#    no console. Mas na hora de rodar o phot (daophot.phot) sao usados os par do apphot.
# 	 Forcei setagem nos dois pacotes.
######
	daophot.datapars.epadu = gan
	daophot.datapars.readnoi = readnoise
#	daophot.datapars.datamin = 0
#	daophot.datapars.datamax = 60000
	daophot.fitskypars.annulus = anel
	daophot.fitskypars.dannulus = danel
	daophot.findpars.thresho = 4
	daophot.centerpars.calgori="centroid"
#
	apphot.datapars.epadu = gan
	apphot.datapars.readnoi = readnoise
#	apphot.datapars.datamin = 0
#	apphot.datapars.datamax = 60000
	apphot.fitskypars.annulus = anel
	apphot.fitskypars.dannulus = danel
	apphot.findpars.thresho = 4
	apphot.centerpars.calgori="centroid"
##	
	if(verify){
		daophot.verify = yes
	}
	else{
		daophot.verify = no
	}
	
	if(access("padrao.nfo") && access("padrao.coo")){
		coofaz=no
#		print("Coordenadas da padrao ja encontradas, refazer? y/n - no (default)")
		print("We found standard star coordinates. Would you like to change them? y/n - no (default)")
		lixo2 = scan(coofaz)
		if(coofaz==no){
			flist1 = "padrao.nfo"
			i=0
			while (fscan(flist1,line1) != EOF) {
				if(i==2)linedata1 = fscan(line1,x1,y1,ceu1,sig1,fwhm1)
				if(i==3)linedata1 = fscan(line1,x2,y2,ceu2,sig2,fwhm2)
				i=i+1
			}
			fwhm=(fwhm1+fwhm2)/2
		}
	}
	
	while(coofaz==yes){
		display(image=imagem,frame=1)
		print(" ")
		print("Estimating the standard star coordinates...")
		print(" ")
		print("Find the two images of the object.")
		print("With the mouse over the bottom image, type a.")
		print("With the mouse over the top image, type a.")
		print("Type q if you are ready.")
#	
		if(access("padrao.coo")) delete("padrao.coo",ver-)
		temp3 = mktemp("tmp$padrao")
		unlearn daoedit
		daoedit(imagem,> temp3//"")
		if(access("padrao.nfo")) delete("padrao.nfo",ver-)
		copy(temp3, "padrao.nfo")
		
		#type(temp3)
		#type("padrao.nfo")		
		
		flist1 = "padrao.nfo"
		i=0
		while (fscan(flist1,line1) != EOF) {
			if(i==2)linedata1 = fscan(line1,x1,y1,ceu1,sig1,fwhm1)
			if(i==3)linedata1 = fscan(line1,x2,y2,ceu2,sig2,fwhm2)
			i=i+1
		}
		
		fwhm=(fwhm1+fwhm2)/2
	
		temp2 = mktemp("tmp$padrao")
		print("#XCENTER  YCENTER   ID",>temp2)
		print(x1//"	"//y1//" 1",>>temp2)
		print(x2//"	"//y2//" 2",>>temp2)
		if(access("padrao.coo")) delete("padrao.coo",ver-)	
		copy(temp2, "padrao.coo")
	
		tvmark.mark = "circle"
		tvmark.radii = 20
		tvmark.color = 206
		tvmark(1,"padrao.coo")
		type("padrao.nfo")
		print("Redo? No is default.")
		coofaz=no
		lixo = scan(coofaz)
	}
	
	ap=int(fwhm)

		
	if(access("padrao_acha.shift") || access("padrao_xreg.shift")){
		faz=no
		print("ACHA_SHIFT or XREGISTER already done. Redo? y/no - no (default)")
		lixo2 = scan(faz)
	}
	if(faz){
		if(desloca == 'acha_shift'){
			print(" ")
			print("Running Acha Shift...")
			print(" ")
			acha_shift(imgref=imagem,images=lista,shifts="padrao",confirm=confirma)
		} else
		if(desloca == 'xregister'){
			print(" ")
#			print("Calculando o deslocamento entre as imagens com o Xregister")
			print("Calculing the shifts between images using Xregister")
			print(" ")
			delete("padrao_xreg.shift",ver-)
			unlearn xregister
			xregister(input=lista,referenc=imagem,regions=regiao,shifts="padrao_xreg.shift",databas=no,xwindow=janela,ywindow=janela)
		}
	}
###
### ******* SETANDO ABERTURAS ************
###
	if(autoabe){
		daophot.photpars.apertur=""
		i=0
		next_ap=ap+deltab
		if (next_ap < 1) next_ap =1
		while(i<nab){
			if(i<(nab-1))daophot.photpars.apertur=daophot.photpars.apertur//next_ap//","
			if(i==(nab-1))daophot.photpars.apertur=daophot.photpars.apertur//next_ap
#			print(next_ap)
#			print(daophot.photpars.apertur)
			i=i+1
			next_ap = next_ap + passoab
		}
#		print(daophot.photpars.apertur)
	}
#
	if(autoabe==no)	daophot.photpars.apertur = aberturas		
	apphot.photpars.apertur=daophot.photpars.apertur
#
###
#### APLICANDO DESLOCAMENTO NOS ARQUIVOS DE COORD. E FAZENDO FOTOMETRIA DE ABERTURA ######
#
	print(" ")
#	print("Aplicando o deslocamento nos arquivos de coordenadas.")
	print("Correcting the coordinates files according to the calculated shifts.")
	print(" ")
#	
	if(desloca == 'xregister'){
		unlearn pccdpack_inpe.ordshift
		pccdpack_inpe.ordshift(infile="padrao_xreg.shift",coorfil="padrao.coo",xside=tamanho,yside=tamanho)
		print(" ")
#		print("Fazendo a fotometria de abertura")
		print("Performing aperture photometry")
		print(" ")
		delete("*.mag.1",ver-)
		daophot.phot(image=lista, coords="@inord", output="default")
	} else
	if(desloca == 'acha_shift'){
		unlearn pccdpack_inpe.ordshift
		pccdpack_inpe.ordshift(infile="padrao_acha.shift",coorfil="padrao.coo",xside=tamanho,yside=tamanho)
		print(" ")
		print("Performing aperture photometry")
		print(" ")
		delete("*.mag.1",ver-)
		daophot.phot(image=lista, coords="@inord", output="default")	
	} else
	if(desloca == 'no'){
		#unlearn phot
		print(" ")
		print("Performing aperture photometry")
		print(" ")
		delete("*.mag.1",ver-)
		daophot.phot(image=lista, coords="padrao.coo", output="default")
	}

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
        #delete(vtmpfile,ver-)
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

###
#### CRIANDO DAT FILE E FAZENDO POLARIMETRIA ######
#	
#	!ls *.mag.1>list_mag
# criando list_mag na mesma ordem do arquivo de imagens
#
    delete("list_mag",ver-)
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
	print(" ")
	print("Calculating the polarization.")
	print("  ")
	if (circular) {
		pccdpack_inpe.pccdgen_inpe.wavetyp="quarter"
		pccdpack_inpe.pccdgen_inpe.retar=90.
		pccdpack_inpe.pccdgen_inpe.zero=zero
		} 
		else {
		pccdpack_inpe.pccdgen_inpe.wavetyp="half"
		pccdpack_inpe.pccdgen_inpe.retar=180.
		pccdpack_inpe.pccdgen_inpe.zero=0.
	}				 
    pccdpack_inpe.pccdgen_inpe.nstars=1
	pccdpack_inpe.pccdgen_inpe.nhw=nume_lam
	pccdpack_inpe.pccdgen_inpe.nap=nab
	pccdpack_inpe.pccdgen_inpe.calc="c"
	pccdpack_inpe.pccdgen_inpe.readnoi=readnoise
	pccdpack_inpe.pccdgen_inpe.ganho=gan
	pccdpack_inpe.pccdgen_inpe.deltath=deltatheta
	pccdpack_inpe.pccdgen_inpe.norm=norma
	pccdpack_inpe.pccdgen_inpe.new_mod=nova

 	pccdpack_inpe.pccdgen_inpe(filename="dat.001",fileout=object//".log")
	print("  ")
	print("Verifying which is the minimum error aperture")
	print(" ")
	macrol_inpe(file_in=object//".log", file_out=object, minimun="full")
	print(" ")
	print("The polarization of your standard is:")
	type(input_fi=object//".out")
	
	delete(vtmpfile,ver-)
	#delete(temp2,ver-)
	print(" ") 	
end

