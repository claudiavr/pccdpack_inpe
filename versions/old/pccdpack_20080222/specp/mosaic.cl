procedure mosaic (graphic,type,interval,number)

string graphic="PA" {enum="PA|QU", prompt="Graphic Type"}
string type="objeto" {enum="objeto|padpol|npol|flat", prompt="Object Type"}
int interval=1        {min=1, prompt='Binning Interval'}
int    number=16	{min=4, max=16, prompt="Number of Waveplate Positions"}
string output="none" {enum="ps|meta|none", prompt="Format of the Output File"}
real lbdmin=INDEF {prompt = "Minimum Wavelength"}
real lbdmax=INDEF {prompt = "Maximum Wavelength"}
string title="img"     {prompt = "Plot Title"}
string corflat="no" {enum="yes|no",prompt="Correct for the Lambda Dependence of Theta?"}
string coreq="no" {enum="yes|no",prompt="Apply Equatorial Correction?"}
string retar="no" {enum="yes|no",prompt="Apply Retardance Correction?"}
string instr="no" {enum="yes|no",prompt="Correct for Instrumental Polarization?"}
string inter="no" {enum="yes|no",prompt="Correct for Interstellar Polarization?"}
string bintotal="yes" {enum="yes|no",prompt="Plot the binned total flux?"}
string binsigma="no"  {enum="yes|no",prompt="Bin the polarization for a given sigma?"}
real perror=0.5		{min=0,max=100,prompt='Bin Error (%)'}

# Parametros que controlam a escala dos graficos

real onemin=INDEF
real onemax=INDEF
real twomin=INDEF
real twomax=INDEF
real threemin=INDEF
real threemax=INDEF
real fourmin=INDEF
real fourmax=INDEF

real cte1=1.2
real cte2=1.2
real cte3=1.2
real cte4=1.2
#string autom = "sim" {enum = "sim|nao", prompt = "Paramatros do grafico automaticamente?"}

# Parametros que controlam a posicao das barras de erro

#real xspol
#real yspol
#real xsteor
#real ysteor
#real xsthet
#real ysthet
struct *flist
struct flist3 {length = 160}

begin

	string nome1, nome2
	string arq1, arq2, arqt, arqf, arqp, arqsan, arqs, arqst, arqtmed
	string arqq,arqu,arqan
	string arq1temp, arq2temp, arqttemp, arqftemp, arqptemp, arqsantemp, arqstemp, arqsttemp
	string arq5
	string arquivo
	string temp1, temp2
	string lixo1, lixo2
	string imagem
	real max1, min1, max2, min2, max4, min4, max3, min3 
	real lmax, lmin
	real sig1x, sig1y, sig2x, sig2y, sig3x, sig3y
	real sig1xu, sig1yu, pxu, pyu
	real px, py, tx, ty, ptx, pty
	real pmedio
	int i1, npix, inut
	bool ver, ver1
	string rot1, rot2
	int numer, interv
	string tip, model,meio
	
	model = graphic
	tip = type
	interv = interval
	numer = number
		
	
	ver1 = access("tmp$")
	
	if (ver1 == no)
		mkdir ("tmp$")
		
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
	
	arqp = nome1//meio//"P_"//interv//"_"//numer//".fits"
	arqan = nome1//meio//"ANG_"//interv//"_"//numer//".fits"
	arqq = nome1//meio//"Q_"//interv//"_"//numer//".fits"
	arqu = nome1//meio//"U_"//interv//"_"//numer//".fits"
	arqf = nome1//meio//"FP_"//interv//"_"//numer//".fits"

	arqt = nome1//"TOT_"//interv//"_"//numer//".fits"
	arqs = nome1//"SIG_"//interv//"_"//numer//".fits"
	arqsan = nome1//"SIGAN_"//interv//"_"//numer//".fits"
	arqst = nome1//"SIGT_"//interv//"_"//numer//".fits"
	
#BINA
	if (binsigma == "yes") {
	    	if (access (arqt)) {
    		}
    		else {
			print ("")
    			print ("ERROR: File "//arqt//" do not exist.")
			print ("Run calcpol again, with interval=1")
			goto fim
		}	
		bina (type=tip,number=numer,corflat=corflat,coreq=coreq,retar=retar,
		      instr=instr,inter=inter,perror=perror)
		
		arqp = "BIN_P.fits"
		arqf = "BIN_FP.fits"
		arqan = "BIN_ANG.fits"
		arqsan = "BIN_SIGAN.fits"
		arqq = "BIN_Q.fits"
		arqu = "BIN_U.fits"
		arqs = "BIN_S.fits"
		arqt = "BIN_TOT.fits"
	}
	


	if (bintotal=="no") {
		arqt = nome1//"TOT_1_"//numer//".fits"
	    	if (access (arqt)) {
    		}
    		else {
			print ("")
    			print ("ERROR: File "//arqt//" do not exist.")
			print ("Run calcpol again, with interval=1")
			goto fim
		}	
	}


		
	if (model == "PA") {
	
		arq1 = arqp
		arq2 = arqan

		arqp = "tmp$"//arq1 # Usado para calc. de pmedio
	
		rot1 = "\iP (%)"
		rot2 = "\gq \\r(\uo)"
	
	} else {
	
		arq1 = arqq
		arq2 = arqu

#		arqp = arqp # Usado para calc. de pmedio
	
		rot1 = "\iQ (%)"
		rot2 = "\iU (%)"
	
	}
	
	
	imcalc (input=arq1, output="tmp$"//arq1,
		   equals="im1*100.",verbose=no)
	arq1 = "tmp$"//arq1
		
	imcalc (input=arqs, output="tmp$"//arqs,
		   equals="im1*100.",verbose=no)
	arqs = "tmp$"//arqs

	imcalc (input=arqst, output="tmp$"//arqst,
		   equals="im1*100.",verbose=no)
	arqst = "tmp$"//arqst
	
	if (model == "QU") {
	
		imcalc (input=arq2, output="tmp$"//arq2,
		   		equals="im1*100.",verbose=no)
		arq2 = "tmp$"//arq2
	
		imcalc (input=arqp, output="tmp$"//arqp,
		   		equals="im1*100.",verbose=no)
	     arqp = "tmp$"//arqp
	} else {	
		imcopy (input = arq2, output = "tmp$"//arq2, verbose = no)
		arq2 = "tmp$"//arq2
	}
	
		
# DETERMINACAO DOS EXTREMOS DE COMPRIMENTO DE ONDA

	
	if (lbdmax == INDEF || lbdmin == INDEF) {
	
	listpix (arq2, wcs="world", >> "tmp$TEMP_1.txt")
	
	flist = "tmp$TEMP_1.txt"
	
	lixo1 = fscan (flist, lmin)
	
	while (fscan (flist, lmax) != EOF) {
	}
	
	delete ("tmp$TEMP_1.txt", ver-)

	}
	
	if (lbdmin != INDEF)
		lmin = lbdmin
	if (lbdmax != INDEF)
		lmax = lbdmax	
	
# CORTA ESPECTROS	
	
	arqttemp = "tmp$arqt_123.fits"
	sarith (input1 = arqt, op = "copy", input2 = "", 
		output = arqttemp, w1 = lmin, w2 = lmax, 
		apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = yes, 
		offset = 0, clobber = yes, merge = no, rebin = yes, errval = 0,
		verbose = no)
	
	arq1temp = "tmp$arq1_123.fits"
	sarith (input1 = arq1, op = "copy", input2 = "", output = arq1temp, 
		w1 = lmin, w2 = lmax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = yes, offset = 0,
		clobber = yes, merge = no, rebin = yes, errval = 0, verbose = no)
		
	arqftemp = "tmp$arqf_123.fits"
	sarith (input1 = arqf, op = "copy", input2 = "", 
		output = arqftemp, w1 = lmin, w2 = lmax, 
		apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = yes, offset = 0,
		clobber = yes, merge = no, rebin = yes, errval = 0, verbose = no)
	
	arq2temp = "tmp$arq2_123.fits"
	sarith (input1 = arq2, op = "copy", input2 = "", output = arq2temp, 
		w1 = lmin, w2 = lmax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = yes, offset = 0,
		clobber = yes, merge = no, rebin = yes, errval = 0, verbose = no)

	arqstemp = "tmp$arqs_123.fits"
	sarith (input1 = arqs, op = "copy", input2 = "", output = arqstemp, 
		w1 = lmin, w2 = lmax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = yes, offset = 0,
		clobber = yes, merge = no, rebin = yes, errval = 0, verbose = no)

	arqsantemp = "tmp$arqsan_123.fits"
	sarith (input1 = arqsan, op = "copy", input2 = "", 
		output = arqsantemp, w1 = lmin, w2 = lmax, 
		apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = yes, offset = 0,
		clobber = yes, merge = no, rebin = yes, errval = 0, verbose = no)
	
	arqsttemp = "tmp$arqst_123.fits"
	sarith (input1 = arqst, op = "copy", input2 = "", output = arqsttemp, 
		w1 = lmin, w2 = lmax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = yes, offset = 0,
		clobber = yes, merge = no, rebin = yes, errval = 0, verbose = no)
		
	arqptemp = "tmp$arqp_123.fits"
	sarith (input1 = arqp, op = "copy", input2 = "", output = arqptemp, 
		w1 = lmin, w2 = lmax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = yes, offset = 0,
		clobber = yes, merge = no, rebin = yes, errval = 0, verbose = no)	

# FLUXO TOTAL * PMEDIO

	imstatistics (images = arqptemp, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "temp1.txt")
	flist = "temp1.txt"
	lixo1 = fscan (flist, pmedio)
	delete ("temp1.txt", ver-)

	pmedio = pmedio / 100. 

	arqtmed = "tmp$PADRAOMED"
	
	sarith (input1 = arqttemp, op = "*", input2 = ""//pmedio, output = arqtmed, 
		w1 = lmin, w2 = lmax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = yes, offset = 0,
		clobber = yes, merge = no, rebin = yes, errval = 0, verbose = no)
	
	
# COORDENADAS DOS GRAFICOS

	imstatistics (images = arqttemp, fields = "min,max", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "temp1.txt")
	flist = "temp1.txt"
	lixo1 = fscan (flist, min1, max1)
	delete ("temp1.txt", ver-)

	min1 = min1/cte1
	max1 = max1*cte1

	if (onemin != INDEF)
		min1 = onemin
	if (onemax != INDEF)
		max1 = onemax
	
	imstatistics (images = arq1temp, fields = "min,max", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "temp1.txt")
	flist = "temp1.txt"
	lixo1 = fscan (flist, min2, max2)
	delete ("temp1.txt", ver-)
	if (model == "PA") 
		min2 = 0

	if (min2 > 0) 
		min2 = min2/cte2
	else min2 = min2*cte2
		if (max2 > 0)
			max2 = max2*cte2
		else max2 = max2/cte2
	
	if (twomin != INDEF)
		min2 = twomin
	if (twomax != INDEF)
		max2 = twomax
		
	imstatistics (images = arq2temp, fields = "min,max", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "temp1.txt")
	flist = "temp1.txt"
	lixo1 = fscan (flist, min3, max3)
	delete ("temp1.txt", ver-)
	
	if (min3 > 0) 
		min3 = min3/cte3
	else min3 = min3*cte3
		if (max3 > 0)
			max3 = max3*cte3
			else max3 = max3/cte3
	
	if (threemin != INDEF)
		min3 = threemin
	if (threemax != INDEF)
		max3 = threemax

	IF (model == "PA" && threemin < 0.) {
# SE TWOMIN eh negativo, entao todo ponto do angulo com valor acima de twomax
# eh subtraido de 180
		imcalc (input=arq2, output="tmp$temp111.fits",
			   equals="if im1 .ge. "//max3//" then im1-180. else im1",
			   verbose=no)
		imdelete(arq2, ver-)
		imrename("tmp$temp111.fits", arq2)
	}
		
	imstatistics (images = arqftemp, fields = "min,max", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "temp1.txt")
	flist = "temp1.txt"
	lixo1 = fscan (flist, min4, max4)
	delete ("temp1.txt", ver-)
	
	min4 = min4/cte4
	max4 = max4*cte4
	
	if (fourmin != INDEF)
		min4 = fourmin
	if (fourmax != INDEF)
		max4 = fourmax

	
# DETERMINACAO DAS PARAMETROS PARA AS BARRAS DE ERRO EM P (ou Q)
	
	imstatistics (images = arqstemp, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "temp1.txt")
	flist = "temp1.txt"
	lixo1 = fscan (flist, sig1y)
	delete ("temp1.txt", ver-)
	sig1x = (lmax - lmin)*.75 + lmin	
	
	listpix (images = arq1temp, wcs = "world", formats = "", verbose = no, >> "temp1.txt")
	flist = "temp1.txt"
	while (fscan(flist, px, py) != EOF) {
	
		if (px > sig1x)
		break
	
	}
	
	if (py >  (max2+min2)/2) 
		py = ((max2-min2)*.2+min2)
	    
	    else
	    	
	    	py = ((max2-min2)*.8+min2)
	
	
	print (sig1x, py, sig1y, >> "tmp$P.txt")
	delete ("temp1.txt", ver-)
	
	if (model == "QU") {
	
# DETERMINACAO DAS PARAMETROS PARA AS BARRAS DE ERRO EM P (ou Q)
	
	imstatistics (images = arqstemp, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "temp1.txt")
	flist = "temp1.txt"
	lixo1 = fscan (flist, sig1yu)
	delete ("temp1.txt", ver-)
	sig1xu = (lmax - lmin)*.75 + lmin	
	
	listpix (images = arq1temp, wcs = "world", formats = "", verbose = no, >> "temp1.txt")
	flist = "temp1.txt"
	while (fscan(flist, pxu, pyu) != EOF) {
	
		if (px > sig1xu)
		break
	
	}
	
	if (pyu >  (max3+min3)/2) 
		pyu = ((max3-min3)*.2+min3)
	    
	    else
	    	
	    	py = ((max3-min3)*.8+min3)
	
	
	print (sig1xu, pyu, sig1yu, >> "tmp$Pu.txt")
	delete ("temp1.txt", ver-)
	
	}
	
# DETERMINACAO DAS PARAMETROS PARA AS BARRAS DE ERRO TEORICO EM P
	
	imstatistics (images = arqsttemp, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "temp1.txt")
	flist = "temp1.txt"
	lixo1 = fscan (flist, sig3y)
	delete ("temp1.txt", ver-)
	sig3x = (lmax - lmin)*.25 + lmin	
	
	listpix (images = arq1temp, wcs = "world", formats = "", verbose = no, >> "temp1.txt")
	flist = "temp1.txt"
	while (fscan(flist, ptx, pty) != EOF) {
	
		if (ptx > sig3x)
		break
	
	}
	
	if (pty >  (max2)/2) 
		pty = ((max2)*.2)
	    
	    else
	    	
	    	pty = ((max2)*.8)
	
	
	print (sig3x, py, sig3y, >> "tmp$Pt.txt")
	delete ("temp1.txt", ver-)

# DETERMINACAO DAS PARAMETROS PARA AS BARRAS DE ERRO EM THETA
	
	imstatistics (images = arqsantemp, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "temp1.txt")
	flist = "temp1.txt"
	lixo1 = fscan (flist, sig2y)
	delete ("temp1.txt", ver-)
	sig2x = (lmax - lmin)*.75 + lmin	

	
	listpix (images = arq2temp, wcs = "world", formats = "", verbose = no, >> "temp1.txt")
	flist = "temp1.txt"
	while (fscan(flist, tx, ty) != EOF) {
	
		if (tx > sig2x)
		break
	
	}
	
	if (ty >  (min3 + max3)/2) 
		ty = ((max3 - min3)*.15 + min3)
	    
	    else
	    	
	    	ty = ((max3 - min3)*.85 + min3)
	    	
	print (sig2x, ty, sig2y, >> "tmp$THETA.txt")
	delete ("temp1.txt", ver-)

# TITULO DO GRAFICO


	if (title == "img") {
		imgets (image = arqt, param = "i_title")
	
	 	flist3 = imgets.value
	 	lixo1 = fscan (flist3, imagem)
	 
	}
	else 
		imagem = title
   

# CONTRUCAO DO ARQUIVO DE ENTRADA PARA O IGI

	
	arq5 = "tmp$COMMANDS.IGI"
	delete (arq5, ver-, >& "dev$null")
	
	
	
	print ("erase", >> arq5)
	print("DEFINE STACK", >> arq5)
	print("location .15 .98 &1 &2", >> arq5)
	print("limits "//lmin//" "//lmax//" &4 &5", >> arq5)
	print("margin", >> arq5)
	print("box &3 2", >> arq5)
	print("step", >> arq5)
	print("END", >> arq5)
	
	print("imgwcs", >> arq5)
	
	print('ysection "'//arqt//'"', >> arq5)
	print("stack  .73 .94 0 "//min1//" "//max1, >> arq5)
	print('expand 1.2; title '//imagem, >> arq5)
	print("move "//((lmin-lmax)*0.18+lmin)//" "//((max1-min1)*.5+min1), >> arq5)
	print('expand 1;justify 5; angle 90; label "\\\iTotal Flux"', >> arq5)
	print("move "//((lmin-lmax)*0.15+lmin)//" "//((max1-min1)*.5+min1), >> arq5)
	print('justify 5; angle 90; expand .8; label "\\\i(counts)"', >> arq5)
	

	print('ysection "'//arq1//'"', >> arq5)
	print("stack .52 .73 0 "//min2//" "//max2, >> arq5)
	print('data tmp$P.txt', >> arq5)
	print('xcolumn 1, ycolumn 2, ecolumn 3', >> arq5)
	print("errorbar -2", >> arq5)
	print("errorbar 2", >> arq5)
	print("move "//(lmax-lmin)*0.0125+sig1x//" "//py, >> arq5)
	inut = 100 * sig1y + .5
	sig1y = inut
	sig1y = sig1y / 100
	print('expand .8; justify 6; angle 0; label "\\iMean Error ('//sig1y//'%)"', >> arq5)
	#print('data tmp$Pt.txt', >> arq5)
	#print('xcolumn 1, ycolumn 2, ecolumn 3', >> arq5)
	#print("errorbar -2", >> arq5)
	#print("errorbar 2", >> arq5)
	#print("move "//(lmax-lmin)*0.0125+sig3x//" "//pty, >> arq5)
	#print('expand .8; justify 6; angle 0; label "\\\iErro teorico"', >> arq5)
	#print('esection "'//arqs//'"', >> arq5)
	#print("errorbar -2", >> arq5)
	#print("errorbar 2", >> arq5)
	print("move "//((lmin-lmax)*0.18+lmin)//" "//((max2-min2)*.5+min2), >> arq5)
	print('expand 1; justify 5; angle 90; label "'//rot1//'"', >> arq5)
	print("move "//((lmin-lmax)*0.15+lmin)//" "//((max2-min2)*.5+min2), >> arq5)
#	print('justify 5; angle 90; expand .8; label "\\\i(%)"', >> arq5)

	
	if (model == "PA") {

	print('ysection "'//arq2//'"', >> arq5)
	print("stack .31 .52 0 "//min3//" "//max3, >> arq5)
	#print('esection "'//arqsan//'"', >> arq5)
	#print("errorbar -2", >> arq5)
	#print("errorbar 2", >> arq5)
	print('data tmp$THETA.txt', >> arq5)
	print('xcolumn 1, ycolumn 2, ecolumn 3', >> arq5)
	print("errorbar -2", >> arq5)
	print("errorbar 2", >> arq5)
	print("move "//(lmax-lmin)*0.0125+sig2x//" "//ty, >> arq5)
	inut = 100 * sig2y + .5
	sig2y = inut
	sig2y = sig2y / 100
	print('expand .8; justify 6; angle 0; label "\\iMean Error ('//sig2y//')"', >> arq5)
	print("move "//((lmin-lmax)*0.18+lmin)//" "//((max3-min3)*.5+min3), >> arq5)
	print('expand 1; justify 5; angle 90; label "'//rot2//'"', >> arq5)
	print("move "//((lmin-lmax)*0.15+lmin)//" "//((max3-min3)*.5+min3), >> arq5)
#	print('justify 5; angle 90; expand .8; label "\\\i(deg)"', >> arq5)
	
	}
	
	else {
	
	print('ysection "'//arq2//'"', >> arq5)
	print("stack .31 .52 0 "//min3//" "//max3, >> arq5)
	print('data tmp$Pu.txt', >> arq5)
	print('xcolumn 1, ycolumn 2, ecolumn 3', >> arq5)
	print("errorbar -2", >> arq5)
	print("errorbar 2", >> arq5)
	print("move "//(lmax-lmin)*0.0125+sig1xu//" "//pyu, >> arq5)
	inut = 100 * sig1yu + .5
	sig1yu = inut
	sig1yu = sig1yu / 100
	print('expand .8; justify 6; angle 0; label "\\iMean Error ('//sig1yu//'%)"', >> arq5)

	#print('data tmp$Pt.txt', >> arq5)
	#print('xcolumn 1, ycolumn 2, ecolumn 3', >> arq5)
	#print("errorbar -2", >> arq5)
	#print("errorbar 2", >> arq5)
	#print("move "//(lmax-lmin)*0.0125+sig3x//" "//pty, >> arq5)
	#print('expand .8; justify 6; angle 0; label "\\\iErro teorico"', >> arq5)
	#print('esection "'//arqs//'"', >> arq5)
	#print("errorbar -2", >> arq5)
	#print("errorbar 2", >> arq5)
	print("move "//((lmin-lmax)*0.18+lmin)//" "//((max3-min3)*.5+min3), >> arq5)
	print('expand 1; justify 5; angle 90; label "'//rot2//'"', >> arq5)
	print("move "//((lmin-lmax)*0.15+lmin)//" "//((max3-min3)*.5+min3), >> arq5)
#	print('justify 5; angle 90; expand .8; label "\\\i(%)"', >> arq5)

	}
	
	print("ltype 1", >> arq5)
	print('ysection "'//arqtmed//'"', >> arq5)
	print("stack .10 .31 1 "//min4//" "//max4, >> arq5)
	print("ltype 0", >> arq5)
	print('ysection "'//arqf//'"', >> arq5)
	print("ltype 0", >> arq5)
	print("step", >> arq5)
	print("ltype 0", >> arq5)
	print("move "//((lmin-lmax)*0.18+lmin)//" "//((max4-min4)*.5+min4), >> arq5)
	print('expand 1; justify 5; angle 90; label "\\\iPol. Flux"', >> arq5)
	print("move "//((lmin-lmax)*0.15+lmin)//" "//((max4-min4)*.5+min4), >> arq5)
	print('justify 5; angle 90; expand .8; label "\\\i(counts)"', >> arq5)
	print("move "//((lmax-lmin)*0.5+lmin)//" "//((min4-max4)*0.35+min4), >> arq5)
	print('angle 0; expand 1; label "\gl \\r(\gV)"', >> arq5)



# CONTRUCAO DOS GRAFICOS

	IF (output == "none") {
		igi < tmp$COMMANDS.IGI
	} ELSE {
		igi < tmp$COMMANDS.IGI
		igi < tmp$COMMANDS.IGI, >G "tmp$TEMP_1.GRA"
	
#	stdgraph (input = "tmp$TEMP_1.GRA", device = "stdgraph", 
#		generic = no, debug = no, verbose = no, gkiunits = no,
#		txquality = "normal", xres = 0, yres = 0)
	}
	if (output == "ps") {
	
	arquivo = "MOSAIC_1.ps"
	i1 = 1
	ver = access (arquivo)
		
	while (ver == yes) {
		i1 = i1 + 1
		arquivo = "MOSAIC_"//i1//".ps"
		ver = access (arquivo)
	}
	
	print ("")
	psikern (input = "tmp$TEMP_1.GRA", device = "psi_port", 
		generic = no, output = arquivo)
	
	}
		
	if (output == "meta") {
	
	arquivo = "MOSAIC_1.ms"
	i1 = 1
	ver = access (arquivo)
		
	while (ver == yes) {
		i1 = i1 + 1
		arquivo = "MOSAIC_"//i1//".ms"
		ver = access (arquivo)
	}
	
	copy ("tmp$TEMP_1.GRA", arquivo)
	
	print ("")
	print ("Arquivo metacode -> "//arquivo)
	
	}
		
	delete ("tmp$COMMANDS.IGI", ver-)
	
	imdelete ("tmp$temp111.fits", verify = no, >& "dev$null")
	imdelete (arq1, verify = no, >& "dev$null")
	imdelete (arq2, verify = no, >& "dev$null")
	imdelete (arqp, verify = no, >& "dev$null")
	imdelete (arqtmed, verify = no, >& "dev$null")
	imdelete (arqs, verify = no, >& "dev$null")
	imdelete (arqst, verify = no, >& "dev$null")
	imdelete (arqttemp, verify = no, >& "dev$null")
	imdelete (arq1temp, verify = no, >& "dev$null")
	imdelete (arqftemp, verify = no, >& "dev$null")
	imdelete (arq2temp, verify = no, >& "dev$null")
	imdelete (arqstemp, verify = no, >& "dev$null")
	imdelete (arqsantemp, verify = no, >& "dev$null")
	imdelete (arqsttemp, verify = no, >& "dev$null")
	imdelete (arqptemp, verify = no, >& "dev$null")

	if (binsigma == "yes") {
		imdelete("BIN_P.fits,BIN_FP.fits,BIN_ANG.fits,BIN_SIGAN.fits,BIN_Q.fits,BIN_U.fits,BIN_S.fits,BIN_TOT.fits",verify = no, >& "dev$null")
	}

	
	delete ("tmp$TEMP_1.GRA",>& "dev$null", ver-)
	delete ("tmp$P.txt", >& "dev$null", ver-)	
	delete ("tmp$Pt.txt", >& "dev$null", ver-)	
	delete ("tmp$Pu.txt", >& "dev$null", ver-)	
	delete ("tmp$THETA.txt", >& "dev$null", ver-)	

	flist = ""
	flist3 = ""
	
fim:    print ("")

end

