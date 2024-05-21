procedure corflat (tipo, intervalo, numero, arquivo)

string tipo="objeto" {enum="objeto|padpol|npol|flat", prompt="Tipo de imagem"}
int intervalo=30        {min=1, prompt='Intervalo usado na "binagem"'}
int    numero=16	{min=4, max=16, prompt="Numero de posicoes da lamina"}
string arquivo = ""	{prompt="Arquivo do ang. de pol. do Pflat (caminho comp.)"}
string filtro = "/users/alex/iraf/V.fil" {prompt="Arquivo com os dados do filtro"}
struct *flist1  



begin

	
	int interv, numer
	string tip, filt
	
	string s1, s2, s3, s4, s5
	string arq1, arq2, arq3, arqf
	string arqq, arqu, arqp, arqan
	string novoq, novou, novoan
	string dir
	string lixo1
	
	bool ver1
	
	real lmin, lmax, lmeio, ang
	
	string nome, nome2
	
	string conta
	
	
	
	interv = intervalo
	numer = numero
	tip = tipo
	arqf = arquivo
	
	
    	dir = "dir.txt"
    	flist1 = dir
    	pathnames (template = "", sort = yes, >> dir)
    	lixo1 = fscan (flist1, dir)
    	
    	
	ver1 = access("home$/tmp")
	
	if (ver1 == no)
		mkdir ("home$tmp/")
		
	chdir ("home$tmp/")
    	
    	
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
	arqp = nome//"P_"//interv//"_"//numer//".imh"
	arqan = nome//"ANG_"//interv//"_"//numer//".imh"
	
	
	imcopy (input=dir//arqp, output = arqp, verbose = no)
	imcopy (input=dir//arqan, output = arqan, verbose = no)
	
   		

	# DETERMINACAO DO ANGULO NO MEIO DO ESPECTRO e CORRECAO DO ANGULO

	
	listpix (arqf, >> "TEMP_1.txt") # Determina extremos de Compr. de Onda

	flist1 = "TEMP_1.txt"
	
	lixo1 = fscan (flist1, lmin)
	
	while (fscan (flist1, lmax) != EOF) {
	}
	
	delete ("TEMP_1.txt", ver-)
	
	lmeio = (lmin + lmax) / 2
	
	arq1 = "TEMP_1.txt"
	arq2 = "TEMP_2.txt"
		
	print (lmeio, " 1 1 C", >> arq1)
	
	unlearn splot 			#tirar isso...
	
	splot (images = arqf, line = 1, band = 1, star_name = "", 
		next_image = "",
		new_image = "", overwrite = yes, cursor = arq1,
		>> arq2, >G "dev$null")

	delete (arq1, >& "dev$null", ver-)

	flist1 = arq2
	
	lixo1 = fscan (flist1, s1, s2, s3, ang)
	delete (arq2, >& "dev$null", ver-)
	
	arq3 = "input.txt"
	print (arqf, >> arq3)
	print (arqan, >> arq3)
	
	conta = "im2-(im1-"//ang//")"

	print ("")
	print ("Gravar arquivo "//arqan//" corrigido sobre o arquivo original? (y/n): "
	scan (ver1)
	
	if (ver1 == yes) {
		imdelete (dir//arqan, verify = no, >& "dev$null")
		novoan = arqan
		}
	    else {
	    	print ("")
	    	print ("Digite nome do arquivo: ")
	    	scan (novoan)
	    }
	
	imcalc (input="@input.txt", output=dir//novoan, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")

	delete (arq3, >& "dev$null", ver-)
	imdelete (arqan, verify = no, >& "dev$null")
	
	# CALCULO DE Q CORRIGIDO
	
	arq3 = "input.txt"
	print (arqp, >> arq3)
	print (dir//novoan, >> arq3)
	
	conta = "im1*cos(2*(-im2+180)*3.14159265/180)"

	print ("")
	print ("Gravar arquivo "//arqq//" corrigido sobre o arquivo original? (y/n): "
	scan (ver1)
	
	if (ver1 == yes) {
		imdelete (dir//arqq, verify = no, >& "dev$null")
		novoq = arqq
		}
	    else {
	    	print ("")
	    	print ("Digite nome do arquivo: ")
	    	scan (novoq)
	    }
	
	imcalc (input="@input.txt", output=dir//novoq, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")

	delete (arq3, >& "dev$null", ver-)
	imdelete (arqq, verify = no, >& "dev$null")

	# CALCULO DE U CORRIGIDO
	
	arq3 = "input.txt"
	print (arqp, >> arq3)
	print (dir//novoan, >> arq3)
	
	conta = "im1*sin(2*(-im2+180)*3.14159265/180)"

	print ("")
	print ("Gravar arquivo "//arqu//" corrigido sobre o arquivo original? (y/n): "
	scan (ver1)
	
	if (ver1 == yes) {
		imdelete (dir//arqu, verify = no, >& "dev$null")
		novou = arqu
		}
	    else {
	    	print ("")
	    	print ("Digite nome do arquivo: ")
	    	scan (novou)
	    }
	
	imcalc (input="@input.txt", output=dir//novou, equals=conta,
		pixtype="old", nullval = 0., verbose = no, mode="al")

	delete (arq3, >& "dev$null", ver-)
	imdelete (arqu, verify = no, >& "dev$null")
	imdelete (arqp, verify = no, >& "dev$null")
	
	
	back (>& "dev$null")	
	delete ("dir.txt", ver-)
	
	print (" ")
	flist1 = ""

end

