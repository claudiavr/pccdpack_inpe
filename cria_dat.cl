#
# Task que cria os dat a partir de uma lista de *mag.*
#
# Voce ja tem que ter os *mag.* criados
#
# Claudia V. Rodrigues - 01/10/98
# 
# modificado para admitir numero arbitratio de imagens um 1 datfile 
# 			CVR - Maio/2003
#

procedure	cria_dat (varim)

string	varim		{"", prompt="Input mag list"}
string  outdat		{"", prompt="Raiz do arquivo de saida"}
int	interval	{"", prompt="Numero de imagens em 1 datfile"}
#real	plate_zero	{prompt="Lamina position in the first image"}
struct  *flistvar

begin
	string 	varima,vtmpfile,namev,dat,arquivo
	int i,ext,num_dat

	varima=varim
        num_dat=interval-1

	# Create list of input star images in a temporary file
	vtmpfile = mktemp ("tmpvar")
	files (varima, > vtmpfile)
	flistvar = vtmpfile
	i = 0
	#
	while (fscan(flistvar, namev) != EOF) 
	{
	  i = i+1
	  # print (i,namev)
	  #
	  # escrevendo em num_dat datfiles a linha que necessitamos
	  for (j=i; j >= i-num_dat; j-=1)
	    {
	    #print (j, outdat//j)
	    if (j < 10)
		arquivo = outdat//".00"//j
	    else if ( j < 100)
		arquivo = outdat//".0"//j
	    else
		arquivo = outdat//"."//j
	    # deletando versao previa do arquivo
	    if (j == i)
	        if (access(arquivo)) delete(arquivo,ver-)		
	    txdump(namev,fields="image,msky,nsky,rapert,sum,area",
		expr="yes", >> arquivo)
	    }
#        print (" ", >> arquivo)
	}
	#
	for (j=i; j >= i-(num_dat-1); j-=1)
	  {
	  #print (j, dat//j)
	    if (j < 10)
		arquivo = outdat//".00"//j
	    else if ( j < 100)
		arquivo = outdat//".0"//j
	    else
		arquivo = outdat//"."//j
	    if (access(arquivo)) delete (arquivo, ver-)
	  }
	#
	for (j=-(num_dat-1); j <= 0; j+=1)
	  {
	  arquivo=outdat//".00"//j
	  if (access(arquivo)) delete (arquivo, ver-)
	  }
	#
	delete (vtmpfile, ver-)
end






