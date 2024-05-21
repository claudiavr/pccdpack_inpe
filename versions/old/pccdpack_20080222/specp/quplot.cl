procedure quplot (type,interval,number)

string    type="objeto"    {enum="objeto|padpol|npol|flat", prompt="Object Type"}
int   interval=1           {min=1, prompt='Binning Interval'}
int     number=16	   {min=4, max=16, prompt="Number of Waveplate Positions"}
real    lbdmin=INDEF       {prompt = "Minimum Wavelength"}
real    lbdmax=INDEF       {prompt = "Maximum Wavelength"}
string corflat="no"        {enum="yes|no",prompt="Correct for the Lambda Dependence of Theta?"}
string   coreq="no"        {enum="yes|no",prompt="Apply Equatorial Correction?"}
string   retar="no"        {enum="yes|no",prompt="Apply Retardance Correction?"}
string   instr="no"        {enum="yes|no",prompt="Correct for Instrumental Polarization?"}
string   inter="no"        {enum="yes|no",prompt="Correct for Interstellar Polarization?"}
pset   axispar             {prompt="axispar file (:e)"}
string binsigma="no"       {enum="yes|no",prompt="Bin the polarization for a given sigma?"}
real    perror=0.5	   {min=0,max=100,prompt='Bin Error (%)'}
bool    qufile="yes"       {prompt="save quplot file?"}

struct *flist

begin

	real qeff, ueff, seff, angeff, sangeff, peff, ll, qq, uu

	string arqp, arqq, arqu, arqsan, arqs, arqang, arqt, arqf
	string nome1, nome2
	string lixo
	string temp100, temp101, temp102, temp103

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
	
    	if (access (arqp)==no) {
		print ("")
		print ("ERROR: File ")
		print (arqp)
		print ("do not exist.")
		goto fim
	}
#BINA
	if (binsigma == "yes") {

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



        temp100 = mktemp("tmp$qugraph")
	temp101 = mktemp("tmp$qugraph")
        temp102 = mktemp("tmp$qugraph")
	temp103 = mktemp("tmp$qugraph")
	listpix(arqq, wcs="world", >> temp100)
	listpix(arqu, wcs="world", >> temp101)

        unlearn tcalc
	tcalc(temp100,"$3","if $1 > "//lbdmin//" && $1 < "//lbdmax//" then $1 else 0.")
        tcalc(temp100,"$4","if $1 > "//lbdmin//" && $1 < "//lbdmax//" then $2 else 0.")
        tcalc(temp101,"$3","if $1 > "//lbdmin//" && $1 < "//lbdmax//" then $1 else 0.")
        tcalc(temp101,"$4","if $1 > "//lbdmin//" && $1 < "//lbdmax//" then $2 else 0.")


	unlearn filecalc
	filecalc(temp100//","//temp101,"$3@1;$4@1;$4@2",>>temp102)

	flist = temp102
            while (fscan (flist, line) != EOF) {
            lixo = fscan(line, ll, qq, uu)
	    if (qq != 0. && uu != 0.) print(qq,uu,ll, >>temp103)
	}

	unlearn tstat

	print("Q")
	tstat(temp103,1)
	print("")
	print("U")
	tstat(temp103,2)



	unlearn sgraph
	#unlearn axispar
        axispar.xlabel = "Q"
	axispar.ylabel = "U"
        sgraph(temp103)

	delete (temp100,ver-)
        delete (temp101,ver-)
        delete (temp102,ver-)
        if (qufile==yes) {
	    if (access("quplot.log")) delete ("quplot.log",ver-)
	    copy(temp103,"quplot.log")
	}
	delete (temp103,ver-)


	if (binsigma == "yes") {
		imdelete("BIN_P.fits,BIN_FP.fits,BIN_ANG.fits,BIN_SIGAN.fits,BIN_Q.fits,BIN_U.fits,BIN_S.fits,BIN_TOT.fits",verify = no, >& "dev$null")
	}



	flist = ""
	
fim:    print ("")

end

