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
int	  		nstars      {3, min=0, prompt="Numero de estrelas"}
int	  		nhw         {min=0, prompt="Numero de posicoes da lamina"}
int       	nap         {min=0, prompt="Numero de aberturas"}
int       	comp        {min=0, prompt="Numero da estrela de comparacao"}
int       	star_out    {0, prompt="Estrela que nao eh incluida na soma dos fluxos, alem da comp"}
string    	file_in     {prompt="Arquivo com saida txdump"}
string    	file_out    {prompt="Nome archivo de saida"}
string      photexe     {"/Users/claudiarodrigues/pccdpack_inpe/git/fortran/phot_pol.e",prompt="Phot_pol execute file (.e)"}
real	  	ganho	    {prompt="Ganho - e/adu"}

begin 

string out,in,input_exe,file2

#print ("oi")

out=file_out
in=file_in

#photexe = "/Users/claudiarodrigues/pccdpack_inpe/git/fortran/phot_pol.e"
#pccdpack_inpe.pccdgen_inpe.fileexe=fileexe
#
input_exe = "input_phot_pol.dat"
if (access(input_exe)) delete(input_exe,ver-)

print(in,>> input_exe)
print(out,>> input_exe)
print(nstars,>> input_exe)
print(nhw,>> input_exe)
print(nap,>> input_exe)
print(comp,>> input_exe)
print(star_out,>> input_exe)
print(ganho,>> input_exe)
  
if (access(out)) delete(out,ver-)

file2 = "roda"
if (access(file2)) delete(file2,ver-)

#print (fileexe, " <", input_exe, " >&", fileout, >> file2)
print (photexe, " <", input_exe, >> file2)
!source roda
 
#pccdpack_inpe.phot_pol_e(in,out,nstars,nhw,nap,comp,star_out,ganho)  
delete(file2, ver-)
delete(input_exe, ver-)

end 
  
