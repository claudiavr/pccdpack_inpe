# 
# Script ORDEM  (Ver 1.40)
#
#
# Esse script roda um executavel (ordem_e.e) baseado na rotina
# acima escrita por A. Pereyra 
# 
# Claudia V. Rodrigues - 06/1999 & Victor de Souza Magalhaes - 05/2012
#
procedure ordem3 (file_in, file_out)
#
real   shiftx         {min=0, prompt="Distancia em pixels no eixo x do par de estrelas"}
real   shifty         {min=0, prompt="Distancia em pixels no eixo y do par de estrelas"}
real   deltax         {min=0, prompt="Erro no shiftx permitido"}
real   deltay         {min=0, prompt="Erro no shifty permitido"}
real   deltamag       {min=0, prompt="Erro em magnitude permitido"}
string file_in        {prompt="Archivo de coordenadas do DAOFIND"}
string file_out       {prompt="Nome arquivo de saida - sera acrescentada a extensao .ord"}
string side           {enum="right|left", prompt="Posicao par superior"}
bool   pripar=yes     {prompt="include only first pair?"}
 
begin 

string ffile_out,filepar

ffile_out=file_out//".ord"
print('Arquivo de saida: ',ffile_out)
filepar = mktemp("tmp$ordem3")
print("parametros de entrada",>>filepar)
print(file_in,>>filepar)
print(ffile_out,>>filepar)
print(shiftx,>>filepar)
print(shifty,>>filepar)
print(deltax,>>filepar)
print(deltay,>>filepar)
print(deltamag,>>filepar)
print(side,>>filepar)
print(pripar,>>filepar)

if(access("ord.par")) delete("ord.par",ver-)
copy(filepar,"ord.par")
ordem_ie

end 
  
