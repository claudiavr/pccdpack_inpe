### Ver. Nov05
###

procedure prepiv

string sequ         {prompt="images sequence (root)"}
string flatn        {prompt="flat image"}
bool   delsky=yes   {prompt="delete sky image?"}
struct *flist

begin
real   x1, x1min, moda, delta
string temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, image
struct line

temp1 = mktemp("tmp$prepiv")
temp2 = mktemp("tmp$prepiv")
dir(sequ//"*.fits",ncol=1,>> temp1)

flist = temp1
x1min = 1e5

unlearn imstat
unlearn imarith
unlearn type
unlearn imcombine


## calculando a moda minima de sequencia
print("image mode")
while (fscan(flist,line) != EOF) {
    imstat(images=line,fields="image,mode", form-) | scan(image,x1)
    print(image," ",x1)
    if (x1 < x1min) x1min = x1
}
print("")
print("min. mode ",x1min)
print("")

imstat(images=sequ//"*.fits",fields="image,npix,mean,midpt,stddev,mode,skew,kurtosis,min,max", form+,>> temp2)
copy(temp2,sequ//".imstat.log")

## calculando deltas de moda e substraindo

print("calculating delta_mode and substracting...")
print("")

flist = ""
flist = temp1

while (fscan(flist,line) != EOF) {
    imstat(images=line,fields="image,mode", form-) | scan(image,moda)
    delta = moda - x1min
    imarith(image,'-',delta,"c"//image,ver+, >> "c"//image//".log")
    type("c"//image//".log")
}

temp3 = mktemp("tmp$prepiv")
imstat(images="c"//sequ//"*.fits",fields="image,npix,mean,midpt,stddev,mode,skew,kurtosis,min,max", form+,>> temp3)
copy(temp3,"c"//sequ//".imstat.log")

## calculando o ceu

print("")
print("creating sky image..."

imcombine("c"//sequ//"*.fits","skymed"//sequ//".fits",logfile="skymed"//sequ//".log",combine="median")
imstat(images="skymed"//sequ//".fits",fields="image,npix,mean,midpt,stddev,mode,skew,kurtosis,min,max", form+,>> "skymed"//sequ//".imstat.log")
imstat(images="skymed"//sequ//".fits",fields="image,mode", form-) | scan(image,moda)
print("")
print("sky image ", image," mode ",moda)
print("")


## susbtraindo ceu

print("substracting sky of sequence...")
print("")

temp4 = mktemp("tmp$prepiv")
imarith(sequ//"*.fits",'-',"skymed"//sequ//".fits","sky//"//sequ//"*.fits",ver+, >> temp4)
copy(temp4,"sky"//sequ//".imarith.log")
type("sky"//sequ//".imarith.log")
print("")

temp5 = mktemp("tmp$prepiv")
imstat(images="sky"//sequ//"*.fits",fields="image,npix,mean,midpt,stddev,mode,skew,kurtosis,min,max", form+,>> temp5)
copy(temp5,"sky"//sequ//".imstat.log")

## correcao pelo flat

print("applying flat correction..."
print("")

temp6 = mktemp("tmp$prepiv")
imarith("sky"//sequ//"*.fits",'/',flatn,"fl"//"sky//"//sequ//"*.fits",ver+, >> temp6)
copy(temp6,"flsky"//sequ//".imarith.log")
type("flsky"//sequ//".imarith.log")

temp7 = mktemp("tmp$prepiv")
imstat(images="flsky"//sequ//"*.fits",fields="image,npix,mean,midpt,stddev,mode,skew,kurtosis,min,max", form+,>> temp7)
copy(temp7,"flsky"//sequ//".imstat.log")


delete(temp1,ver-)
delete(temp2,ver-)
delete(temp3,ver-)
delete("c"//sequ//"*.fits",ver-)
delete(temp4,ver-)
delete(temp5,ver-)
if (delsky==yes) delete("skymed"//sequ//".fits",ver-)
delete("sky"//sequ//"*.fits",ver-)
delete(temp6,ver-)
delete(temp7,ver-)

end

