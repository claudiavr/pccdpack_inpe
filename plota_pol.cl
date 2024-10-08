#
# Task que faz grafico de polarizacao como funcao de HJD/Fase orbital
#
#################################################
# Claudia V. Rodrigues - Maio/2003
# 
# Atualizado em Set/2004 - CVR
#
# Outubro/2006 - Adaptado para ler *.out do macrol
#
# Fevereiro/2007 - Modificado para desconsiderar pontos que envolvem
# tempos grandes intervalos no HJD
#
# Outubro/2009 - incluido como opcao valores minimos e maximos do
# eixo de polarizacao circular
#
# Dezembro/2009 - verifica se numero de linhas dos dois arquivos sao consistentes
#
# Fevereiro/2011 - calcula a média e o desvio padrão dos valores de polarizacao circular
#
# Agosto/2014 - CVR - Modificacoes
#	* a media de V utiliza apenas os valores que sao plotados em funcao da opcao
#		redund = yes or no e tambem em funcao de plotar ou nao pontos que incluem
#		intervalos em tempo
#	* incluida opcao para escolha do intervalo maximo entre imagens para que ponto 
#		de polarizacao seja plotado
#	* tinha tambem um erro na parte do plot. Os pontos plotados eram 8, 16, etc.
#				  e nao 1, 9, 17, etc...
# 	* modificada logica para retirar pontos redundantes. Na atual versao, se
#		redund=no, sao plotados os pontos
#			1, 9, 17, ... se dat = 8
#			1, 17, 33 ... se dat = 16
#			se algum desses pontos eh calculado serie de imagem com grande intervalo
#			de tempo entre elas, tambem eh retirado do plot e do calculo da media
#	* incluida opcao de erro maximo em V
#
# Outubro/2015 - CVR - Modificacoes
#
# Incluida opcao de setar eixo Y da polarizacao linear.
#
##### - CVR - Janeiro/2016
# saida da polarizacao linear em arquivo txt tem tambem Q e U, como duas ultimas colunas. Lembrar que
# erro de Q e U sao iguais entre si e iguais a erro de P_linear. 
#
############################################################
#
procedure	plota_pl (macrol)

string	macrol		{"log.out", prompt="Input macrol file"}
string  tempo		{"hjd.lis", prompt="File with time input"}
bool	l2			{no,prompt="(Y) Half-wave data; (N) quarter-wave"}
bool	pl			{no,prompt="Plot linear polar, if l/4"}
int		datnumber	{8, prompt="Number of images in a datfile"}
bool	conecta		{no,prompt="Connect the points"}
bool	pontos		{yes ,prompt="Plot points"}
bool	erros		{yes ,prompt="Plot errorbars"}
bool	theta		{yes, prompt="Plot polarization angle"}
bool 	redund		{yes, prompt="Plot redundant data points"}
real	interval	{3., prompt="Maximum time interval between points relative to the mode"}
real 	maxerror	{100., prompt="Maximum error of circular polarization in percentage of plotted points"} 
string  title		{"", prompt="Title of the graphics"}
real	v_min		{0., prompt="Minimum value of the V axis (percentage)  "}
real	v_max		{1., prompt="Maximum value of the V axis (percentage)  "}
real	p_min		{0., prompt="Minimum value of the P axis (percentage)  "}
real	p_max		{1., prompt="Maximum value of the P axis (percentage)  "}
bool	phase		{no, prompt="Convert HJD to orbital phase"}
real 	to			{0., prompt="To das efemerides"}
real	per			{0., prompt="Periodo (dias)"}
bool	eps    	   	{no, prompt="Create eps file"}
string	arqout		{"", prompt="Phase, pol file, null to not create"}

struct  *flist
struct  *flist2

begin
	real lixo,pmin,pmax,emax,tto,pper,vmin,vmax,evmax,mmoda,npol,iinterval
	real mmaxerror
	real lixo4 = 0
	real tt = 0
	real t1 = 0
	real t2 = 0
	real t3 = 0
	real t4 = 0
	real t5 = 0
	real t[2000],tn[2000],p[2000],ep[2000],et[2000],fase[2000]
	real v[2000],ev[2000],hhjd[2000],tttheta[2000],dif[2000],vmed,evmed
	real u,q,pa
	string igifile,ttitle,mmacrol,vtmpfile,ttempo,namev
	string tempofile,hjd,lixos,diffile,poldat,arqmed1,arqmed2
	bool cconecta,eerros,ppontos,ttheta,rredund,eeps
	bool pphase,ll2,ppl,plota[2000]
	struct line,linedata,line2,linedata2
	int i,j,n,ddat,min,lixo1,nmed
#
	cconecta=conecta
	eerros=erros
	ppontos=pontos
	ttitle=title
	mmacrol=macrol
	ddat=datnumber
	ttheta=theta
	rredund=redund
	eeps=eps
	pphase=phase
	tto=to
	pper=per
	ll2=l2
	ppl=pl
	iinterval=interval
	mmaxerror=maxerror
#	print (tto)
#
	igifile = 'igi_in'
	tempofile=mktemp('/tmp/tmptempo')
	diffile=mktemp('/tmp/tmpdif')
	poldat = mktemp('/tmp/tmppol')
#	poldat = 'testepol'
#
##############################################
# deleta versao anterior de arquivo de entrada 
#
     	if (access(igifile)) delete(igifile,ver-)
     	if (access(tempofile)) delete(tempofile,ver-)
     	if (access(diffile)) delete(diffile,ver-)
        if (access("dlist.lixo")) delete("dlist.lixo",ver-)
	if (access(arqout)) delete(arqout,ver-)
	if (access("sgi*.eps")) delete("sgi*.eps",ver-)
#	unlearn(rename)
#
#################################################
# 	Lendo arquivo de entrada com tempos
#
	flist=tempo
	i=1
        while (fscan(flist, line) != EOF) {
         linedata=fscan(line,tt)
         t[i]=tt
	 if (i > 1) {
	   dif[i-1]=t[i]-t[i-1]
           plota[i-1]=yes
	   print (dif[i-1], >> diffile)
#          print ((i-1),plota[i-1],dif[i-1])
         }
         i=i+1
	}
	n=i-ddat
	if (n > 2000) {
	  print(" ")
      print("  Number of images larger than 2000! ")
	  print(" ")
	  goto erro
	}	
#
############################################
# 
# Esta parte faz tres selecoes de pontos a serem considerados
# 1 -
# Quando o HJD da um salto, marcar os pontos
# que incluem o salto para nao incluir no grafico, medias, etc...
# 2-
# Se opcao redund=no, seleciona apenas pontos sem redundancia:
# 1, 9, 17, se datnumber=8 OU
# 1, 17, 33, se datnumber=16
# 3-
# se erro de v > maxerror, nao plota ponto
#
       moda(texto=diffile,coluna=1,grafico=no,verbose=no)
       mmoda=moda.value
       mmoda=iinterval*mmoda
       if (access(diffile)) delete(diffile,ver-)
       i = 1
       while (i <= n) {
       if (rredund == no)
       		 if ((frac((real(i-1)/ddat))) != 0) plota[i]=no
	   if (dif[i] > mmoda) {
            if (i < (ddat-2) ) 
		       min=1 
		       else
		         min=i-ddat+2
                 for (j=min; j<= i; j+=1) {
		            plota[j]=no
                 } 
            }
	   i=i+1
       }
       for (i=1; i<=n; i+=1) {
	   print (i,plota[i], >> diffile)
       }	  
#
###############################
##############################
# Se plota HJD, pega parte fracioanario;
# se plota fase orbital, calcula a dita cuja
#
# corrigindo: tempo eh igual media do tempo da primeira imagem e
# da ultima imagem
#
# o arquivo tempofile so pode ser criado apos a verificacao do valor de ev
#
	if (pphase) {
 	  for (j=1; j <= n; j+=1) {
 	   fase[j]=t[j]-tto
	   fase[j]=fase[j]/pper
	   if (fase[j]< 0.) {
	        print(mod(fase[j],1))
	   	fase[j]=fase[j]-(int(fase[j])-1)
   	        print (fase[j])
#	   	print(int(fase[j]))
	   }
	   fase[j]=mod(fase[j],1)
#	   print (fase[j])
# 	   print ("oi")
#	   if (plota[j]) print (fase[j], >> tempofile)
	  }
	 }
	 else {
          hjd=str(int(t[1]))
 	  for (j=1; j <= n; j+=1) {
   	   tn[j]=(t[j]+t[j+ddat-1])/2 
           hhjd[j]=tn[j]
           tn[j]=tn[j]-int(tn[j])
#	   if (plota[j]) print (tn[j], >> tempofile )
          }
         }
         t[1]=tn[1]
         t[n]=tn[n]
#	 print (t[1],t[n])
# 
####################################################	
# 	Lendo arquivo de entrada com polarizacao e theta
#
	flist2=mmacrol
	i=1
 #
 	if (ll2) {
	 lixos=fscan(flist2,line2)
         while (fscan(flist2,line2) != EOF) {
          linedata2=fscan(line2,lixo,lixo,t2,t1,t5)
          p[i]=t1
          ep[i]=t2
          if (p[i] != 0.) 
           et[i]=ep[i]/p[i]*28.6479
           else
           et[i]=180.
          u=t5*atan2(1,0)/45.
          q=100.*p[i]*cos(u)
          u=100.*p[i]*sin(u)
          if (plota[i]) print (hhjd[i],100.*p[i],100.*ep[i],t5,et[i],q,u, >> poldat)
		  #print, 100.*p[i],sqrt(q*q+u*u)
		  #print, t5,0.5*atan(u,q)
		  #print, ' '
          i=i+1
   	 }
   	 }
	 else 
	 arqmed1 = mktemp('/tmp/medpol1')
	 arqmed2 = mktemp('/tmp/medpol2')
	 lixos=fscan(flist2,line2)
         while (fscan(flist2,line2) != EOF) {
#          linedata2=fscan(line2,lixos,t3,t4,lixo,lixo,t2,t1,t5)
          linedata2=fscan(line2,t3,t4,lixo,lixo,t2,t1,t5)
          v[i]=t3
          ev[i]=t4
          p[i]=t1
          ep[i]=t2
          if (p[i] != 0.) 
           et[i]=ep[i]/p[i]*28.6479
           else
           et[i]=180.
#	        print (hhjd[i],100.*v[i],100.*ev[i],100.*p[i],100.*ep[i],t5,et[i])
#           print (plota[i]
          if (ev[i]*100. > mmaxerror) {
          		plota[i]=no
          }
          if (plota[i]) {
            u=t5*atan2(1,0)/45.
            q=100.*p[i]*cos(u)
            u=100.*p[i]*sin(u)
          	print (hhjd[i],100.*v[i],100.*ev[i],100.*p[i],100.*ep[i],t5,et[i],q,u, >> poldat)
          	print (100.*v[i], >> arqmed1)
          	print (100.*ev[i], >> arqmed2)
#		    print, 100.*p[i],sqrt(q*q+u*u)
#		    print, 1.*t5, 0.5*atan(u,q)*180./3.14159
#		    print, ' '
          }
          i=i+1
	 }
         npol=i-1
         if (npol != n) {
	       print, 'Numeros de linhas dos arquivos *out e hjd.lis inconsistentes!'
           print (npol,n)
           return
         } 
#
##############################
# Cria tempofile
#
 	for (j=1; j <= n; j+=1) {
	  if (pphase) {
	     if (plota[j]) print (fase[j], >> tempofile)
	   }
	   else {
	     if (plota[j]) print (tn[j], >> tempofile )
       }
    }
# 
####################################################	
# Calculando media de V 
#
    if (ll2 == no) {
	print, ' '
    print, '==== Valores em porcentagem ===='
    print, '[Media de V] e [Dispersao de V]    N'
	average (option="new_sample", < arqmed1)
	print, ' '
    print, '[Media de Sigma_V] e [Dispersao de Sigma_V]    N'
	average (option="new_sample", < arqmed2)
	print, ' '
    delete(arqmed1,ver-)
    delete(arqmed2,ver-)
    }
#
### final do calculo da media
#
	pmin=p[1]
	pmax=p[1]
	emax=ep[1]
	vmin=v[1]
	vmax=v[1]
	evmax=ev[1]
	for (j=2; j <= n; j+=1) {
	 pmin=min(pmin,p[j])
	 pmax=max(pmax,p[j])
	 emax=max(emax,ep[j])
	 if (ll2 == no) {
	  vmin=min(vmin,v[j])
	  vmax=max(vmax,v[j])
	  evmax=max(evmax,ev[j])
	 }
  	}
  	pmin=pmin-emax
  	pmax=pmax+emax
  	pmin=100.*pmin
  	pmax=pmax*100.
  	vmin=vmin-evmax
  	vmax=vmax+evmax
  	vmin=100.*vmin
  	vmax=vmax*100.
    if ((v_min != 0.) || (v_max != 1.)) {
           vmin=v_min
           vmax=v_max
	}
    if ((p_min != 0.) || (p_max != 1.)) {
           pmin=p_min
           pmax=p_max
	}
        print (pmin,pmax)
#
#
#        print (poldat)
#        page poldat
# colocando comandos no arquivo de entrada do IGI
#
# se l/2 = yes
#
	if (ll2) {
		print ("erase", >> igifile) 
        print ("data "//tempofile, >> igifile)
        print ("xcolumn 1", >> igifile)
        print ("data "//poldat, >> igifile)
		if (ttheta) 
          print ("location .075 .98 0.52 0.94 ", >> igifile)
        else
          print ("window 1 1 1", >> igifile)
        print ("ycolumn 2; ecolumn 3", >> igifile)
        #print ("yevaluate y; eevaluate e", >> igifile)
        if (pphase)
         print ("limits 0. 1. "//pmin//" "//pmax, >> igifile)
 	 	 else 
         print ("limits "//t[1]//" "//t[n]//" "//pmin//" "//pmax, >> igifile)
#         print ("limits ", >> igifile)
        print ("margin 0.050", >> igifile)
        if (ttheta)
          print ("box 0 2", >> igifile)
          else {
          print ("box", >> igifile)
        if (pphase)
           print ("xlabel Orbital phase", >> igifile)
           else
           print ("xlabel HJD - "//hjd,>> igifile)
        } 
#        print ("dlist", >> igifile) 
        print ("ylabel P(%)", >> igifile)
        if (ppontos) { 
	      print ("expand 0.5", >> igifile)
          print ("points", >> igifile)
	      print ("expand 1.0", >> igifile)
        }
        if (eerros) {
	      print ("expand 0.5", >> igifile)
          print ("etype 1; errorbar 2; errorbar -2", >> igifile)
	      print ("expand 1.0", >> igifile)
        }
        if (cconecta)
          print ("connect", >> igifile)
        print ("title "//ttitle, >>igifile)  
	#
	# imprimindo theta
	#
	if (ttheta) {
          print ("location .075 .98 0.10 0.52", >> igifile)
          print ("ycolumn 4", >> igifile)
          print ("ecolumn 5", >> igifile)
          print ("margin 0.5", >> igifile)          
          if (pphase) {
           print ("limits 0. 1. 0. 180. ", >> igifile)
           print ("margin 0.050", >> igifile)
           print ("box", >> igifile)
           print ("xlabel Orbital phase ",>> igifile)
           }
           else {
           print ("limits "//t[1]//" "//t[n]//" 0. 180. ", >> igifile)
           print ("margin 0.050", >> igifile)
           print ("box", >> igifile)
           print ("xlabel HJD - "//hjd,>> igifile)
           }
          print ("ylabel \gq (deg)", >> igifile)
          if (ppontos)  {
	        print ("expand 0.5", >> igifile)
            print ("points", >> igifile)
            print ("expand 1.0", >> igifile)
          }
          if (eerros)  {
 	        print ("expand 0.5", >> igifile)
            print ("etype 1; errorbar 2; errorbar -2", >> igifile)
	        print ("expand 1.0", >> igifile)
          }
          if (cconecta)
            print ("connect", >> igifile)
          }
	}
#
# else abaixo: se ll2 = no
#
	else {
	print ("erase", >> igifile)
	print ("ptype 7 3", >> igifile)
    print ("data "//tempofile, >> igifile)
    print ("xcolumn 1", >> igifile)
    print ("data "//poldat, >> igifile)
	if (ppl)
         if (ttheta) 
           print ("location .075 .98 0.66 0.94 ", >> igifile)
           else
           print ("location .075 .98 0.52 0.94", >> igifile)
      else
      print ("window 1 1 1", >> igifile)     
    print ("ycolumn 2;ecolumn 3", >> igifile)     
	print ("dlist dlist.lixo", >> igifile)
    if (pphase)
         print ("limits 0. 1. "//vmin//" "//vmax, >> igifile)
 	 else 
         print ("limits "//t[1]//" "//t[n]//" "//vmin//" "//vmax, >> igifile)
#         print ("limits "//t[1]//" "//t[n]//" -5. 5.", >> igifile)
    print ("margin 0.050", >> igifile)
    if (ppl)
          print ("box 0 2", >> igifile)
          else {
          print ("box", >> igifile)
          if (pphase)
           print ("xlabel Orbital phase", >> igifile)
           else
           print ("xlabel HJD - "//hjd,>> igifile)
    }
    print ("ylabel V(%)", >> igifile)
    if (ppontos) { 
	      print ("expand 0.5", >> igifile)
          print ("points", >> igifile)
   	      print ("expand 1.0", >> igifile)
    }
    if (eerros) {
	      print ("expand 0.5", >> igifile)
          print ("etype 1; errorbar 2; errorbar -2", >> igifile)
	      print ("expand 1.0", >> igifile)
	}
    if (cconecta)
          print ("connect", >> igifile)
          print ("title "//ttitle, >>igifile)  
	#
	# imprimindo pol.linear 
	#
	if (ppl) {
        print ("data "//poldat, >> igifile)
        if (ttheta) 
           print ("location .075 .98 0.38 0.66 ", >> igifile)
           else
           print ("location .075 .98 0.10 0.52", >> igifile)
        print ("ycolumn 4;ecolumn 5", >> igifile)     
        if (pphase)
         print ("limits 0. 1. "//pmin//" "//pmax, >> igifile)
 	 else 
         print ("limits "//t[1]//" "//t[n]//" "//pmin//" "//pmax, >> igifile)
        print ("margin 0.050", >> igifile)
        if (theta)
            print ("box 0 2", >> igifile)
          else {
            print ("box", >> igifile)
            if (pphase)
             print ("xlabel Orbital phase", >> igifile)
             else
             print ("xlabel HJD - "//hjd,>> igifile)
          }
           print ("ylabel P(%)", >> igifile)
        if (ppontos) {
	  	  print ("expand 0.5", >> igifile)
          print ("points", >> igifile)
	  	  print ("expand 1.0", >> igifile)
	}	
        if (eerros) {
       	  print ("expand 0.5", >> igifile)
          print ("etype 1; errorbar 2; errorbar -2", >> igifile)
	  	  print ("expand 1.0", >> igifile)
	}
        if (cconecta)
          print ("connect", >> igifile)
	#
	# imprimindo theta
	#
	if (ttheta) {
          	print ("location .075 .98 0.10 0.38", >> igifile)
          	print ("ycolumn 6", >> igifile)
          	print ("ecolumn 7", >> igifile)
          if (pphase) {
           print ("limits 0. 1. 0. 180. ", >> igifile)
           print ("margin 0.050", >> igifile)
           print ("box", >> igifile)
           print ("xlabel Orbital phase ",>> igifile)
           }
           else {
           print ("limits "//t[1]//" "//t[n]//" 0. 180. ", >> igifile)
           print ("margin 0.050", >> igifile)
           print ("box", >> igifile)
           print ("xlabel HJD - "//hjd,>> igifile)
           }
          print ("ylabel \gq (deg)", >> igifile)
          if (ppontos) {
	    	print ("expand 0.5", >> igifile)
            print ("points", >> igifile)
	    	print ("expand 1.0", >> igifile)
          }
          if (eerros) {
	    	print ("expand 0.5", >> igifile)
            print ("etype 1; errorbar 2; errorbar -2", >> igifile)
	    	print ("expand 1.0", >> igifile)
          }
          if (cconecta)
            print ("connect", >> igifile)
          } # fecha o if theta
         }
	}
        print ("end", >>igifile)
#     
#     
     	unlearn igi 
    	igi < igi_in
#
# criando metacode file
#
	if (eps) {
          if (access("dlist.lixo")) delete("dlist.lixo",ver-)
          if (access("dlist.lixo")) delete("dlist.lixo",ver-)
          if (access(mmacrol//".mc")) delete(mmacrol//".mc")  
          igi < igi_in , >G mmacrol//".mc"
          if (access(mmacrol//".eps")) delete(mmacrol//".eps",ver-)
          set stdplot = epsl
          stdplot(mmacrol//".mc")
          sleep 1
          rename ("sgi*.eps",mmacrol//".eps",field="all")
          if (access(mmacrol//".mc")) delete(mmacrol//".mc",ver-)
        }
        #
	###################
	# deletando arquivos temporarios
	#
    if (access(igifile)) delete(igifile,ver-)     	
   	if (access("dlist.lixo")) delete("dlist.lixo",ver-)
    if (access(tempofile)) delete(tempofile,ver-)
    if (access(diffile)) delete(diffile,ver-)
    if (arqout != "") rename(poldat,arqout,field="all")
    delete(poldat,ver-)
    
    goto fim
erro:
	print("   ERRO   ")

fim:
	print("     ")
	end

