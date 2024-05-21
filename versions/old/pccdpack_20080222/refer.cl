#
# Ver. Aug04
#

procedure refer

string file_sel     {prompt="select input file (.sel)"}
string file_txt     {prompt="output file (.txt)"}
real   xo           {prompt="x-coordinate reference in image"}
real   yo           {prompt="y-coordinate reference in image"}
real   xoi          {prompt="x-coordinate reference in CCD frame"}
real   yoi          {prompt="y-coordinate reference in CCD frame"}
real   epimg        {prompt="image plate scale (arcsec/pixel) "}
real   epccd        {prompt="CCD plate scale (arcseg/pixel) "}
real   ximagem      {prompt="x image size (pixels)"}
real   yimagem      {prompt="y image size (pixels)"}
real   xside        {prompt="x CCD size (pixels)"}
real   yside        {prompt="y CCD size (pixels)"}
string norte        {enum="right|left|top|bottom", prompt="north-position in CCD field?"}
string leste        {enum="right|left|top|bottom", prompt="east-position in CCD field?"}
real   incli = 0    {prompt="angle between axis respect to equat. system?"}
bool   recen = no   {prompt="recenter?"}
string imgrefer     {prompt="reference image (.imh,.fits)"}
real   cbox = 5     {prompt="centering box width in scale units"}

struct *flist
struct *flist1
struct line         {length=160}

begin
  
  real xi, yi, newx, newy, rr, ang, rr1, ang1
  real xcenter, ycenter, p, q, u, theta, sigma, deltatheta, cq, cu
  int  nl = 0
  int  star
  string linedata, lix, line0, linedata1, temp0, temp1, temp2, id, filetxt
  
  if (access(file_txt)) delete(file_txt, ver-)
  temp0 = mktemp("tmp$ref")
  filetxt = mktemp("tmp$ref")
 
  flist = file_sel
  while (fscan(flist, line) != EOF) {
         linedata = fscan(line,xcenter,ycenter,p,theta,q,u,sigma,lix,lix,star)
         nl = nl + 1
          
         if (nl == 1) {
          line0 = substr(line,stridx("dt",line),strlen(line))
          linedata1 = fscan(line0,lix,deltatheta,lix,cq,lix,cu)          
         }
            
         if (nl > 2) {
           if (p != 0 && theta != deltatheta && q != cq && u != cu && sigma != 0) {
          
           #  linedata = fscan(line,xcenter,ycenter,p,theta,lix,lix,sigma,lix,lix,star)
             
             if (norte == "left" && leste == "top") {
                 #checked, not tested
                 xi = xo + yoi*epccd/epimg
                 yi = yo + xoi*epccd/epimg

                 newx = xi - ycenter*epccd/epimg
                 newy = yi - xcenter*epccd/epimg
                 theta = theta + 90
             }
             
             if (norte == "left" && leste == "bottom") {
                 #checked, not tested
                 xi = xo - yoi*epccd/epimg
                 yi = yo + xoi*epccd/epimg

                 newx = xi + ycenter*epccd/epimg
                 newy = yi - xcenter*epccd/epimg
                 theta = theta + 90
             
             }
             if (norte == "right" && leste == "top") {
                 #checked, tested
                 xi = xo + yoi*epccd/epimg
                 yi = yo - xoi*epccd/epimg

                 newx = xi - ycenter*epccd/epimg
                 newy = yi + xcenter*epccd/epimg
                 theta = theta + 90
             }
             if (norte == "right" && leste == "bottom") {
                 #checked, tested
		 xi = xo - yoi*epccd/epimg
                 yi = yo - xoi*epccd/epimg
  
                 newx = xi + ycenter*epccd/epimg
                 newy = yi + xcenter*epccd/epimg
                 theta = theta + 90             
             }
             if (norte == "top" && leste == "right") {  
                 #checked, tested
                 rr = sqrt(xoi**2 + yoi**2)
		 ang = atan2(yoi,xoi)

                 xi = xo + rr*cos(ang - incli*3.14159/180)*epccd/epimg
                 yi = yo - rr*sin(ang - incli*3.14159/180)*epccd/epimg

                 rr1 = sqrt(xcenter**2 + ycenter**2)
		 ang1 = atan2(ycenter,xcenter)

		 newx = xi - rr1*cos(ang1 - incli*3.14159/180)*epccd/epimg
		 newy = yi + rr1*sin(ang1 - incli*3.14159/180)*epccd/epimg

                 theta = theta + 90             
             }
             if (norte == "top" && leste == "left") {
	         #checked, not tested
                 xi = xo - xoi*epccd/epimg
                 yi = yo - yoi*epccd/epimg
  
                 newx = xi + xcenter*epccd/epimg
                 newy = yi + ycenter*epccd/epimg
                 theta = theta + 90             
             }
             if (norte == "bottom" && leste == "right") {
	         #checked, not tested
                 xi = xo + xoi*epccd/epimg
                 yi = yo + yoi*epccd/epimg

                 newx = xi - xcenter*epccd/epimg
                 newy = yi - ycenter*epccd/epimg
                 theta = theta + 90
             }
             if (norte == "bottom" && leste == "left") {
	         #checked, not tested
                 xi = xo - xoi*epccd/epimg
                 yi = yo + yoi*epccd/epimg

                 newx = xi + xcenter*epccd/epimg
                 newy = yi - ycenter*epccd/epimg
                 theta = theta + 90
                 
             }    
             
             
             print(int(newx*1e3)/1e3, int(newy*1e3)/1e3, p, theta, sigma, star, >> temp0)
        
        }
     }        
  }  
  
  if (recen == yes) {
  
  unlearn datapars
  unlearn centerpars
  centerpars.calgorithm = "centroid"
  centerpars.cbox = cbox
  
  unlearn center
  center.image = imgrefer
  center.coords = temp0
  center.interactive = no
  temp1 = mktemp("tmp$ref")
  center.output = temp1
  center.verify = no
  center 
  

  
  unlearn txdump
  temp2 = mktemp("tmp$ref")
  txdump (temp1,"xcenter,ycenter",expr+, > temp2)
  
  flist  = temp2 #saida do txdump
  flist1 = temp0 #saida do refer
  filetxt = mktemp("tmp$ref")
  
  while (fscan(flist,line) != EOF) {
    
   
       linedata = fscan(line,newx,newy)
       linedata = fscan(flist1,lix,lix,p,theta,sigma,star)
       print (int(newx*1e3)/1e3, int(newy*1e3)/1e3, p, theta, sigma, star, >> filetxt)
  
     }  
  
  
  } else {
  
  copy(temp0,filetxt)
  
  }
  
  
  print("0  0  0  0  0",>> filetxt)
  print(ximagem, yimagem, " 0  0  0", >> filetxt)

  copy(filetxt,file_txt)
  
  del(temp0,ver-)
  del(filetxt,ver-)
  if (recen == yes) {
      del(temp1,ver-)
      del(temp2,ver-)
  }

  flist=""
  flist1=""
  line=""
end            
