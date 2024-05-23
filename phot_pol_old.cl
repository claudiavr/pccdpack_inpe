# 
# Script phot_pol  (Ver 1.0)
#
#
# Esse script roda um executavel (phot_pol_e.e) baseado na rotina 
# 
# Claudia V. Rodrigues - 08/1999
#
######
# Junho/2008 - CVR
# modificacao de modo a pedir estrela de comparacao. Isto eh, referencia de fluxo.
######
#
procedure phot_pol (file_in, file_out)
#
int	  		nstars      {min=0, prompt="Numero de estrelas"}
int	  		nhw         {min=0, prompt="Numero de posicoes da lamina"}
int       	nap         {min=0, prompt="Numero de aberturas"}
int       	comp        {min=0, prompt="Numero da estrela de comparacao"}
int       	star_out    {0, prompt="Estrela que nao eh incluida na soma dos fluxos, alem da comp"}
string    	file_in     {prompt="Arquivo com saida txdump"}
string    	file_out    {prompt="Nome archivo de saida"}
real	  	ganho	      {prompt="Ganho - e/adu"}
 
begin 

string out,in

out=file_out
in=file_in

if (access(out)) delete (out,ver-)
pccdpack_inpe.phot_pol_e(in,out,nstars,nhw,nap,comp,star_out,ganho)  
#print(ganho)

end 
  
