#
# Ver. Mar05
#

procedure extfib

string  image = ""       {prompt="Input reconstructed 2D image (tc.wl.ldisp)"}
int     aperture=2       {prompt="aperture used to extract fibers?"}
string  image2 =""       {prompt="Input wavelenght corrected image (tc.wl)"}
string  outimg           {prompt="output image"}

struct  *flist

begin

string temp1,temp2, temp3, temp4, line, linedata, sum, sum0, aa, bb
real   xo,yo, xi, xf, yi, yf, rad
real   fibnum[3]
int    xoint, yoint, cenfib, xiint, xfint, yiint, yfint, x, y, pos, num



unlearn datapars
unlearn findpars
unlearn centerpars
unlearn fitskypars
unlearn photpars
unlearn daopars



print("")
print"Running DISPLAY ...")
print("")

unlearn display
display.image = image
display.zscale = no


display(frame=1)

sleep 1

sum0 = "sum"

for (i=1; i<=3; i+=1) {

sum = sum0//i

print("")
print("Select center with cursor ...")
print("")



temp1 = mktemp("tmp$daoedit")


 if (i==3) {

 print("")
 print("type sky position (X,Y)...")
 scan(aa)
 scan(bb)
 print(aa," ",bb, >> temp1//"")

 } else {


 unlearn daoedit

 daoedit(image,> temp1//"")

 }

 type temp1//""




 temp2 = mktemp("tmp$tstat")
 temp3 = mktemp("tmp$tstat")

 unlearn tstat
 tstat(temp1,1, > temp2)
 xo = tstat.mean
 tstat(temp1,2, > temp3)
 yo = tstat.mean
 print("")
 print("centroid ",xo,yo)

 ## center (X,Y) integer

 xoint = int(xo) + int(frac(xo)/0.5)
 yoint = int(yo) + int(frac(yo)/0.5)

 cenfib = xoint + 32*(yoint - 1) - 2 # central fiber pos.

 print("central fiber: ("//xoint//","//yoint//") number: "//cenfib)


 xi = xo - aper
 xiint = int(xi) + int(frac(xi)/0.5)
 xf = xo + aper
 xfint = int(xf) + int(frac(xf)/0.5)

 yi = yo - aper
 yiint = int(yi) + int(frac(yi)/0.5)
 yf = yo + aper
 yfint = int(yf) + int(frac(yf)/0.5)

 temp4 = mktemp("tmp$xypos")

 print("extracting fibers around centroid with radius aperture = "//aper//" :")

 num = 0

 unlearn scopy
 for (x=xiint;  x <= xfint;  x += 1) {

 	for (y=yiint; y <= yfint; y +=1) {
       		rad = sqrt( (x - xo)**2 + (y - yo)**2)
		if (rad <= aper) {
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
imdelete("tmp$tmp*")

}

unlearn sarith

sarith("tmp$sum3","*",fibnum[1],"tmp$skyo",format="one", ver+,renumber+)
sarith("tmp$sum3","*",fibnum[2],"tmp$skye",format="one", ver+,renumber+)

sarith("tmp$sum1,tmp$sum2,tmp$skyo.0001,tmp$skye.0001","copy","",outimg,format="mult", ver+,renumber+)

imdelete("tmp$sum*",ver-)
imdelete("tmp$sky*",ver-)
#copy("tmp$outimg",outimg)


end


