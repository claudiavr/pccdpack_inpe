#
# Ver. Jul06
#

procedure extfib

string  image = ""       {prompt="Input reconstructed 2D image (tc.wl.ldisp)"}
string  typeaper="fixed" {enum="fwhm|fixed|unfixed",prompt="type of aperture?"}
int     aper=2           {prompt="aperture used to extract fibers (fixed/unfixed)?"}
real    times=1          {prompt="fwhm times for aperture (option:fwhm)"}
bool    checkxy=no       {prompt="check center?"}
string  image2 =""       {prompt="Input wavelenght corrected image (tc.wl)"}
int     radsky=2         {prompt="aperture used to extract sky fibers?"}
string  outimg           {prompt="output image"}

struct  *flist

begin

string temp1,temp2, temp3, temp4, temp5, temp6, line, linedata, sum, sum0, aa, bb
real   xo,yo, xi, xf, yi, yf, erad, efwhm
real   fibnum[3]
int    xoint, yoint, cenfib, xiint, xfint, yiint, yfint, x, y, pos, num, uaper
bool   manual=yes


unlearn datapars
unlearn findpars
unlearn centerpars
unlearn fitskypars
unlearn photpars
unlearn daopars

delete("tmp$sum*",ver-)
delete("tmp$sky*",ver-)
delete("tmp$tmp*",ver-)
delete("tmp$log*",ver-)
delete(outimg//".log",ver-)
delete(outimg//".fits",ver-)

print("")
print"Running DISPLAY ...")
print("")

unlearn display
display.image = image
display.zscale = yes


display(frame=1)

sleep 1

sum0 = "sum"
temp5 = mktemp("tmp$extfib")

for (i=1; i<=3; i+=1) {

sum = sum0//i

print("")
print("Select center with cursor ...")
print("")



temp1 = mktemp("tmp$extfib")


 if (i==3) {

 print("")
 print("type sky position (X,Y)...")
 scan(aa)
 scan(bb)
 print(aa," ",bb,>> temp1//"")
 print("sky aperture: "//radsky)
 uaper = radsky

 } else {

 unlearn daoedit

 daoedit(image,> temp1//"")

 uaper = aper

 }

 type temp1//""




 temp2 = mktemp("tmp$extfib")
 temp3 = mktemp("tmp$extfib")
 temp6 = mktemp("tem$extfib")
 



 unlearn tstat
 tstat(temp1,1, > temp2)
 xo = tstat.mean
 tstat(temp1,2, > temp3)
 yo = tstat.mean



 if (i!=3) {
   tstat(temp1,5, > temp6)
   efwhm = tstat.mean*times
   if (typeaper=="fwhm") uaper = int(efwhm) + int(frac(efwhm)/0.5)
 }
 print("")
 print("centroid ",xo,yo)
 print("centroid ",xo,yo,>>temp5)
 if (i!=3) {
   print("fwhm ", efwhm)
   print("fwhm ", efwhm,>>temp5)
 }


 ## center (X,Y) integer and rounded

 xoint = int(xo) + int(frac(xo)/0.5)
 yoint = int(yo) + int(frac(yo)/0.5)

 ## check center

 cenfib = xoint + 32*(yoint - 1) - 2 # central fiber pos.

 print("central fiber: ("//xoint//","//yoint//") number: "//cenfib)
 print("central fiber: ("//xoint//","//yoint//") number: "//cenfib,>>temp5)

 if (checkxy==yes) {
   print("is it correct?")
   scan(manual)

   if (manual==no) {

   print("")
   print("type center (X,Y)...")
   scan(aa)
   scan(bb)
   xoint = int(aa)
   yoint = int(bb)

   cenfib = xoint + 32*(yoint - 1) - 2 # central fiber pos.
   print("new central fiber: ("//xoint//","//yoint//") number: "//cenfib)
   print("new central fiber: ("//xoint//","//yoint//") number: "//cenfib,>>temp5)

   }

  }




 if (typeaper=="fixed") {
     xo = xoint
     yo = yoint
 }

 xi = xo - uaper
 xiint = int(xi) + int(frac(xi)/0.5)
 xf = xo + uaper
 xfint = int(xf) + int(frac(xf)/0.5)

 yi = yo - uaper
 yiint = int(yi) + int(frac(yi)/0.5)
 yf = yo + uaper
 yfint = int(yf) + int(frac(yf)/0.5)

 temp4 = mktemp("tmp$extfib")

 print("extracting fibers around centroid with radius aperture = "//uaper//" :")
 print("extracting fibers around centroid with radius aperture = "//uaper//" :",>>temp5)

 num = 0

 unlearn scopy

 for (x=xiint;  x <= xfint;  x += 1) {

 	for (y=yiint; y <= yfint; y +=1) {
       		erad = sqrt( (x - xo)**2 + (y - yo)**2)
		if (erad <= uaper) {
                    pos = x + 32*(y - 1) -2  # fiber pos.
		    print (x, y, pos, >> temp4)
                    print("("//x//","//y//") number: "//pos)
		    scopy.apertures = pos
#		    scopy.renumber = yes
		    scopy(image2,"tmp$tmp",format="one")
		    num = num + 1

		}
	}
 }

 fibnum[i] = num

 unlearn scombine
 scombine.group = "all"
# scombine.reject = "sigclip"
# scombine.lsigma = 2
# scombine.hsigma = 2
# scombine.nlow = 5
# scombine.nhigh = 5

 if (i==3) scombine.combine = "median"
 else  scombine.combine = "sum"
 scombine("tmp$tmp*","tmp$sum"//i)

 unlearn tvmark
 tvmark.pointsize = 1
 tvmark(1,temp4)

 tvmark.color = 205
 tvmark(1,temp1)



delete(temp1,ver-)
delete(temp2,ver-)
delete(temp3,ver-)
delete(temp4,ver-)
delete(temp6,ver-)
delete("tmp$tmp*",ver-)

}




unlearn sarith


sarith("tmp$sum3","*",fibnum[1],"tmp$skyo",format="one", ver+,renumber+,>> temp5)
sarith("tmp$sum3","*",fibnum[2],"tmp$skye",format="one", ver+,renumber+,>> temp5)

#unlearn imcalc
#imcalc("tmp$sum1,tmp$skyo.0001","tmp$sum1cor","im1-im2")
#imcalc("tmp$sum2,tmp$skye.0001","tmp$sum2cor","im1-im2")
#imcalc("tmp$skyo.0001,tmp$skyo.0001","tmp$skyocor","im1-im2")
#imcalc("tmp$skye.0001,tmp$skye.0001","tmp$skyecor","im1-im2")

sarith("tmp$sum1,tmp$sum2,tmp$skyo.0001,tmp$skye.0001","copy","",outimg,format="mult", ver+,renumber+,>> temp5)
#sarith("tmp$sum1cor,tmp$sum2cor,tmp$skyocor,tmp$skyecor","copy","",outimg,format="mult", ver+,renumber+,>> temp5)


type(temp5)
copy(temp5,outimg//".log")

delete("tmp$sum*",ver-)
delete("tmp$sky*",ver-)
delete(temp5,ver-)
#copy("tmp$outimg",outimg)


end


