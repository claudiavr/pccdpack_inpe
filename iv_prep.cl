#	Modificação do prepiv do pacote pccdpack
#	escalonamento da moda com multiplicacao ao inves de subtracao
#
#	Victor de Souza Magalhaes -> 06/07/2011
#
#	Adcionada a suavisacao da imagem de ceu com mascara de bad pixels
#
#	Victor de Souza Magalhaes -> 11/07/2011
#
#	Adcionado o toggle para a suavizacao da imagem de ceu
#
#	Victor de Souza Magalhaes -> 13/07/2011
#	
#	Comentado o toggle para a suavizacao do ceu.
#	
#	Victor de Souza Magalhaes -> 14/07/2011
#
#	Semi implementado, uso de laminas alternadas.
#
#	Victor de Souza Magalhaes -> 29/07/2011


procedure iv_prep

string  sequ         {prompt="Sequencia de imagens (raiz)"}
bool    flatcor=no  {prompt="Correcao por flat-field?"}
string  flatn        {prompt="Imagem de flat-field"}
bool    delsky=no   {prompt="deleta imagem de ceu?"}
bool	verbose=yes	{prompt="Imprime mensagens do imstat e imarith?"}
#bool	objeto=no		{prompt="Calcula ceu para apenas um objeto, nao usar, experimental!"}
#pset	pospars		{prompt="Definir qual laminas utilizar para calcular o ceu <experimental!>"}
#bool	corrigeceu	{prompt="Corrige a imagem de ceu para bad pixels?"}
struct  *flist

begin
real   x1, x1min, moda, delta, escalaceu, escalaimagem
string temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, image
string sequencia_c,tdel
struct line,lixo2
bool	corrigeceu, corr, para

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
print("Moda das imagens:")
while (fscan(flist,line) != EOF) {
    imstat(images=line,fields="image,mode",lower=0, form-) | scan(image,x1)
	if(verbose) print(image," ",x1)
    if (x1 < x1min) x1min = x1
}
print("")
print("Moda minima ",x1min)
print("")


imstat(images=sequ//"*.fits",fields="image,npix,mean,midpt,stddev,mode,skew,kurtosis,min,max",lower=0, form+,>> temp2)

tdel=sequ//".imstat.log"
if (access(tdel)) del(tdel,ver-)

copy(temp2,sequ//".imstat.log")

## calculando deltas de moda e substraindo

print("Escalonando a moda...")
#print("calculating delta_mode and substracting...")
print("")

flist = ""
flist = temp1

while (fscan(flist,line) != EOF) {
    imstat(images=line,fields="image,mode",lower=0, form-) | scan(image,moda)
	escalaceu = x1min / moda
	tdel="c"//image
	if (access(tdel)) imdel(tdel,ver-)
	tdel="c"//image//".log"
	if (access(tdel)) del(tdel,ver-)
	imarith(image,'*',escalaceu,"c"//image,ver+, >> "c"//image//".log")
#   delta = moda - x1min
#   imarith(image,'-',delta,"c"//image,ver+, >> "c"//image//".log") 
	if(verbose) type("c"//image//".log")
}

print("Criando arquivo de log")

temp3 = mktemp("tmp$prepiv")
imstat(images="c"//sequ//"*.fits",fields="image,npix,mean,midpt,stddev,mode,skew,kurtosis,min,max", form+,>> temp3)

tdel="c"//sequ//".imstat.log"
if (access(tdel)) del(tdel,ver-)
copy(temp3,"c"//sequ//".imstat.log")

## calculando o ceu

print("")
print("criando imagem de ceu..."

sequencia_c = mktemp("tmp$iv_prep")

#if(objeto){
#	unlearn dir
#	if(pospars.pos_1)  dir(sequ//"0*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_2)  dir(sequ//"1*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_3)  dir(sequ//"2*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_4)  dir(sequ//"3*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_5)  dir(sequ//"4*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_6)  dir(sequ//"5*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_7)  dir(sequ//"6*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_8)  dir(sequ//"7*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_9)  dir(sequ//"8*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_10)  dir(sequ//"9*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_11)  dir(sequ//"a*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_12)  dir(sequ//"b*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_13)  dir(sequ//"c*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_14)  dir(sequ//"d*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_15)  dir(sequ//"e*", maxch=30, ncols=1,>> sequencia_c)
#	if(pospars.pos_16)  dir(sequ//"f*", maxch=30, ncols=1,>> sequencia_c)
#}
#if(objeto==no){
#	dir(sequ//"*", maxch=30, ncols=1,>> sequencia_c)
#}

dir(sequ//"*.fits", maxch=30, ncols=1,>> sequencia_c)

tdel="list_ceu"
if (access(tdel)) del(tdel,ver-)
copy(sequencia_c,"list_ceu")

tdel="skymed"//sequ//".fits"
if (access(tdel)) imdel(tdel,ver-)
tdel="skymed"//sequ//".log"
if (access(tdel)) del(tdel,ver-)

#imcombine("@list_ceu","skymed"//sequ//".fits",logfile="skymed"//sequ//".log",combine="median",grow=0,reject="avsigclip")#,hthresh=1000,lthresh=0)

imcombine("@list_ceu","skymed"//sequ//".fits",logfile="skymed"//sequ//".log",combine="median",grow=0,reject="minmax",nlow=0,nhigh=8) #,hthresh=1000,lthresh=0)
imarith("skymed"//sequ//".fits", '-', 20, "skymed"//sequ//".fits", >> "skymed"//sequ//".imstat.log")

### entender ate aqui. Claudia

lixo2 = scan(para)

#beep
display(image="skymed"//sequ//".fits", frame=1)
print("")
print("Mostrando imagem de ceu...")

imstat(images="skymed"//sequ//".fits",fields="image,npix,mean,midpt,stddev,mode")

#print("Corrige a imagem de ceu de badpixels?")

#corr=scan(corrigeceu)

#if(corrigeceu){
#	print("")
#	print("Retirando os pixels ruins da imagem de ceu")
#	print("")
#
#	unlearn hedit
#	hedit(images="skymed"//sequ//".fits", fields="FIXPIX", add=no, addonly=no, delete=yes, verify=no, show=yes, update=yes)
#	unlearn badfaz
#	badfaz(imagem="skymed"//sequ//".fits", bad="skybad", norm=yes, z1=0.85, z2=1.15, auto=yes)
#	unlearn fixpix
#	fixpix(images="skymed"//sequ//".fits", masks="skybad")
#}


imstat(images="skymed"//sequ//".fits",fields="image,npix,mean,midpt,stddev,mode,skew,kurtosis,min,max",lower=0, form+,>> "skymed"//sequ//".imstat.log")
imstat(images="skymed"//sequ//".fits",fields="image,mode",lower=0, form-) | scan(image,moda)
print("")
print("Imagem de ceu: ", image,", moda: ",moda)
print("")

## subtraindo o ceu

print("Subtraindo o ceu da sequencia de imagens...")
print("")
temp4 = mktemp("tmp$prepiv")
flist = ""
flist = temp1
while (fscan(flist,line) != EOF) {
    imstat(images=line,fields="image,mode",lower=0, form-) | scan(image,moda)
	escalaimagem = moda / x1min
	tdel="csky"//image
	if (access(tdel)) imdel(tdel,ver-)
	tdel="sky"//image
	if (access(tdel)) imdel(tdel,ver-)
	tdel="c"//image//".log"
	if (access(tdel)) del(tdel,ver-)
	imarith("c"//image,'-',"skymed"//sequ//".fits","csky"//image,ver+, >> "c"//image//".log")
	imarith("csky"//image,'+',50,"csky"//image,ver+, >> "c"//image//".log")
	imarith("csky"//image,'*',escalaimagem,"sky"//image,ver+, >> "c"//image//".log")
    if(verbose) type("c"//image//".log")
}


#temp4 = mktemp("tmp$prepiv")
#imarith(sequ//"*.fits",'-',"skymed"//sequ//".fits","sky//"//sequ//"*.fits",ver+, >> temp4)
#copy(temp4,"sky"//sequ//".imarith.log")
#type("sky"//sequ//".imarith.log")
#print("")


#print("substracting sky of sequence...")
#print("")

#temp4 = mktemp("tmp$prepiv")
#imarith(sequ//"*.fits",'-',"skymed"//sequ//".fits","sky//"//sequ//"*.fits",ver+, >> temp4)
#copy(temp4,"sky"//sequ//".imarith.log")
#type("sky"//sequ//".imarith.log")
#print("")

temp5 = mktemp("tmp$prepiv")
imstat(images="sky"//sequ//"*.fits",fields="image,npix,mean,midpt,stddev,mode,skew,kurtosis,min,max",lower=0, form+,>> temp5)

tdel="sky"//sequ//".imstat.log"
if (access(tdel)) del(tdel,ver-)
copy(temp5,tdel)

## correcao pelo flat

if (flatcor==yes) {

print("applying flat correction..."
print("")

temp6 = mktemp("tmp$prepiv")
imarith("sky"//sequ//"*.fits",'/',flatn,"fl"//"sky//"//sequ//"*.fits",ver+, >> temp6)
copy(temp6,"flsky"//sequ//".imarith.log")
if(verbose) type("flsky"//sequ//".imarith.log")

temp7 = mktemp("tmp$prepiv")
imstat(images="flsky"//sequ//"*.fits",fields="image,npix,mean,midpt,stddev,mode,skew,kurtosis,min,max", form+,>> temp7)
copy(temp7,"flsky"//sequ//".imstat.log")

if (access(temp6)) delete(temp6,ver-)
if (access(temp7)) delete(temp7,ver-)

}

if (access(temp1)) delete(temp1,ver-)
if (access(temp2)) delete(temp2,ver-)
if (access(temp3)) delete(temp3,ver-)
delete("c"//sequ//"*.fits",ver-)
delete("csky"//sequ//"*.fits",ver-)
if (access(temp4)) delete(temp4,ver-)
if (access(temp5)) delete(temp5,ver-)
if (delsky==yes) delete("skymed"//sequ//".fits",ver-)
if (flatcor==yes) delete("sky"//sequ//"*.fits",ver-)

end

