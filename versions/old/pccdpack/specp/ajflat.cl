procedure ajflat (interval, number, outim)
int interval=1        {min=1, prompt='Binning Interval (Points)'}
int    number=16	{min=4, max=16, prompt="Number of Waveplate Positions"}
string function="legendre" {prompt="Function Type"}
int order="4"	{prompt="Function Order"}
string outim="FLAT.fits" {prompt="Output Image"}
real lbdmin=INDEF {prompt = "Minimum Wavelength of Fitting Interval"}
real lbdmax=INDEF {prompt = "Maximum Wavelength of Fitting Interval"}
string modify="no" {enum="yes|no",prompt="Modify Lambda Interval and/or Dispersion?"}
string refspectrum="" {prompt="Reference spectrum"}
struct *flist1  
#struct flist3 {length=160}


begin

	
	int interv, numer
	
	string s1, dir
	string arq1, arq2, arq3, arqf,arqf2
	string line1
	string nome
	string lixo1
	
	bool ver, ver1
	
	real r1, r2
	
	real coef[10]
	


	limpa
	
	interv = interval
	numer = number
	
	ver1 = access("tmp$")
	
	if (ver1 == no)
		mkdir ("tmp$")
		
	arqf = "FLAT_00000_ANG_"//interv//"_"//numer//".fits"
	arqf2 = "tmp$"//arqf
	
    	if (access (arqf)) {
	}
	else {
		print ("")
		print ("ERROR: File ")
		print (arqf)
		print ("do not exist.")
		goto fim
	}
	if (modify=="yes") {	
    	if (access (refspectrum)) {
	}
	else {
		print ("")
		print ("ERROR: File with the reference spectrum: ")
		print (refspectrum)
		print ("do not exist.")
		goto fim
	}
	}
	

	sarith (input1 = arqf, op = "copy", input2 = "", output = arqf2, w1 = lbdmin,
		w2 = lbdmax, apertures = "", beams = "", apmodulus = 0,reverse = no,
		ignoreaps = yes, format = "multispec", renumber = no, offset = 0,
		clobber = no, merge = no, rebin = yes, errval = 0, verbose = no)
	
	
# AJUSTE DA CURVA
	
	arq1 = "tmp$TEMP_1.out"
	
	unlearn gfit1d
	gfit1d (input=arqf2, output=arq1, functio=function,order=order)
	
	
# Escreve arquivo de saida

	if (modify=="yes") {
		s1 = refspectrum
	} else {
		s1 = arqf
	}

    	imdelete (outim, ver-, >& "dev$null")
	
	unlearn function
	function (input1=s1,input2=arq1,output=outim,row=1)
	
    	delete (arq1, ver-, >& "dev$null")
	
   	dir = "dir.txt"
    	flist1 = dir
    	pathnames (template = "", sort = yes, >> dir)
    	lixo1 = fscan (flist1, dir)

	calcpol.ffile = dir//outim

    	delete ("dir.txt", ver-, >& "dev$null")


fim:    print ("")
	
end


