#
# Ver. Aug06
#

procedure vecplot

string files_txt                  {prompt="input file with vectors (.txt)"}
string file_img                   {prompt="reference image (.imh,.fits)"}
string file_ps                    {prompt="output postscript file"}
string glut                    {prompt="Graphics LUT table (psikern)"}
real   bin = 1                    {prompt="scale for binning (pixels)"}
string devps = "psi_port"         {prompt="postscript device to use"}
real   xorig = 1                  {prompt="x-origin for image offset"}
real   yorig = 1                  {prompt="y-origin for image offset"}
bool   pvec = yes                 {prompt="plot vectors?"}
string posvec = "middle"          {enum="middle|origin", prompt="vector position respect to object?"}
real   escala = 2000              {prompt="scale plot"}
string titulo = "default"         {prompt="title string?"}
bool   escalatitle = yes          {prompt="title with scale?"}
int    longescala = 5             {prompt="scale size (%)"}
bool   pimage = no                {prompt="overplot image?"}
bool   niveisfull = no            {prompt="lower and higher zrange levels?"}
real   z1                         {prompt="custom lower zrange level?"}
real   z2                         {prompt="custom higher zrange level?"}
string mapsao = "none"            {prompt="saocmap file name"}
bool   typeimg = yes              {prompt="negative image?"}
bool   typestar = yes             {prompt="plot star number?"}
bool   reposiciona = yes          {prompt="locus of star number repositioned?"}
string typefont = "large"         {enum="large|medium|small",prompt="character size"}
bool   pext = no                  {prompt="plot the extinction?"}
string file_ext                   {prompt="extinction image"}
pset   newcont                    {prompt="newcont parameters (:e to edit)"}
bool   deligi = yes               {prompt="delete igi file?"}
struct *flist0
struct *flist1  
struct line1                      {length=160}        
        
begin

real   pixmax, pixmin, corrx, corry
real   loc_left   = .1           
real   loc_right  = .9           
real   loc_bottom = .35           
real   loc_top    = .95   
#int      star = 0
string   star
string   igi, temp0, temp1, linedata,lix, filestxt, igi2, lix1
real     xx, yy, pola, theta, xaxis, yaxis
struct   ftxt
       

flpr


imgets(file_img,"i_minpixval"); pixmin = real(imgets.value)
imgets(file_img,"i_maxpixval"); pixmax = real(imgets.value)
imgets(file_img,"i_naxis1"); xaxis = real(imgets.value)
imgets(file_img,"i_naxis2"); yaxis = real(imgets.value)

filestxt = files_txt
delete (file_ps//".eps", ver-)

#igi = mktemp("tmp$vec")
igi = "igi"

temp1 = mktemp("tmp$vec")

#escala = escala/bin
#xaxis  = xaxis/bin
#yaxis  = yaxis/bin

if (xaxis > yaxis) {    
    loc_bottom = .95 - 0.6*yaxis/xaxis           
    loc_top    = .95
}

if (yaxis > xaxis) {
    loc_left   = (1 - 0.8*xaxis/yaxis)/2          
    loc_right  = loc_left + 0.8*xaxis/yaxis
    
}  
             
print("loc_left   ",loc_left)
print("loc_right  ",loc_right)
print("loc_bottom ",loc_bottom)
print("loc_top    ",loc_top)

print("location ",loc_left," ",loc_right," ",loc_bottom," ",loc_top, >> igi)


#print("zsection  '"//file_img//"[*,*]'", >> igi)

print("zsection  '"//file_img//"'", >> igi)

####### colocamos "[*,*]'" para asegurar 
####### letura do 'zsection' em imagens IPAC ( tipo [241,241,1] )

print("limits ", >> igi)

if (niveisfull == no) {
    pixmin = z1 ; pixmax = z2
}

if (typeimg == no) print("zrange ",pixmin, " ",pixmax, >> igi)
   else print("zrange ",pixmax, " ",pixmin, >> igi)
   
if (mapsao == "none" || mapsao == " " || mapsao == "") print(" ", >> igi)
   else print("saocmap ",mapsao, >> igi)
if (pimage == yes) print("pixmap", >> igi)
print("wcslab", >> igi)
print("ticksize ",xaxis, " ", xaxis, " ", yaxis, " ", yaxis, >> igi)
print("box 0 0", >> igi)
print("fontset hard", >> igi)

######## titulo ###########


# if (escalatitle == yes) {
#    print("title ",filestxt, " scale ", escala, >> igi) 
#  
# } else {
 if (titulo=="default") titulo = filestxt
 print("title ",titulo, >> igi)
# }
 
###########################


 if (substr(filestxt,1,1) != "@") {
    temp0 = mktemp("tmp$vec")
    print(filestxt, >> temp0)
    filestxt = temp0
    
 } else {

    filestxt =  substr(filestxt,2,strlen(filestxt))

 }    

 flist0 = filestxt 
 if (typefont == "large")  print("expand 1.6",  >> igi)
 if (typefont == "medium") print("expand 0.8",  >> igi)
 if (typefont == "small")  print("expand 0.4",  >> igi)
 
 

 while (fscan(flist0, ftxt) != EOF) {
  print(ftxt)
  flist1 = ftxt
  while (fscan (flist1, line1) != EOF) {

        star = " "
        linedata = fscan(line1,xx,yy,pola,theta,lix,star)

        
    
      
        
        xx = xx - xorig + 1 
        yy = yy - yorig + 1 
        
         xx    = xx/bin
         yy    = yy/bin
        
        
        
        if (typestar == yes) {
             
                print("move ",xx, " ", yy, >> igi)
            
                if (reposiciona == yes) {
                
                   if (theta >= 0 && theta < 90)
                       print("justify 1", >>igi)
                   if (theta >= 90 && theta < 180)
                       print("justify 3", >>igi)
                   if (theta >= 180 && theta < 270)
                       print("justify 9", >>igi)
                   if (theta >= 270 && theta < 360)
                       print("justify 7", >>igi)   
                       
                   star = " "//star                                    
                
                } else { 
                
                              
                print("justify 5", >>igi)
                
                }
                
                if (star != "  ")
                    print("label '",star,"'", >> igi)
        }   
        
        if (posvec == "middle") {
                
           xx = xx - (pola*escala*cos(theta*3.1415927/180))/2 
           yy = yy - (pola*escala*sin(theta*3.1415927/180))/2 
        }
        
        
        if (pvec == yes) {
        
            if (pola != 0 && xx >= 0 && yy >= 0) {
                
                if (xx > xaxis)  xx = xaxis
                if (yy > yaxis)  yy = yaxis 
                
                print("move ",xx," ",yy, >> igi)
                
                xx = xx+pola*escala*cos(theta*3.1415927/180) 
                if (xx > xaxis)  xx = xaxis
                if (xx < 0)      xx = 0    
                yy = yy+pola*escala*sin(theta*3.1415927/180) 
                if (yy > yaxis)  yy = yaxis 
                if (yy < 0)      yy = 0   
                    
                print("draw ",xx, " ",yy, >> igi)
            }    
        }         
   }
     
 }

########### dibuja escala ################

if (escalatitle == yes) {
  print("expand 1",  >> igi)
  #yy = yaxis + 60
  #yy = 1.05*yaxis
  yy = yaxis + 0.03*yaxis/(loc_top - loc_bottom)
  
  print ("move ",xaxis," ",yy, >> igi)
  
  xx = xaxis - (longescala/100.) * escala
   
  print ("draw ",xx, " ",yy, >> igi)
  
  #yy = yaxis + 20
  #yy = 1.02*yaxis 
  yy = yaxis + 0.01*yaxis/(loc_top - loc_bottom)
  
  print ("move ",xx," ",yy,"; justify 9; label "//longescala//" %",  >> igi)
}


###########################################

if (pext == yes) {
    
    imgets(file_ext,"i_naxis1"); xaxis = real(imgets.value)
    imgets(file_ext,"i_naxis2"); yaxis = real(imgets.value)
    corrx = (loc_right - loc_left)/xaxis/2
    corry = (loc_top - loc_bottom)/yaxis/2
    
    
    unlearn dvpar
    
    dvpar.append = no
    dvpar.left   = loc_left + corrx
    dvpar.right  = loc_right - corrx
    dvpar.bottom = loc_bottom + corry
    dvpar.top    = loc_top - corry
    dvpar.fill   = no
    newcont.preserve = no
    newcont.perimeter = no
    newcont.usewcs = yes
    newcont (file_ext)
    dvpar.append = yes
    newcont file_ext//"", >G temp1//""
}
################


print("creating temporary metacode file...")
unlearn igi
igi.append   = yes
igi < igi//"", >>G temp1//""


if (pimage==yes && pext==yes) {
    dvpar.append = no
    newcont (file_ext)
    dvpar.append = yes
    newcont file_ext//"", >>G temp1//""

    igi2 = mktemp("tmp$vec")
    flist1 = igi
    while (fscan (flist1, line1) != EOF) {
        linedata = fscan(line1,lix1,lix)
	if (lix1 != "pixmap") print(line1,>> igi2)
    }
    igi < igi2//"", >>G temp1//""
    delete(igi2,ver-)
}

print("creating PostScript file...")
unlearn psikern
psikern.device = devps
psikern.graphics_lut = glut
psikern.output = file_ps
psikern(temp1)

sleep 1
rename ("psk*.eps",file_ps//".eps")

delete(temp1,ver-)
if (deligi == yes) delete(igi,ver-)


if (substr(files_txt,1,1) != "@") delete (temp0, ver-)

flist0 = ""
flist1 = ""
line1 = ""

end