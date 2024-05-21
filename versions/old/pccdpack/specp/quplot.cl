## ver. mar/07

procedure quplot (type,interval,number)

string    type="objeto"    {enum="objeto|padpol|npol|flat", prompt="Object Type"}
int       interval=1           {min=1, prompt='Binning Interval'}
int       number=16	   {min=4, max=16, prompt="Number of Waveplate Positions"}
real      lbdmin=INDEF       {prompt = "Minimum Wavelength"}
real      lbdmax=INDEF       {prompt = "Maximum Wavelength"}
string    corflat="no"        {enum="yes|no",prompt="Correct for the Lambda Dependence of Theta?"}
string    coreq="no"        {enum="yes|no",prompt="Apply Equatorial Correction?"}
string    retar="no"        {enum="yes|no",prompt="Apply Retardance Correction?"}
string    instr="no"        {enum="yes|no",prompt="Correct for Instrumental Polarization?"}
string    inter="no"        {enum="yes|no",prompt="Correct for Interstellar Polarization?"}
pset      axispar             {prompt="axispar file (:e)"}
string    binsigma="no"       {enum="yes|no",prompt="Bin the polarization for a given sigma?"}
real      perror=0.5	   {min=0,max=100,prompt='Bin Error (%)'}
bool      avesec="no"        {prompt="average subsections (only with bin+)?"}
real      seca=INDEF
real      secb=INDEF
real      secc=INDEF
real      secd=INDEF
bool      qufile="yes"       {prompt="save quplot file?"}

struct *flist

begin

	real qeff, ueff, seff, angeff, sangeff, peff, ll, qq, uu
        real mean_qa, stddev_qa, mean_ua, stddev_ua
	real mean_qb, stddev_qb, mean_ub, stddev_ub
	real mean_qc, stddev_qc, mean_uc, stddev_uc
	real mean_qd, stddev_qd, mean_ud, stddev_ud
	real mean_qe, stddev_qe, mean_ue, stddev_ue
	real c1, c2, ec1, ec2, theta_int1, theta_int2, qql, uul
	real llseci, qqseci, uuseci, llsecf, llmeansec
	real qqseci_ante, uuseci_ante, llseci_ante, llsecf_ante
	real qq2, uu2, ll2, qq3, uu3, ll3
	real error_theta_int


	string arqp, arqq, arqu, arqsan, arqs, arqang, arqt, arqf
	string nome1, nome2
	string lixo
	string temp100, temp101, temp102, temp103
	string temp104, temp105, temp106, temp107
	string temp108, temp109, temp200, temp201
	string temp204, temp205, temp206, temp207
        string aa,bb,cc,dd,ee,ff,gg,hh,ii,jj,kk,llo, linedata1
	int numer, interv, nnll
	string tip, model,meio
	
	bool ver1
	
	tip = type
	interv = interval
	numer = number
		
	
	ver1 = access("tmp$")
	
	if (ver1 == no)
		mkdir ("tmp$")
		
	limpa
	delete ("tmp$qugraph*",ver-)

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
	arqf = ""
	arqang = nome1//meio//"ANG_"//interv//"_"//numer//".fits"
	arqsan = nome1//"SIGAN_"//interv//"_"//numer//".fits"
	arqq = nome1//meio//"Q_"//interv//"_"//numer//".fits"
	arqu = nome1//meio//"U_"//interv//"_"//numer//".fits"
	arqs = nome1//"SIG_"//interv//"_"//numer//".fits"
	arqt = ""


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
		arqang = "BIN_ANG.fits"
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
#       type(temp100)
#        copy(temp100, "temp100in")
#	type(temp101)


        unlearn tcalc
	tcalc(temp100,"$3","if $1 > "//lbdmin//" && $1 < "//lbdmax//" then $1 else 0.")
        tcalc(temp100,"$4","if $1 > "//lbdmin//" && $1 < "//lbdmax//" then $2 else 0.")
#	type(temp100)
#	copy(temp100, "temp100out")
        tcalc(temp101,"$3","if $1 > "//lbdmin//" && $1 < "//lbdmax//" then $1 else 0.")
        tcalc(temp101,"$4","if $1 > "//lbdmin//" && $1 < "//lbdmax//" then $2 else 0.")
#        type(temp101)


	unlearn filecalc
	filecalc(temp100//","//temp101,"$3@1;$4@1;$4@2",>>temp102)
#	copy(temp102,"temp102")


	flist = temp102
	    qqseci = 99999
	    uuseci = 99999
	    llseci = 99999
            llsecf = 99999
	    nnll = 0


        while (fscan (flist, line) != EOF) {

            lixo  = fscan(line, ll, qq, uu)

            if (binsigma == "yes") {
	    ## guarda valores iniciales de q e u no bin
	    ## guarda valores inciais e finais de lambda no bin e promedia

	        if (qq != 0. && uu != 0.) {

	            if (qq != qqseci && uu != uuseci) {
                        nnll = nnll + 1
		        if (nnll != 1) {
			    llmeansec = (llseci + llsecf)/2
#		            printf("%4.0f%9.5f%9.5f%9.2f%9.2f%9.2f\n",nnll,
#		            qqseci,uuseci,llseci,llsecf,llmeansec)
                            printf("%9.5f%9.5f%9.2f\n",
		            qqseci,uuseci,llmeansec, >> temp103)

		        }

	            llseci = ll
	            qqseci = qq
	            uuseci = uu

	            } else llsecf = ll

		##perdemos o ultimo bin !!

	        }

            } else if (qq != 0. && uu != 0.) print(qq,uu,ll, >>temp103)

        }


	unlearn tstat

        temp106 = mktemp("tmp$qugraph")
	print("Full Interval: ",lbdmin//" - "//lbdmax)
	tstat(temp103,1,>>temp106)
	printf("nbins: %9.0f\n",tstat.nrows)
	printf("Q    : %9.5f%9.5f\n",tstat.mean,tstat.stddev/sqrt(tstat.nrows))
	tstat(temp103,2,>>temp106)
        printf("U    : %9.5f%9.5f\n",tstat.mean,tstat.stddev/sqrt(tstat.nrows))

        if (avesec==yes) {



        temp104 = mktemp("tmp$qugraph")
	temp105 = mktemp("tmp$qugraph")
	temp109 = mktemp("tmp$qugraph")



	unlearn tcalc
        tcalc(temp103,"$4","if $3 > "//lbdmin//" && $3 <= "//seca//" then $1 else INDEF")
	tcalc(temp103,"$5","if $3 > "//lbdmin//" && $3 <= "//seca//" then $2 else INDEF")
	tstat(temp103,4,>>temp106)
	mean_qa   = tstat.mean
	if (tstat.nrows != 1) stddev_qa = tstat.stddev/sqrt(tstat.nrows)
	else stddev_qa = perror/1e2
	tstat(temp103,5,>>temp106)
	mean_ua   = tstat.mean
	if (tstat.nrows != 1) stddev_ua = tstat.stddev/sqrt(tstat.nrows)
	else stddev_ua = perror/1e2
	print("")
	print("Sec. A: ",lbdmin//" - "//seca)

	printf("nbins  : %9.0f\n",tstat.nrows)
	printf("Q_secA : %9.5f%9.5f\n",mean_qa,stddev_qa)
	printf("U_secA : %9.5f%9.5f\n",mean_ua,stddev_ua)
	print(mean_qa,mean_ua,stddev_qa,stddev_ua,>>temp104)
	temp204 = mktemp("tmp$qugraph")
	print(mean_qa,mean_ua,>>temp204)

        tcalc(temp103,"$6","if $3 > "//seca//" && $3 <= "//secb//" then $1 else INDEF")
	tcalc(temp103,"$7","if $3 > "//seca//" && $3 <= "//secb//" then $2 else INDEF")
	tstat(temp103,6,>>temp106)
	mean_qb   = tstat.mean
	if (tstat.nrows != 1) stddev_qb = tstat.stddev/sqrt(tstat.nrows)
	else stddev_qb = perror/1e2
	tstat(temp103,7,>>temp106)
	mean_ub   = tstat.mean
	if (tstat.nrows != 1) stddev_ub = tstat.stddev/sqrt(tstat.nrows)
	else stddev_ub = perror/1e2
	print("")
	print("Sec. B: ",seca//" - "//secb)
	printf("nbins  : %9.0f\n",tstat.nrows)
	printf("Q_secB : %9.5f%9.5f\n",mean_qb,stddev_qb)
	printf("U_secB : %9.5f%9.5f\n",mean_ub,stddev_ub)
	if (seca != secb) print(mean_qb,mean_ub,stddev_qb,stddev_ub,>>temp104)
	temp205 = mktemp("tmp$qugraph")
	print(mean_qb,mean_ub,>>temp205)



	tcalc(temp103,"$8","if $3 > "//secb//" && $3 <= "//secc//" then $1 else 0.")
	tcalc(temp103,"$9","if $3 > "//secb//" && $3 <= "//secc//" then $2 else 0.")

	unlearn filecalc
	filecalc(temp103,"$8;$9",>>temp105)

        qql = 9999
	uul = 9999

	## cuidado, quando binsigma- erro = perror (nao eh o caso)
	flist = temp105
            while (fscan (flist, line) != EOF) {
            lixo = fscan(line, qq, uu)
	    if (qq != 0. && uu != 0.) {
	        print(qq,uu,perror/1e2,perror/1e2, >>temp104)
		if (qq != qql && uu != uul) print(qq,uu,perror/1e2,perror/1e2, >>temp109)
		qql = qq
		uul = uu
            }
	}
#	type(temp109)

	tstat(temp104,1,>>temp106)
	mean_qc   = tstat.mean
	if (tstat.nrows != 1) stddev_qc = tstat.stddev/sqrt(tstat.nrows)
	else stddev_qc = perror/1e2
	tstat(temp104,1,>>temp106)
	mean_uc   = tstat.mean
	if (tstat.nrows != 1) stddev_uc = tstat.stddev/sqrt(tstat.nrows)
	else stddev_uc = perror/1e2
	print("")
	print("Sec. C: ",secb//" - "//secc)
	printf("nbins  : %9.0f\n",tstat.nrows)
	printf("Q_secC : %9.5f%9.5f\n",mean_qc,stddev_qc)
	printf("U_secC : %9.5f%9.5f\n",mean_uc,stddev_uc)

	tcalc(temp103,"$10","if $3 > "//secc//" && $3 <= "//secd//" then $1 else INDEF")
	tcalc(temp103,"$11","if $3 > "//secc//" && $3 <= "//secd//" then $2 else INDEF")
	tstat(temp103,10,>>temp106)
	mean_qd   = tstat.mean
	if (tstat.nrows != 1) stddev_qd = tstat.stddev/sqrt(tstat.nrows)
	else stddev_qd = perror/1e2
	tstat(temp103,11,>>temp106)
	mean_ud   = tstat.mean
	if (tstat.nrows != 1) stddev_ud = tstat.stddev/sqrt(tstat.nrows)
	else stddev_ud = perror/1e2
	print("")
	print("Sec. D: ",secc//" - "//secd)
	printf("nbins  : %9.0f\n",tstat.nrows)
	printf("Q_secD : %9.5f%9.5f\n",mean_qd,stddev_qd)
	printf("U_secD : %9.5f%9.5f\n",mean_ud,stddev_ud)
	if (secc != secd) print(mean_qd,mean_ud,stddev_qd,stddev_ud,>>temp104)
	temp206 = mktemp("tmp$qugraph")
	print(mean_qd,mean_ud,>>temp206)

	tcalc(temp103,"$12","if $3 > "//secd//" && $3 < "//lbdmax//" then $1 else INDEF")
	tcalc(temp103,"$13","if $3 > "//secd//" && $3 < "//lbdmax//" then $2 else INDEF")
	tstat(temp103,12,>>temp106)
	mean_qe   = tstat.mean
	if (tstat.nrows != 1) stddev_qe = tstat.stddev/sqrt(tstat.nrows)
	else stddev_qe = perror/1e2
	tstat(temp103,13,>>temp106)
	mean_ue   = tstat.mean
	if (tstat.nrows != 1) stddev_ue = tstat.stddev/sqrt(tstat.nrows)
	else stddev_ue = perror/1e2
	print("")
	print("Sec. E: ",secd//" - "//lbdmax)
	printf("nbins  : %9.0f\n",tstat.nrows)
	printf("Q_secE : %9.5f%9.5f\n",mean_qe,stddev_qe)
	printf("U_secE : %9.5f%9.5f\n",mean_ue,stddev_ue)
	print(mean_qe,mean_ue,stddev_qe,stddev_ue,>>temp104)
	temp207 = mktemp("tmp$qugraph")
	print(mean_qe,mean_ue,>>temp207)

        unlearn dvpar
	dvpar.fill = no
	unlearn sgraph
        axispar.xlabel = "Q"
	axispar.ylabel = "U"
	axispar.title = " "
	axispar.sysid = no

	if (access("teste.mc")) delete("teste.mc",ver-)
	#type(temp104)
        sgraph(temp104,pointmode-)
	sgraph(temp104,pointmode-,>G "teste.mc")
	sgraph(temp109,pointmode+,marker="circle",szmarker=0.025,dvpar.append+)
	sgraph(temp109,pointmode+,marker="circle",szmarker=0.025,dvpar.append+,>>G "teste.mc")

        temp107 = mktemp("tmp$qugraph")
	filecalc(temp104,"$1;$2;$3",>>temp107)
	sgraph(temp107,pointmode-,errcol=3,erraxis=1,dvpar.append+)
	sgraph(temp107,pointmode-,errcol=3,erraxis=1,dvpar.append+,>>G "teste.mc")
        temp108 = mktemp("tmp$qugraph")
	filecalc(temp104,"$1;$2;$4",>>temp108)
	sgraph(temp108,pointmode-,errcol=3,erraxis=2,dvpar.append+)
	sgraph(temp108,pointmode-,errcol=3,erraxis=2,dvpar.append+,>>G "teste.mc")


        ## sec_A
##	pltpar.crvcolor=5
##	pltpar.pattern="dashed"
	unlearn pltpar
	sgraph(temp204,pointmode+,marker="box",szmarker=0.025,dvpar.append+)
	sgraph(temp204,pointmode+,marker="box",szmarker=0.025,dvpar.append+,>>G "teste.mc")
	delete(temp204,ver-)
        ## sec_B
	sgraph(temp205,pointmode+,marker="box",szmarker=0.025,dvpar.append+)
	sgraph(temp205,pointmode+,marker="box",szmarker=0.025,dvpar.append+,>>G "teste.mc")
	delete(temp205,ver-)
        ## sec_D
	sgraph(temp206,pointmode+,marker="diamond",szmarker=0.025,dvpar.append+)
	sgraph(temp206,pointmode+,marker="diamond",szmarker=0.025,dvpar.append+,>>G "teste.mc")
	delete(temp206,ver-)
        ## sec_E
	sgraph(temp207,pointmode+,marker="diamond",szmarker=0.025,dvpar.append+)
	sgraph(temp207,pointmode+,marker="diamond",szmarker=0.025,dvpar.append+,>>G "teste.mc")
	delete(temp207,ver-)






	temp200 = mktemp("tmp$qugraph")
	temp201 = mktemp("tmp$qugraph")
	unlearn userpars
        userpars.function = "c1*x+c2"
	userpars.c1 = 1
	userpars.c2 = 1
	userpars.v1 = yes
	userpars.v2 = yes
        print("")
##	type(temp109)
	nfit1d(temp109,temp200,function="user",intera-)
	prfit(temp200,>>temp201)
	type(temp201//"")

	flist = temp201
        while (fscan (flist, line) != EOF) {
            linedata1 = fscan(line,aa,bb,cc,dd,ee,ff,gg,hh,ii,jj,kk,llo)
            if (substr(line,1,2) == "c1") {
	        c1  = real(substr(cc,1,strlen(cc)-1))
		ec1 = real(substr(dd,1,strlen(dd)-1))
	    }
	    if (substr(line,1,2) == "c2") c2 = real(substr(cc,1,strlen(cc)-1))
	}

	print("")
	printf("deltau/deltaq %8.4f\n",c1)
	print("")
	print("0.5*atan(deltau,deltaq)")

	theta_int1 = 0.5*atan(c1,1)*180/3.14159
	if (theta_int1 < 0) theta_int1 = theta_int1 + 180

	theta_int2 = 0.5*atan(-1*c1,-1)*180/3.14159
	if (theta_int2 < 0) theta_int2 = theta_int2 + 180

	## calculo do erro no theta_int
        error_theta_int = 0.5*atan(c1+ec1,1)*180/3.14159 -
	                  0.5*atan(c1-ec1,1)*180/3.14159

	if (c1 < 0) {
	    printf("%8.1f (deltau<0, deltaq>0)\n",theta_int1)
	    printf("%8.1f (deltau>0, deltaq<0)\n",theta_int2)
        }
	if (c1 > 0) {
	    printf("%8.1f (deltau>0, deltaq>0)\n",theta_int1)
	    printf("%8.1f (deltau<0, deltaq<0)\n",theta_int2)
        }

	## error_theta_int dividido por 2
        printf("%8.1f error\n", error_theta_int/2)

	delete(temp104,ver-)
        delete(temp105,ver-)
	delete(temp107,ver-)
	delete(temp108,ver-)
	delete(temp109,ver-)
	delete(temp200//".tab",ver-)
	delete(temp201,ver-)



	} else {


        unlearn dvpar
	unlearn sgraph
	#unlearn axispar
        axispar.xlabel = "Q"
	axispar.ylabel = "U"

        sgraph(temp103)

	}

	delete (temp100,ver-)
        delete (temp101,ver-)
        delete (temp102,ver-)
        if (qufile==yes) {
	    if (access("quplot.txt")) delete ("quplot.txt",ver-)
	    copy(temp103,"quplot.txt")
	}
	delete (temp103,ver-)
        delete (temp106,ver-)


	if (binsigma == "yes") {
		imdelete("BIN_P.fits,BIN_FP.fits,BIN_ANG.fits,BIN_SIGAN.fits,BIN_Q.fits,BIN_U.fits,BIN_S.fits,BIN_TOT.fits",verify = no, >& "dev$null")
	}


	flist = ""
	
fim:    print ("")

end

