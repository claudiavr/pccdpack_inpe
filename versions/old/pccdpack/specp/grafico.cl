procedure grafico  (number, interval, proc,lmin, lmax)

int interval=1        {min=1, prompt='Binning Interval'}
int    number=16	{min=4, max=16, prompt="Number of Waveplate Positions"}
string proc = "interval" {enum="interval|filter", prompt="Procedure: 'interval' or 'filter'?"}
real lmin = INDEF {prompt="Lower Wavelength"}
real lmax = INDEF {prompt="Upper Wavelength"}
string filter = "/users/alex/iraf/V.fil" {prompt="File with filter bandpass"}
string output="none" {enum="ps|meta|none", prompt="Format of the Output File"}
string title="img"     {prompt = "Plot Title"}
real ylim = INDEF {prompt = "Y limit"}
struct *flist1  
#struct *flist2  
struct flist3 {length=160}
#struct *flist4 {length=160}


begin

	
	int numer, interv
	
	string arq1
	string dir, dirtmp
	string lixo1,proce
	
	string arquivo,arqt,nome1
	real lambdamin, lambdamax
	int inut
	int sinal
	
	real r1
	int u1
	real pi
	bool ver, ver1
	
	real qeff, ueff, seff, angeff, peff
	real rqeff, rueff, rseff, rangeff, rpeff
	string seffect, qeffect, ueffect, peffect
	string fol
			
	string imagem

	real ormin, ormax
	
	
	numer = number
	interv = interval
	proce = proc

	if (proce == "interval") {
		lambdamin = lmin
		lambdamax = lmax
	}
    		
    	if (access ("Z1_"//interv//"_"//numer//".fits")) {
    		}
    		else {
    		print ("Files Z*.fits do no exist.")
    		print ("Run calcpol with parameter erase='no'")
    		goto fim
    	}
		
	if (proce == "filter") {
#		cfiltro (input=entr, type=tip, number=numer, interval=interv,
#			filter=filter, regist="sim")
	} else
	     cinter (number=numer, interval=interv, lmin=lambdamin,
	     		lmax=lambdamax, regist="yes")
				
	flist1 = "tmp$GRAFICO.log"
	
	lixo1 = fscan (flist1, flist3)
	
	imagem = flist3

	lixo1 = fscan (flist1, flist3)
	lixo1 = fscan (flist1, flist3)
	
	lixo1 = fscan (flist3, qeff, ueff, seff, peff, angeff)
	
	lixo1 = fscan (flist1, flist3)
	
	while (fscan (flist1, flist3) != EOF) {
		print (flist3, >> "tmp$Z.txt"
	}

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

	rueff = -ueff
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
	
	rangeff = angeff
	inut = 100 * angeff + .5
	angeff = inut
	angeff = angeff / 100
	
	pi = 3.14159265
	
	for (i=0; i <= 360; i += 1) {
	
		r1 = rqeff*cos(4*i*pi/180)+rueff*sin(4*i*pi/180)
	
		print (i, r1, >> "tmp$GRAFICO.txt")
		
	}
	;
	
	ormin = -ylim
	ormax = ylim
	
	if (ylim == INDEF) {
		ormin = -sqrt(abs(rqeff)**2 + abs(rueff)**2) - rseff
		ormax = sqrt(abs(rqeff)**2 + abs(rueff)**2) + rseff
	}
	;	

# TITULO DO GRAFICO


	if (title == "img") {
		arqt = "Z1_"//interv//"_"//numer//".fits"		
		imgets (image = arqt, param = "i_title")
	
	 	flist3 = imgets.value
	 	lixo1 = fscan (flist3, imagem)
	 
	}
	else 
		imagem = title
	
	
# CONTRUCAO DO ARQUIVO DE ENTRADA PARA O IGI
	
	arq1 = "tmp$COMMANDS.IGI"
	delete (arq1, ver-, >& "dev$null")
	
	print ("erase", >> arq1)
	print ("location .10 1 .10 .80", >> arq1)
	print ("data tmp$GRAFICO.txt", >> arq1)
	print ("xcolumn 1; ycolumn 2", >> arq1)
	print ("limits 0 360 "//ormin//" "//ormax, >> arq1)
	print ("margin .04", >> arq1)
	print ("ticksize 11.25 45", >> arq1)
	print ("notation 0 370 1e-3 2", >> arq1)
	print ("box", >> arq1)
	print ("connect", >> arq1)
	print ("ltype 1; lweight 1;grid", >> arq1)
	
	print ("data tmp$Z.txt", >> arq1)
	print ("xcolumn 1; ycolumn 2; ecolumn 3", >> arq1)
	print ("ptype 3 3; expand .8; points", >> arq1)
	print ("ltype 0", >> arq1)
	print ("errorbar -2", >> arq1)
	print ("errorbar 2", >> arq1)
	print ("expand 1.2", >> arq1)
#	print ('xlabel "\\\iPosic\b\d\d \u\d,\d \\\ua\b\u\u \d\u~\\\do da Lamina (graus)"', >> arq1)
#	print ("ylabel '\\\iAmplitude de Modulac\b\d\d \u\d,\d \\\ua\b\u\u \d\u~\\\do'", >> arq1)
	print ('xlabel "\\iWaveplate Position (degrees)"', >> arq1)
	print ("ylabel '\\iModulation Amplitude'", >> arq1)
	
	print ("location .10 1 .80 .93", >> arq1)
	print ("expand 1.7", >> arq1)
	print ("fillpat 2", >> arq1)
	print ("title "//imagem, >> arq1)
	
	print ("vmove .25 .90", >> arq1)
	print ("justify 5; expand 1; label '\\iQ'", >> arq1)
	print ("vmove .40 .90", >> arq1)
	print ("justify 5; expand 1; label '\\iU'", >> arq1)
	print ("vmove .55 .90", >> arq1)
	print ("justify 5; expand 1; label '\gs'", >> arq1)
	print ("vmove .70 .90", >> arq1)
	print ("justify 5; expand 1; label '\iP'", >> arq1)
	print ("vmove .85 .90", >> arq1)
	print ("justify 5; expand 1; label '\gq'", >> arq1)
	
	print ("vmove .25 .85", >> arq1)
	print ("justify 5; expand 1; label "//qeffect, >> arq1)
	print ("vmove .40 .85", >> arq1)
	print ("justify 5; expand 1; label "//ueffect, >> arq1)
	print ("vmove .55 .85", >> arq1)
	print ("justify 5; expand 1; label "//seffect, >> arq1)
	print ("vmove .70 .85", >> arq1)
	print ("justify 5; expand 1; label "//peffect, >> arq1)
	print ("vmove .85 .85", >> arq1)
	print ("justify 5; expand 1; label "//angeff, >> arq1)
	
	
	igi < tmp$COMMANDS.IGI
	igi < tmp$COMMANDS.IGI, >G "tmp$TEMP_1.GRA")
	
	if (output == "none") {
	
#		stdgraph (input = "tmp$TEMP_1.GRA", device = "stdgraph", 
#			generic = no, debug = no, verbose = no, gkiunits = no,
#			txquality = "normal", xres = 0, yres = 0)
		
	} else {
	
	if (output == "ps") {
	
	arquivo = "GRAF_1.ps"
	u1 = 1
	ver = access (arquivo)
		
	while (ver == yes) {
		u1 = u1 + 1
		arquivo = "GRAF_"//u1//".ps"
		ver = access (arquivo)
	}
	
	psikern (input = "tmp$TEMP_1.GRA", device = "psi_land", 
		generic = no, output = arquivo, )

	}
	
	else {
	
	arquivo = "GRAF_1.ms"
	u1 = 1
	ver = access (arquivo)
		
	while (ver == yes) {
		u1 = u1 + 1
		arquivo = "GRAF_"//u1//".ms"
		ver = access (arquivo)
	}
	
	copy ("tmp$TEMP_1.GRA", arquivo)
	
	print ("Arquivo metacode -> "//arquivo)
	print ("")
	
	}
	
	}
	
	delete ("tmp$COMMANDS.IGI",>& "dev$null", ver-)
	delete ("tmp$TEMP_1.GRA",>& "dev$null", ver-)
	delete ("tmp$GRAFICO.txt,tmp$Z.txt", ver-, >& "dev$null")
	delete ("tmp$GRAFICO.log", ver-, >& "dev$null")
	
	
	flist1 = ""
	flist3 = ""
	
fim:    print ("")
 		
end

