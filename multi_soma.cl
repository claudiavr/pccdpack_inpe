#	Faz o Soma para diversas laminas com uma mesma raiz
#	
#
#	Victor de Souza Magalhaes 12/07/2011
#

procedure multi_soma(rraiz,ssai,rrefe,numelam)

string	rraiz	{prompt="Raiz das imagens de entrada"}
string	ssai	{prompt="Raiz das imagens de saida"}
string	rrefe	{prompt="Numero da imagem de referencia (ultimos 4 digitos)"}
int		numelam	{prompt="Numero de laminas a serem combinadas"}
pset    pospars_inpe	{prompt="Posicoes da lamina de meia onda :e"}
bool	letra	{prompt="Letras marcam posicoes depois do nove?"}
string	regi	{prompt="Regiao para comparacao das imagens"}
int		jane	{prompt="Janela para comparacao das imagens"}
bool	confir	{prompt="Confirma cada combinacao?"}

begin
	int comp, lam, k
	bool posicoes[16]
	string alga,raiz,sai,refe
	comp = 0
	k = 1
#	posicoes[]=no
	lam = numelam
	raiz = rraiz
	sai = ssai
	refe = rrefe
	delete("*.shift")
	unlearn soma_iv
	while(k<17){
		posicoes[k] = no
		k = k+1
	}
#	print(posicoes)
	if(pospars_inpe_inpe.pos_1) posicoes[1]=yes
	if(pospars_inpe.pos_2) posicoes[2]=yes
	if(pospars_inpe.pos_3) posicoes[3]=yes
	if(pospars_inpe.pos_4) posicoes[4]=yes
	if(pospars_inpe.pos_5) posicoes[5]=yes
	if(pospars_inpe.pos_6) posicoes[6]=yes
	if(pospars_inpe.pos_7) posicoes[7]=yes
	if(pospars_inpe.pos_8) posicoes[8]=yes
	if(pospars_inpe.pos_9) posicoes[9]=yes
	if(pospars_inpe.pos_10) posicoes[10]=yes
	if(pospars_inpe.pos_11) posicoes[11]=yes
	if(pospars_inpe.pos_12) posicoes[12]=yes
	if(pospars_inpe.pos_13) posicoes[13]=yes
	if(pospars_inpe.pos_14) posicoes[14]=yes
	if(pospars_inpe.pos_15) posicoes[15]=yes
	if(pospars_inpe.pos_16) posicoes[16]=yes
#	print(posicoes)
	while (comp < 16){
		alga = comp
		if(letra){
			if(comp==10) alga = "a"
			if(comp==11) alga = "b"
			if(comp==12) alga = "c"
			if(comp==13) alga = "d"
			if(comp==14) alga = "e"
			if(comp==15) alga = "f"
		}
#		print(alga)
#		print(raiz//alga//"*")
#		print(raiz//alga//"_"//refe)
		comp = comp + 1
		print(posicoes[comp])
		if(posicoes[comp]){
			soma_iv(list_in=raiz//alga//"*",imagem=raiz//alga//"_"//refe, saida=sai//alga, regiao=regi, janela=jane, deleta=yes, confirma=confir) 
		}
	}
	
#	!mkdir pol
#	!ls sai//"*" > list_obj
#	!mv sai//"*" pol/
#	!mv list_obj pol/
	
	
	beep
	sleep
	beep

end