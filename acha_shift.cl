# Acha o deslocamento entre as imagens com o auxilio da tela
# Modificada da rotina align do pccdpack.
# Criada em 29/06/2011
#

procedure acha_shift

string  imgref = ""       {prompt="Imagem de referencia"}
string  images = ""       {prompt="Lista de imagens deslocadas"}
string  shifts = "acha"	  {prompt="Arquivo de saida"}
bool    confirm=no        {prompt="Confirma cada imagem?"}


struct *flist1
struct *flist2


begin

string temp1, temp2, temp3, temp4, temp5, aa, linedata
struct line1, line2, lixo
real   xref, yref, xcomp, ycomp, deltax, deltay
bool   bb=no
int    n=0
int    nlin

if (access(shifts//"_acha.shift"))             delete (shifts//".shifts",ver-)
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
print"Exibindo a imagem de referencia")
print("")

display.image = imgref
display(frame=1)
sleep 1

while (bb == no) {

 print("")
 print("Rodando DAOEDIT ...")
 print("")
 print("1. marque duas estrelas")
 #print("2. aperte <r> to see the profile (in a tek window) and check the position")
 print("3. aperte <a> para salvar a posicao")
 print("4. aperte <q> para sair do daoedit")
 print("")


 temp1 = mktemp("tmp$align")

 unlearn daoedit

 daoedit(imgref,> temp1//"")
 type temp1//""

 print("")
 print("Rodando TVMARK ...")
 print("")

 unlearn tvmark
 display(imgref,1)
 tvmark.mark = "circle"
 tvmark.radii = 20
 tvmark.color = 206 
 tvmark(1,temp1)

 print("")
 bb=yes
 print("Esta correto (y|n)? Yes is default.")
 lixo = scan(bb)
 print(bb)
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





 print("")
 print("Exibindo imagens a alinhar")
 print("")

 temp2 = mktemp("tmp$align")
 dir(images,ncol=1,>> temp2)

 flist1 = temp2

 while (fscan(flist1,line1) != EOF) {

 n=n+1
 print("")
 print("Exibindo: "//line1)
 print("")
 display(line1,frame=1)
 sleep 1

 bb=no


 while (bb == no) {

 print("")
 print("Rodando o DAOEDIT")
 print("")
 print("1. aponte as mesmas estrelas que na imagem de referencia")
 print("2. Aperte q para sair do daoedit")
 print("")


 temp3 = mktemp("tmp$align")

 unlearn daoedit
 #print(line1 > temp3)
 #type(temp3)
 daoedit(line1,> temp3//"")
 type temp3//""

 if(confirm==yes){
	print("")
	print("Rodando TVMARK")
	print("")

	unlearn tvmark
	display(line1,1)
	tvmark.mark = "circle"
	tvmark.radii = 20
	tvmark.color = 206
	tvmark(1,temp3)

    bb=yes
    print("Esta correto (y|n)? Yes is default.")
 	lixo = scan(bb)
 	print(bb)
 }
 else{
	bb=yes
 }
 print("Calculando o deslocamento")

 nlin=0
 flist2=temp3
 while (fscan(flist2,line2) != EOF) {
        nlin=nlin+1
	if (nlin==3) linedata=fscan(line2, xcomp, ycomp)


 }

 print(xcomp,ycomp)

 deltax = xref - xcomp
 deltay = yref - ycomp
 print(line1,"  ",deltax,deltay, >> temp4)




 del(temp3,ver-)

}

print("shifts")
type temp4//""

}


#copy(temp1,shifts//"ref")
del(shifts//"_acha.shift",ver-)
copy(temp4,shifts//"_acha.shift")



copy(temp1,shifts//"ref")

delete(temp1, ver-)
#delete(temp2, ver-)
#delete(temp3, ver-)
if (confirm==yes) {
   delete(temp4, ver-)
   delete(temp2, ver-)
}



end

