#
# Task que imprime fotometria como funcao de HJD/Fase orbital
#
# Voce deve ter saida do phot_pol.cl
#
# Claudia V. Rodrigues - Maio/2003
# 
## Maio/2008
# opcao de converter ou nao de fluxo para magnitude
#
##### Junho/2008 - Karleyne e Claudia
#
#opção de mudar os limites de magnitude e de plotar no mesmo gráfico
# as curvas de luz de todas as estrelas para uma dada abertura
# Usar estrela = 0 e nao usar conversao para magnitude
#
## Outubro de 2010 - Claudia
# 
# testa se arquivo com HJD tem linhas consistentes com input luz file
#
# Setembro de 2016 - CVR
#   Alterado limite de imagens para 2000.
#   Incluido teste para limite acima.
#
########
#
procedure	plota_luz (arqpht)

string	arqpht		{"", prompt="Input *.luz file"}
string  tempo		{"hjd.lis", prompt="File with time input"}
int		star		{1,prompt="Number of star to plot the photometry"}
int 	aper		{1,prompt="Ordinal number of the aperture"}
bool	conecta		{no,prompt="Connect the points"}
bool	pontos		{yes ,prompt="Plot points"}
#bool	erros		{yes ,prompt="Plot errorbars"}
string  title		{"", prompt="Title of the graphics"}
bool	phase		{no, prompt="Convert HJD to orbital phase"}
real 	to			{0., prompt="To das efemerides"}
real	per			{0., prompt="Periodo (dias)"}
bool	convert_mag	{no, prompt="Convert input dat to magnitudes?"}
real    deltamag    {0., prompt="Calibrar?"}
bool	ffile		{no, prompt="Create hjd,mag file? Apply to star different from 0"}
string	mmagfile	{"", prompt="Name of the hjd,mag file"}
bool	eps    	    {no, prompt="Create eps file"}
bool    lim         {no, prompt="Change limits"}

struct  *flist

begin
	real tto,pper
	real tt = 0
	real t[2000],fase[2000]
	int i,j,n,inicio,fim,sstar,aaper,emin,emax,tipo,nl,ie,ne,npos,nstar
	string igifile,ttitle,aarqpht,tempofile,hjd,magfile,ymagfile
	bool cconecta,pphase,ppontos,eeps,nofirst,cont,conv_mag,limm
	bool arq
	real xmin,xmax,ymin,ymax,niv
#

	struct line,linedata
#	struct line,linedata,line2,linedata2
#
	limm=lim
    cconecta=conecta
#	eerros=erros
	ppontos=pontos
	ttitle=title
	aarqpht=arqpht
	eeps=eps
	pphase=phase
	tto=to
	pper=per
	aaper=aper
	sstar=star
	arq=ffile
	magfile=mmagfile
	conv_mag=convert_mag
    tipo=3
    niv=deltamag          
#
	cont=yes
	nofirst=no
#
	igifile = "igi_in"
	tempofile="ttfile"
	ymagfile="ymagfile"
    delete(tempofile,ver-)
    delete(ymagfile,ver-)
    delete("dlist.lllixo*",ver-)
    delete("lllixo*",ver-)
    if (arq) 
	    delete(magfile,ver-)
#
# 	Lendo arquivo de entrada com tempos
#
	flist=tempo
	i=1
        while (fscan(flist, line) != EOF) {
         linedata=fscan(line,tt)
         t[i]=tt
         i=i+1
	}
	n=i-1
	if (n > 2000) {
	  print(" ")
      print("  Number of images larger than 2000! ")
	  print(" ")
	  goto erro
	}
#
# ####
#       Descobrindo o numero de estrelas (ne) e posicoes da lamina (npos)
#       do arquivo *.luz
#
    flist=aarqpht
#	
    npos=0
    while (fscan(flist, line) != EOF) {
    	linedata=fscan(line,ne)
		npos=npos+1
    }
	npos=(npos-(ne+3)*2)/(ne+1)-3
	if (npos != n) {
	  	  print(" ")
          print("  Numero de posicao da lamina no pht: ",npos)
          print("  Numero de posicao da lamina no lis: ",n)
          print("  Numeros acima sao inconsistentes!")
	  	  print(" ")
	      goto erro
	}
#         
########################################################	
# 
# Se plota HJD, pega parte fracionario;
# se plota fase orbital, calcula a dita cuja
#
# corrigindo: tempo eh igual media do tempo da primeira imagem e
# da ultima imagem
#
	if (pphase) {
 	  for (j=1; j <= n; j+=1) {
 	   fase[j]=t[j]-tto
	   fase[j]=fase[j]/pper
#           print (fase[j])
	   fase[j]=mod(fase[j],1)
	   if (fase[j]<0) fase[j]=fase[j]+1.
	   print (fase[j], >> tempofile)
	   xmin=0.
	   xmax=1.
	  }
	}
	else {
          hjd=str(int(t[1]))
 	      for (j=1; j <= n; j+=1) {
            t[j]=t[j]-int(t[j])
#           print (t[j])
	        print (t[j], >> tempofile )
	        xmin=t[1]
	        xmax=t[n]
          }
 	}
#
# Entrando no loop de display
#
#
	while (cont) {
     	  delete(igifile,ver-)
	  if (nofirst) {
	   print("Type: #star #apertura. Star 0 means sum of all stars.")
	   scan(sstar, aaper)
           } # fecha if (nofirst)
	   else 
	    nofirst=yes
	  aaper=aaper+1
#
          if (sstar == 0) {
#
#Plotando no mesmo gráfico todas as curvas de luz
#
	     nstar=0
             print(" ")
             print("Type Ymin Ymax")
             print("Choose numbers that define the correct range.")
             scan(ymin, ymax)
	     emin=1
         emax=ne
	     print ("erase", >> igifile)
         print ("window 1 1 1", >> igifile)
  	     print ("ptype 12 3", >> igifile)
         print ("limits "//xmin//" "//xmax//" "//ymin//" "//ymax, >> igifile)
	     print ("margin 0.05", >> igifile)
         print ("data "//tempofile, >> igifile)
         print ("xcolumn 1", >> igifile)
         print ("title "//ttitle//" - Apert: "//aaper-1, >>igifile)
         if (pphase)
               print ("xlabel Orbital phase", >> igifile)
               else
               print ("xlabel HJD - "//hjd,>> igifile)
         if (conv_mag) {
		     print ("yflip; box", >> igifile)
	         print ("ylabel \gD(mag)", >> igifile)
		 } 
		 else {
  		 print ("box", >> igifile)
	          print ("ylabel Relative Flux", >> igifile)
	     }
         for (ie=emin; ie<= emax; ie +=1) {
	       nstar=nstar+1
           inicio=1+(ie-1)*n
	       fim=n+(ie-1)*n
           print ("data "//aarqpht, >> igifile)
           print ("lines "//inicio//" "//fim, >> igifile)
           print ("ycolumn "//aaper, >> igifile)
           if (conv_mag) {
                 print ("yevaluate -2.5*log10(y)+"//niv , >> igifile)
       	         print ("ylabel \gD(mag)", >> igifile)
		   } 
		   else {
	          print ("ylabel Relative Flux", >> igifile)
	       }
           if (ppontos) {
                 print ("expand 0.3", >> igifile)
                 print ("points ", >> igifile)
                 print ("expand 1.0", >> igifile)
           }
           if (cconecta)
                print ("connect", >> igifile)
#
#
	       delete("igi_tmp",ver-)
     	   delete("dlist.lllixo",ver-)
     	   delete("lllixo.*",ver-)
           print ("data "//aarqpht, >> "igi_tmp")
           print ("lines "//inicio//" "//fim, >> "igi_tmp")
           print ("xcolumn "//aaper, >> "igi_tmp")
           if (conv_mag) 
	       print ("xevaluate -2.5*log10(x) + "//niv, >> "igi_tmp")
	       print ("dlist dlist.lllixo", >> "igi_tmp")
	       print ("end", >> "igi_tmp")
	       igi < "igi_tmp"
     	   print("  ")
     	   print(" Estrela: ",nstar, "Abertura: ",(aaper-1))
     	   print("   Average          Sigma           N")
	       columns("dlist.lllixo",2,outroot="lllixo.")
	       average < "lllixo.2"    
#
        } #fechando o for
	    } # fechando o if compara
	else { # se eh uma estrela so a ser plotada
#
# *** ROTINA PARA UMA ESTRELA SO **********
#
# calculando parametros de entrada do IGI
#       
	inicio=1+(sstar-1)*n
	fim=n+(sstar-1)*n
#	
#
# colocando comandos no arquivo de entrada do IGI
#
	print ("erase", >> igifile)
	print ("ptype 7 3", >> igifile)
    print ("data "//tempofile, >> igifile)
    print ("xcolumn 1", >> igifile)
    print ("data "//aarqpht, >> igifile)
    print ("lines "//inicio//" "//fim, >> igifile
    print ("window 1 1 1", >> igifile)
    print ("ycolumn "//aaper, >> igifile)
    if (conv_mag)
		print ("yevaluate -2.5*log10(y)+"//niv, >> igifile)
  	delete("dlist.lllixo",ver-)
	print ("dlist dlist.lllixo", >> igifile)
    print(" ")
#     
#Mudando o limite de y
#   
        if (limm) {
           print("Digite #y1 #y2")
           scan(ymin, ymax)
           print ("limits "//xmin//" "//xmax//" "//ymin//" "//ymax, >> igifile)
           }
	   else
           print ("limits ",>> igifile)
	print ("margin 0.05", >> igifile)
        if (conv_mag) {
	        print ("yflip; box", >> igifile)
	        print ("ylabel \gD(mag)", >> igifile)
		} 
		else {
	        print ("box", >> igifile)
	        print ("ylabel Relative flux", >> igifile)
		}		
        if (pphase)
           print ("xlabel Orbital phase", >> igifile)
           else
           print ("xlabel HJD - "//hjd,>> igifile)

        if (ppontos) {
          print ("expand 0.5", >> igifile)
          print ("points", >> igifile)
          print ("expand 1.0", >> igifile)
        }
        if (cconecta)
          print ("connect", >> igifile)
        print ("title "//ttitle//" - Estrela: "//sstar//" - Apert: "//aaper-1, >>igifile)  
        print ("end", >>igifile)
	} # final do else do if compara
#     
#     
     	unlearn igi 
     	igi < igi_in
	print(" ")  
    delete("lllixo*",ver-)
	if (sstar != 0) {
     	  print(" Estrela: ",sstar, "Abertura: ",(aaper-1))
     	  print("   Average          Sigma           N")
	      columns("dlist.lllixo",3,outroot="lllixo.")
	      average < "lllixo.3"    
	      if (arq) {
	        delete(magfile,ver-)
	        joinlines(tempo,"lllixo.3",out=magfile)
	      }
     	  delete("dlist.lllixo",ver-)
     	  delete("lllixo.3",ver-)
	}
#
#
#
# criando metacode file
#
	if (eeps) {
          delete(aarqpht//".mc")  
          igi <igi_in, >G aarqpht//".mc"
          delete(aarqpht//".eps",ver-)
          stdplot(aarqpht//".mc",device='epsl')
          sleep 1
          rename ("sgi*.eps",aarqpht//".eps",field="all")
          delete(aarqpht//".mc",ver-)
          }
        #
        #
        print("Continua? Sim [y]; Nao [n]")
        scan (cont)
    } # fecha o while (cont)
    delete(igifile,ver-)
    delete(tempofile,ver-)
    delete("dlist.lllixo",ver-)
    delete("lllixo.*",ver-)
    delete("lixo.lixo",ver-)
	delete("igi_tmp",ver-)
	goto final
erro:
	print("   ERRO   ")
final:
	print("  ")
end
