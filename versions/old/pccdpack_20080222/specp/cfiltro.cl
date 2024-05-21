procedure cfiltro  (entrada, tipo, numero, intervalo, filtro)

string entrada="@espectros"	{prompt="Lista das imagens a serem processadas"}
string tipo="objeto" {enum="objeto|padpol|npol|flat", prompt="Tipo de imagem"}
int intervalo="30"        {min=1, prompt='Intervalo usado na "binagem"'}
int    numero=16	{min=4, max=16, prompt="Numero de posicoes da lamina"}
string filtro = "/users/alex/iraf/V.fil" {prompt="Arquivo com os dados do filtro"}
string regist = "sim"   {enum="sim|nao", prompt="Cria arquivo GRAFICO.log?"}
struct *flist1  
struct *flist2  
struct flist3 {length=160}
struct *flist4 {length=160}


begin

	
	int numer, interv
	string tip, entr, filt
	
	string arq1, arq2, arq3
	string dir, dirtmp
	string lixo1
	string par
	struct linha
	
	string arqu,arqq,arqs
	string nome	
	real lambdamin, lambdamax
	int npix
	int inut
	int sinal
	
	real r1, r2, r3, r4, r5
	int u1, u2, u3, u4, u5
	real e[16], o[16]
	real z[16], k, k1, k2, ssoma
	real pi
	bool ver, ver1
	
	int cont
	real soma1, soma2
	real qeff, ueff, seff, angeff, peff, leff
	real rqeff, rueff, rseff, rangeff, rpeff, rleff
	string seffect, qeffect, ueffect, peffect
			
	string s1, s2, s3, imagem
	int i1
	string line1
	string listaord, listaext


	
	entr = entrada
	numer = numero
	interv = intervalo
	tip = tipo
    	filt = filtro
    	
    	dir = "dir.txt"
    	flist1 = dir
    	pathnames (template = "", sort = yes, >> dir)
    	lixo1 = fscan (flist1, dir)
    	
    		
	ver1 = access("home$tmp")
	
	if (ver1 == no)
	
		mkdir ("home$tmp/")
		
   	
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

	arqq = nome//"Q_"//interv//"_"//numer//".imh"
	arqu = nome//"U_"//interv//"_"//numer//".imh"
	arqs = nome//"SIG_"//interv//"_"//numer//".imh"


# PROCEDIMENTO POR CONVOLUCAO PELO FILTRO

	print ("")
	print ("Convoluindo as imagens com o filtro: "//filt)
	print ("")
	
	
	# SEPARA O ESPECTRO BIDIMENSIONAL EM DOIS ESPECTROS UNIDIMENSIONAIS
	
	
 	i1 = strlen(entr)
	
	entr = substr(entr, 2, i1) 
	
	flist1 = entr
	
	for (i = 1; i <= numer; i += 1) {
	
	lixo1 = fscan (flist1, s1)
	imcopy (input = s1, output = "home$tmp/"//s1, verbose = no)
	
	}
	;
	
	dir = "dir.txt"
    	flist1 = dir
    	pathnames (template = "", sort = yes, >> dir)
    	lixo1 = fscan (flist1, dir)
    	
    	chdir ("home$tmp/")
	
	copy (dir//entr, entr, verbose = no)
	
	flist1 = entr
	
	for (i = 1; i <= numer; i += 1) {
	
	lixo1 = fscan (flist1, s1)
		
	sarith (input1 = s1, op = "copy", input2 = "", output = s1, w1 = INDEF, 
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "onedspec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
		
	}
	;
	 	
	imdelete (images = "@"//entr, >& "dev$null", ver-)
	delete (entr, ver-)
		 
	# GERA LISTA COM OS NOMES PADRAO PARA OS ESPECTROS
	
	listaord = "temp1.txt"
	listaext = "temp2.txt"

	for (i=1; i <= numer; i+=1)  {
		s1 = "o"//i						
		print (s1, >> listaord)
	}
	for (i=1; i <= numer; i+=1)  {
		s1 = "e"//i
		print (s1, >> listaext)
	}
	;	
	
	#  RENOMEIA OS ARQUIVOS DE ENTRADA PARA OS FORMATOS PADRAO	

	imrename (oldnames = "*0001.imh", newnames = "@temp1.txt", verbose = no)
	imrename (oldnames = "*0002.imh", newnames = "@temp2.txt", verbose = no)

	# DETERMINACAO DE npix

	listpix ("e1.imh", >> "TEMP_1.txt") # Determina extremos de Compr. de Onda
	
	flist1 = "TEMP_1.txt"
	
	lixo1 = fscan (flist1, lambdamin)
	
	while (fscan (flist1, lambdamax) != EOF) {
	}
	
	delete ("TEMP_1.txt", ver-)

		
	npix = (lambdamax - lambdamin) / interv
	
	
	# GERA ESPECTRO UNITARIO 

	unlearn wtextimage
			
	wtextimage (input = dir//arqu, output = "U.txt") #melhorar esta parte

	arq1 = "U.txt"
	arq2 = "TEMP_2.txt"
	
	flist1 = arq1
	
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
			
			print ("1.", " ", "1.", " ", "1.", " ", "1.", " ", "1.", >> arq2)
			
			}
						
		}
		;
	
	}
	
	unlearn rtextimage
	
	rtextimage (input = "TEMP_2.txt", output = "UNITARIO") #, otype = "", header = yes) #, nskip = 0, dim =)
	
		
	imdelete (images = "TEMP*.imh", >& "dev$null", ver-)
	delete ("TEMP*.txt", ver-)
	delete ("U.txt", ver-)
	
	
	# CONSTROI O ESPECTRO COM O FORMATO DA BANDA PASSANTE
	 
	flist2 = filt
	 
	cont = 0

	lixo1 = fscan (flist2, lambdamin)
	
	while (fscan (flist2, lambdamax) != EOF) {
	  	cont = cont + 1
	}
	
	dispcor.log = no
	dispcor.logfile = ""
	
	sarith (input1 = "UNITARIO.imh", op = "copy", input2 = "", 
		output = "UNIPAD", w1 = lambdamin,
		w2 = lambdamax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = no, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
	
	dispcor (input = "UNIPAD.imh", output = "UNIPAD.imh", linearize = yes, database = "database",
		table = "", w1 = INDEF, w2 = INDEF, dw = INDEF, nw = cont+1, flux = no,
		samedisp = yes, global = yes, ignoreaps = yes, confirm = no, listonly = no,
		verbose = no)
	
	arq3 = "UNIPAD.imh"
		
	wtextimage (input = arq3, output = "U.txt")

	arq1 = "U.txt"
	arq2 = "TEMP_1.txt"
	
	flist1 = arq1
	flist2 = filt
	
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
			
			linha = ""
			
			for (i = 1; i <= 5; i += 1) {
			
			lixo1 = fscan (flist2, r1,r2)
			
			linha = linha//r2//" "
			
			}			
			
			
			print (linha, >> arq2)
			
			}
						
		}
		;
	
	}
	
	unlearn rtextimage
	
	rtextimage (input = arq2, output = "FPAD") #, otype = "", header = yes) #, nskip = 0, dim =)
	
	par = kpnoslit.interp
	kpnoslit.interp = "nearest"
	
	sarith (input1 = "UNITARIO.imh", op = "*", input2 = "FPAD.imh", 
		output = "FILTROV", 
		w1 = INDEF, w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = no, errval = 0, verbose = no)
	
	kpnoslit.interp = par
	
	imdelete (images = "TEMP*.imh,FPAD", verify = no, >& "dev$null")
	delete ("TEMP*.txt", ver-)
	delete ("U.txt", ver-)
	
	# CALCULO DO COMPRIMENTO DE ONDA EFETIVO
	# CALCULO DE INT (FILTROV * TOTAL.imh * dL)
	
	scombine (input="@"//listaord//",@"//listaext, output="TOTAL.imh", 
		 noutput="", logfile="STDOUT", 
		 apertures="", group="all", combine="average", reject="none",
		 first = no, w1 = INDEF, w2 = INDEF, dw = INDEF, nw = INDEF,
		 scale = "none", zero = "none", weight = "none", sample = "",
		 lthreshold = INDEF, hthreshold = INDEF, nlow = 1, nhigh = 1, 
		 mclip = yes, lsigma = 3., hsigma = 3., rdnoise = "0.", gain = "1.",
		 sigscale = 0.1, pclip = -0.5, grow = 0, blank = 0., >& "dev$null"
	
	sarith (input1 = "FILTROV.imh", op = "*", input2 = "TOTAL.imh", 
		output = "PRODUTO.imh", w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
	
	
	listpix ("PRODUTO.imh", >> "PRODUTO.txt")
	
	flist1 = "PRODUTO.txt"
	flist2 = "PRODUTO.txt"
	
	soma1 = 0
	
	lixo1 = fscan (flist1, r1, r2)
	lixo1 = fscan (flist1, r1, r2)
	
	for (i = 1; i <= npix; i += 1) {
	
		lixo1 = fscan (flist2, r3, r4)
		
		soma1 = soma1 + r2 * (r1-r3)

		lixo1 = fscan (flist1, r1, r2)
	
	}
	
	flist1 = "PRODUTO.txt"
	flist2 = "PRODUTO.txt"
	
	soma2 = 0
	
	lixo1 = fscan (flist1, r1, r2)
	lixo1 = fscan (flist1, r1, r2)
	
	for (i = 1; i <= npix; i += 1) {
	
		lixo1 = fscan (flist2, r3, r4)
		
		soma2 = soma2 + r2 * (r1-r3) * r3

		lixo1 = fscan (flist1, r1, r2)
	
	}
	
	leff = soma2 / soma1
	
	imdelete ("PRODUTO", verify = no, >& "dev$null")
	imdelete ("TOTAL", verify = no, >& "dev$null")
	delete ("PRODUTO.txt", >& "dev$null", ver-)

	
	# CALCULO DE INT (FILTROV * dL)
	
	listpix ("FILTROV.imh", >> "FILTROV.txt")
	
	flist1 = "FILTROV.txt"
	flist2 = "FILTROV.txt"
	
	soma1 = 0
	
	lixo1 = fscan (flist1, r1, r2)
	lixo1 = fscan (flist1, r1, r2)
	
	for (i = 1; i <= npix; i += 1) {
	
		lixo1 = fscan (flist2, r3, r4)
		
		soma1 = soma1 + r2 * (r1-r3)

		lixo1 = fscan (flist1, r1, r2)
		
	}
		
	# CONVOLUE OS ESPECTRO ORD. COM O FORMATO DO FILTRO
	# CALCULO DE INT (FILTROV * ORD*.imh * dL)
	
	flist4 = listaord	
	
	for (i = 1; i <= numer; i += 1) {
		
	sarith (input1 = "FILTROV", op = "*", input2 = flist4, 
		output = "PRODUTOO.imh", w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
	
	
	listpix ("PRODUTOO.imh", >> "PRODUTOO.txt")
	
	flist1 = "PRODUTOO.txt"
	flist2 = "PRODUTOO.txt"
	
	
	soma2 = 0
	
	lixo1 = fscan (flist1, r1, r2)
	lixo1 = fscan (flist1, r1, r2)
	
	for (j = 1; j <= npix; j += 1) {
	
		lixo1 = fscan (flist2, r3, r4)
		
		soma2 = soma2 + r2 * (r1-r3)
	
		lixo1 = fscan (flist1, r1, r2)
	
	}
	
	o[i] = soma2 / soma1
	
	imdelete ("PRODUTOO", verify = no, >& "dev$null")
	delete ("PRODUTOO.txt", >& "dev$null", ver-)

	
	}
	;

	# CALCULO DE INT (FILTROV * EXTR*.imh * dL)
	
	flist4 = listaext	
	
	for (i = 1; i <= numer; i += 1) {
		
	sarith (input1 = "FILTROV", op = "*", input2 = flist4, 
		output = "PRODUTOQ.imh", w1 = INDEF,
		w2 = INDEF, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
	
	
	listpix ("PRODUTOQ.imh", >> "PRODUTOQ.txt")
	
	flist1 = "PRODUTOQ.txt"
	flist2 = "PRODUTOQ.txt"
	
	
	soma2 = 0
	
	lixo1 = fscan (flist1, r1, r2)
	lixo1 = fscan (flist1, r1, r2)
	
	for (j = 1; j <= npix; j += 1) {
	
		lixo1 = fscan (flist2, r3, r4)
		
		soma2 = soma2 + r2 * (r1-r3)

		lixo1 = fscan (flist1, r1, r2)
	
	}
	
	e[i] = soma2 / soma1
	
	imdelete ("PRODUTOQ", verify = no, >& "dev$null")
	delete ("PRODUTOQ.txt", >& "dev$null", ver-)

	
	}
	;

	k1 = 0
	k2 = 0

	for (i = 1; i <= numer; i += 1) {
	
	k1 = k1 + o[i]
	k2 = k2 + e[i]
	
	}
	;
	
	k = k2 / k1
	
	for (i = 1; i <= numer; i += 1) {
	
	z[i] = (e[i] - o[i]*k)/(e[i] + o[i]*k)
		
	}
	;
	
	if (numer == 16) {
	
		qeff = (z[1] - z[3] + z[5] - z[7] + z[9] - z[11] + z[13] - z[15])/8
		ueff = (z[2] - z[4] + z[6] - z[8] + z[10] - z[12] + z[14] - z[16])/8
	
	}
	;
	
	if (numer == 12) {
	
		qeff = (z[1] - z[3] + z[5] - z[7] + z[9] - z[11])/6
		ueff = (z[2] - z[4] + z[6] - z[8] + z[10] - z[12])/6
	
	}
	;
	
	if (numer == 8) {
	
		qeff = (z[1] - z[3] + z[5] - z[7])/4
		ueff = (z[2] - z[4] + z[6] - z[8])/4
	
	}
	;
	
	if (numer == 4) {
	
		qeff = (z[1] - z[3])/2
		ueff = (z[2] - z[4])/2
	
	}
	;
	
	ssoma = 0
	
	for (i = 1; i <= numer; i += 1) {
	
	ssoma = ssoma + z[i] ** 2
		
	}
	;
 	
	seff = sqrt (1./(numer-2)*(1./(numer/2)*ssoma-qeff**2-ueff**2))

	for (i = 1; i <= numer; i += 1) {
	
		print (22.5*(i-1), z[i], seff, >> "Z.txt")
		
	}
	;

	imdelete ("FILTROV,UNIPAD,UNITARIO", verify = no, >& "dev$null")
	imdelete ("@"//listaord, verify = no, >& "dev$null")
	imdelete ("@"//listaext, verify = no, >& "dev$null")
	delete (listaext, ver-)
	delete (listaord, ver-)
	delete ("FILTROV.txt", >& "dev$null", ver-)


	rleff = leff
	inut = 100 * leff + .5
	leff = inut
	leff = leff / 100
	
	print (" ")
	print ("Compr. de onda efetivo: "//leff)
	print (" ")
	
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
	print ("Q efetivo: "//qeffect)
	print (" ")
	
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
	print ("U efetivo: "//ueffect)
	print (" ")
	
	
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
	print ("SIGMA efetivo: "//seffect)
	print (" ")
	
	
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
	print ("Polarizacao efetiva: "//peffect)
	print (" ")
	
	
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
	angeff = 180 - angeff
	
	rangeff = angeff
	inut = 100 * angeff + .5
	angeff = inut
	angeff = angeff / 100
	print (" ")
	print ("Ang. efetivo: "//angeff)
	print (" ")

	imgets (image = dir//arqq, param = "i_title")
	
	flist3 = imgets.value
	
	lixo1 = fscan (flist3, imagem)
		
	if (regist == "sim") {
		delete (dir//"GRAFICO.log", ver-, >& "dev$null")
		print (imagem, >> dir//"GRAFICO.log")
		print ("# Q     U      SIGMA    P       ANG. LEFF", >> dir//"GRAFICO.log")
		print (rqeff, rueff, rseff, rpeff, rangeff, rleff, >> dir//"GRAFICO.log")
		print (" ", >> dir//"GRAFICO.log")
		flist1 = "Z.txt"
		while (fscan (flist1, flist3) != EOF) {
			print (flist3, >> dir//"GRAFICO.log")
		}
	}
				
	delete ("Z.txt", ver-, >& "dev$null")
	
	back (>& "dev$null")	
	delete ("dir.txt", ver-)
	
	flist1 = ""
	flist2 = ""
	flist3 = ""
	flist4 = ""
	
		
end
