# Acha o deslocamento entre as imagens,registra e soma.
# Criado 05/07/2011
#
#
#




procedure soma_iv (list_in, imagem, saida)

string	list_in="@list"		{prompt="Lista de imagens"}
string	imagem				{prompt="Imagem de referencia"}
string	regiao				{prompt="Regiao para a comparacao das imagens"}
int		janela				{prompt="Tamanho da janela de correlacao"}
string	saida				{prompt="Nome da imagem de saida"}
bool	deleta=yes			{prompt="Deleta imagens registradas?"}
bool	confirma=yes		{prompt="Confirma os deslocamentos?"}

begin
	string corr, regiao2
	int jan2
	bool correto
	correto = no
	!mkdir temp
	while(correto==no){
		print("")
		print("Copiando imagens...")
		print("")
		if(access(image//"_xreg.shift")) delete(image//"_xreg.shift")
		imcopy(input=list_in, output="temp/", verbose=yes)
		!ls temp/* > list_temp
		unlearn xregister
		print("")
		print("Calculando o deslocamento entre as imagens...")
		print("")
		xregister (input="@list_temp", referenc="temp/"//imagem,output="@list_temp", regions=regiao, xwindow=janela, ywindow=janela, databas=no, shifts=image//"_xreg.shift")
		if(confirma){
			print("Exibindo imagens para conferir")
			disp_var(varim="@list_temp")
			print("Esta correto?")
			corr=scan(correto)
			if(correto==no){
				delete(files="temp/*")
				print("")
				print("Novo tamanho para a janela de correlacao")
				print("")
				jan2 = scan(janela)
				print("")
				print("Nova regiao para comparacao")
				print("")
				regiao2 = scan(regiao)
			}
		}
		else {
			correto=yes
		}
	}
	print("")
	print("Combinando imagens...")
	print("")
	unlearn imcombine
	if(access(saida//".fits")) delete(saida//".fits")
	imcombine(input="@list_temp", output=saida, combine="average", reject="avsigclip")
	delete list_temp
	if(deleta){
		!rm -r temp/
	}
#	type list_temp
	beep
	beep
end