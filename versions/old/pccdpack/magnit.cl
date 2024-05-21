#
# Ver. Mar06 - Antonio Pereyra
#
##########
# Claudia V. Rodrigues - Oct/2014
# - small modifications in delete files
# - change the maximum number of apertures to 20
# - correction in the eps file creation
############

procedure magnit (file_mag,file_sel)

string  file_mag         {prompt="input magnitude file from phot (.mag.?)"}
string  file_sel         {prompt="input select file (.sel)"}
string  file_out         {prompt="root of the output file (.mgn)"}
string  ganho="epadu"    {prompt="keyword for gain in magnitude file?"}
real    correc=0         {prompt="magnitude correction?"}
real    erro_correc=0    {prompt="error in magnitude correction?"}
bool    outgraph=yes     {prompt="create eps (.eps)?"}
struct  *flist
struct  line             {length=160}


begin
   int      star,i,pos,id
   int      nl = 0
   real     aperture, razon, sum, sum1, sum2, area, area1, area2, msky, msky1, msky2, magnitude
   real     pola, theta, xmin1, xmax1, ymin1, ymax1,ymin2, ymax2, gain, merr, sigma, stdev1, stdev2, stdev
   real     nsky1, nsky2, nsky, nstars, zmag, itime, q, u, cq, cu, deltatheta
   string   lix, linedata, line1, filemag, fileout, temp1, temp2, igi, histo, ps, line0, linedata1
   real     p[20]

   if (access(file_out//".mgn")) delete (file_out//".mgn",ver-)
   fileout = mktemp("tmp$mag")
#   fileout = file_out//".mgn"
   filemag = file_mag
   temp1 = mktemp ("tmp$mag")
   temp2 = mktemp ("tmp$mag")
#   igi   = "igi"


   unlearn pdump
   temp1 = mktemp ("tmp$mag")
   pdump (filemag,"rapert","id == 1", >> temp1)


   flist = temp1
   linedata = fscan(flist,line)
   i = 0
   line = line//" "
   while (strlen(line) != 0) {
       i = i + 1

       while (substr (line,1,1) == " ")
              line = substr (line,2,strlen (line))
       p[i] = real(substr (line,1,stridx (" ",line)))
       line = substr (line,stridx (" ",line)+1,strlen (line))

   }
   if (access(temp1)) delete (temp1, ver-)

   ##### read GAIN #####
   unlearn pdump
   temp1 = mktemp ("tmp$mag")
   pdump (filemag,ganho,"id == 1", >> temp1)

   flist = temp1
   linedata = fscan(flist,gain)
   if (access(temp1)) delete (temp1, ver-)

   #print(gain)


   ##### read ZMAG ######
   unlearn pdump
   temp1 = mktemp ("tmp$mag")
   pdump (filemag,"zmag","id == 1", >> temp1)

   flist = temp1
   linedata = fscan(flist,zmag)
   if (access(temp1)) delete (temp1, ver-)

   #print(zmag)

   ###### read ITIME ######
   unlearn pdump
   temp1 = mktemp ("tmp$mag")
   pdump (filemag,"itime","id == 1", >> temp1)

   flist = temp1
   linedata = fscan(flist,itime)
   if (access(temp1)) delete (temp1, ver-)

   #print(itime)

   flist = file_sel

   while (fscan (flist, line) != EOF) {
      linedata = fscan(line, lix, lix, pola, theta, q, u, sigma, lix, aperture, star)
      nl = nl + 1

      if (nl == 1) {
          line0 = substr(line,stridx("dt",line),strlen(line))
          linedata1 = fscan(line0,lix,deltatheta,lix,cq,lix,cu)
      }

      if (nl > 2 ) {
          for (i = 1; i <= 10; i +=1) {
              razon = abs(aperture - p[i])
              if (aperture == 0) pos = 1
              if (mod(razon,10) < 1e-14) pos = i
          }

	  if (pola != 0 && theta != deltatheta && q != cq && u != cu && sigma != 0) {
              pdump (filemag,"sum["//pos//"],area["//pos//"],msky,stdev,nsky,id","id >= "//2*star-1//" && id <= "//2*star, >> temp2)
              print (pola," ", theta, " ", sigma, >> temp2)
          }
      }
   }

   unlearn tstat; tstat(temp2,1, >& "dev$null")
   nl = 0
   flist = temp2
   while (nl < (tstat.nrows)/3) {
      linedata = fscan(flist,sum1,area1,msky1,stdev1,nsky1,id)
      linedata = fscan(flist,sum2,area2,msky2,stdev2,nsky2)
      linedata = fscan(flist,pola,theta,sigma)  
      nl   = nl + 1
      sum  = sum1 + sum2
      #print(sum)
      msky = (msky1 + msky2)/2
      #print(msky)
      area = area1
      #print(area)
      stdev = sqrt((stdev1**2 + stdev2**2)/4)
      #print (stdev)
      nsky  = (nsky1 + nsky2)/2
      #print(nsky)
      msky = 2*msky
      magnitude = zmag - 2.5*log10(sum - area * msky) + 2.5*log10(itime) + correc
      #print(magnitude)
      merr = 1.0857 * sqrt((sum-area*msky)/gain+area*stdev**2+area**2*stdev**2/nsky)/(sum-area*msky)
      merr = sqrt(merr**2 + erro_correc**2)

      print(int(magnitude*1e4)/1e4, " ", int(merr*1e4)/1e4, " ", 100*pola, " ", 100*sigma, " ", theta," ",(id+1)/2, >> fileout )
   }
   

   unlearn tstat
   tstat (fileout,outtable = "",column = 1)
   xmin1 = int(0.8*tstat.vmin) 
   xmax1 = int(1.2*tstat.vmax)
   nstars = tstat.nrows
 

   unlearn thistogram
   thistogram.column = 1
   thistogram.nbins = INDEF
   thistogram.lowval = xmin1
   thistogram.highval = xmax1
   thistogram.dx = 0.5
   
   histo = mktemp("tmp$mag")
   thistogram(fileout,"STDOUT",1, >> histo)

   unlearn tstat
   tstat (histo,outtable = "",column = 2)
   ymin1 = 0
   ymax1 = 1.2*tstat.vmax

   igi = mktemp("tmp$igi")

   print ("erase", >> igi)
   print ("window 2 1 1", >> igi)

   print ("location .15 .9 .15 .9", >> igi)
   print ("data ",histo, >> igi)
   print ("xcolumn 1; ycolumn 2", >> igi)
   print ("limits ",xmin1," ",xmax1, "  ",ymin1," ",ymax1, >> igi)
##   print ("ticksize ", int(100*polmax/4)/100, " ", int(100*polmax/4)/100, " ", int(tstat.vmax/4), " ", int(tstat.vmax/4),>> igi)
   print ("box", >> igi)
   print ("histogram", >> igi)
   print ("xlabel magnitude", >> igi)
   print ("ylabel counts", >> igi)
   print ("title ",fileout," nstars ",nstars,>> igi)

   unlearn tstat
   tstat (fileout,outtable = "",column = 3)
   ymin2 = 0
   ymax2 = 1.2*tstat.vmax
   
   print ("window 2", >> igi)
   print ("location .15 .9 .15 .9", >> igi)
   print ("data ",fileout, >> igi)
   print ("limits ",xmin1," ",xmax1, " ",ymin2, " ",ymax2,  >> igi)
   print ("xcolumn 1", >> igi)
   print ("ycolumn 3", >> igi)
   print ("ecol 2; etype 2; errorbar 1; errorbar -1", >> igi)
   print ("ecol 4; etype 2; errorbar 2; errorbar -2", >> igi)
   print ("box", >> igi)
   print ("expand 0.3; ptype 12 3; points", >> igi)
   print ("expand 1",  >> igi)
   print ("xlabel magnitude", >> igi)
   print ("ylabel polarization (%)", >> igi)
   print ("title correc ",correc," +/- ",erro_correc, >> igi)

   unlearn igi
   igi < igi//""


 if (outgraph == yes) {
          if (access(fileout//".eps")) delete(fileout//".eps",ver-)
	  	  ps = mktemp("ps")
          igi <igi//"", >G ps//".mc"
          set stdplot = epsh
          stdplot(ps//".mc")
          sleep 1
          rename ("sgi*.eps",file_out//"_mgn.eps")
          if (access(ps//".mc")) delete(ps//".mc",ver-)
     }
 unlearn igi

   rename(fileout,file_out//".mgn")
   if (access(fileout)) delete(fileout,ver-)
   if (access(temp2)) delete (temp2, ver-)
   if (access(histo)) delete (histo, ver-)
   if (access(igi)) delete (igi,ver-)
   flist=""
   line=""
end
            


