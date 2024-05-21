procedure cinter  (number, interval, lmin, lmax)

int interval=1        {min=1, prompt='Binning Interval'}
int    number=16	{min=4, max=16, prompt="Number of Waveplate Positions"}
real lmin = INDEF {prompt="Lower Wavelength"}
real lmax = INDEF {prompt="Upper Wavelength"}
string regist = "yes" {enum="yes|no", prompt = "Cria arquivo GRAFICO.log?"}
struct *flist1  
#struct *flist2  
struct flist3 {length=160}
#struct *flist4 {length=160}


begin

	
	int numer, interv
	
	string arq1, arq2, arq3, arq4
	string lixo1,conta
	
	string arqu,arqq,arqs
	string arqub,arqqb,arqsb

	real lambdamin, lambdamax
	int npix
	int inut
	int sinal
	string s1, s2, s3, s4, s5
	
	real r1
	int u1
	real pi
	bool ver, ver1
	
	real qeff, ueff, seff, angeff, peff
	real rqeff, rueff, rseff, rangeff, rpeff
	string seffect, qeffect, ueffect, peffect
			
	string imagem
	
	limpa
	
	numer = number
	interv = interval
	lambdamin = lmin
	lambdamax = lmax
	
    	
    	if (access ("Z1_"//interv//"_"//numer//".fits")) {
    		}
    		else {
    		print ("Files Z*.fits do no exist.")
    		print ("Run calcpol with parameter erase='no'")
    		goto fim
    	}
    	    	
	
# USA OS Z'S PARA CALCULAR Q E U INSTRUMENTAL

# CALCULO DE Q

	conta = "("
	arq4 = "tmp$input.txt"
		
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
	
	arqq = "tmp$Qtemp.fits"

	imcalc (input="@tmp$input.txt", output=arqq, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")
					  
	delete (arq4, ver-, >& "dev$null")
	
# CALCULO DE U

	conta = conta // " *(-1.)"

	for (i=1; i <= (numer/4); i+=1) {

	s1 = "Z"//(i+1+3*(i-1))//"_"//interv//"_"//numer//".fits"
	s2 = "Z"//((i+1+3*(i-1))+2)//"_"//interv//"_"//numer//".fits"

	print (s1, >> arq4)
	print (s2, >> arq4)
	
	}
	;  	

	arqu = "tmp$Utemp.fits"
	
	imcalc (input="@tmp$input.txt", output=arqu, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")
		
	delete (arq4, ver-, >& "dev$null")

# CALCULO DO ERRO EXPERIMENTAL
	
	for (i=1; i <= numer; i+=1)  {
	
	s1 = "Z"//i//"_"//interv//"_"//numer//".fits"
	s2 = "tmp$Zquad"//i
	
	imcalc (input=s1, output=s2, equals="im1**2",
		pixtype="old", nullval = 0., verbose = no, mode="al")
	
	}
	
	scombine (input="tmp$Zquad*.fits", output="tmp$ZZQUAD8", noutput="", logfile="STDOUT",
		 apertures="", group="all", combine="sum", reject="none",
		 first = no, w1 = INDEF, w2 = INDEF, dw = INDEF, nw = INDEF,
		 scale = "none", zero = "none", weight = "none", sample = "",
		 lthreshold = INDEF, hthreshold = INDEF, nlow = 1, nhigh = 1,
		 mclip = yes, lsigma = 3., hsigma = 3., rdnoise = "0.", gain = "1.",
		 sigscale = 0.1, pclip = -0.5, grow = 0, blank = 0., >& "dev$null")

	
	arqs = "tmp$SIGtemp.fits"
	
	print ("tmp$ZZQUAD8.fits", >> arq4)
	print (arqq, >> arq4)
	print (arqu, >> arq4)
	
	conta = "sqrt(1./"//numer-2//"*((im1/"//s4//".)-(im2**2+im3**2)))"
	
	imcalc (input="@tmp$input.txt", output=arqs, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")
	
	imdelete (images = "tmp$Zquad*.fits,tmp$ZZQUAD8.fits", verify = no, >& "dev$null")
	delete (arq4, ver-, >& "dev$null")
	
# PROCEDIMENTO MEDIA NO INTERVALO
# Arquivos cortados
	arqqb = "tmp$Qtempbin.fits"	
	arqub = "tmp$Utempbin.fits"	
	arqsb = "tmp$SIGtempbin.fits"	


	print(" ")
	print("Calculating Effective Values in the interval "//lambdamin//" a "//lambdamax//" angstroms")
	
	# OBTENCAO DE Qeff, Ueff, SIGMA
	
	sarith (input1 = arqq, op = "copy", input2 = "", output = arqqb, w1 = lambdamin,
		w2 = lambdamax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
	
	sarith (input1 = arqu, op = "copy", input2 = "", output = arqub, w1 = lambdamin,
		w2 = lambdamax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
	
	sarith (input1 = arqs, op = "copy", input2 = "", output = arqsb, w1 = lambdamin,
		w2 = lambdamax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
		
	# DETERMINACAO DE npix

	imstatistics (images = arqqb, fields = "npix", lower = INDEF, 
	upper = INDEF, binwidth = 0, format = no, >> "tmp$TEMP_1.txt")
	
	flist1 = "tmp$TEMP_1.txt"
	lixo1 = fscan (flist1, npix)
	
	delete ("tmp$TEMP_1.txt", ver-)
	
	imstatistics (images = arqqb, fields = "mean", lower = INDEF, 
	upper = INDEF, binwidth = 0, format = no, >> "tmp$Q.txt")
	
	imstatistics (images = arqub, fields = "mean", lower = INDEF, 
	upper = INDEF, binwidth = 0, format = no, >> "tmp$U.txt")

	imstatistics (images = arqsb, fields = "mean", lower = INDEF, 
	upper = INDEF, binwidth = 0, format = no, >> "tmp$S.txt")
	
	flist1 = "tmp$Q.txt"
	lixo1 = fscan (flist1, qeff)
	
	flist1 = "tmp$U.txt"
	lixo1 = fscan (flist1, ueff)
	
	flist1 = "tmp$S.txt"
	lixo1 = fscan (flist1, seff)

	delete ("tmp$Q.txt,tmp$U.txt,tmp$S.txt", ver-, >& "dev$null")
	
#	seff = seff / sqrt(npix)
	
	for (i=1; i <= numer; i += 1) {
	
	arq1 = "Z"//i//"_"//interv//"_"//numer//".fits"
	arq3 = "tmp$bZ"//i//"_"//interv//"_"//numer//".fits"
	
	sarith (input1 = arq1, op = "copy", input2 = "", output = arq3, w1 = lambdamin,
		w2 = lambdamax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
		
	imstatistics (images = arq3, fields = "mean", lower = INDEF, 
	upper = INDEF, binwidth = 0, format = no, >> "tmp$TEMP.txt")
	
	flist1 = "tmp$TEMP.txt"
	lixo1 = fscan (flist1, r1)
	
	print((i-1)*22.5, r1, seff, >> "tmp$Z.txt")
	
	delete ("tmp$TEMP.txt", ver-)
		
	}
		
	imdelete ("tmp$bZ*.fits", verify = no, >& "dev$null")
	imdelete (arqu, verify = no, >& "dev$null")
	imdelete (arqs, verify = no, >& "dev$null")


	rqeff = qeff
	sinal = qeff / abs(qeff)  
	qeff = abs (qeff)
	if (qeff >= .001) {
	  inut = 100000 * qeff + .5
	   qeff = inut
	   qeff = qeff / 100000
	   qeff = qeff * sinal
	   qeffect = ""//qeff }
	else {
	   u1 = log10(qeff)
	   u1 = -u1 + 1
	   inut = 1000000000 * qeff + .5
	   qeff = inut
	   qeff = qeff / 100000
	   if (u1 > 4)
	   qeff = qeff * 10 * (u1-4)
	   qeff = qeff * sinal
	   qeffect = ""//qeff//"E-"//u1
	}
	; 
	  	
	print (" ")
	print ("Effective Q: "//qeffect)
	
	rueff = ueff
	sinal = ueff / abs(ueff)  
	ueff = abs (ueff)
	if (ueff >= .001) {
	  inut = 100000 * ueff + .5
	   ueff = inut
	   ueff = ueff / 100000
	   ueff = ueff * sinal
	   ueffect = ""//ueff }
	else {
	   u1 = log10(ueff)
	   u1 = -u1 + 1
	   inut = 1000000000 * ueff + .5
	   ueff = inut
	   ueff = ueff / 100000
	   if (u1 > 4)
	   ueff = ueff * 10 * (u1-4)
	   ueff = ueff * sinal
	   ueffect = ""//ueff//"E-"//u1
	}
	;

	print (" ")
	print ("Effective U: "//ueffect)
	
	
	rseff = seff
	if (seff >= .001) {
	  inut = 100000 * seff + .5
	   seff = inut
	   seff = seff / 100000
	   seffect = ""//seff }
	else {
	
	   u1 = log10(seff)
	   u1 = -u1 + 1
	   inut = 1000000000 * seff + .5
	   seff = inut
	   seff = seff / 100000
	   if (u1 > 4)
	   seff = seff * 10 * (u1-4)
	   seffect = ""//seff//"E-"//u1
	   
	}
	;
		
	print (" ")
	print ("Effective Sigma: "//seffect)
	
	
# CALCULO DE Peff, etc

	peff = sqrt(rqeff**2 + rueff**2)
	rpeff = peff
	if (peff >= .001) {
	  inut = 100000 * peff + .5
	   peff = inut
	   peff = peff / 100000
	   peffect = ""//peff }
	else {
	   u1 = log10(peff)
	   u1 = -u1 + 1
	   inut = 1000000000 * peff + .5
	   peff = inut
	   peff = peff / 100000
	   if (u1 > 4)
	   peff = peff * 10 * (u1-4)
	   peffect = ""//peff//"E-"//u1
	}
	;
	
	print (" ")
	print ("Effective Polarization: "//peffect)
	
	
	pi = 3.14159265359
	
	if (rueff > 0 && rqeff > 0) 
	angeff = atan2(rueff/rqeff,1) * 180 / pi
			
	if (rueff > 0 && rqeff < 0) 
	angeff = atan2(rueff/rqeff,1) * 180 / pi + 180
			
			
	if (rueff < 0 && rqeff > 0) 
	angeff = atan2(rueff/rqeff,1) * 180 / pi + 360
			
						
	if (rueff < 0 && rqeff < 0) 
	angeff = atan2(rueff/rqeff,1) * 180 / pi + 180
	
	angeff = angeff / 2
#	angeff = 180 - angeff
	
	rangeff = angeff
	inut = 100 * angeff + .5
	angeff = inut
	angeff = angeff / 100

	print (" ")
	print ("Effective PA: "//angeff)

	imgets (image = arqq, param = "i_title")
	imdelete (arqq, verify = no, >& "dev$null")
	
	flist3 = imgets.value
	
	lixo1 = fscan (flist3, imagem)
		
	if (regist == "yes") {
		delete ("tmp$GRAFICO.log", ver-, >& "dev$null")
		print (imagem, >> "tmp$GRAFICO.log")
		print ("# Q     U      SIGMA    P       ANG.", >> "tmp$GRAFICO.log")
		print (rqeff, rueff, rseff, rpeff, rangeff, >> "tmp$GRAFICO.log")
		print (" ", >> "tmp$GRAFICO.log")
		flist1 = "tmp$Z.txt"
		while (fscan (flist1, flist3) != EOF) {
			print (flist3, >> "tmp$GRAFICO.log")
		}
	}
	;
		
	delete ("tmp$Z.txt", ver-, >& "dev$null")
	

fim:    print ("")
	
	flist1 = ""
	flist3 = ""
	
end

