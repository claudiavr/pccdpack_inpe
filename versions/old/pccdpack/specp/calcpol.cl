procedure calcpol (input, type, number, interval)

string input="@entrada"	{prompt="Image List"}
string type="objeto" {enum="objeto|padpol|npol|flat", prompt="Image Type"}
int    number=16	{min=4, max=16, prompt="Number of Waveplate Positions"}
int interval=1        {min=1, prompt='Binning Interval (Points)'}
string folder=""	{prompt="Location of the Input Images"}
string corflat="no" {enum="yes|no",prompt="Correct for the Lambda Dependence of Theta?"}
string ffile="" {prompt="File with the Output of Routine AJFLAT"}
string coreq="no" {enum="yes|no",prompt="Apply Equatorial Correction?"}
real dtheta=0.	{prompt="Delta Theta (Theta_Eq = Theta_Ins + Delta Theta)"}
#real eqlmin=5000. {prompt="Lower Wavelength"}
#real eqlmax=6000. {prompt="Upper Wavelength"}
string retar="no" {enum="yes|no",prompt="Apply Retardance Correction?"}
string instr="no" {enum="yes|no",prompt="Correct for Instrumental Polarization?"}
string qfile="" {prompt="File with Instrumental Q (full path)"}
string ufile="" {prompt="File with Instrumental U (full path)"}
string inter="no" {enum="yes|no",prompt="Correct for Interstellar Polarization?"}
string law="wilking82" {enum="wilking82|wilking80|serkowsky", prompt="Interstellar Polarization Law"}
real pmax=4. 		{prompt="Pmax (Percent)"}
real lbdmax=5000. {prompt="Lambda Max (Angstroms)"}
real theta=0. {prompt="Theta (degrees)"}
real rdnoise = 0.	{min=0., prompt="CCD Readout Noise (eletrons)"}
real ganho = 1.	{min=1., prompt="CCD Gain (eletrons)"}
string ifu="no"	{enum="yes|no", prompt="Use IFU's file format?"}
string erase="no"	{enum="yes|no", prompt="Delete Files Z*.imh?"}
struct *flist1  
struct *flist2  
struct flist3 {length=160}
struct flist4 {length=160}
struct *flist5


begin


	string entr, tip
	int interv, numer
	
	string listaord
	string listaext
	string listaceuo, listaceue
	string s1, s2, s3, s4, s5
	string arq1, arq2, arq3, arq4
	string lixo1
	struct linha1 
	struct linha2 
	string dir
	string dirtmp
	string fol
	
	string header1
	string conta
	
	# angulo
	real r1, r2, r3, r4, r5
	real u1, u2, u3, u4, u5
	int i1
	real pi
	bool ver, ver1
	
	real lmeio,lmin,lmax,ang
	real k
	real pmaxi
	
	# binagem
	real lambdamin, lambdamax
	real intreal
	int npix,npix2
	
	string npontosy
	real ruido, npontosx
	
	# nomes
	string nome, nome2
	string arqq, arqu, arqp, arqs, arqst, arqt, arqf, arqan, arqsan
	string arqq2,arqu2,arqp2,arqan2,arqf2
	string arqpad
	string meio
	
	string line1,line2
	
	
	entr = input
	fol = folder
	numer = number
	interv =  interval
	tip = type
	
	pmaxi = pmax/100.

	limpa
	
# O NOME DAS IMAGENS DE SAIDA EH CONSTRUIDO DA SEGUINTE FORMA:
# <TIPO>_00000_<DADO>_<BINAGEM}_<NUMERO POSICOES>
# O 00000 acima refere-se as correcoes aplicadas, 1 indica que a correcao foi
# feita e 0 o contrario. A ordem eh a seguinte:
# 1-Dependencia espectral do angulo de polarizacao da lamina retardadora;
# 2-Correcao Equatorial
# 3-Correcao pela retardancia da lamina 
# 4-Polarizacao Instrumental
# 5-Polarizacao Interestelar	

	meio=""
	if (corflat=="yes") {meio=meio//"1"} else {meio=meio//"0"}
	if (coreq  =="yes") {meio=meio//"1"} else {meio=meio//"0"}
	if (retar  =="yes") {meio=meio//"1"} else {meio=meio//"0"}
	if (instr  =="yes") {meio=meio//"1"} else {meio=meio//"0"}
	if (inter  =="yes") {meio=meio//"1"} else {meio=meio//"0"}
	meio = meio//"_"

# SEPARA O ESPECTRO BIDIMENSIONAL EM DOIS ESPECTROS UNIDIMENSIONAIS
# GERA AS IMAGENS QUE SERAO UTILIZADAS PARA A EXTRACAO DO ESPECTRO DO CEU
	

	ver1 = access("tmp$")
	
	if (ver1 == no)
		mkdir ("tmp$")
		
	i1 = strlen(entr)
	
	entr = substr(entr, 2, i1) 
	
	flist1 = entr
	
	for (i = 1; i <= numer; i += 1) {
	
	lixo1 = fscan (flist1, s1)

	imcopy (input = fol//s1, output = "tmp$/"//s1, verbose = no)
	}
	;

	dir = "dir.txt"
    	flist1 = dir
   	pathnames (template = "", sort = yes, >> dir)
    	lixo1 = fscan (flist1, dir)
    	delete ("dir.txt", ver-, >& "dev$null")
    	
    	chdir ("tmp$")
	
	delete (entr, ver-, >& "dev$null")
	copy (dir//entr, entr, verbose = no)
	
	flist1 = entr
	
	if (ifu == "no") {
	for (i = 1; i <= numer; i += 1) {
	
	lixo1 = fscan (flist1, s1)
	
	sarith (input1 = s1, op = "copy", input2 = "", output = s1, w1 = INDEF, 
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "onedspec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
		
	}
	}

	
#VOLTAR!
#O QUE SAO AS IMAGENS 100*, 200*, 300*? ELAS ERAM GERADAS ANTES
	imdelete (images = "*.100*", verify = no, >& "dev$null")
	imdelete (images = "*.200*", verify = no, >& "dev$null")
	imdelete (images = "*.300*", verify = no, >& "dev$null")

	
	
# EXTRAI ESPECTROS DO CEU

# VOLTAR!	
#	hedit (images = "@"//entr, 
#	       fields = "WCSDIM,CD1_1,CD2_2,LTM1_1,LTM2_2", 
#		  value = "", add = no, delete = yes, verify = no, 
##		  show = no, 
#		  update = yes, 
#		  >& "dev$null")

	listaceuo = "temp3.txt"
	listaceue = "temp4.txt"

	for (i=1; i <= numer; i+=1)  {
		s1 = "co"//i						
		print (s1, >> listaceuo)
		
		s2 = "ce"//i
		print (s2, >> listaceue)
	}
	;	
	
	flist1 = entr
	flist2 = listaceuo

	for (i=1; i <= numer; i+=1) {
	
	lixo1 = fscan (flist1, s1)
	lixo1 = fscan (flist2, s2)
	
	if (ifu=="no") {
		imcopy (input = s1//"[*,1,3]", output = s2, verbose = no)
	} else {
		imcopy (input = s1//"[*,3]", output = s2, verbose = no)
	}
	}
	;
	
	flist1 = entr
	flist2 = listaceue

	for (i=1; i <= numer; i+=1) {
	
	lixo1 = fscan (flist1, s1)
	lixo1 = fscan (flist2, s2)
	
	if (ifu=="no") {
		imcopy (input = s1//"[*,1,3]", output = s2, verbose = no)
	} else {
		imcopy (input = s1//"[*,3]", output = s2, verbose = no)
	}
	
	}
	;
	
	if (ifu=="no") {
		imdelete ("@"//dir//entr, verify = no, >& "dev$null")
		delete (entr, ver-, >& "dev$null")
	}
	
# SETA VARIAVEL nome PARA O NOME DO ARQUIVO
	
	if (tip == "objeto") {
		nome = dir//"OBJ_"
		nome2= "OBJ_"
	}
	;
	if (tip == "npol") {
		nome = dir//"NPOL_"
		nome2= "NPOL_"
	}
	;	
	if (tip == "padpol") {
		nome = dir//"PAD_"
		nome2= "PAD_"
	}
	;	
	if (tip == "flat") {
		nome = dir//"FLAT_"
		nome2= "FLAT_"
	}
	;
	

# GERA LISTA COM OS NOMES PADRAO PARA OS ESPECTROS
	
	
	listaord = "temp1.txt"
	listaext = "temp2.txt"

	for (i=1; i <= numer; i+=1)  {
		s1 = "o"//i						
		print (s1, >> listaord)
		
		s2 = "e"//i
		print (s2, >> listaext)
	}
	;
	
	if (ifu=="yes") {
#IFU	
	flist1 = entr
	flist2 = listaord

	for (i=1; i <= numer; i+=1) {
	
	lixo1 = fscan (flist1, s1)
	lixo1 = fscan (flist2, s2)
	
	imcopy (input = s1//"[*,1]", output = s2, verbose = no)
	
	}
	;
	
	flist1 = entr
	flist2 = listaext

	for (i=1; i <= numer; i+=1) {
	
	lixo1 = fscan (flist1, s1)
	lixo1 = fscan (flist2, s2)
	
	imcopy (input = s1//"[*,2]", output = s2, verbose = no)
	
	}
	;
	}	
	
#  RENOMEIA OS ARQUIVOS DE ENTRADA PARA OS FORMATOS PADRAO	
	if (ifu == "no"){
	imrename (oldnames = "*0001.fits", newnames = "@temp1.txt", verbose = no)
	imrename (oldnames = "*0002.fits", newnames = "@temp2.txt", verbose = no)
	}
# INFORMACAO SOBRE O HEADER

	imgets (image = "e1.fits", param = "i_title")
	
	flist3 = imgets.value
	lixo1 = fscan (flist3, header1)
	
# CALCULO DO FLUXO TOTAL

     arqt = nome//"TOT_"//interv//"_"//numer//".fits"
	
	if (access (arqt)) {
		print ("File "//nome2//"TOT_"//interv//"_"//numer//" exists. Overwriting...")
		print (" ")
		imdelete (arqt, ver-, >& "dev$null")
	}
	;
	
	scombine (input="@"//listaord//",@"//listaext, output=arqt, 
		 noutput="", logfile="STDOUT", 
		 apertures="", group="all", combine="average", reject="none",
		 first = no, w1 = INDEF, w2 = INDEF, dw = INDEF, nw = INDEF,
		 scale = "none", zero = "none", weight = "none", sample = "",
		 lthreshold = INDEF, hthreshold = INDEF, nlow = 1, nhigh = 1, 
		 mclip = yes, lsigma = 3., hsigma = 3., rdnoise = "0.", gain = "1.",
		 sigscale = 0.1, pclip = -0.5, grow = 0, blank = 0., >& "dev$null"
		 		 
	hedit (images = arqt, fields = "CALCPOL", 
		  value = "Total Flux "//header1, add = yes,
		  delete = no, verify = no, 
#		  show = no, 
		  update = yes,
		  >& "dev$null")
	
     print ("TOTAL FLUX FOR "//header1, "  ->  ", nome2//"TOT_"//interv//"_"//numer//".fits")
	print (" ")
		
     imdelete (images = "TOTALnn1.fits,TOTALnn2.fits", verify = no, >& "dev$null")
	

# "BINAGEM" DAS IMAGENS

	if (interv != 1) {
	
	print ('Binning Interval: '//interv//" points")
	imgets (image= arqt, param = "CDELT1")
	print ('Old Resolution: ',real(imgets.value),'A/pixel')

# Determina numero de pontos do espectro	
	listpix (arqt, wcs="physical", >> "TEMP_1.txt") 
	
	flist1 = "TEMP_1.txt"
	
	lixo1 = fscan (flist1, lambdamin)
	
	while (fscan (flist1, lambdamax) != EOF) {}
	
	delete ("TEMP_1.txt", ver-)
	
	npix = (lambdamax - lambdamin) / interv
	
	intreal = (lambdamax - lambdamin)/npix
	
	r1 = interv / real(imgets.value)
		
	npontosx = r1
	
	dispcor.log = no
	dispcor.logfile = ""

	dispcor (input = arqt, output = arqt,
		linearize = yes, database = dir//"database",
		table = "", w1 = INDEF, w2 = INDEF, dw = INDEF, nw = npix, flux = no,
		samedisp = yes, global = no, ignoreaps = yes, confirm = no, listonly = no,
		verbose = no)
	imgets (image= arqt, param = "CDELT1")
	print ('New Resolution: ',real(imgets.value),'A/pixel')
	
	dispcor (input = "@temp1.txt,@temp2.txt", output = "@temp1.txt,@temp2.txt",
		linearize = yes, database = dir//"database",
		table = "", w1 = INDEF, w2 = INDEF, dw = INDEF, nw = npix, flux = no,
		samedisp = yes, global = no, ignoreaps = yes, confirm = no, listonly = no,
		verbose = no)

	dispcor (input = "@temp3.txt,@temp4.txt", output = "@temp3.txt,@temp4.txt", 
		linearize = yes, database = dir//"database",
		table = "", w1 = INDEF, w2 = INDEF, dw = INDEF, nw = npix, flux = no,
		samedisp = yes, global = no, ignoreaps = yes, confirm = no, listonly = no,
		verbose = no) # <-- bina os espectros do Ceu: flux = no
	 }
	 else {
	 	npontosx = 1
	 }
	 ;	
			
# CALCULO DE K
	
	print ("Calculating k...")

	scombine (input="@temp1.txt", output="KTemp.0001", noutput="", logfile="STDOUT", 
		 apertures="", group="apertures", combine="average", reject="none",
		 first = no, w1 = INDEF, w2 = INDEF, dw = INDEF, nw = INDEF,
		 scale = "none", zero = "none", weight = "none", sample = "",
		 lthreshold = INDEF, hthreshold = INDEF, nlow = 1, nhigh = 1, 
		 mclip = yes, lsigma = 3., hsigma = 3., rdnoise = "0.", gain = "1.",
		 sigscale = 0.1, pclip = -0.5, grow = 0, blank = 0., >& "dev$null")
		
	scombine (input="@temp2.txt", output="KTemp.0002", noutput="", logfile="STDOUT", 
		 apertures="", group="apertures", combine="average", reject="none",
		 first = no, w1 = INDEF, w2 = INDEF, dw = INDEF, nw = INDEF,
		 scale = "none", zero = "none", weight = "none", sample = "",
		 lthreshold = INDEF, hthreshold = INDEF, nlow = 1, nhigh = 1, 
		 mclip = yes, lsigma = 3., hsigma = 3., rdnoise = "0.", gain = "1.",
		 sigscale = 0.1, pclip = -0.5, grow = 0, blank = 0., >& "dev$null")	
		
						
	sarith (input1 = "KTemp.0002.fits", op = "/", input2 = "KTemp.0001.fits",
	 	output = "temp_9.fits", w1 = INDEF, w2 = INDEF, apertures = "",
	 	beams = "", apmodulus = 0, reverse = no, ignoreaps = yes,
	 	format = "multispec", renumber = no, offset = 0, clobber = no,
	 	merge = no, rebin = yes, errval = 0, verbose = no)	

		
	
# CALCULO DE Z

	flist1 = listaord
	flist2 = listaext
	
	print ("Calculating Zs...")
	print (" ")

	for (i=1; i <= numer; i+=1)  {
		
		linha1 = flist1//".fits"
		linha2 = flist2//".fits"



		s1 = "Z"//i//"_"//interv//"_"//numer//".fits"

		conta = "(im2-im1*im3)/(im2+im1*im3)"

		imcalc (input=linha1//","//linha2//",temp_9.fits", output=s1, equals=conta,
			pixtype="old", nullval = 0., verbose = no, mode="al")

	}
	;
	
	imdelete ("temp_9.fits", verify = no, >& "dev$null")


# CALCULO DE Q

	conta = "("
	arq4 = "input.txt"
		
	for (i=1; i <= (numer/4); i+=1) {
		
	s1 = "Z"//(i+3*(i-1))//"_"//interv//"_"//numer//".fits"
	s2 = "Z"//((i+3*(i-1))+2)//"_"//interv//"_"//numer//".fits"

	print (s1, >> arq4)
	print (s2, >> arq4)
	conta = conta//"im"//(2*i-1)//"-im"//(2*i)//"+"
	
	}
	;
	
	s4 = ""//(numer/2)
	
	conta = conta + "0.) / "//s4
	
	arqq = nome//meio//"Q_"//interv//"_"//numer//".fits"
	arqq2 = nome2//meio//"Q_"//interv//"_"//numer//".fits"

	if (access (arqq)) {
		print ("File "//arqq2//" exists. Overwriting...")
		print (" ")
		imdelete (arqq, ver-, >& "dev$null")
	}
	;
	
	imcalc (input="@input.txt", output=arqq, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")
					  
	print ("Stokes Parameter Q for Object "//header1, "  ->  ", arqq2)
	print (" ")
			
	delete (arq4, ver-, >& "dev$null")
	
# CALCULO DE U

#ATENCAO AQUI
#TROCO O SINAL DE U PARA COLOCA-LO NO SISTEMA "DO CEU"
#ISSO EH EQUIVALENTE A FAZER THETA_OBS = 180. - THETA_CEU

	conta = conta // "* (-1.)"

	for (i=1; i <= (numer/4); i+=1) {

	s1 = "Z"//(i+1+3*(i-1))//"_"//interv//"_"//numer//".fits"
	s2 = "Z"//((i+1+3*(i-1))+2)//"_"//interv//"_"//numer//".fits"

	print (s1, >> arq4)
	print (s2, >> arq4)
	
	}
	;  	
	arqu = nome//meio//"U_"//interv//"_"//numer//".fits"
	arqu2 = nome2//meio//"U_"//interv//"_"//numer//".fits"

	if (access (arqu)) {
		print ("File "//arqu2//" exists. Overwriting...")
		print (" ")
		imdelete (arqu, ver-, >& "dev$null")
	}
	;
	
	imcalc (input="@input.txt", output=arqu, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")
		
	print ("Stokes Parameter U for Object "//header1, "  ->  ", arqu2)
	print (" ")
	
	delete (arq4, ver-, >& "dev$null")
	
	
# CALCULO DO MODULO DO VETOR DE POLARIZACAO P

	arqp = nome//meio//"P_"//interv//"_"//numer//".fits"
	arqp2 = nome2//meio//"P_"//interv//"_"//numer//".fits"	

	if (access (arqp)) {
		print ("File "//arqp2//" exists. Overwriting...")
		print (" ")
		imdelete (arqp, ver-, >& "dev$null")
	}
	;	
	
	print (arqq, >> arq4)
	print (arqu, >> arq4)
	
	imcalc (input="@input.txt", output=arqp, equals="sqrt(im1**2+im2**2)",
		pixtype="old", nullval = 0., verbose = no, mode="al")
			
	print ("Polarization P for Object "//header1, "  ->  ", arqp2)
	print (" ")
		
	delete (arq4, ver-, >& "dev$null")
	
# CALCULO DO ANGULO DE POLARIZACAO

	sarith (input1 = arqu, op = "/", input2 = arqq, output = "TEMP_1", w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	unlearn wtextimage

	wtextimage (input = "TEMP_1.fits", output = "TEMP_1.txt") #, header = yes, format = "",


	wtextimage (input = arqu, output = "U.txt")

	pi = 3.14159265359
	
	arq1 = "TEMP_1.txt"
	arq2 = "TEMP_2.txt"
	arq3 = "U.txt"
	
	flist1 = arq1
	flist2 = arq3
	
	ver = yes
	s1 = "nulo"
		
	while (fscan (flist1, flist3) != EOF) {
		
		lixo1 = fscan (flist2, flist4)
		lixo1 = fscan (flist3, line1)
		
		if (line1 != "END" && ver == yes) {
		print (flist3, >> arq2)
		}
		else {
			if (ver == yes) {
			print (flist3, >> arq2)
			ver = no
			
			}
		}		
		;

		if (ver == no && line1 != "END") {
			lixo1 = fscan (flist3, s1)
			
			if (s1 == "nulo") 
			print ("            ", >> arq2)
			else {
			
			lixo1 = fscan (flist4, u1, u2, u3, u4, u5)
			
			lixo1 = fscan (flist3, r1, r2, r3, r4, r5)
			
			# r1 u1
			
			if (u1 > 0 && r1 > 0) 
			r1 = atan2(r1,1) * 180 / pi
								
			
			if (u1 > 0 && r1 < 0) 
			r1 = atan2(r1,1) * 180 / pi + 180
			
			
			if (u1 < 0 && r1 > 0) 
			r1 = atan2(r1,1) * 180 / pi + 180
			
						
			if (u1 < 0 && r1 < 0) 
			r1 = atan2(r1,1) * 180 / pi + 360
			
			
			# r2 u2
			
			if (u2 > 0 && r2 > 0) 
			r2 = atan2(r2,1) * 180 / pi
								
			
			if (u2 > 0 && r2 < 0) 
			r2 = atan2(r2,1) * 180 / pi + 180
			
			
			if (u2 < 0 && r2 > 0) 
			r2 = atan2(r2,1) * 180 / pi + 180
			
						
			if (u2 < 0 && r2 < 0) 
			r2 = atan2(r2,1) * 180 / pi + 360
			
			
			# r3 u3
			
			if (u3 > 0 && r3 > 0) 
			r3 = atan2(r3,1) * 180 / pi
								
			
			if (u3 > 0 && r3 < 0) 
			r3 = atan2(r3,1) * 180 / pi + 180
			
			
			if (u3 < 0 && r3 > 0) 
			r3 = atan2(r3,1) * 180 / pi + 180
			
						
			if (u3 < 0 && r3 < 0) 
			r3 = atan2(r3,1) * 180 / pi + 360
			
			
			# r4 u4
			
			if (u4 > 0 && r4 > 0) 
			r4 = atan2(r4,1) * 180 / pi
								
			
			if (u4 > 0 && r4 < 0) 
			r4 = atan2(r4,1) * 180 / pi + 180
			
			
			
			if (u4 < 0 && r4 > 0) 
			r4 = atan2(r4,1) * 180 / pi + 180
			
						
			if (u4 < 0 && r4 < 0) 
			r4 = atan2(r4,1) * 180 / pi + 360
			
			
			# r5 u5
			
			if (u5 > 0 && r5 > 0) 
			r5 = atan2(r5,1) * 180 / pi
								
			
			if (u5 > 0 && r5 < 0) 
			r5 = atan2(r5,1) * 180 / pi + 180
			
			
			if (u5 < 0 && r5 > 0) 
			r5 = atan2(r5,1) * 180 / pi + 180
			
						
			if (u5 < 0 && r5 < 0) 
			r5 = atan2(r5,1) * 180 / pi + 360
			
			print (r1/2, " ", r2/2, " ", r3/2, " ", r4/2, " ", r5/2, >> arq2)
			#print (180-r1/2, " ", 180-r2/2, " ", 180-r3/2, " ", 180-r4/2, " ", 180-r5/2, >> arq2)
			
			}
						
		}
		;
	
	}
		
	arqan = nome//meio//"ANG_"//interv//"_"//numer//".fits"
	arqan2 = nome2//meio//"ANG_"//interv//"_"//numer//".fits"
	
	if (access (arqan)) {
		print ("File "//arqan2//" exists. Overwriting...")
		print (" ")
		imdelete (arqan, ver-, >& "dev$null")
	}
	;
	
	unlearn rtextimage

	rtextimage (input = "TEMP_2.txt", output = arqan) #, otype = "", header = yes) #, nskip = 0, dim =)
	imdelete (images = "TEMP*.fits", verify = no, >& "dev$null")
	delete ("TEMP*.txt", ver-, >& "dev$null")
	delete ("U.txt", ver-)

	print ("Polarization Angle for Object "//header1, "  ->  ", arqan2)
	print (" ")	
	
# CALCULO DO ERRO EXPERIMENTAL
	
	for (i=1; i <= numer; i+=1)  {
	
	s1 = "Z"//i//"_"//interv//"_"//numer//".fits"
	s2 = "Zquad"//i
	
	imcalc (input=s1, output=s2, equals="im1**2",
		pixtype="old", nullval = 0., verbose = no, mode="al")
	
	}
	
	scombine (input="Zquad*.fits", output="ZZQUAD8", noutput="", logfile="STDOUT",
		 apertures="", group="all", combine="sum", reject="none",
		 first = no, w1 = INDEF, w2 = INDEF, dw = INDEF, nw = INDEF,
		 scale = "none", zero = "none", weight = "none", sample = "",
		 lthreshold = INDEF, hthreshold = INDEF, nlow = 1, nhigh = 1,
		 mclip = yes, lsigma = 3., hsigma = 3., rdnoise = "0.", gain = "1.",
		 sigscale = 0.1, pclip = -0.5, grow = 0, blank = 0., >& "dev$null")

	
	arqs = nome//"SIG_"//interv//"_"//numer//".fits"
	
	if (access (arqs)) {
		print ("File "//nome2//"SIG_"//interv//"_"//numer//" exists. Overwriting...")
		print (" ")
		imdelete (arqs, ver-, >& "dev$null")
	}
	;	
	
	print ("ZZQUAD8.fits", >> arq4)
	print (arqq, >> arq4)
	print (arqu, >> arq4)
	
	conta = "sqrt(1./"//numer-2//"*((im1/"//s4//".)-(im2**2+im3**2)))"
	
	imcalc (input="@input.txt", output=arqs, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")
	
	hedit (images = arqs, fields = "CALCPOL", value = "Polarization Error for Object "//header1, add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")

	print ("Polarization Error for Object "//header1, "  ->  ", nome2//"SIG_"//interv//"_"//numer//".fits")
	print (" ")

	imdelete (images = "Zquad*.fits,ZZQUAD8.fits", verify = no, >& "dev$null")
	delete (arq4, ver-, >& "dev$null")	
	
#SE FOR O CASO, APLICA CORRECAO DA DEPENDENCIA ESPECTRAL DO THETA
	if (corflat=="yes") {
	
	print ("Applying correction for the Spectral Dependence of Theta...")
	print (" ")
# COPIA ANG E P PARA DIRETORIO TEMPORARIO
	imcopy(input=arqan,output=arqan2, >& "dev$null")
	imcopy(input=arqp,output=arqp2, >& "dev$null")

# DETERMINACAO DO ANGULO NO MEIO DO ESPECTRO e CORRECAO DO ANGULO
	if (interv != 1) {
		dispcor.log = no
		dispcor.logfile = ""

	dispcor (input = ffile, output = "flat123.fits",
		linearize = yes, database = dir//"database",
		table = "", w1 = INDEF, w2 = INDEF, dw = INDEF, nw = npix, flux = no,
		samedisp = yes, global = no, ignoreaps = yes, confirm = no, listonly = no,
		verbose = no)
	} else {
		imcopy(input=ffile,output="flat123.fits", >& "dev$null")
	}
	
	unlearn listpix
	listpix ("flat123.fits", wcs="world", >> "TEMP_1.txt") # Determina extremos de Compr. de Onda

	flist1 = "TEMP_1.txt"
	
	lixo1 = fscan (flist1, lmin)
	
	while (fscan (flist1, lmax) != EOF) {}
	  
	delete ("TEMP_1.txt", ver-)
	
	lmeio = (lmin + lmax) / 2
	
	arq1 = "TEMP_1.txt"
	arq2 = "TEMP_2.txt"
		
	print (lmeio, " 1 1 C", >> arq1)
	
	unlearn splot 			#tirar isso...
	
	splot (images = "flat123.fits", line = 1, band = 1, star_name = "", 
		next_image = "",
		new_image = "", overwrite = yes, cursor = arq1,
		>> arq2, >G "dev$null")

	delete (arq1, >& "dev$null", ver-)

	flist1 = arq2
	
	lixo1 = fscan (flist1, s1, s2, s3, ang)
	delete (arq2, >& "dev$null", ver-)
	
	arq3 = "input.txt"
	print ("flat123.fits", >> arq3)
	print (arqan2, >> arq3)
	
	conta = "im2-(im1-"//ang//")"
	
	imdelete (arqan, verify = no, >& "dev$null")
	
	imcalc (input="@input.txt", output=arqan, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")

	hedit (images = arqan, fields = "CORFLAT", 
	       value = ffile, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")

	delete (arq3, >& "dev$null", ver-)
	imdelete (arqan2, verify = no, >& "dev$null")
	
# CALCULO DE Q CORRIGIDO
	
	arq3 = "input.txt"
	print (arqp2, >> arq3)
	print (arqan, >> arq3)
	
#	conta = "im1*cos(2*(-im2+180)*3.14159265/180)"
	conta = "im1*cos(2*im2*3.14159265/180)"

	imdelete (arqq, verify = no, >& "dev$null")
	
	imcalc (input="@input.txt", output=arqq, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")

	hedit (images = arqq, fields = "CORFLAT", 
	       value = ffile, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")

	delete (arq3, >& "dev$null", ver-)
	imdelete (arqq2, verify = no, >& "dev$null")

	# CALCULO DE U CORRIGIDO
	
	arq3 = "input.txt"
	print (arqp2, >> arq3)
	print (arqan, >> arq3)
	
	conta = "im1*sin(2.*im2*3.14159265/180)"

	imdelete (arqu, verify = no, >& "dev$null")
	
	imcalc (input="@input.txt", output=arqu, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")

	hedit (images = arqu, fields = "CORFLAT", 
	       value = ffile, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
		  
	hedit (images = arqp, fields = "CORFLAT", 
	       value = ffile, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")

	delete (arq3, >& "dev$null", ver-)
	imdelete (arqu2, verify = no, >& "dev$null")
	imdelete (arqp2, verify = no, >& "dev$null")
	imdelete ("flat123", verify = no, >& "dev$null")
	
	
	}
	
	if (coreq=="yes") {
	
	print ("Rotating PA to Equatorial System...")
	print (" ")
# COPIA ANG E P PARA DIRETORIO TEMPORARIO
	imcopy(input=arqan,output=arqan2, >& "dev$null")
	imcopy(input=arqp,output=arqp2, >& "dev$null")

#	sarith (input1 = arqan2, op = "copy", input2 = "", output = "temp22", 
#	     w1 = eqlmin, w2 = eqlmax, 
#		apertures = "", beams = "", apmodulus = 0,reverse = no,
#		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
#		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
	
# DETERMINACAO DE npix2

#	imstatistics (images = "temp22", fields = "npix", lower = INDEF, 
#	upper = INDEF, binwidth = 0, format = no, >> "TEMP_1.txt")
	
#	flist1 = "TEMP_1.txt"
#	lixo1 = fscan (flist1, npix2)
#	delete ("TEMP_1.txt", ver-)
	
#	imstatistics (images = "temp22", fields = "mean", lower = INDEF, 
#	upper = INDEF, binwidth = 0, format = no, >> "ANG.txt")
		
#	flist1 = "ANG.txt"
#	lixo1 = fscan (flist1, ang)

#	delete ("ANG", ver-, >& "dev$null")
	
	imdelete (arqan, verify = no, >& "dev$null")
	sarith (input1 = arqan2, op = "+", input2 = dtheta, output = "ANG_TEMP", 
	     w1 = INDEF, w2 = INDEF, 
		apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	imdelete (arqan2, verify = no, >& "dev$null")
	
# CALCULO DE Q CORRIGIDO
	
	arq3 = "input.txt"
	print (arqp2, >> arq3)
	print ("ANG_TEMP", >> arq3)
	
	conta = "im1*cos(2.*im2*3.14159265/180.)"

	imdelete (arqq, verify = no, >& "dev$null")
	
	imcalc (input="@input.txt", output=arqq, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")

	hedit (images = arqq, fields = "COREQ", 
	       value = dtheta, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")

	delete (arq3, >& "dev$null", ver-)
	imdelete (arqq2, verify = no, >& "dev$null")
	
# CALCULO DE U CORRIGIDO
	
	arq3 = "input.txt"
	print (arqp2, >> arq3)
	print ("ANG_TEMP", >> arq3)
	
	conta = "im1*sin(2.*im2*3.14159265/180.)"

	imdelete (arqu, verify = no, >& "dev$null")
	
	imcalc (input="@input.txt", output=arqu, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")

	hedit (images = arqu, fields = "COREQ", 
	       value = dtheta, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
		  
	delete (arq3, >& "dev$null", ver-)
	imdelete (arqu2, verify = no, >& "dev$null")
	imdelete (arqp2, verify = no, >& "dev$null")
	
# CALCULO DO ANGULO DE POLARIZACAO

	sarith (input1 = arqu, op = "/", input2 = arqq, output = "TEMP_1", w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	unlearn wtextimage

	wtextimage (input = "TEMP_1.fits", output = "TEMP_1.txt") #, header = yes, format = "",
		
		
	wtextimage (input = arqu, output = "U.txt")

	pi = 3.14159265359
	
	arq1 = "TEMP_1.txt"
	arq2 = "TEMP_2.txt"
	arq3 = "U.txt"
	
	flist1 = arq1
	flist2 = arq3
	
	ver = yes
	s1 = "nulo"
		
	while (fscan (flist1, flist3) != EOF) {
		
		lixo1 = fscan (flist2, flist4)
		lixo1 = fscan (flist3, line1)
		
		if (line1 != "END" && ver == yes) {
		print (flist3, >> arq2)
		}
		else {
			if (ver == yes) {
			print (flist3, >> arq2)
			ver = no
			
			}
		}		
		;
		
		if (ver == no && line1 != "END") {
			lixo1 = fscan (flist3, s1)
			
			if (s1 == "nulo") 
			print ("            ", >> arq2)
			else {
			
			lixo1 = fscan (flist4, u1, u2, u3, u4, u5)
			
			lixo1 = fscan (flist3, r1, r2, r3, r4, r5)
			
			# r1 u1
			
			if (u1 > 0 && r1 > 0) 
			r1 = atan2(r1,1) * 180 / pi
								
			
			if (u1 > 0 && r1 < 0) 
			r1 = atan2(r1,1) * 180 / pi + 180
			
			
			if (u1 < 0 && r1 > 0) 
			r1 = atan2(r1,1) * 180 / pi + 180
			
						
			if (u1 < 0 && r1 < 0) 
			r1 = atan2(r1,1) * 180 / pi + 360
			
			
			# r2 u2
			
			if (u2 > 0 && r2 > 0) 
			r2 = atan2(r2,1) * 180 / pi
								
			
			if (u2 > 0 && r2 < 0) 
			r2 = atan2(r2,1) * 180 / pi + 180
			
			
			if (u2 < 0 && r2 > 0) 
			r2 = atan2(r2,1) * 180 / pi + 180
			
						
			if (u2 < 0 && r2 < 0) 
			r2 = atan2(r2,1) * 180 / pi + 360
			
			
			# r3 u3
			
			if (u3 > 0 && r3 > 0) 
			r3 = atan2(r3,1) * 180 / pi
								
			
			if (u3 > 0 && r3 < 0) 
			r3 = atan2(r3,1) * 180 / pi + 180
			
			
			if (u3 < 0 && r3 > 0) 
			r3 = atan2(r3,1) * 180 / pi + 180
			
						
			if (u3 < 0 && r3 < 0) 
			r3 = atan2(r3,1) * 180 / pi + 360
			
			
			# r4 u4
			
			if (u4 > 0 && r4 > 0) 
			r4 = atan2(r4,1) * 180 / pi
								
			
			if (u4 > 0 && r4 < 0) 
			r4 = atan2(r4,1) * 180 / pi + 180
			
			
			
			if (u4 < 0 && r4 > 0) 
			r4 = atan2(r4,1) * 180 / pi + 180
			
						
			if (u4 < 0 && r4 < 0) 
			r4 = atan2(r4,1) * 180 / pi + 360
			
			
			# r5 u5
			
			if (u5 > 0 && r5 > 0) 
			r5 = atan2(r5,1) * 180 / pi
								
			
			if (u5 > 0 && r5 < 0) 
			r5 = atan2(r5,1) * 180 / pi + 180
			
			
			if (u5 < 0 && r5 > 0) 
			r5 = atan2(r5,1) * 180 / pi + 180
			
						
			if (u5 < 0 && r5 < 0) 
			r5 = atan2(r5,1) * 180 / pi + 360
			
			print (r1/2, " ", r2/2, " ", r3/2, " ", r4/2, " ", r5/2, >> arq2)
			#print (180-r1/2, " ", 180-r2/2, " ", 180-r3/2, " ", 180-r4/2, " ", 180-r5/2, >> arq2)
			
			}
						
		}
		;
	
	}
		
	imdelete (arqan, ver-, >& "dev$null")

	unlearn rtextimage

	rtextimage (input = "TEMP_2.txt", output = arqan) #, otype = "", header = yes) #, nskip = 0, dim =)
	imdelete (images = "TEMP*.fits", verify = no, >& "dev$null")
	delete ("TEMP*.txt", ver-, >& "dev$null")
	delete ("U.txt", ver-)
	
	}

	if (retar=="yes") {}

# INSTRUMENTAL POLARIZATION	
	if (instr=="yes") {
	
	print ("Correcting for the Instrumental Polarization...")
	print (" ")
	
	if (interv != 1) {
		dispcor.log = no
		dispcor.logfile = ""

	dispcor (input = qfile, output = "q123.fits",
		linearize = yes, database = dir//"database",
		table = "", w1 = INDEF, w2 = INDEF, dw = INDEF, nw = npix, flux = no,
		samedisp = yes, global = no, ignoreaps = yes, confirm = no, listonly = no,
		verbose = no)
	} else {
		imcopy(input=qfile,output="q123.fits", >& "dev$null")
	}
	
	sarith (input1 = arqq, op = "-", input2 = "q123.fits", output = arqq2, 
	     w1 = INDEF, w2 = INDEF, 
		apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	imdelete (images = "q123.fits", verify = no, >& "dev$null")

	if (interv != 1) {
		dispcor.log = no
		dispcor.logfile = ""

	dispcor (input = ufile, output = "u123.fits",
		linearize = yes, database = dir//"database",
		table = "", w1 = INDEF, w2 = INDEF, dw = INDEF, nw = npix, flux = no,
		samedisp = yes, global = no, ignoreaps = yes, confirm = no, listonly = no,
		verbose = no)
	} else {
		imcopy(input=ufile,output="u123.fits", >& "dev$null")
	}
		
	sarith (input1 = arqu, op = "-", input2 = "u123.fits", output = arqu2, 
	     w1 = INDEF, w2 = INDEF, 
		apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
		
	imdelete (images = "u123.fits", verify = no, >& "dev$null")

	imdelete (images = arqq, verify = no, >& "dev$null")
	imdelete (images = arqu, verify = no, >& "dev$null")
	
	imcopy(input=arqq2,output=arqq, >& "dev$null")
	imcopy(input=arqu2,output=arqu, >& "dev$null")

	imdelete (images = arqq2, verify = no, >& "dev$null")
	imdelete (images = arqu2, verify = no, >& "dev$null")
	
	hedit (images = arqq, fields = "INSTR", 
	       value = qfile, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
		  
	hedit (images = arqu, fields = "INSTR", 
	       value = ufile, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")

# CALCULO DE P CORRIGIDO
	
	imdelete (arqp, ver-, >& "dev$null")
	
	print (arqq, >> arq4)
	print (arqu, >> arq4)
	
	imcalc (input="@input.txt", output=arqp, equals="sqrt(im1**2+im2**2)",
		pixtype="old", nullval = 0., verbose = no, mode="al")
			
	hedit (images = arqp, fields = "CALCPOL", value = "Polarization P for Object "//header1, add = yes,
		delete = no, verify = no, 
     	update = yes,
		>& "dev$null")
		  
	delete (arq4, ver-, >& "dev$null")
	
# CALCULO DO ANGULO DE POLARIZACAO

	sarith (input1 = arqu, op = "/", input2 = arqq, output = "TEMP_1", w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	unlearn wtextimage

	wtextimage (input = "TEMP_1.fits", output = "TEMP_1.txt") #, header = yes, format = "",
		
		
	wtextimage (input = arqu, output = "U.txt")

	pi = 3.14159265359
	
	arq1 = "TEMP_1.txt"
	arq2 = "TEMP_2.txt"
	arq3 = "U.txt"
	
	flist1 = arq1
	flist2 = arq3
	
	ver = yes
	s1 = "nulo"
		
	while (fscan (flist1, flist3) != EOF) {
		
		lixo1 = fscan (flist2, flist4)
		lixo1 = fscan (flist3, line1)
		
		if (line1 != "END" && ver == yes) {
		print (flist3, >> arq2)
		}
		else {
			if (ver == yes) {
			print (flist3, >> arq2)
			ver = no
			
			}
		}		
		;
		
		if (ver == no && line1 != "END") {
			lixo1 = fscan (flist3, s1)
			
			if (s1 == "nulo") 
			print ("            ", >> arq2)
			else {
			
			lixo1 = fscan (flist4, u1, u2, u3, u4, u5)
			
			lixo1 = fscan (flist3, r1, r2, r3, r4, r5)
			
			# r1 u1
			
			if (u1 > 0 && r1 > 0) 
			r1 = atan2(r1,1) * 180 / pi
								
			
			if (u1 > 0 && r1 < 0) 
			r1 = atan2(r1,1) * 180 / pi + 180
			
			
			if (u1 < 0 && r1 > 0) 
			r1 = atan2(r1,1) * 180 / pi + 180
			
						
			if (u1 < 0 && r1 < 0) 
			r1 = atan2(r1,1) * 180 / pi + 360
			
			
			# r2 u2
			
			if (u2 > 0 && r2 > 0) 
			r2 = atan2(r2,1) * 180 / pi
								
			
			if (u2 > 0 && r2 < 0) 
			r2 = atan2(r2,1) * 180 / pi + 180
			
			
			if (u2 < 0 && r2 > 0) 
			r2 = atan2(r2,1) * 180 / pi + 180
			
						
			if (u2 < 0 && r2 < 0) 
			r2 = atan2(r2,1) * 180 / pi + 360
			
			
			# r3 u3
			
			if (u3 > 0 && r3 > 0) 
			r3 = atan2(r3,1) * 180 / pi
								
			
			if (u3 > 0 && r3 < 0) 
			r3 = atan2(r3,1) * 180 / pi + 180
			
			
			if (u3 < 0 && r3 > 0) 
			r3 = atan2(r3,1) * 180 / pi + 180
			
						
			if (u3 < 0 && r3 < 0) 
			r3 = atan2(r3,1) * 180 / pi + 360
			
			
			# r4 u4
			
			if (u4 > 0 && r4 > 0) 
			r4 = atan2(r4,1) * 180 / pi
								
			
			if (u4 > 0 && r4 < 0) 
			r4 = atan2(r4,1) * 180 / pi + 180
			
			
			
			if (u4 < 0 && r4 > 0) 
			r4 = atan2(r4,1) * 180 / pi + 180
			
						
			if (u4 < 0 && r4 < 0) 
			r4 = atan2(r4,1) * 180 / pi + 360
			
			
			# r5 u5
			
			if (u5 > 0 && r5 > 0) 
			r5 = atan2(r5,1) * 180 / pi
								
			
			if (u5 > 0 && r5 < 0) 
			r5 = atan2(r5,1) * 180 / pi + 180
			
			
			if (u5 < 0 && r5 > 0) 
			r5 = atan2(r5,1) * 180 / pi + 180
			
						
			if (u5 < 0 && r5 < 0) 
			r5 = atan2(r5,1) * 180 / pi + 360
			
			print (r1/2, " ", r2/2, " ", r3/2, " ", r4/2, " ", r5/2, >> arq2)
			#print (180-r1/2, " ", 180-r2/2, " ", 180-r3/2, " ", 180-r4/2, " ", 180-r5/2, >> arq2)
			
			}
						
		}
		;
	
	}
		
	imdelete (arqan, ver-, >& "dev$null")

	unlearn rtextimage

	rtextimage (input = "TEMP_2.txt", output = arqan) #, otype = "", header = yes) #, nskip = 0, dim =)
	imdelete (images = "TEMP*.fits", verify = no, >& "dev$null")
	delete ("TEMP*.txt", ver-, >& "dev$null")
	delete ("U.txt", ver-)

	}	
	
	
# INTERSTELLAR POLARIZATION	
	if (inter=="yes") {
	
	print ("Correcting for the Interstellar Polarization...")
	print (" ")

	imcopy(input=arqq,output=arqq2, >& "dev$null")
	imcopy(input=arqu,output=arqu2, >& "dev$null")

	unlearn wtextimage
	
	wtextimage (input = arqq, >> "ARQUIVO.txt")

# CONSTROI O ESPECTRO COM O O FORMATO DA FUNCAO
	 
 	flist1 = "ARQUIVO.txt"
 	flist2 = "ARQUIVO.txt"
	
	arq1 = "TEMP_1.txt"
	
	listpix (arqt, 
	         wcs="world", >> arq1)
	
	flist5 = arq1
	
	arq2 = "TEMP_2.txt"
	
	if (law=="wilking82") {
		k = -0.1 + 1.86*lbdmax/1.E4 #lbdmax is in microns
	}
	if (law=="wilking80") {
		k = -0.002 + 1.68*lbdmax/1.E4 #lbdmax is in microns
	}
	if (law=="serkowsky") {
		k = 1.15
	}


	ver = yes
	s1 = "nulo"
		
	while (fscan (flist1, flist3) != EOF) {
		
		lixo1 = fscan (flist3, line1)
		
		if (line1 != "END" && ver == yes) {
		print (flist3, >> arq2)
		}
		else {
			if (ver == yes) {
			print (flist3, >> arq2)
			ver = no
			
			}
		}		
		;
		
		if (ver == no && line1 != "END") {
			lixo1 = fscan (flist3, s1)
			if (s1 == "nulo") 
			print ("            ", >> arq2)
			
			else {
			
			lixo1 = fscan(flist5, r1)
			lixo1 = fscan(flist5, r2)
			lixo1 = fscan(flist5, r3)
			lixo1 = fscan(flist5, r4)
			lixo1 = fscan(flist5, r5)
			
			r1 = pmaxi * exp(-k*log(lbdmax/r1)**2)
			r2 = pmaxi * exp(-k*log(lbdmax/r2)**2)
			r3 = pmaxi * exp(-k*log(lbdmax/r3)**2)
			r4 = pmaxi * exp(-k*log(lbdmax/r4)**2)
			r5 = pmaxi * exp(-k*log(lbdmax/r5)**2)
			
			flist3 = ""//r1//" "//r2//" "//r3//" "//r4//" "//r5
						
			print (flist3, >> arq2)
			
			}
						
		}
		;
	
	}
	
	unlearn rtextimage
	
	arq1 = "IP_"//interv//".fits"
	print ("Insterstellar Polarization  ->  ", arq1)
	
#	if (access (dir//arq1)) {
#		print ("File "//arq1//" exists. Overwriting...")
		imdelete (dir//arq1, ver-, >& "dev$null")
#	}
#	;
	
	rtextimage (input = arq2, output = dir//arq1) #, otype = "", header = yes) #, nskip = 0, dim =)
	
#	imdelete (images = "TEMP*.imh", verify = no, >& "dev$null")
	imdelete (images = "TEMP*.fits", verify = no, >& "dev$null")
	delete ("TEMP*.txt, ARQUIVO.txt", ver-)
	
	
# Calculate interstellar Q and U
	arq2 = "IQ_"//interv//".fits"
	arq3 = "IU_"//interv//".fits"
	print ("Insterstellar Q   ->  ", arq2)
	print ("Insterstellar U   ->  ", arq3)

#	if (access (dir//arq2)) {
#		print ("File "//arq2//" exists. Overwriting...")
		imdelete (dir//arq2, ver-, >& "dev$null")
#	}
#	;

	r1 = cos(2.*theta*pi/180.)
	sarith (input1 = dir//arq1, op = "*", input2 = r1,
	 	output = dir//arq2, w1 = INDEF, w2 = INDEF, apertures = "",
	 	beams = "", apmodulus = 0, reverse = no, ignoreaps = yes,
	 	format = "multispec", renumber = no, offset = 0, clobber = no,
	 	merge = no, rebin = yes, errval = 0, verbose = no)	

#	if (access (dir//arq3)) {
#		print ("File "//arq3//" exists. Overwriting...")
		imdelete (dir//arq3, ver-, >& "dev$null")
#	}
#	;
		
#ATENCAO PARA O MENOS AQUI! ISSO FAZ O SISTEMA GIRAR EM 180 graus
# theta = 180-theta		
	r2 = -sin(2.*theta*pi/180.)
	sarith (input1 = dir//arq1, op = "*", input2 = r2,
	 	output = dir//arq3, w1 = INDEF, w2 = INDEF, apertures = "",
	 	beams = "", apmodulus = 0, reverse = no, ignoreaps = yes,
	 	format = "multispec", renumber = no, offset = 0, clobber = no,
	 	merge = no, rebin = yes, errval = 0, verbose = no)	

#Correct for Interstellar Polarization

	imdelete (arqq, ver-, >& "dev$null")

	sarith (input1 = arqq2, op = "-", input2 = dir//arq2, output = arqq, w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	hedit (images = arqq, fields = "INTER", 
	       value = "Corrected for Inter. Polar.: Pmax="//pmaxi//"; Lmax="//lbdmax//"; Theta="//theta, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")

	imdelete (arqq2, ver-, >& "dev$null")
		
	imdelete (arqu, ver-, >& "dev$null")

	sarith (input1 = arqu2, op = "-", input2 = dir//arq3, output = arqu, w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	hedit (images = arqu, fields = "INTER", 
	       value = "Corrected for Inter. Polar.: Pmax="//pmaxi//"; Lmax="//lbdmax//"; Theta="//theta, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")

	imdelete (arqu2, ver-, >& "dev$null")
	
# CALCULO DE P CORRIGIDO
	
	imdelete (arqp, ver-, >& "dev$null")
	
	print (arqq, >> arq4)
	print (arqu, >> arq4)
	
	imcalc (input="@input.txt", output=arqp, equals="sqrt(im1**2+im2**2)",
		pixtype="old", nullval = 0., verbose = no, mode="al")
			
	hedit (images = arqp, fields = "INTER", 
	       value = "Corrected for Inter. Polar.: Pmax="//pmaxi//"; Lmax="//lbdmax//"; Theta="//theta, 
		delete = no, verify = no, 
     	update = yes,
		>& "dev$null")
		  
	delete (arq4, ver-, >& "dev$null")
	
# CALCULO DO ANGULO DE POLARIZACAO

	sarith (input1 = arqu, op = "/", input2 = arqq, output = "TEMP_1", w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	unlearn wtextimage

	wtextimage (input = "TEMP_1.fits", output = "TEMP_1.txt") #, header = yes, format = "",
		
		
	wtextimage (input = arqu, output = "U.txt")

	pi = 3.14159265359
	
	arq1 = "TEMP_1.txt"
	arq2 = "TEMP_2.txt"
	arq3 = "U.txt"
	
	flist1 = arq1
	flist2 = arq3
	
	ver = yes
	s1 = "nulo"
		
	while (fscan (flist1, flist3) != EOF) {
		
		lixo1 = fscan (flist2, flist4)
		lixo1 = fscan (flist3, line1)
		
		if (line1 != "END" && ver == yes) {
		print (flist3, >> arq2)
		}
		else {
			if (ver == yes) {
			print (flist3, >> arq2)
			ver = no
			
			}
		}		
		;
		
		if (ver == no && line1 != "END") {
			lixo1 = fscan (flist3, s1)
			
			if (s1 == "nulo") 
			print ("            ", >> arq2)
			else {
			
			lixo1 = fscan (flist4, u1, u2, u3, u4, u5)
			
			lixo1 = fscan (flist3, r1, r2, r3, r4, r5)
			
			# r1 u1
			
			if (u1 > 0 && r1 > 0) 
			r1 = atan2(r1,1) * 180 / pi
								
			
			if (u1 > 0 && r1 < 0) 
			r1 = atan2(r1,1) * 180 / pi + 180
			
			
			if (u1 < 0 && r1 > 0) 
			r1 = atan2(r1,1) * 180 / pi + 180
			
						
			if (u1 < 0 && r1 < 0) 
			r1 = atan2(r1,1) * 180 / pi + 360
			
			
			# r2 u2
			
			if (u2 > 0 && r2 > 0) 
			r2 = atan2(r2,1) * 180 / pi
								
			
			if (u2 > 0 && r2 < 0) 
			r2 = atan2(r2,1) * 180 / pi + 180
			
			
			if (u2 < 0 && r2 > 0) 
			r2 = atan2(r2,1) * 180 / pi + 180
			
						
			if (u2 < 0 && r2 < 0) 
			r2 = atan2(r2,1) * 180 / pi + 360
			
			
			# r3 u3
			
			if (u3 > 0 && r3 > 0) 
			r3 = atan2(r3,1) * 180 / pi
								
			
			if (u3 > 0 && r3 < 0) 
			r3 = atan2(r3,1) * 180 / pi + 180
			
			
			if (u3 < 0 && r3 > 0) 
			r3 = atan2(r3,1) * 180 / pi + 180
			
						
			if (u3 < 0 && r3 < 0) 
			r3 = atan2(r3,1) * 180 / pi + 360
			
			
			# r4 u4
			
			if (u4 > 0 && r4 > 0) 
			r4 = atan2(r4,1) * 180 / pi
								
			
			if (u4 > 0 && r4 < 0) 
			r4 = atan2(r4,1) * 180 / pi + 180
			
			
			
			if (u4 < 0 && r4 > 0) 
			r4 = atan2(r4,1) * 180 / pi + 180
			
						
			if (u4 < 0 && r4 < 0) 
			r4 = atan2(r4,1) * 180 / pi + 360
			
			
			# r5 u5
			
			if (u5 > 0 && r5 > 0) 
			r5 = atan2(r5,1) * 180 / pi
								
			
			if (u5 > 0 && r5 < 0) 
			r5 = atan2(r5,1) * 180 / pi + 180
			
			
			if (u5 < 0 && r5 > 0) 
			r5 = atan2(r5,1) * 180 / pi + 180
			
						
			if (u5 < 0 && r5 < 0) 
			r5 = atan2(r5,1) * 180 / pi + 360
			
			print (r1/2, " ", r2/2, " ", r3/2, " ", r4/2, " ", r5/2, >> arq2)
			#print (180-r1/2, " ", 180-r2/2, " ", 180-r3/2, " ", 180-r4/2, " ", 180-r5/2, >> arq2)
			
			}
						
		}
		;
	
	}
		
	imdelete (arqan, ver-, >& "dev$null")

	unlearn rtextimage

	rtextimage (input = "TEMP_2.txt", output = arqan) #, otype = "", header = yes) #, nskip = 0, dim =)
	imdelete (images = "TEMP*.fits", verify = no, >& "dev$null")
	delete ("TEMP*.txt", ver-, >& "dev$null")
	delete ("U.txt", ver-)

	hedit (images = arqan, fields = "INTER", 
	       value = "Corrected for Inter. Polar.: Pmax="//pmaxi//"; Lmax="//lbdmax//"; Theta="//theta, 
		delete = no, verify = no, 
     	update = yes,
		>& "dev$null")

	}
	
	hedit (images = arqq, fields = "CALCPOL", 
		value = "Stokes Parameter Q for Object "//header1, add = yes,
		delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
	hedit (images = arqu, fields = "CALCPOL", value = "Stokes Parameter U for Object "//header1, add = yes,
		delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
	
	hedit (images = arqp, fields = "CALCPOL", value = "Polarization P for Object "//header1, add = yes,
		delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
		  
	hedit (images = arqan, fields = "CALCPOL", value = "Polarization Angle for Object "//header1, add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
	
	
# CALCULO DO ERRO TEORICO

	imgets (image= arqt, param = "NPONTOS")
	
	npontosy = imgets.value
		
	ruido = rdnoise**2 # * numer # verificar isso

	scombine (input="@temp3.txt,@temp4.txt", output="CEU", noutput="", logfile="STDOUT", 
		 apertures="", group="all", combine="average", reject="none",
		 first = no, w1 = INDEF, w2 = INDEF, dw = INDEF, nw = INDEF,
		 scale = "none", zero = "none", weight = "none", sample = "",
		 lthreshold = INDEF, hthreshold = INDEF, nlow = 1, nhigh = 1, 
		 mclip = yes, lsigma = 3., hsigma = 3., rdnoise = "0.", gain = "1.",
		 sigscale = 0.1, pclip = -0.5, grow = 0, blank = 0., >& "dev$null")

	print ("KTemp.0001.fits", >> arq4)
	print ("KTemp.0002.fits", >> arq4)
	print ("CEU", >> arq4)
	
	arqst = nome//"SIGT_"//interv//"_"//numer//".fits"
	
	if (access (arqst)) {
		print ("File "//nome2//"SIGT_"//interv//"_"//numer//" exists. Overwriting...")
		print (" ")
		imdelete (arqst, ver-, >& "dev$null")
	}
	;
	
	conta = "1/sqrt("//numer//")*(sqrt((im1/2+im2/2+2*im3+2*"//ruido//")*"//npontosx//"*"//npontosy//".)/((im1+im2)/2*"//npontosx//"*"//npontosy//".))"

	print (conta, >> "input2.txt")
	
	imcalc (input="@input.txt", output=arqst, equals="@input2.txt",
		pixtype="old", nullval = 0., verbose = no, mode="al")
	
	hedit (images = arqst, fields = "CALCPOL", value = "Theoretical Error in P for Object "//header1, add = yes,
		 delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
		
	print ("Theoretical Error in P for Object "//header1, "  ->  ", nome2//"SIGT_"//interv//"_"//numer//".fits")
	print (" ")		
		
	imdelete (images = "CEU", verify = no, >& "dev$null")
	imdelete (images = "temp_*.fits,KTemp.*.fits", verify = no, >& "dev$null")
	imdelete (images = "@"//listaceuo, verify = no, >& "dev$null")
	imdelete (images = "@"//listaceue, verify = no, >& "dev$null")
	delete (listaceue, ver-, >& "dev$null")
	delete (listaceuo, ver-, >& "dev$null")
	delete (arq4, ver-, >& "dev$null")
	delete ("input2.txt", ver-, >& "dev$null")


# CALCULO DO FLUXO POLARIZADO

	arqf = nome//meio//"FP_"//interv//"_"//numer//".fits"
	arqf2 = nome2//meio//"FP_"//interv//"_"//numer//".fits"
	
	if (access (arqf)) {
		print ("File "//arqf2//" exists. Overwriting...")
		print (" ")
		imdelete (arqf, ver-, >& "dev$null")
	}
	;
	
	sarith (input1 = arqp, op = "*", input2 = arqt, output = arqf, w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)


	hedit (images = arqf, fields = "CALCPOL", value = "Polarized Flux for Object "//header1, add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
		
	print ("Polarized Flux for Object "//header1, "  ->  ", arqf2)
	print (" ")	

# CALCULO DO ERRO EM THETA

	
	print (arqs, >> arq4)
	print (arqp, >> arq4)
	
	arqsan = nome//"SIGAN_"//interv//"_"//numer//".fits"

	if (access (arqsan)) {
		print ("File "//nome2//"SIGAN_"//interv//"_"//numer//" exists. Overwriting...")
		print (" ")
		imdelete (arqsan, ver-, >& "dev$null")
	}
	;
		
	imcalc (input="@input.txt", output=arqsan, equals="28.65*im1/im2",
		pixtype="old", nullval = 0., verbose = no, mode="al")
	
	hedit (images = arqsan, fields = "CALCPOL", value = "Error of Polarization Angle for Object "//header1, add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
		
	print ("Error of Polarization Angle for Object "//header1, "  ->  ", nome2//"SIGAN_"//interv//"_"//numer//".fits")
	print (" ")
	delete (arq4, ver-, >& "dev$null")


# APAGA OS ARQUIVOS TEMPORARIOS CRIADOS AO LONGO DO SCRIPT

	print ("Deleting temporary files...")
	
	imdelete (images = "@temp1.txt,@temp2.txt", verify = no, >& "dev$null")
	
	delete (listaord, ver-)
	delete (listaext, ver-)
	
	if (erase == "yes")   
		imdelete (images = "Z*.fits", verify = no, >& "dev$null")
	else {
# Arrumar isso... Z nao pode ser sobreposto
##	    	files ("Z*.imh", >> "temp_1.txt")
#		files ("Z*.fits", >> "temp_1.txt")
#	    	imrename(oldnames="@temp_1.txt",newnames = dir//"@temp_1.txt", verbose=no)
#	    	delete ("temp_1.txt", ver-)

		for (i=1; i <= numer; i+=1)  {
		
			s1 = "Z"//i//"_"//interv//"_"//numer//".fits"
			s2 = dir//s1
			imdelete(images=s2,verify=no, >& "dev$null")
			imrename(oldnames=s1,newnames=s2,verbose=no)
		}
		;
	}	
	
	back (>& "dev$null")
	
	mosaic.corflat=corflat
	mosaic.coreq=coreq
	mosaic.retar=retar
	mosaic.instr=instr
	mosaic.inter=inter
	mosaic.interval=interv
	mosaic.type=tip
	mosaic.number=numer
	
	mosaic (mode='h')
	

	flist1 = ""
	flist2 = ""
	flist3 = ""
	flist4 = ""
	flist5 = ""

fim: print ("")	

end


