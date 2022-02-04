##
##	Uso do programa estat direto do cl.
##
## Versao original: Victor de Souza Magalhaes
##
###########
#  Claudia V. Rodrigues -Oct/2014
#  - translate instructions to English
##########################################
##
procedure clestat (imagem)

string	imagem		{"", prompt="Imagem a ser usada como referencia"}
bool    marca=no	{prompt="Show objects using tvmark"}

begin
bool faz
string lixo, temp,temp3
faz = yes


while(faz==yes){
	temp = mktemp("tmp$clestat")
	if (access("clestat.dao")) delete("clestat.dao",ver-)
	display(image=imagem, frame=1)
	print("With the cursor over the bottom image of a pair, type <a>.")
	print("With the cursor over the top image of a pair, type <a>.")
	print("Repeat this procedure to some stars.")
	print("Type <q> when you are done.")
	temp3 = mktemp("tmp$clestat")
	unlearn daoedit
	#print(line1 > temp3)
	#type(temp3)
	fitskypars.annulus = 60
	fitskypars.dannulus = 10
	daoedit(imagem,> temp3//"")
	type temp3//""
	copy(temp3, "clestat.dao")
	if (access("estat.log")) delete("estat.log",ver-)
	estat_cl
	type("estat.log")
	if (marca) {
		tvmark.mark = "circle"
		tvmark.radii = 20
		tvmark.color = 206
		tvmark(1,"clestat.dao",number=yes,txsize=4)
	}		
	print("Would you like to repeat the clestat procedure? Yes/No (Default)")
	faz=no
	lixo = scan(faz)
}
#!open -a textedit estat.log
end
