	#
# Ver. out11
################################################
# Victor de Souza Magalhaes - Out11
# Adcionada opcao de usar um fintab como entrada
# em implementacao
################################################

procedure sel_ftb #(ftb)


string  ftb                       {prompt="fintab"}
bool	medianeira				  {prompt="Arquivo contem informacao de numero de medidas?"}
real    polinf = 0                {prompt="minimum polarization (range: 0 - 1)"}
real    polmax = 1                {prompt="maximum polarization (range: 0 - 1)"}
real    thetainf = 0              {prompt="theta minimum (range: 0 - 180)"}
real    thetasup = 180            {prompt="theta maximum (range: 0 - 180)"}
real	psp = 3.				  {prompt="Minimum value for P over Sigma_p"}
real    deltatheta = 0            {prompt="delta theta"}
bool    outgraph = no             {prompt="create eps from graphic output?"}
string  devps="psi_land"          {enum="psi_land|psi_port|psi_square", prompt="postscript device to use?"}
string  vecconst = "constant"     {prompt="scale for fieldplot"}
real    binpol = 0.01             {prompt="binwidth for pol-histogram"}
bool    thetafit  = no            {prompt="fit theta-histogram?"}
pset    gaussparst = "gausspars"  {prompt="parameters for fit theta-histogram (:e to edit)"}
real    bintheta = 5              {prompt="binwidth for theta-histogram"}
real    thetamin = 0              {min=-90, max=0, prompt="theta-minimum for theta-histogram"}
real    thetamax = 180            {min=90, max=180, prompt="theta-maximum for theta-histogram"}
bool    meanvalue = yes           {prompt="print mean values?"}
struct  *flist
struct  line                      {length=160}

begin


 int nl = 0
 int ww = 0
 int j, starout 
 int star = 0
 real aperture = 0
 real qsuma = 0
 real usuma = 0
 real sigma2 = 0
 real razaopsp
 #struct flist
 int ah,am,dg,dm,medidas,nstars,id
 real q, u, sigma, polarization, theta, stheo, xx, yy, errotheta, xx1, yy1, xmax, ymax , lix,as,ds
 real xcenter, ycenter, xcenter1, ycenter1, id1, minimo, izq, tick1, escala, limx
 string plotqu, hist_theta, file5, hist_pola,  file8, file90,file100 , file50, file51, file70,file200
 string file10, file11, file20, linedata
 string linedata1, linedata2, linedata3, temp0
 struct line2
 string aa,bb,cc,dd,ee,ff,gg,hh,ii,jj,kk,ll, tmp, sel_file
 bool   stargood = yes
 real   rms = 0
 real   npts = 0
 real   cent1 = 0
 real   ampl1 = 0
 real   fwhm1 = 0
 real   e_cent1,e_ampl1,e_fwhm1
  
 real   i, r1, posx, posy, qm, um, pm, thetameio, xlab, ylab

 string  file_sel
 string	 file_ftb
	
 file_sel = ftb//"_ftb.sel"
 file_ftb = ftb//".ftb"
 # checagem no diretorio local
 if (access(file_sel)) delete (file_sel,ver-)

 sel_file = file_sel

 tmp = envget("tmp")
 file_sel = tmp // file_sel
 if (access(file_sel)) delete (file_sel,ver-)

 if(medianeira==yes)print ("MAIN_ID	RA	DEC	POLARIZATION	SIGMA	THETA	MEASURES",>> file_sel)
 if(medianeira==yes) print ("----	----------	------------	----	----	-----	-", >> file_sel)
 
 if(medianeira==no)print ("MAIN_ID	RA	DEC	POLARIZATION	SIGMA	THETA",>> file_sel)
 if(medianeira==no) print ("----	----------	------------	----	----	-----", >> file_sel)
 
 flist = file_ftb

 nstars = -1

 linedata = fscan(flist, line)
 linedata = fscan(flist, line)
 
 while (fscan (flist, line) != EOF) {
	
	if(medianeira==yes)linedata = fscan(line, id,ah,am,as,dg,dm,ds,polarization,sigma,theta,medidas)
	if(medianeira==no)linedata = fscan(line, id,ah,am,as,dg,dm,ds,polarization,sigma,theta)
	
#	print("queijo")
#	print(id,ah,am,as,dg,dm,ds,polarization,sigma,theta,medidas)
	if(sigma>0)razaopsp = polarization / sigma
	if(sigma==0)razaopsp=0
	polarization = 0.01*polarization
	if (polarization <= polmax && polarization >= polinf && razaopsp >= psp) {
		nstars = nstars + 1
		#print(id)
		if (thetainf > thetasup) {
			if (thetainf < theta || thetasup >= theta){
				if(medianeira==yes)print (id,"	",ah," ",am," ",as,"	",dg," ",dm," ",ds,"	",100*polarization,"	", sigma,"	",theta,"	",medidas,>> file_sel)
				if(medianeira==no)print (id,"	",ah," ",am," ",as,"	",dg," ",dm," ",ds,"	",100*polarization,"	", sigma,"	",theta,>> file_sel)
			}
		}
		else {
			if (thetainf < theta && thetasup >= theta){
				if(medianeira==yes)print (id,"	",ah," ",am," ",as,"	",dg," ",dm," ",ds,"	",100*polarization,"	", sigma,"	",theta,"	",medidas,>> file_sel)
				if(medianeira==no)print (id,"	",ah," ",am," ",as,"	",dg," ",dm," ",ds,"	",100*polarization,"	", sigma,"	",theta,>> file_sel)
			}
		}
	}
 }
 nstars = nstars +1
 #print(nstars)
 plotqu = mktemp("tmp$sel")
 #plotqu = "qu"
 hist_theta = mktemp("tmp$sel")
 #hist_theta = "theta"
 #file5 = mktemp("tmp$sel")
 #file5 = "campo"
 hist_pola = mktemp("tmp$sel")
 #hist_pola = "histopol"
 file100 = mktemp("tmp$sel")
 file200 = mktemp("tmp$sel")
 #file100 = "igi"
  
 flist = file_sel
 while (fscan (flist, line) != EOF) {
	
	if(medianeira==yes)linedata = fscan(line, id,ah,am,as,dg,dm,ds,polarization,sigma,theta,medidas)
	if(medianeira==no)linedata = fscan(line, id,ah,am,as,dg,dm,ds,polarization,sigma,theta)
  	polarization = 0.01*polarization
	sigma = 0.01*sigma
	theta = theta + deltatheta
	if(theta > 180) theta = theta -180
	if(theta < 0) theta = theta + 180
	q = polarization * cos(2 * theta * 3.1415927 / 180)
	u = polarization * sin(2 * theta * 3.1415927 / 180)
	nl = nl + 1
	#print(id)
	if (nl > 2 && (nl-2) <= nstars) {
		print (q, " ", u, " ", sigma, >> plotqu)
		qsuma  = qsuma + q/(sigma**2)
		usuma  = usuma + u/(sigma**2)
		sigma2 = sigma2 + 1/(sigma**2)
		print (polarization, >> hist_pola)
		print (theta, >> hist_theta)
	}  
 } 
 if (nl==2){
	print("No stars above signal to noise ratio threshold")
 }
 else{

 unlearn tstat
 tstat (plotqu,outtable = "",column = 1)
 #nstars = tstat.nrows
   
 tick1 = int(100*polmax/2)/100       
 
 print ("erase", >> file100)
# print ("move -0.1 0.98", >> file100)
# print ("label a)", >> file100)
# print ("move 0.46 0.98", >> file100) 
# print ("label b)", >> file100)
# print ("move -0.1 0.40", >> file100)
# print ("label c)", >> file100)
# print ("move 0.46 0.40", >> file100)
# print ("label d)", >> file100)
 
 
 print ("window 2 2 3", >> file100)
 print ("location .2 .8 .1 .9", >> file100)
 print ("data ", plotqu, >> file100)
 print ("xcolumn 1; ycolumn 2", >> file100)
 print ("limits ", -1*polmax, " ", polmax, " ", -1*polmax, " ", polmax, >> file100)
 print ("margin", >>file100)
 print ("expand .3", >> file100)
 print ("points", >> file100)
 print ("expand .6", >> file100)
 print ("ticksize ",tick1, " ",tick1, " ",tick1," ",tick1, >> file100)
 print ("box", >> file100)
 print ("xlabel Q ", >> file100)
 print ("ylabel U ", >> file100)
 print ("title ",sel_file," ",polinf,"< p < ",polmax," nstars ",nstars,>> file100)
 print ("ltype 6", >>file100) 
 print ("move 0 -"//polmax//"; draw 0 "//polmax, >> file100)
 print ("move -"//polmax//" 0 ; draw "//polmax// " 0", >> file100)
 print ("ltype 0", >>file100)
 
 qm     = qsuma/sigma2
 um     = usuma/sigma2
 pm     = (qm**2+um**2)**0.5
 thetameio = ( atan2(um,qm) * 180 / 3.1415927 ) / 2
 if (thetameio < 0) thetameio = thetameio + 180
 


 xlab = 0.82 #0.65
 ylab = 0.56 #0.85
 #if (qm > 0) xlab = 0.24 #0.24
 #if (um > 0) ylab = 0.28 #0.28
 
 
 if (meanvalue == yes) {
     print ("vmove "//xlab//" "//ylab//"; label Q "//int(qm*1e4)/1e4, >> file100)
     print ("vmove "//xlab//" "//ylab-.04//"; label U "//int(um*1e4)/1e4, >> file100)
     print ("vmove "//xlab//" "//ylab-.08//"; label P "//int(pm*1e6)/1e4//"%", >> file100)
     print ("vmove "//xlab//" "//ylab-.12//"; label s "//int(100*sqrt(1/sigma2)*1e6)/1e4//"%", >> file100)
     print ("vmove "//xlab//" "//ylab-.16//"; label \\gq "//int(thetameio*1e2)/1e2, >> file100)
     
 }    
 
 unlearn tstat
 tstat (hist_theta,outtable = "",column = 1)
 nstars = tstat.nrows
 
 errotheta = 28.65 / 3.
 
 file90 = mktemp("tmp$sel")
 #file90 = "theta.his"
 
 unlearn thistogram
 thistogram.column = 1
 thistogram.nbins = INDEF
 thistogram.lowval = thetamin
 thistogram.highval = thetamax
 thistogram.dx = bintheta
 thistogram(hist_theta,"STDOUT",1, >> file90)
 
 
 
 unlearn tstat
 tstat (file90,outtable = "",column = 2)
 

 print ("window 1", >> file100)
 print ("location .15 .9 .1 .9", >> file100)
 print ("data ",file90, >> file100)
 print ("xcolumn 1; ycolumn 2", >> file100)
 print ("limits "//thetamin//" "//thetamax//" 0 "//1.1*tstat.vmax, >> file100)
 print ("ticksize 30 30 ", int(tstat.vmax/4), " ", int(tstat.vmax/4), >> file100)
 print ("box", >> file100)
 print ("histogram", >> file100) 
 print ("xlabel theta", >> file100)
 print ("ylabel counts", >> file100)
 print ("title "//thetainf//" < theta <= "//thetasup//" bin ", bintheta , " deltatheta ",deltatheta ," nstars ",nstars, " cmax ",tstat.vmax, >> file100)

 print ("window 1", >> file200)
 print ("location .15 .9 .1 .9", >> file200)
 print ("data ",file90, >> file200)
 print ("xcolumn 1; ycolumn 2", >> file200)
 print ("limits "//thetamin//" "//thetamax//" 0 "//1.1*tstat.vmax, >> file200)
 print ("ticksize 30 30 ", int(tstat.vmax/4), " ", int(tstat.vmax/4), >> file200)
 print ("box", >> file200)
 print ("histogram", >> file200) 
 print ("xlabel theta", >> file200)
 print ("ylabel counts", >> file200)
 print ("title "//thetainf//" < theta <= "//thetasup//" bin ", bintheta , " erromax ",errotheta ," nstars ",nstars, " cmax ",tstat.vmax, >> file200)

 
 if (thetafit == yes) {
     
     file50 = mktemp("tmp$sel")
     #file50 = "tab"
     file51 = mktemp("tmp$sel")
     #file51 = "as"


     unlearn ngaussfit
     #ngaussfit.niterate = 100
     #ngaussfit.errors = yes
     ngaussfit.interactive = no

     unlearn errorpars
     errorpars.resample = yes

     unlearn controlpars

     unlearn samplepars


     ngaussfit(file90,file50)
     prfit(file50, >> file51)
     
     flist = file51
     posx = 0.2

     file70 = mktemp("tmp$sel")
     #file70 = "gausstheta"
     
     while (fscan (flist, line) != EOF) {
     
         linedata1 = fscan(line,aa,bb,cc,dd,ee,ff,gg,hh,ii,jj,kk,ll)
        
         if (substr(line,1,9) == "Function:") 
             #rms = real(dd)
             rms = real(ff)

         if (substr(line,1,6) == "Units:") 
             npts = real(dd)
             
         if (substr(line,1,3) == "pos") {
             ww = ww + 1
             cent1   = real(substr(cc,1,strlen(cc)-1))
             e_cent1 = real(substr(dd,1,strlen(dd)-1)) 
             ampl1   = real(substr(gg,1,strlen(gg)-1))
             e_ampl1 = real(substr(hh,1,strlen(hh)-1))
             fwhm1   = real(substr(kk,1,strlen(kk)-1))
             e_fwhm1 = real(substr(ll,1,strlen(ll)-1))
             print ("   ")
             print ("Fit for theta-histogram")
             print ("       npts  ",npts)  
             print ("       rms   ",rms)
             print ("       ampl"//ww//" "//ampl1//" ("//e_ampl1//")")
             print ("       cent"//ww//" "//cent1//" ("//e_cent1//")")
             print ("       fwhm"//ww//" "//fwhm1//" ("//e_fwhm1//")")


	     
             for (i=thetamin; i <= thetamax; i += 1) {
	          r1 = ampl1 * exp (-2.70927 * ((i - cent1) / fwhm1) ** 2)
	          print (i, r1, >> file70)
             } 
             
             print (thetamax," 0", >> file70)
             print (thetamin," 0", >> file70)                 

             posy = 0.8-(ww-1)*0.12
             if (cent1 <= (thetamax+thetamin)/2 && ww == 1)
                 posx = 0.65
             print ("expand .5", >> file100)
             if (ww == 1)
                 print ("vmove "//posx//" 0.84; putlab 9 rms "//rms, >> file100)
             print ("vmove "//posx//" "//posy//"; putlab 9 ampl"//ww//" "//ampl1//" ("//e_ampl1//")",  >> file100)   
             print ("vmove "//posx//" "//posy-.04//"; putlab 9 cent"//ww//" "//cent1//" ("//e_cent1//")", >> file100)
             print ("vmove "//posx//" "//posy-.08//"; putlab 9 fwhm"//ww//" "//fwhm1//" ("//e_fwhm1//")", >> file100)
             print ("expand .6", >> file100) 
			 print ("vmove "//posx//" "//posy//"; putlab 9 ampl"//ww//" "//ampl1//" ("//e_ampl1//")",  >> file200)   
             print ("vmove "//posx//" "//posy-.04//"; putlab 9 cent"//ww//" "//cent1//" ("//e_cent1//")", >> file200)
             print ("vmove "//posx//" "//posy-.08//"; putlab 9 fwhm"//ww//" "//fwhm1//" ("//e_fwhm1//")", >> file200)
             print ("expand .6", >> file200) 
                               
         } 
         print ("data ",file70,>> file100)
         print ("xcol 1; ycol 2", >> file100)
         print ("ltype 0; connect", >> file100) 
         print ("data ",file70,>> file200)
         print ("xcol 1; ycol 2", >> file200)
         print ("ltype 0; connect", >> file200) 
  
     }    
     #copy(file70,ftb//"_theta.gauss")
     delete(file50//".tab",ver-)
     delete(file51,ver-)
                 
 
      
 }
 
 unlearn tstat
 tstat (hist_pola,outtable = "",column = 1)
 nstars = tstat.nrows
 
 unlearn thistogram
 thistogram.column = 1
 thistogram.nbins = INDEF
 thistogram.lowval = 0
 thistogram.highval = polmax
 thistogram.dx = binpol
 
 file10 = mktemp("tmp$sel")
 #file10 = "histopol.his"
 thistogram(hist_pola,"STDOUT",1, >> file10)
 
 unlearn tstat
 tstat (file10,outtable = "",column = 2)
 
 print ("window 2", >> file100)
 print ("location .15 .9 .1 .9", >> file100)
 print ("data ",file10, >> file100)
 print ("xcolumn 1; ycolumn 2", >> file100)
 print ("limits 0 ",polmax, " 0 ",1.1*tstat.vmax, >> file100)
 print ("ticksize ", int(100*polmax/4)/100, " ", int(100*polmax/4)/100, " ", int(tstat.vmax/4), " ", int(tstat.vmax/4),>> file100)
 print ("box", >> file100)
 print ("histogram", >> file100) 
 print ("xlabel polarization", >> file100)
 print ("ylabel counts", >> file100)
 print ("title ",sel_file," bin = ",binpol," nstars ",nstars, "cmax =",tstat.vmax, >> file100)
 
 
 unlearn igi
 igi < file100//""
 #igi < file200//""

 
 file11 = "ps" // polmax // "pi" // polinf 
} 
 if (outgraph == yes) {
          if (access(sel_file//".eps")) delete(sel_file//".eps",ver-)
          if (access(file_sel//".eps")) delete(file_sel//".eps",ver-)
          delete("sgi*.eps",ver-) # Claudia's suggestion
          if (access(file11//".mc")) delete(file11//".mc",ver-) # Claudia's suggestion + acces
	  igi < file100//"", >G file11//".mc"

#          set stdplot = devps//""
#          stdplot(file11//".mc")
#          sleep 1
#          rename ("sgi*.eps",file_sel//".eps")
          psikern(file11//".mc",device=devps)
          if (access(file11//".mc")) delete(file11//".mc",ver-)
          sleep 1
          rename ("psk*.eps",file_sel//".eps")
          movefiles(file_sel//".eps",".")
     }
 unlearn igi
 
 copy(file90,ftb//"_theta.his")
# copy(file70,ftb//"_theta.gauss")
 delete  (plotqu,ver-)
 delete  (hist_theta,ver-)
 #delete  (file5,ver-)
 delete  (hist_pola,ver-)
 
 
 
 delete  (file10,ver-)
 if (thetafit == yes)
     delete (file70,ver-)
 delete  (file90,ver-)
 delete  (file100,ver-)
 delete	 (file200,ver-)
 flist =""

movefiles(file_sel,".")

file_sel = sel_file


end 
  

    
 



