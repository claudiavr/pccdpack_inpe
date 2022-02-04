#
# Dando o display de varias imagens
# Com a opção de colocar sempre no mesmo frame
# Precisa da pausa mesmo...
#
# Victor de Souza Magalhaes 05/06/2011

procedure disp_var (varim)

string	varim		{"", prompt="Input image list"}
int		fra			{prompt="frame a exibir a imagem"}
#bool	mesmo		{prompt="Exibe todas as imagens no mesmo frame?"}
struct  *flistvar

begin

	bool mesmo
	string 	varima,vtmpfile,namev,lixo
	int i
	i=0
	varima=varim
	mesmo=no

	# Create list of input star images in a temporary file
	vtmpfile = mktemp ("/tmp/tmpvar")
	files (varima, > vtmpfile)
	flistvar = vtmpfile


	while (fscan(flistvar, namev) != EOF) 
	{
	i=i+1
	print(i)
	print(namev)
	if(mesmo){
		display(image=namev,frame=fra)
	}
	else{
		display(namev)
	}
	}
  	delete(vtmpfile,ver-)
end
