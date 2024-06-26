#
# Ver. set11
################################################
# Victor Magalhaes - Set 2011
# Colocado o corte em sigmax
################################################
# Claudia V Rodrigues - Ago 2011
# Tirei o theta_inversion, pois incluimos essa 
# opcao no pccdgen.
##############################################
# Jan 2011 - Claudia Rodrigues, Victor Magalhaes
# Stdplot Nao estava funcionando no iraf 2.15.1
# Modificada a saida eps para o psikern
################################################
# Claudia V Rodrigues
# Criado o theta_inversion para dar conta da rotacao
# da lamina na gaveta nova em sentido contrario
# ao da gaveta antiga.
#################################################

procedure select_inpe (file_out,file_ord)


string  file_out                  {prompt="macrol input file (.out)"}
string  file_ord                  {prompt="ordem input file (.ord)"}
string  file_sel                  {prompt="output file (.sel)"}
real    polmin = 3                {prompt="S/N minimum"}
real    polinf = 0                {prompt="minimum polarization (range: 0 - 1)"}
real    polmax = 1                {prompt="maximum polarization (range: 0 - 1)"}
bool    maiors = no               {prompt="select higher between sigma and stheo?"}
real	sigmax	= 1				  {prompt="Maior erro aceitavel"}
real    stheomax = 1              {prompt="theor. error maximum?"}
real    thetainf = 0              {prompt="theta minimum (range: 0 - 180)"}
real    thetasup = 180            {prompt="theta maximum (range: 0 - 180)"}
real    deltatheta = 0            {prompt="delta theta"}
real    coorq  = 0                {prompt="Q correction"}
real    cooru  = 0                {prompt="U correction"}
real    xpixmax = 1000            {prompt="x ccd size (pixels)"}
real    ypixmax = 1000            {prompt="y ccd size (pixels)"}
bool    outgraph = no             {prompt="create eps from graphic output?"}
string  devps="psi_land"          {enum="psi_land|psi_port|psi_square", prompt="postscript device to use?"}
string  vecconst = "constant"     {prompt="scale for fieldplot"}
string  norte = "right"           {enum="right|left|top|bottom", prompt="north-position in CCD field?"}
string  leste = "top"             {enum="right|left|top|bottom", prompt="east-position in CCD field?"}
real    binpol = 0.01             {prompt="binwidth for pol-histogram"}
bool    thetafit  = no            {prompt="fit theta-histogram?"}
pset    gaussparst = "gausspars"  {prompt="parameters for fit theta-histogram (:e to edit)"}
real    bintheta = 5              {prompt="binwidth for theta-histogram"}
real    thetamin = 0              {min=-90, max=0, prompt="theta-minimum for theta-histogram"}
real    thetamax = 180            {min=90, max=180, prompt="theta-maximum for theta-histogram"}
string  starelim = " "            {prompt="file with stars to eliminate"}
bool    meanvalue = yes           {prompt="print mean values?"}
bool    ivdata = no               {prompt="iv data?"}
struct  *flist
struct  *flist1
struct  *flist2
struct  line                      {length=160}
struct  line1                     {length=160}

begin


 int nl = 0
 int ww = 0
 int j, starout 
 int star = 0
 real aperture = 0
 real qsuma = 0
 real usuma = 0
 real sigma2 = 0
 real q, u, sigma, pola, theta, stheo, xx, yy, errotheta, nstars, xx1, yy1, xmax, ymax , lix
 real xcenter, ycenter, id, xcenter1, ycenter1, id1, minimo, izq, tick1, escala, limx
 string file3, file4, file5, file6,  file8, file90,file100 , file50, file51, file70
 string file10, file11, file20, linedata,ffile_sel
 string linedata1, linedata2, linedata3, fileout, fileord, temp0
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

 # checagem no diretorio local
 if (access(file_sel)) delete (file_sel,ver-)

 sel_file = file_sel

 # make temporary ffile_sel file
 ffile_sel = mktemp("tmp$sel")

 print (polinf,"< p < ",polmax," p/sigma(p) > ",polmin," dt ",deltatheta," cQ ",coorq," cU ",cooru, " ", thetainf, " < theta <= ", thetasup,>> ffile_sel)
 print ("XCENTER  YCENTER  P     THETA   Q       U    SIGMA   ID     APERTURE   STAR", >> ffile_sel)

 fileout = file_out
 fileord = file_ord


 flist1 = fileout
 flist2 = fileord

 unlearn tstat
 tstat(fileout,outtable = "",column = 1)
 nstars = tstat.nrows + 1

 linedata1 = fscan(flist1, line1)
 linedata2 = fscan(flist2, line2)

 for (j = 1; j < nstars ; j = j + 1) {
 
         stargood = yes
      
         linedata1 = fscan(flist1, line1)
	 if (ivdata == yes)
             linedata1 = fscan(line1, lix, lix, q, u, sigma, pola, theta, stheo, lix, aperture, star)
         else
             linedata1 = fscan(line1, q, u, sigma, pola, theta, stheo, aperture, star)
         linedata2 = fscan(flist2, line2)
         linedata2 = fscan(line2, xcenter, ycenter, id)
         linedata2 = fscan(flist2, line2)
         linedata2 = fscan(line2, xcenter1, ycenter1, id1)
         
         if (starelim != " ") {
             if (access(starelim) == yes) {
                 flist = starelim
		 while (fscan(flist,line) != EOF) {
                        linedata3 = fscan(line,starout,lix)
                        if (star == starout)
                            stargood = no
                 }
             }
         }    
         
         if (stargood == yes) {
         
             q = pola * cos(2 * theta * 3.1415927 / 180)
	     u = pola * sin(2 * theta * 3.1415927 / 180)
         
             if (maiors == yes) {
                 if (stheo > sigma) sigma = stheo  
             }
                  
             minimo = polmin * sigma
             if (pola >= minimo && pola <= polmax && pola >= polinf && sigma <= sigmax) {
             
               if (stheo < stheomax) {
               
                 
       
 	         if (deltatheta != 0) {
 	             theta = theta + deltatheta
 	             q = pola * cos(2 * theta * 3.1415927 / 180)
	             u = pola * sin(2 * theta * 3.1415927 / 180)
	         }
	   					
                 if (coorq != 0 || cooru != 0) {
                     q = q - coorq
                     u = u - cooru
	             pola = sqrt(q * q + u * u)
                     theta = ( atan2(u,q) * 180 / 3.1415927 ) / 2
                     if (theta < 0) theta = theta + 180.
	     	             
                 }
             
                 if (theta > 180) {
                         theta = theta - 180
                 }
                 if (theta < 0) {
                         theta = theta + 180
                 } 
             
                 if (thetainf > thetasup) {
                      if (thetainf < theta || thetasup >= theta)
                          print (xcenter1, " ", ycenter1, " ", pola, " ", theta, " ", q, " ", u, " ", sigma, " ", id1, " ", aperture, " ", star, >> ffile_sel)
                 }
                 else {
                     if (thetainf < theta && thetasup >= theta)
                     print (xcenter1, " ", ycenter1, " ", pola, " ", theta, " ", q, " ", u, " ", sigma, " ", id1, " ", aperture, " ", star, >> ffile_sel)
                 }
              }
           }
        }

    }
    
 file3 = mktemp("tmp$sel")
 #file3 = "qu"
 file4 = mktemp("tmp$sel")
 #file4 = "theta"
 file5 = mktemp("tmp$sel")
 #file5 = "campo"
 file6 = mktemp("tmp$sel")
 #file6 = "histopol"
 file100 = mktemp("tmp$sel")
 #file100 = "igi"
  
 flist = ffile_sel
 while (fscan (flist, line) != EOF) {
 
   linedata = fscan(line, xx, yy, pola, theta, q, u, sigma, lix, lix, lix)
   nl = nl + 1
 
   
 
   if (nl > 2 ) {

     if (pola != 0 && theta != deltatheta && q != coorq && u != cooru && sigma != 0) {
   
     #filtragem de estrelas, elimina estrelas com dados ruins
   
       print (q, " ", u, " ", sigma, >> file3)
       qsuma  = qsuma + q/(sigma**2)
       usuma  = usuma + u/(sigma**2)
       sigma2 = sigma2 + 1/(sigma**2)
        
       print (pola, >> file6)
              
       if (vecconst == "constant") {
           pola = 0.1
       }
       
       if (norte == "left" && leste == "top") {
          # theta = 180 - theta
          xx1  = ypixmax - yy
          yy1  = xpixmax - xx
          xmax = ypixmax
          ymax = xpixmax
          theta = theta + 90
       }
       if (norte == "left" && leste == "bottom") {
           # theta = 180 + theta
           xx1  = yy
           yy1  = xpixmax - xx
           xmax = ypixmax
           ymax = xpixmax
           theta = theta + 90
       }
       if (norte == "right" && leste == "top") {
           # theta = theta
           xx1  = ypixmax - yy
           yy1  = xx
           xmax = ypixmax
           ymax = xpixmax
           theta = theta + 90
       }
       if (norte == "right" && leste == "bottom") {
           # theta = 360 - theta
           xx1  = yy
           yy1  = xx
           xmax = ypixmax
           ymax = xpixmax
           theta = theta + 90
       }
       if (norte == "top" && leste == "right") {
           # theta = 90 - theta
           xx1  = xpixmax - xx
           yy1  = yy
           xmax = xpixmax
           ymax = ypixmax
           theta = theta + 90
       }
       if (norte == "top" && leste == "left") {
           # theta = 90 + theta
           xx1  = xx
           yy1  = yy
           xmax = xpixmax
           ymax = ypixmax
           theta = theta + 90
       }
       if (norte == "bottom" && leste == "right") {
           # theta = 270 + theta
           xx1  = xpixmax - xx
           yy1  = ypixmax - yy
           xmax = xpixmax
           ymax = ypixmax
           theta = theta + 90
       }
       if (norte == "bottom" && leste == "left") {
           # theta = 270 - theta
           xx1  = xx
           yy1  = ypixmax - yy
           xmax = xpixmax
           ymax = ypixmax
           theta = theta + 90
       }      
       print (xx1, " ", yy1, " ", pola, " ", theta, >> file5)
       theta = theta - 90

       if (theta > thetamax)
           theta = theta - 180
     
       if (theta < thetamin) 
           theta = theta + 180
 
       print (theta, >> file4)
       
     
     } 
   }  
 } 
 
 print("0  0  0  0 ", >> file5)
 print(xmax, ymax, " 0  0 ", >> file5) 
  
 unlearn tstat
 tstat (file3,outtable = "",column = 1)
 nstars = tstat.nrows
   
 tick1 = int(100*polmax/2)/100       
 
 print ("erase", >> file100)
 print ("move -0.1 0.98", >> file100)
 print ("label a)", >> file100)
 print ("move 0.46 0.98", >> file100) 
 print ("label b)", >> file100)
 print ("move -0.1 0.40", >> file100)
 print ("label c)", >> file100)
 print ("move 0.46 0.40", >> file100)
 print ("label d)", >> file100)
 
 
 print ("window 2 2 3", >> file100)
 print ("location .2 .8 .1 .9", >> file100)
 print ("data ", file3, >> file100)
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
 print ("title ",sel_file," ",polinf,"< p < ",polmax," p/sigma(p) > ",polmin," cQ ",coorq," cU ",cooru," nstars ",nstars,>> file100)
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
     print ("vmove "//xlab//" "//ylab-.12//"; label s "//int(sqrt(1/sigma2)*1e6)/1e4//"%", >> file100)
     print ("vmove "//xlab//" "//ylab-.16//"; label \\gq "//int(thetameio*1e2)/1e2, >> file100)
     
 }    
 
 unlearn tstat
 tstat (file4,outtable = "",column = 1)
 nstars = tstat.nrows
 
 if (polmin == 0) {
     errotheta = 5
 }
 else {
     errotheta = 28.65 / polmin
 }
 
 file90 = mktemp("tmp$sel")
 #file90 = "theta.his"
 
 unlearn thistogram
 thistogram.column = 1
 thistogram.nbins = INDEF
 thistogram.lowval = thetamin
 thistogram.highval = thetamax
 thistogram.dx = bintheta
 thistogram(file4,"STDOUT",1, >> file90)
 
 
 
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
 print ("title "//thetainf//" < theta <= "//thetasup//" bin ", bintheta , " erromax ",errotheta ," nstars ",nstars, " cmax ",tstat.vmax, >> file100)
 
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
     
                               
         } 
         print ("data ",file70,>> file100)
         print ("xcol 1; ycol 2", >> file100)
         print ("ltype 0; connect", >> file100) 
         
         
  
     }    
 
     delete(file50//".tab",ver-)
     delete(file51,ver-)
                 
 
      
 }
 
 unlearn tstat
 tstat (file6,outtable = "",column = 1)
 nstars = tstat.nrows
 
 unlearn thistogram
 thistogram.column = 1
 thistogram.nbins = INDEF
 thistogram.lowval = 0
 thistogram.highval = polmax
 thistogram.dx = binpol
 
 file10 = mktemp("tmp$sel")
 #file10 = "histopol.his"
 thistogram(file6,"STDOUT",1, >> file10)
 
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
 
 
 unlearn tstat
 tstat (file5,outtable = "",column = 1)
 nstars = tstat.nrows - 2
 
 flist = file5
 if (vecconst == "constant")
     escala = 1000
 else
     escala = real(vecconst)
 
 print ("window 4", >> file100)
 if (xmax > ymax) {
   #  limx = (1 - (ymax/xmax)*0.8*4/3)/2
   #  print ("location 0.1 0.9 ", limx, " ",1-limx, >> file100)
      limx = (1 - (xmax/ymax)*0.8*3/4)/2
      print ("location ", limx, " ",1-limx, " 0.1 0.9", >> file100)
     } else {
     limx = (1 - (xmax/ymax)*0.8*3/4)/2
     print ("location ", limx, " ",1-limx, " 0.1 0.9", >> file100)
     }
 print ("limits 0 ",xmax," 0 ",ymax, >> file100)
 print ("ticksize ",int(xmax/4), " ",int(xmax/4)," ",int(ymax/4)," ",int(ymax/4), >> file100)
 print ("box", >> file100)
 print ("xlabel S", >> file100)
 print ("ylabel E", >> file100)
 print ("title ", sel_file, " nstars ", nstars, " scale ", escala, >> file100) 
 
     
 while (fscan (flist, line) != EOF) {
        linedata = fscan(line,xx,yy,pola,theta)
        print("move ",xx," ",yy, >> file100)
        xx = xx+pola*escala*cos(theta*3.1415927/180)
        if (xx > xmax)
            xx = xmax
        if (xx < 0)
            xx = 0    
        yy = yy+pola*escala*sin(theta*3.1415927/180)
        if (yy > ymax)
            yy = ymax 
        if (yy < 0)
            yy = 0       
        print("draw ",xx, " ",yy, >> file100)
          
        }
 print ("move ",1.05*xmax," ",1.07*ymax, >> file100)
 print ("draw ",1.05*xmax-.05*escala, " ",1.07*ymax, >> file100)
 print ("move ",1.05*xmax-.05*escala, " ",1.07*ymax-35,"; label 5 %",  >> file100)

 
 
 print(0, " ", 0, " ", 0, " ", 0, " ", 0, " ", 0, " ", 0, >> ffile_sel)
 print(xpixmax, ypixmax, 0, " ", 0, " ", 0, " ", 0, " ", 0, >> ffile_sel)  

 unlearn igi
 igi < file100//""

 
 file11 = "ps" // polmax // "pi" // polinf // "s" // polmin // "q" // coorq // "u" // cooru 
 
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
          if (access(file_sel//".eps")) delete(file_sel//".eps",ver-)
          rename ("psk*.eps",file_sel//".eps",field="all")
#          movefiles(file_sel//".eps",".")
     }
 unlearn igi
 
 delete  (file3,ver-)
 delete  (file4,ver-)
 delete  (file5,ver-)
 delete  (file6,ver-)
 if (thetafit == yes)
     delete (file70,ver-)
 # delete  (file90,ver-)
 if (access("histo_pol.dat")) delete("histo_pol.dat",ver-)
 rename (file10,"histo_pol.dat",field="all")
 if (access("histo_pa.dat")) delete("histo_pa.dat",ver-)
 rename (file90,"histo_pa.dat",field="all")
 delete  (file100,ver-)

 flist =""
 flist1=""
 flist2=""

rename(ffile_sel,file_sel,field="all")

#file_sel = sel_file


end 
  

    
 




