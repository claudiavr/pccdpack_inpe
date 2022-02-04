procedure mapa_combina
#
bool	combina			{prompt="Combina os fintabs?"}
bool	inspec			{prompt="inspeciona os fintabs"}
int		num_ftb			{max=10, prompt="Numero de fintabs"}
real	separacao		{prompt="Separacao máxima para combinacao (arcsec)"}
bool	retira			{prompt="retira objetos marcados no ftb.inspec"}
string	nome_fora		{prompt="Nome de saida do modo combina"}
string	ftb1=""			{prompt="fintab numero 1 sem a extensao"}
real	cent1			{prompt="centro da distribuicao de PA do fintab1"}
real	fwhm1			{prompt="FWHM da distribuicao de PA do fintab1"}
string	ftb2=""			{prompt="fintab numero 2 sem a extensao"}
real	cent2			{prompt="centro da distribuicao de PA do fintab2"}
real	fwhm2			{prompt="FWHM da distribuicao de PA do fintab2"}
string	ftb3=""			{prompt="fintab numero 3 sem a extensao"}
real	cent3			{prompt="centro da distribuicao de PA do fintab3"}
real	fwhm3			{prompt="FWHM da distribuicao de PA do fintab3"}
string	ftb4=""			{prompt="fintab numero 4 sem a extensao"}
real	cent4			{prompt="centro da distribuicao de PA do fintab4"}
real	fwhm4			{prompt="FWHM da distribuicao de PA do fintab4"}
string	ftb5=""			{prompt="fintab numero 5 sem a extensao"}
real	cent5			{prompt="centro da distribuicao de PA do fintab5"}
real	fwhm5			{prompt="FWHM da distribuicao de PA do fintab5"}
string	ftb6=""			{prompt="fintab numero 6 sem a extensao"}
real	cent6			{prompt="centro da distribuicao de PA do fintab6"}
real	fwhm6			{prompt="FWHM da distribuicao de PA do fintab6"}
string	ftb7=""			{prompt="fintab numero 7 sem a extensao"}
real	cent7			{prompt="centro da distribuicao de PA do fintab7"}
real	fwhm7			{prompt="FWHM da distribuicao de PA do fintab7"}
string	ftb8=""			{prompt="fintab numero 8 sem a extensao"}
real	cent8			{prompt="centro da distribuicao de PA do fintab8"}
real	fwhm8			{prompt="FWHM da distribuicao de PA do fintab8"}
string	ftb9=""			{prompt="fintab numero 9 sem a extensao"}
real	cent9			{prompt="centro da distribuicao de PA do fintab9"}
real	fwhm9			{prompt="FWHM da distribuicao de PA do fintab9"}
string	ftb10=""		{prompt="fintab numero 10 sem a extensao"}
real	cent10			{prompt="centro da distribuicao de PA do fintab10"}
real	fwhm10			{prompt="FWHM da distribuicao de PA do fintab10"}
 
begin 

	string filepar,lixo
	string nftb[10]
	int i 

	lixo=""
	filepar = mktemp("tmp$combina")
	print(nome_fora//".ftb",>filepar)
	print("## Se nao houver gaussiana colocar fwhm = 0 ##",>>filepar)
	if(combina) print("combina(1|0)	1",>>filepar)
	if(combina==no) print("combina(1|0)	0",>>filepar)
	if(inspec) print("inspecao(1|0)	1",>>filepar)
	if(inspec==no) print("inspecao(1|0)	0",>>filepar)
	print("num_ftb		",num_ftb,>>filepar)
	print("separacao(arcsec)	",separacao,>>filepar)
	print("	Arquivo		centro	fwhm",>>filepar)
	
	
	
	if(ftb1!=lixo) {
		if(retira==no){
			print("ftb1	",ftb1//".ftb","	",cent1,"	",fwhm1,>>filepar)
		}
		if(retira==yes){
			print("ftb1	","corr_"//ftb1//".ftb","	",cent1,"	",fwhm1,>>filepar)
		}
		nftb[1]=ftb1
	}
	if(ftb2!=lixo) {
		if(retira==no){
			print("ftb2	",ftb2//".ftb","	",cent2,"	",fwhm2,>>filepar)
		}
		if(retira==yes){
			print("ftb2	","corr_"//ftb2//".ftb","	",cent2,"	",fwhm2,>>filepar)
		}
		nftb[2]=ftb2
	}
	if(ftb3!=lixo) {
		if(retira==no){
			print("ftb3	",ftb3//".ftb","	",cent3,"	",fwhm3,>>filepar)
		}
		if(retira==yes){
			print("ftb3	","corr_"//ftb3//".ftb","	",cent3,"	",fwhm3,>>filepar)
		}
		nftb[3]=ftb3
	}
	if(ftb4!=lixo) {
		if(retira==no){
			print("ftb4	",ftb4//".ftb","	",cent4,"	",fwhm4,>>filepar)
		}
		if(retira==yes){
			print("ftb4	","corr_"//ftb4//".ftb","	",cent4,"	",fwhm4,>>filepar)
		}
		nftb[4]=ftb4
	}
	if(ftb5!=lixo) {
		if(retira==no){
			print("ftb5	",ftb5//".ftb","	",cent5,"	",fwhm5,>>filepar)
		}
		if(retira==yes){
			print("ftb5	","corr_"//ftb5//".ftb","	",cent5,"	",fwhm5,>>filepar)
		}
		nftb[5]=ftb5
	}
	if(ftb6!=lixo) {
		if(retira==no){
			print("ftb6	",ftb6//".ftb","	",cent6,"	",fwhm6,>>filepar)
		}
		if(retira==yes){
			print("ftb6	","corr_"//ftb6//".ftb","	",cent6,"	",fwhm6,>>filepar)
		}
		nftb[6]=ftb6
	}
	if(ftb7!=lixo) {
		if(retira==no){
			print("ftb7	",ftb7//".ftb","	",cent7,"	",fwhm7,>>filepar)
		}
		if(retira==yes){
			print("ftb7	","corr_"//ftb7//".ftb","	",cent7,"	",fwhm7,>>filepar)
		}
		nftb[7]=ftb7
	}
	if(ftb8!=lixo) {
		if(retira==no){
			print("ftb8	",ftb8//".ftb","	",cent8,"	",fwhm8,>>filepar)
		}
		if(retira==yes){
			print("ftb8	","corr_"//ftb8//".ftb","	",cent8,"	",fwhm8,>>filepar)
		}
		nftb[8]=ftb8
	}
	if(ftb9!=lixo) {
		if(retira==no){
			print("ftb9	",ftb9//".ftb","	",cent9,"	",fwhm9,>>filepar)
		}
		if(retira==yes){
			print("ftb9	","corr_"//ftb9//".ftb","	",cent9,"	",fwhm9,>>filepar)
		}
		nftb[9]=ftb9
	}
	if(ftb10!=lixo) {
		if(retira==no){
			print("ftb10	",ftb10//".ftb","	",cent10,"	",fwhm10,>>filepar)
		}
		if(retira==yes){
			print("ftb10	","corr_"//ftb10//".ftb","	",cent10,"	",fwhm10,>>filepar)
		}
		nftb[10]=ftb10
	}


	if(access("combina_pol.par")) delete("combina_pol.par")
	copy(filepar,"combina_pol.par")

	if(inspec){
		combina_pol
		print("tiraespaco *") | cl
		i=1
		while(i<=num_ftb){
			print("limpa_mapa 1 "//nftb[i]//".ftb.inspec "//nftb[i]//".sel "//nftb[i]//".txt") | cl
			i=i+1
		}
		print("tiraespaco *") | cl
	}
	if(combina){
		if(retira){
			i=1
			while(i<=num_ftb){
				print("limpa_mapa 2 "//nftb[i]//".ftb.inspec "//nftb[i]//".ftb corr_"//nftb[i]//".ftb") | cl
				i=i+1
			}
		}
		combina_pol
	}
	
	
	# tiraespaco *
	# limpa -> de acordo com o modo!!!
	# tiraespaco *

	delete(filepar, ver-)

end 
