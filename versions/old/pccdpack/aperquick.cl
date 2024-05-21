#
# Ver. Sep07
#

procedure aperquick (subdir)

string  image = ""       {prompt="daofind: Input (reference) image"}
string  subdir = ""      {prompt="sub-directory to create for temporary files"}
bool    intera = no      {prompt="use interactive selection for objects?"}
bool    reimag = no      {prompt="imalign: Run with bright stars?"}
string  images = ""      {prompt="imalign: Input images"}
real    boxsize = 7      {min=1,prompt="imalign: Size of the small centering box"}
real    bigbox = 11      {min=1,prompt="imalign: Size of the big centering box"}
string  apertures = "3:12:1" {prompt="phot: List of aperture radii in pixels"}
real    annulini=20      {prompt="phot: initial annulus"}
real    dannulus=10      {prompt="phot: dannulus"}
real    nannul=1         {prompt="annulus number"}
string  calgo="none"     {enum="centroid|gauss|none|ofilter",prompt="phot: calgoritm"}
string  salgo="mode"     {enum="median|mode|centroid|gauss|crosscor|ofilter|histplot|radplot|constant|file|mean",prompt="phot: salgoritm"}
string  namefile ="aperquick.log"     {prompt="log file"}

#int     nap = 10         {prompt="pccd: number of apertures (maximum 10)"}
#string  calc = "c"       {enum="c|p", prompt="pccd: analyser: calcite (c) / polaroid (p)"}
#real    readnoise = 2    {prompt="pccd: CCD readnoise (adu)"}
#real    ganho = 3.3      {prompt="pccd: CCD gain (e/adu)"}
#real    deltatheta = 0   {prompt="pccd: correction in polarization angle (degrees)"}
#string  fileexe = "/iraf/extern/pccdpack/pccd/pccd2000.exe" {prompt="pccd: pccd execute file (.exe)"}
#string  norte = "right"  {enum="right|left|top|bottom", prompt="select: north-position in CCD field?"}
#string  leste = "top"    {enum="right|left|top|bottom", prompt="select: east-position in CCD field?"}
struct   *flist
struct   line1


begin

string temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp66
string temp9, temp10, lix, xlong, ylong, direct, aa, temp20
bool   bb = no
bool   cc = no
real   sky_mean, skysigma_mean, fwhm_mean, fwhm, sigma
int    ii = 0
int    nap
real   anulo, nstars

#ordem param
real    shiftx = 10
real    shifty = 10
real    deltax = 2
real    deltay = 2
real    deltamag = 1
string  side = "right"
##########

string line2

direct = subdir

if (access(direct))
    delete(direct//"/*",ver-)
else
    mkdir (direct)

chdir(direct)

unlearn datapars
unlearn findpars
unlearn centerpars
unlearn fitskypars
unlearn photpars
unlearn daopars


if (intera == yes) {

print("")
print"Running DISPLAY ...")
print("")

display.image = "../"//image

display(frame=1)

sleep 1

while (bb == no) {

 print("")
 print("Running DAOEDIT ...")
 print("")
 print("1. put the cursor on the bottom image of a object")
 print("2. type <r> to see the profile (in a tek window) and check the position")
 print("3. type <a> to save the position")
 print("4. put the cursor on the top image of a object and repeat 2 and 3")
 print("5. repeat 1 to 4 for another object, if you wish")
 print("6. type <q> to quit of daoedit")
 print("")

 temp1 = mktemp("daoedit")

 unlearn daoedit

 daoedit("../"//image,> temp1//"")
 type temp1//""

 print("")
 print("Running TVMARK ...")
 print("")

 unlearn tvmark
 display("../"//image,1)
 tvmark.mark = "circle"
 tvmark.radii = 15
 tvmark(1,temp1)

 print("")
 print("is it correct (yes|no)?")
 aa=scan(bb)

}

temp20 = mktemp("tmp$filecalc")
temp2 = mktemp("filecalc")

unlearn filecalc

print("#  XCENTER   YCENTER       SKY  SKYSIGMA      FWHM    COUNTS       MAG",>temp20)

filecalc.format = "%10.2f%10.2f%10.1f%10.2f%10.2f%10.1f%10.2f"

filecalc(temp1,"$1;$2;$3;$4;$5;$6;$7",>>temp20)

copy(temp20,temp2)
delete(temp20)

unlearn rename
rename(temp2,temp2//".ord")

print("")
type temp2//".ord"
print("")

unlearn tstat
tstat(temp2//".ord",3)
sky_mean = tstat.mean
tstat(temp2//".ord",4)
skysigma_mean = tstat.mean
tstat(temp2//".ord",5)
fwhm_mean = tstat.mean

print("")
print("Mean values")
print("sky      : ",sky_mean)
print("skysigma : ",skysigma_mean)
print("fwhm     : ",fwhm_mean)
}
else {

print(" ")
print("Running DAOFIND ...")
print(" ")

temp1 = mktemp("daofind")

unlearn daofind

daofind.image = "../"//image
daofind.output = temp1
daofind.verbose = yes

daofind



print("Running ORDEM ...")
print(" ")

temp2 = mktemp("ordem")

unlearn ordem

ordem.shiftx = shiftx
ordem.shifty = shifty
ordem.deltax = deltax
ordem.deltay = deltay
ordem.deltamag = deltamag
ordem.side = side

ordem(temp1,temp2)

}

if (reimag == yes) {

bb=no

print("")
print("Select bright stars interactively? (yes|no)?")
aa=scan(bb)

if (bb==yes) {

print("")
print"Running DISPLAY ...")
print("")

display.image = "../"//image

display(frame=1)

sleep 1

while (cc == no) {

 print("")
 print("Mark the bright stars...")
 print("Running DAOEDIT...")
 print("")
 print("1. put the cursor on the selected star")
 print("2. type <r> to see the profile (in a tek window) and check the position")
 print("3. type <a> to save the position")
 print("4. repeat steps 1-3 for each selected star")
 print("5. type <q> to quit of daoedit")
 print("")

 
 temp7 = mktemp("daoedit")

 unlearn daoedit

 daoedit("../"//image,> temp7//"")
 type temp7//""

 print("")
 print("Running TVMARK ...")
 print("")

 unlearn tvmark
 display("../"//image,1)
 sleep 1
 tvmark.mark = "circle"
 tvmark.radii = 15
 tvmark(1,temp7)

 print("")
 print("is it correct (yes|no)?")
 aa=scan(cc)



}


} else {


print(" ")
print("Running DAOFIND for bright stars ...")
print(" ")

 


temp7 = mktemp("daofind")

unlearn daofind

daofind.image = "../"//image
daofind.output = temp7
daofind.verbose = yes

daofind

}

}


print(" ")
print("Running IMALIGN ...")
print(" ")

temp3 = mktemp("imalign")

unlearn imalign

imalign.boxsize = boxsize
imalign.bigbox = bigbox
imalign.shiftimages = no
imalign.trimimages = no

if (reimag == yes)
imalign("../"//images,"../"//image,temp7,"",> temp3//"")
else
imalign("../"//images,"../"//image,temp2//".ord","",> temp3//"")

type temp3//""

print("")
print("continue (yes|no)?")

bb = no
scan(bb)
if (bb == no) error(1, "Try with new boxsize and bigbox parameters or less objects.")


print(" ")
print("Running COORSHIFT ...")
print(" ")

unlearn coorshift

imgets("../"//image,"i_naxis1")
xlong = imgets.value
imgets("../"//image,"i_naxis2")
ylong = imgets.value

coorshift.infile = temp3
coorshift.coorfile = temp2//".ord"
coorshift.corrige = no
if (reimag == yes) {
coorshift.corrige = yes
coorshift.xside = int(xlong)
coorshift.yside = int(ylong)
= coorshift.deltax
= coorshift.deltay

}

coorshift

temp0 = mktemp("tstat")

unlearn tstat
tstat(temp2//".ord",1,> temp0)
tstat.nrows = tstat.nrows/2

nstars = tstat.nrows

while (ii < nannul) {

ii = ii + 1

print(" ")
print(" ")
print("Running PHOT ...")



unlearn datapars
datapars.readnoise = pccdgen.readnoise*pccdgen.ganho
datapars.epadu = pccdgen.ganho
datapars.fwhmpsf = fwhm_mean
datapars.sigma = skysigma_mean
print("")
print("FWHM of the PSF in scale units: ",datapars.fwhm)
print("")
print("Standard deviation of background in counts: ",datapars.sigma)


unlearn centerpars
centerpars.calgorithm = calgo
unlearn fitskypars
fitskypars.salgorithm = salgo
anulo = annulini + (ii-1)*dannulus
fitskypars.annulus = anulo
fitskypars.dannulus = dannulus
unlearn photpars
photpars.apertures = apertures

print("annulus ",anulo)

unlearn phot

phot.coords = "@inord"
phot.output = "default"
phot.interactive = no
phot.verify = no

phot("../"//images)

print(" ")
print("Running TXDUMP ...")
print(" ")

temp4 = mktemp("txdump")

unlearn txdump

nap = pccdgen.nap

txdump("*.mag."//ii,"image,msky,nsky,rapert[1-"//str(nap)//"],sum[1-"//str(nap)//"],area[1-"//str(nap)//"]",yes,> temp4//"")
#lpar txdump



print(" ")
print("Running PCCD ...")
print(" ")

temp5 = mktemp("pccd"//anulo)

#unlearn pccdgen

pccdgen.filename = temp4
#pccdgen.nstars = nstars
dir("../"//images,ncol=1) | count | tstat column=1,>> temp0//""
#pccdgen.nhw = tstat.mean
#pccdgen.nap = nap
#pccdgen.calc = calc
#pccdgen.readnoise = readnoise
#pccdgen.ganho = ganho
#pccdgen.deltatheta = deltatheta
pccdgen.fileout = temp5
#pccdgen.fileexe = file

#lpar pccd
print("")
pccdgen(temp4)

print(" ")
print("Running MACROL ...")
print(" ")

temp6  = mktemp("macrol_ap"//anulo//"fi")
temp66 = mktemp("macrol_ap"//anulo//"fu")

unlearn macrol

#### minimum=first ####
macrol.file_in = temp5
macrol.file_out = temp6

macrol

#### minimum=full ####
macrol.file_in = temp5
macrol.file_out = temp66
macrol.minimun = "full"

macrol



print("")
print("")

flist = temp6//".out"

line2 = fscan(flist,line1)
line2 = fscan(flist,line1)

if (ii == 1) {
if (pccdgen.wavetype == "half")
print("annulus     Q        U      SIGMA      P    THETA SIGMAth.  APER. STAR",>>namefile)
if (pccdgen.wavetype == "quarter" || pccdgen.wavetype == "other")
print("annulus    V     SIGMAV      Q        U      SIGMA      P    THETA SIGMAth.    rms     APER. STAR",>>namefile)
}
print(anulo//"   "//line1//"first",>>namefile)

flist = temp66//".out"

line2 = fscan(flist,line1)
line2 = fscan(flist,line1)

print(anulo//"   "//line1//"full",>>namefile)


#print("")
#print(" ")
#print("Running SELECT ...")
#print(" ")


#temp8 = mktemp("select")
#temp10 = mktemp("tstat")

#unlearn tstat
#tstat(temp6//".out",4,> temp10)

#unlearn select

#select.file_sel = temp8//""
#select.polmin = 0
#select.polmax = 1.2*tstat.vmax
#select.xpixmax = int(xlong)
#select.ypixmax = int(ylong)
#select.norte = norte
#select.leste = leste


#select(temp6//".out",temp2//".ord")

#temp9 = mktemp("tstat")

#unlearn tstat
#tstat(temp8//"",1,> temp9)

#unlearn filecalc
#print("annulus ",anulo)
#print("")
#print("   XCENTER   YCENTER      P        THETA     SIGMA   ID  APERTURE    STAR")

#filecalc.lines = "3-"//str(tstat.nrows-1)
#filecalc.format = "%10.3f%10.3f%10.5f%10.1f%10.5f%5.0f%7.0f%9.0f"

#filecalc(temp8//"","$1;$2;$3;$4;$7;$8;$9;$10")

print("")

}

type(namefile//"")




#delete(temp0)
#delete(temp1)
#delete(temp2//".ord")
#delete(temp3)
#delete(temp4)
#delete(temp5)
#delete("c*.ord")
#delete("inord")
#delete("*.mag.1")
#delete(temp6//".out")
#delete(direct//"/pccdtemp/*")
#if (reimag == yes) delete(temp7)
#delete(temp8)
#delete(temp9)
#delete(temp10

chdir("../")

end



