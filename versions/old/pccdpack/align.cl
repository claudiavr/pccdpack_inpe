#
# Ver. Jun07
#

procedure align

string  imgref = ""       {prompt="Input reference image"}
string  images = ""       {prompt="Input images to align"}
string  shifts = "shifts" {prompt="shifts file"}
bool    confirm=yes       {prompt="confirm each image?"}
int     boxsize=7         {prompt="boxsize:imalign"}
int     bigbox=11         {prompt="bigbox:imalign"}
bool    sumfiles=no       {prompt="sum aligned images?"}
string  filesum           {prompt="sum file"}

struct *flist1
struct *flist2


begin

string temp1, temp2, temp3, temp4, temp5, aa, linedata
struct line1, line2
real   xref, yref, xcomp, ycomp, deltax, deltay
bool   bb=no
int    n=0
int    nlin

if (access(shifts//".shifts"))             delete (shifts//".shifts",ver-)
if (access(shifts//"ref"))                 delete (shifts//"ref", ver-)
if (access("sh"//shifts//".imalign.log"))  delete ("sh"//shifts//".imalign.log", ver-)
if (access("sh"//imgref))                  delete ("sh//"//images,ver-)


unlearn datapars
unlearn findpars
unlearn centerpars
unlearn fitskypars
unlearn photpars
unlearn daopars

print("")
print"Running DISPLAY with reference image...")
print("")

display.image = imgref
display(frame=1)
sleep 1

while (bb == no) {

 print("")
 print("Running DAOEDIT ...")
 print("")
 print("1. mark two stars")
 print("2. type <r> to see the profile (in a tek window) and check the position")
 print("3. type <a> to save the position")
 print("4. type <q> to quit of daoedit")
 print("")


 temp1 = mktemp("tmp$align")

 unlearn daoedit

 daoedit(imgref,> temp1//"")
 type temp1//""

 print("")
 print("Running TVMARK ...")
 print("")

 unlearn tvmark
 display(imgref,1)
 tvmark.mark = "circle"
 tvmark.radii = 15
 tvmark(1,temp1)

 print("")
 print("is it correct (yes|no)?")
 aa=scan(bb)

}

 type temp1//""

 nlin=0
 flist1=temp1
 while (fscan(flist1,line1) != EOF) {
        nlin=nlin+1
	if (nlin==3) linedata=fscan(line1, xref, yref)


 }
       print(xref,yref)

 temp4 = mktemp("tmp$align")



 if (confirm==yes) {


 print("")
 print("Running DISPLAY with images list to align ...")
 print("")

 temp2 = mktemp("tmp$align")
 dir(images,ncol=1,>> temp2)

 flist1 = temp2

 while (fscan(flist1,line1) != EOF) {

 n=n+1
 print("")
 print("Running DISPLAY with "//line1)
 print("")
 display(line1,frame=1)
 sleep 1

 bb=no


 while (bb == no) {

 print("")
 print("Running DAOEDIT ...")
 print("")
 print("1. repeat the same star pointed on reference image")
 print("2. type <q> to quit of daoedit")
 print("")


 temp3 = mktemp("tmp$align")

 unlearn daoedit

 daoedit(line1,> temp3//"")
 type temp3//""

 print("")
 print("Running TVMARK ...")
 print("")

 unlearn tvmark
 display(line1,1)
 tvmark.mark = "circle"
 tvmark.radii = 15
 tvmark(1,temp3)

 print("")
 print("is it correct (yes|no)?")
 aa=scan(bb)

 print("calculating shifts ...")

 nlin=0
 flist2=temp3
 while (fscan(flist2,line2) != EOF) {
        nlin=nlin+1
	if (nlin==3) linedata=fscan(line2, xcomp, ycomp)


 }

 print(xcomp,ycomp)

 deltax = xref - xcomp
 deltay = yref - ycomp
 print(deltax,deltay, >> temp4)




 del(temp3,ver-)

}

print("shifts")
type temp4//""

}




#copy(temp1,shifts//"ref")
copy(temp4,shifts//".shifts")

} # end confirm

copy(temp1,shifts//"ref")

print("")
print("Running IMALIGN ...")

unlearn imalign
imalign.input=images
imalign.reference = imgref
imalign.coords = shifts//"ref"
if (confirm==yes)imalign.shifts = shifts//".shifts"
imalign.output = "sh//"//images
imalign.boxsize = boxsize
imalign.bigbox = bigbox

imalign(trimim=no,shiftim=no)
temp5 = mktemp("tmp$align")
imalign(trimim=yes,shiftim=yes,>>temp5)

copy(temp5,"sh"//shifts//".imalign.log")


if (sumfiles==yes) {
    if (access(filesum//".fits")) delete(filesum//".fits",ver-)
    if (access(filesum//".log")) delete(filesum//".log",ver-)
    imsum("sh//"//images,filesum//".fits",>>filesum//".log")
    print("")
    type(filesum//".log")
}

delete(temp1, ver-)
#delete(temp2, ver-)
#delete(temp3, ver-)
if (confirm==yes) {
   delete(temp4, ver-)
   delete(temp2, ver-)
}
delete(temp5, ver-)


beep
beep


end

