procedure inter (type, number, interval, pmax, lmax, theta)

string type="objeto" {enum="objeto|padpol|npol|flat", prompt="Image Type"}
int interval=1        {min=1, prompt='Binning Interval (Points)'}
int    number=16	{min=4, max=16, prompt="Number of Waveplate Positions"}
string law="wilking82" {enum="wilking82|wilking80|serkowsky", prompt="Interstellar Polarization Law"}
real pmax=4. 		{prompt="Pmax (Percent)"}
real lmax=5000. {prompt="Lambda Max (Angstroms)"}
real theta=0. {prompt="Theta (degrees)"}
struct *flist1  
struct *flist2  
struct flist3 {length=160}
struct *flist4 
struct flist5 {length=160}


begin

	
	int interv, numer
	real k, pmaxi,thetai,lmaxi
	
	string s1, s2, s3, s4, s5
	string arq1, arq2, arq3
	string dir
	string lixo1
	string par
	struct linha
	
	
	# angulo
	real r1, r2, r3, r4, r5
	real u1, u2, u3, u4, u5
	real pi
	bool ver
	
	real lambdamin, lambdamax
	int npix
	
	# nomes
	string nome,tip
	string arqq, arqu, arqp, arqs, arqst, arqt, arqf, arqan, arqsan
	string arqpad
	string arqqc,arquc,arqtc,arqpc
	
	# correcao equatorial
	int cont
	real soma1, soma2
	real qeff, ueff, leff
	real pol, ang
			
	string line1,line2



	interv = interval
	numer = number
	tip = type
	lmaxi=lmax
	pmaxi=pmax/100.
	thetai=theta
	
	pi = 3.14159265359
	

	
	limpa

    	dir = "dir.txt"
    	flist1 = dir
    	pathnames (template = "", sort = yes, >> dir)
    	lixo1 = fscan (flist1, dir)
	delete ("dir.txt", ver-)

	
    	chdir ("tmp$")

 # SETA VARIAVEL nome PARA O NOME DO ARQUIVO
	
	if (tip == "objeto") {
		nome = "OBJ_"
	}
	;
	if (tip == "npol") {
		nome = "NPOL_"
	}
	;	
	if (tip == "padpol") {
		nome = "PAD_"
	}
	;	
	if (tip == "flat") {
		nome = "FLAT_"
	}
	;
	
	arqq = nome//"Q_"//interv//"_"//numer//".fits"
	arqu = nome//"U_"//interv//"_"//numer//".fits"
	arqp = nome//"P_"//interv//"_"//numer//".fits"
	arqt = nome//"ANG_"//interv//"_"//numer//".fits"

	arqqc = "c"//nome//"Q_"//interv//"_"//numer//".fits"
	arquc = "c"//nome//"U_"//interv//"_"//numer//".fits"
	arqpc = "c"//nome//"P_"//interv//"_"//numer//".fits"
	arqtc = "c"//nome//"ANG_"//interv//"_"//numer//".fits"


	unlearn wtextimage
	
	wtextimage (input = dir//arqq, >> "ARQUIVO.txt")

# CONSTROI O ESPECTRO COM O O FORMATO DA FUNCAO
	 
 	flist1 = "ARQUIVO.txt"
 	flist2 = "ARQUIVO.txt"
	
	arq1 = "TEMP_1.txt"
	
	listpix (dir//nome//"TOT_"//interv//"_"//numer//".fits", 
	         wcs="world", >> arq1)
	
	flist4 = arq1
	
	arq2 = "TEMP_2.txt"
	
	if (law=="wilking82") {
		k = -0.1 + 1.86*lmaxi/1.E4 #lmaxi is in microns
	}
	if (law=="wilking80") {
		k = -0.002 + 1.68*lmaxi/1.E4 #lmaxi is in microns
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
			
			lixo1 = fscan(flist4, r1)
			lixo1 = fscan(flist4, r2)
			lixo1 = fscan(flist4, r3)
			lixo1 = fscan(flist4, r4)
			lixo1 = fscan(flist4, r5)
			
			r1 = pmaxi * exp(-k*log(lmaxi/r1)**2)
			r2 = pmaxi * exp(-k*log(lmaxi/r2)**2)
			r3 = pmaxi * exp(-k*log(lmaxi/r3)**2)
			r4 = pmaxi * exp(-k*log(lmaxi/r4)**2)
			r5 = pmaxi * exp(-k*log(lmaxi/r5)**2)
			
			flist3 = ""//r1//" "//r2//" "//r3//" "//r4//" "//r5
						
			print (flist3, >> arq2)
			
			}
						
		}
		;
	
	}
	
	unlearn rtextimage
	
	arq1 = "IP_"//interv//".fits"
	
	if (access (dir//arq1)) {
		print ("File "//arq1//" exists. Overwriting...")
		imdelete (dir//arq1, ver-, >& "dev$null")
	}
	;
	
	rtextimage (input = arq2, output = dir//arq1) #, otype = "", header = yes) #, nskip = 0, dim =)
	
#	imdelete (images = "TEMP*.imh", verify = no, >& "dev$null")
	imdelete (images = "TEMP*.fits", verify = no, >& "dev$null")
	delete ("TEMP*.txt, ARQUIVO.txt", ver-)
	
	
	back (>& "dev$null")
	
# Calculate interstellar Q and U
	arq2 = "IQ_"//interv//".fits"
	arq3 = "IU_"//interv//".fits"

	if (access (arq2)) {
		print ("File "//arq2//" exists. Overwriting...")
		imdelete (arq2, ver-, >& "dev$null")
	}
	;

	r1 = cos(2.*thetai*pi/180.)
	sarith (input1 = arq1, op = "*", input2 = r1,
	 	output = arq2, w1 = INDEF, w2 = INDEF, apertures = "",
	 	beams = "", apmodulus = 0, reverse = no, ignoreaps = yes,
	 	format = "multispec", renumber = no, offset = 0, clobber = no,
	 	merge = no, rebin = yes, errval = 0, verbose = no)	

	if (access (arq3)) {
		print ("File "//arq3//" exists. Overwriting...")
		imdelete (arq3, ver-, >& "dev$null")
	}
	;
		
#ATENCAO PARA O MENOS AQUI! ISSO FAZ O SISTEMA GIRAR EM 180 graus
# theta = 180-theta		
	r2 = -sin(2.*thetai*pi/180.)
	sarith (input1 = arq1, op = "*", input2 = r2,
	 	output = arq3, w1 = INDEF, w2 = INDEF, apertures = "",
	 	beams = "", apmodulus = 0, reverse = no, ignoreaps = yes,
	 	format = "multispec", renumber = no, offset = 0, clobber = no,
	 	merge = no, rebin = yes, errval = 0, verbose = no)	

#Correct for Interstellar Polarization

	if (access (arqqc)) {
		print ("File "//arqqc//" exists. Overwriting...")
		imdelete (arqqc, ver-, >& "dev$null")
	}
	;

	sarith (input1 = arqq, op = "-", input2 = arq2, output = arqqc, w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	hedit (images = arqqc, fields = "INTER", 
	       value = "Corrected for Inter. Polar.: Pmaxi="//pmaxi//"; Lmaxi="//lmaxi//"; Thetai="//thetai, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")

		
	if (access (arquc)) {
		print ("File "//arquc//" exists. Overwriting...")
		imdelete (arquc, ver-, >& "dev$null")
	}
	;

	sarith (input1 = arqu, op = "-", input2 = arq3, output = arquc, w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	hedit (images = arquc, fields = "INTER", 
	       value = "Corrected for Inter. Polar.: Pmaxi="//pmaxi//"; Lmaxi="//lmaxi//"; Thetai="//thetai, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")

	if (access (arqpc)) {
		print ("File "//arqpc//" exists. Overwriting...")
		imdelete (arqpc, ver-, >& "dev$null")
	}
	;
		
	imcalc (input=arqqc//","//arquc, output=arqpc, equals="sqrt(im1**2+im2**2)",
		pixtype="old", nullval = 0., verbose = no, mode="al")
			
	hedit (images = arqpc, fields = "INTER", 
	       value = "Corrected for Inter. Polar.: Pmaxi="//pmaxi//"; Lmaxi="//lmaxi//"; Thetai="//thetai, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
		  
#THETA
	if (access (arqtc)) {
		print ("File "//arqtc//" exists. Overwriting...")
		imdelete (arqtc, ver-, >& "dev$null")
	}
	;
		  
	sarith (input1 = arquc, op = "/", input2 = arqqc, output = "tmp$TEMP_1", w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	unlearn wtextimage

	wtextimage (input = "tmp$TEMP_1.fits", output = "tmp$TEMP_1.txt") #, header = yes, format = "",
		
	wtextimage (input = arquc, output = "tmp$U.txt")

	arq1 = "tmp$TEMP_1.txt"
	arq2 = "tmp$TEMP_2.txt"
	arq3 = "tmp$U.txt"
	
	flist1 = arq1
	flist2 = arq3
	
	ver = yes
	s1 = "nulo"
		
	while (fscan (flist1, flist3) != EOF) {
		
		lixo1 = fscan (flist2, flist5)
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
			
			lixo1 = fscan (flist5, u1, u2, u3, u4, u5)
			
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
			
			#print (r1/2, " ", r2/2, " ", r3/2, " ", r4/2, " ", r5/2, >> arq2)
			print (180-r1/2, " ", 180-r2/2, " ", 180-r3/2, " ", 180-r4/2, " ", 180-r5/2, >> arq2)
			
			}
						
		}
		;
	
	}
		
	unlearn rtextimage

	rtextimage (input = "tmp$TEMP_2.txt", output = arqtc) #, otype = "", header = yes) #, nskip = 0, dim =)
	imdelete (images = "tmp$TEMP*.fits", verify = no, >& "dev$null")
	delete ("tmp$TEMP*.txt", ver-, >& "dev$null")
	delete ("tmp$U.txt", ver-)

	hedit (images = arqtc, fields = "INTER", 
	       value = "Corrected for Inter. Polar.: Pmaxi="//pmaxi//"; Lmaxi="//lmaxi//"; Thetai="//thetai, 
		  add = yes,
		  delete = no, verify = no, 
		  update = yes,
		  >& "dev$null")
		  
		
	flist1 = ""
	flist2 = ""
	flist3 = ""
	flist4 = ""
	flist5 = ""
	
end


