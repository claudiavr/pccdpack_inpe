procedure mosaic (type,interval,number)

string type="objeto" {enum="objeto|padpol|npol|flat", prompt="Object Type"}
int interval=1        {min=1, prompt='Binning Interval'}
int    number=16	{min=4, max=16, prompt="Number of Waveplate Positions"}
real lbdmin=INDEF {prompt = "Minimum Wavelength"}
real lbdmax=INDEF {prompt = "Maximum Wavelength"}
string corflat="no" {enum="yes|no",prompt="Correct for the Lambda Dependence of Theta?"}
string coreq="no" {enum="yes|no",prompt="Apply Equatorial Correction?"}
string retar="no" {enum="yes|no",prompt="Apply Retardance Correction?"}
string instr="no" {enum="yes|no",prompt="Correct for Instrumental Polarization?"}
string inter="no" {enum="yes|no",prompt="Correct for Interstellar Polarization?"}
string binsigma="no"  {enum="yes|no",prompt="Bin the polarization for a given sigma?"}
real perror=0.5		{min=0,max=100,prompt='Bin Error (%)'}

struct *flist
#struct flist3 {length = 160}

begin

	real qeff, ueff, seff, angeff, sangeff, peff

	string arqp, arqq, arqu, arqsan, arqs, arqang
	string arqt, arqf
#	string arq1, arq2, arqt, arqf, arqp, arqsan, arqs, arqst, arqtmed
	string nome1, nome2
	string lixo1, lixo2

	int numer, interv
	string tip, model,meio
	
	bool ver1
	
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
	arqang = nome1//meio//"ANG_"//interv//"_"//numer//".fits"
	arqq = nome1//meio//"Q_"//interv//"_"//numer//".fits"
	arqu = nome1//meio//"U_"//interv//"_"//numer//".fits"
	arqs = nome1//"SIG_"//interv//"_"//numer//".fits"
	arqsan = nome1//"SIGAN_"//interv//"_"//numer//".fits"
	arqt = nome1//"TOT_"//interv//"_"//numer//".fits"

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

		arqp = "BIN_P.fits"
		arqf = "BIN_FP.fits"
		arqang = "BIN_ANG.fits"
		arqsan = "BIN_SIGAN.fits"
		arqq = "BIN_Q.fits"
		arqu = "BIN_U.fits"
		arqs = "BIN_S.fits"
		arqt = "BIN_TOT.fits"
	}





	
    	if (access (arqp)==no) {
		print ("")
		print ("ERROR: File ")
		print (arqp)
		print ("do not exist.")
		goto fim
	}


	sarith (input1 = arqp, op = "copy", input2 = "", output = "tmp$"//arqp, 
		w1 = lbdmin, w2 = lbdmax, apertures = "", beams = "", apmodulus = 0,
		reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	arqp = "tmp$"//arqp

	sarith (input1 = arqang, op = "copy", input2 = "", output = "tmp$"//arqang, 
		w1 = lbdmin, w2 = lbdmax, apertures = "", beams = "", apmodulus = 0,
		reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	arqang = "tmp$"//arqang

	sarith (input1 = arqq, op = "copy", input2 = "", output = "tmp$"//arqq, 
		w1 = lbdmin, w2 = lbdmax, apertures = "", beams = "", apmodulus = 0,
		reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	arqq = "tmp$"//arqq
	
	sarith (input1 = arqu, op = "copy", input2 = "", output = "tmp$"//arqu, 
		w1 = lbdmin, w2 = lbdmax, apertures = "", beams = "", apmodulus = 0,
		reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	arqu = "tmp$"//arqu

	sarith (input1 = arqs, op = "copy", input2 = "", output = "tmp$"//arqs, 
		w1 = lbdmin, w2 = lbdmax, apertures = "", beams = "", apmodulus = 0,
		reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	arqs = "tmp$"//arqs

	sarith (input1 = arqsan, op = "copy", input2 = "", output = "tmp$"//arqsan, 
		w1 = lbdmin, w2 = lbdmax, apertures = "", beams = "", apmodulus = 0,
		reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)

	arqsan = "tmp$"//arqsan

	
	imstatistics (images = arqp, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "tmp$temp1.txt")
	flist = "tmp$temp1.txt"
	lixo1 = fscan (flist, peff)
	delete ("tmp$temp1.txt", ver-)

	imstatistics (images = arqq, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "tmp$temp1.txt")
	flist = "tmp$temp1.txt"
	lixo1 = fscan (flist, qeff)
	delete ("tmp$temp1.txt", ver-)

	imstatistics (images = arqu, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "tmp$temp1.txt")
	flist = "tmp$temp1.txt"
	lixo1 = fscan (flist, ueff)
	delete ("tmp$temp1.txt", ver-)

	imstatistics (images = arqang, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "tmp$temp1.txt")
	flist = "tmp$temp1.txt"
	lixo1 = fscan (flist, angeff)
	delete ("tmp$temp1.txt", ver-)

	imstatistics (images = arqs, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "tmp$temp1.txt")
	flist = "tmp$temp1.txt"
	lixo1 = fscan (flist, seff)
	delete ("tmp$temp1.txt", ver-)

	imstatistics (images = arqsan, fields = "mean", lower = INDEF, upper = INDEF, binwidth = 0.1, format = no, >> "tmp$temp1.txt")
	flist = "tmp$temp1.txt"
	lixo1 = fscan (flist, sangeff)
	delete ("tmp$temp1.txt", ver-)

	print (" ")
	print ("Average Q: "//qeff)
	
	print (" ")
	print ("Average U: "//ueff)
			
	print (" ")
	print ("Average Sigma: "//seff)
		
	print (" ")
	print ("Average Polarization: "//peff)
	
	print (" ")
	print ("Average PA: "//angeff)
		
	print (" ")
	print ("Average PA sigma: "//sangeff)

	imdelete (arqp, verify = no, >& "dev$null")
	imdelete (arqq, verify = no, >& "dev$null")
	imdelete (arqu, verify = no, >& "dev$null")
	imdelete (arqs, verify = no, >& "dev$null")
	imdelete (arqsan, verify = no, >& "dev$null")
	imdelete (arqang, verify = no, >& "dev$null")
	
	flist = ""
	
fim:    print ("")

end

