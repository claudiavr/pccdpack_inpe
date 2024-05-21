procedure bina (type,number)

string type="objeto" {enum="objeto|padpol|npol|flat", prompt="Object Type"}
#int interval=1        {min=1, prompt='Binning Interval'}
int    number=16	{min=4, max=16, prompt="Number of Waveplate Positions"}
string corflat="no" {enum="yes|no",prompt="Correct for the Lambda Dependence of Theta?"}
string coreq="no" {enum="yes|no",prompt="Apply Equatorial Correction?"}
string retar="no" {enum="yes|no",prompt="Apply Retardance Correction?"}
string instr="no" {enum="yes|no",prompt="Correct for Instrumental Polarization?"}
string inter="no" {enum="yes|no",prompt="Correct for Interstellar Polarization?"}

#string bmode="points"	{enum="points|error", prompt='Binning Mode'}
string weight="uniform"	{enum="uniform|variance", prompt="Weight used for averaging"}
real perror=0.5		{min=0,max=100,prompt='Bin Error (%)'}
real sigmax=50.	{min=0,max=100,prompt='Maximum valid error value (%)'}
int npmin=1	{min=1,prompt='Minimum number of points in a bin'}
struct *flist1  
struct *flist2  
struct *flist3 
struct flist4 {length=160}
struct flist5 {length=160}
struct *flist6 


begin


string tip,meio
int numer, interv
	
string s1, s2, s3, s4, s5, s6
string arq1, arq2, arq4, arq3, arq5
string lixo1
struct linha1 
struct linha2 
string dir

string header1

real r1, r2, r3, r4, r5
real u1, u2, u3, u4, u5
int i1
real pi
bool ver, ver1
	
# binagem
real qfinal[10000],ufinal[10000],sfinal[10000],tfinal[10000]
real lambdamin, lambdamax
real intreal
int npix1, npix2
real delta1, delta2
int npontos, resto
real somaq, somau, somat, somaerro, mediaq,mediau, mediat, mediaerro
real wgt, somawgt, isomawgt
real q, u, s, t, dum
int cont1, cont2, cont3
real limite	
string npontosx, npontosy
real ruido
	
# nomes
string nome1, nome2
string arqq, arqu, arqp, arqs, arqst, arqt, arqf, arqan, arqsan
string arqq2, arqu2, arqp2, arqs2, arqst2, arqt2, arqf2, arqan2, arqsan2

string line1,line2
	
	
	tip = type
	interv = 1
	numer = number
		
	
	ver1 = access("tmp$")
	
	if (ver1 == no)
		mkdir ("tmp$")
		
	limpa

	print ('')
	print ('Binning data to get bins with sigma= '//perror//' %')

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

# SETA VARIAVEL nome PARA O NOME DO ARQUIVO

	if (tip == "objeto") {
		nome1 = "OBJ_"
		nome2= "OBJ_"
	}
	;
	if (tip == "npol") {
		nome1 = "NPOL_"
		nome2= "NPOL_"
	}
	;	
	if (tip == "padpol") {
		nome1 = "PAD_"
		nome2= "PAD_"
	}
	;	
	if (tip == "flat") {
		nome1 = "FLAT_"
		nome2= "FLAT_"
	}
	;

	arqt = nome1//"TOT_"//interv//"_"//numer//".fits"
	arqq = nome1//meio//"Q_"//interv//"_"//numer//".fits"
	arqu = nome1//meio//"U_"//interv//"_"//numer//".fits"
	arqs = nome1//"SIG_"//interv//"_"//numer//".fits"
	
    	if (access (arqq)==no) {
		print ("")
		print ("ERROR: File ")
		print (arqp)
		print ("do not exist.")
		goto fim
	}
	
# "BINAGEM" DAS IMAGENS
# Copia arquivos Q, U e SIGMA convertidos para txt para o diretorio tmp

wtextimage (input=arqq, output="tmp$Q1_TEMP.txt", header=yes, format="",
	maxline=80)

wtextimage (input=arqu, output="tmp$U1_TEMP.txt", header=yes, format="",
	maxline=80)

wtextimage (input=arqs, output="tmp$S1_TEMP.txt", header=yes, format="",
	maxline=80)

wtextimage (input=arqt, output="tmp$T1_TEMP.txt", header=yes, format="",
	maxline=80)
	
listpixels (images=arqq, wcs="world",formats="", 
	verbose=no, >> "tmp$Q1_DATA.txt")

listpixels (images=arqu, wcs="world",formats="", 
	verbose=no, >> "tmp$U1_DATA.txt")

listpixels (images=arqs, wcs="world",formats="", 
	verbose=no, >> "tmp$S1_DATA.txt")
	
listpixels (images=arqt, wcs="world",formats="", 
	verbose=no, >> "tmp$T1_DATA.txt")

# Determina numero de pontos no espectro
	unlearn tstat
	tstat (intable = "tmp$Q1_DATA.txt", column=1,, >& "dev$null")
	npix1 = tstat.nrows
	
# SEPARA HEADER

flist1 = "tmp$Q1_TEMP.txt"

arq1 = "tmp$Q1_BIN.txt"
while (fscan (flist1, flist4) != EOF) {
	
	lixo1 = fscan (flist4, line1)
	
	if (line1 != "END")
	      	print (flist4, >> arq1)
	else {
		print (flist4, >> arq1)
		break
	}
}

delete ("tmp$Q1_TEMP.txt", ver-, >& "dev$null")

flist1 = "tmp$U1_TEMP.txt"

arq1 = "tmp$U1_BIN.txt"
	
while (fscan (flist1, flist4) != EOF) {
	
	lixo1 = fscan (flist4, line1)
	
	if (line1 != "END")
	      	print (flist4, >> arq1)
	else {
		print (flist4, >> arq1)
		break
	}
}

delete ("tmp$U1_TEMP.txt", ver-, >& "dev$null")

flist1 = "tmp$S1_TEMP.txt"

arq1 = "tmp$S1_BIN.txt"
	
while (fscan (flist1, flist4) != EOF) {
	
	lixo1 = fscan (flist4, line1)
	
	if (line1 != "END")
	      	print (flist4, >> arq1)
	else {
		print (flist4, >> arq1)
		break
	}		
	;
}

delete ("tmp$S1_TEMP.txt", ver-, >& "dev$null")

flist1 = "tmp$T1_TEMP.txt"

arq1 = "tmp$T1_BIN.txt"
	
while (fscan (flist1, flist4) != EOF) {
	
	lixo1 = fscan (flist4, line1)
	
	if (line1 != "END")
	      	print (flist4, >> arq1)
	else {
		print (flist4, >> arq1)
		break
	}		
	;
}

delete ("tmp$T1_TEMP.txt", ver-, >& "dev$null")

# CALCULO DOS BINS COM ERRO < perro / 100

limite = perror / 100

flist1 = "tmp$Q1_DATA.txt"
flist2 = "tmp$U1_DATA.txt"
flist3 = "tmp$S1_DATA.txt"
flist6 = "tmp$T1_DATA.txt"

arq4 = "tmp$Q1_LOG.txt"

somaq = 0 
somau = 0 
somat = 0 
somaerro = 0
cont1 = 0
cont2 = 0
cont3 = 0

while (fscan (flist1, r1, q) != EOF)  {
		
	lixo1 = fscan (flist2, r1, u)
	lixo1 = fscan (flist3, r1, s)
	lixo1 = fscan (flist6, r1, t)
	
	if (s > sigmax/100. || s == 0.) {
		s = limite
	} 
	
	
	cont1 = cont1 + 1
	cont2 = cont2 + 1

	if (weight == "uniform") {
# Media simples
		somaq = somaq + q
		somau = somau + u
		somat = somat + t
		somaerro = somaerro + s**2
		dum = sqrt(somaerro)/cont1
	} else {
# Media ponderada
		wgt = 1./s**2.
		somaerro = somaerro + wgt
		somaq = somaq + wgt*q
		somau = somau + wgt*u
		somat = somat + wgt*t
		dum = 1./sqrt(somaerro)
	}

	if (cont2 == npix1) {
		if (weight == "uniform") {
# Media simples
			mediaq = somaq / cont1
			mediau = somau / cont1
			mediat = somat / cont1
			mediaerro = sqrt(somaerro) / cont1
		} else {
# Media ponderada
			mediaq = somaq / somaerro
			mediau = somau / somaerro
			mediat = somat / somaerro
			mediaerro = 1./sqrt(somaerro)
		}
	
		print (mediaq, " ", mediau, " ", mediat, " ", mediaerro, " ", cont1, >> arq4)
		cont3 = cont3 + 1
		break	
	}
	
	
	if (dum <= limite && cont1 >= npmin) {
		if (weight == "uniform") {
# Media simples
			mediaq = somaq / cont1
			mediau = somau / cont1
			mediat = somat / cont1
			mediaerro = sqrt(somaerro) / cont1
		} else {
# Media ponderada
			mediaq = somaq / somaerro
			mediau = somau / somaerro
			mediat = somat / somaerro
			mediaerro = 1./sqrt(somaerro)
		}

		print (mediaq, " ", mediau, " ", mediat, " ", mediaerro, " ", cont1, >> arq4)
		somaq = 0
		somau = 0
		somat = 0
		somaerro = 0
		cont1 = 0
		cont3 = cont3 + 1	
	}
	;
}

delete ("tmp$Q1_DATA.txt", ver-, >& "dev$null")
delete ("tmp$U1_DATA.txt", ver-, >& "dev$null")
delete ("tmp$S1_DATA.txt", ver-, >& "dev$null")
delete ("tmp$T1_DATA.txt", ver-, >& "dev$null")

arq1 = "tmp$Q1_BIN.txt"
arq2 = "tmp$U1_BIN.txt"
arq3 = "tmp$S1_BIN.txt"
arq5 = "tmp$T1_BIN.txt"

print ('Number of bins: '//cont3)

# CONSTROI Q, U e SIGMA

flist1 = arq4

j = 0

while (fscan (flist1, q, u, t, s, cont1) != EOF) {

	for (i = 1; i <= cont1; i += 1) {
		j = j+1
		qfinal[j] = q
		ufinal[j] = u
		sfinal[j] = s
		tfinal[j] = t
	}	
}

for (i = 1; i <=npix1/5+1; i += 1) {
	print(qfinal[(i-1)*5+1],qfinal[(i-1)*5+2],qfinal[(i-1)*5+3],qfinal[(i-1)*5+4],qfinal[(i-1)*5+5], >> arq1)
	print(ufinal[(i-1)*5+1],ufinal[(i-1)*5+2],ufinal[(i-1)*5+3],ufinal[(i-1)*5+4],ufinal[(i-1)*5+5], >> arq2)
	print(sfinal[(i-1)*5+1],sfinal[(i-1)*5+2],sfinal[(i-1)*5+3],sfinal[(i-1)*5+4],sfinal[(i-1)*5+5], >> arq3)
	print(tfinal[(i-1)*5+1],tfinal[(i-1)*5+2],tfinal[(i-1)*5+3],tfinal[(i-1)*5+4],tfinal[(i-1)*5+5], >> arq5)
}

delete (arq4, ver-, >& "dev$null")

arqq = "BIN_Q.fits"
arqu = "BIN_U.fits"
arqs = "BIN_S.fits"
arqt = "BIN_TOT.fits"
imdelete (arqq, ver-, >& "dev$null")
imdelete (arqu, ver-, >& "dev$null")
imdelete (arqs, ver-, >& "dev$null")
imdelete (arqt, ver-, >& "dev$null")

unlearn rtextimage
rtextimage (input = arq1, output = arqq)
rtextimage (input = arq2, output = arqu)
rtextimage (input = arq3, output = arqs)
rtextimage (input = arq5, output = arqt)

delete (arq1, ver-, >& "dev$null")
delete (arq2, ver-, >& "dev$null")
delete (arq3, ver-, >& "dev$null")
delete (arq5, ver-, >& "dev$null")


# CALCULA P, ANG, ETC

arqp = "BIN_P.fits"
arqf = "BIN_FP.fits"
arqan = "BIN_ANG.fits"
arqsan = "BIN_SIGAN.fits"

imdelete (arqp, ver-, >& "dev$null")
	
imcalc (input=arqq//","//arqu, output=arqp, equals="sqrt(im1**2+im2**2)",
	    pixtype="old", nullval = 0., verbose = no, mode="al")

#ANGULO	    
	sarith (input1 = arqu, op = "/", input2 = arqq, output = "tmp$TEMP_1", w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	unlearn wtextimage

	wtextimage (input = "tmp$TEMP_1.fits", output = "tmp$TEMP_1.txt") #, header = yes, format = "",
		
		
	wtextimage (input = arqu, output = "tmp$U.txt")

	pi = 3.14159265359
	
	arq1 = "tmp$TEMP_1.txt"
	arq2 = "tmp$TEMP_2.txt"
	arq3 = "tmp$U.txt"
	
	flist1 = arq1
	flist2 = arq3
	
	ver = yes
	s1 = "nulo"
		
	while (fscan (flist1, flist5) != EOF) {
		
		lixo1 = fscan (flist2, flist4)
		lixo1 = fscan (flist5, line1)
		
		if (line1 != "END" && ver == yes) {
		print (flist5, >> arq2)
		}
		else {
			if (ver == yes) {
			print (flist5, >> arq2)
			ver = no
			
			}
		}		
		;
		
		if (ver == no && line1 != "END") {
			lixo1 = fscan (flist5, s1)
			
			if (s1 == "nulo") 
			print ("            ", >> arq2)
			else {
			
			lixo1 = fscan (flist4, u1, u2, u3, u4, u5)
			
			lixo1 = fscan (flist5, r1, r2, r3, r4, r5)
			
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
#	copy(arq2,"teste")
	unlearn rtextimage

	rtextimage (input = "tmp$TEMP_2.txt", output = arqan) #, otype = "", header = yes) #, nskip = 0, dim =)
	imdelete (images = "tmp$TEMP*.fits", verify = no, >& "dev$null")
	delete ("tmp$TEMP*.txt", ver-, >& "dev$null")
	delete ("tmp$U.txt", ver-)
	
# ERROR IN THETA
	imdelete (arqsan, ver-, >& "dev$null")
		
	imcalc (input=arqs//","//arqp, output=arqsan, equals="28.65*im1/im2",
		pixtype="old", nullval = 0., verbose = no, mode="al")


# FLUXO POLARIZADO
	imdelete (arqf, ver-, >& "dev$null")
		
	imcalc (input=arqp//","//arqt, output=arqf, equals="im1*im2",
		pixtype="old", nullval = 0., verbose = no, mode="al")
			

fim:    print ("")

flist1 = ""
flist2 = ""
flist3 = ""
flist4 = ""
flist5 = ""
flist6 = ""

end


