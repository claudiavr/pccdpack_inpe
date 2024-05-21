#	Calculo da Polarizacao de Estrelas a partir de
#	fotometria de abertura usando qphot ou apphot.
 

procedure pccd (filename)

string  filename     {prompt="Archivo de entrada (.dat)"}
int     nstars       {prompt="Numero de estrelas"}
int     nhw          {prompt="Numero de posicoes lamina"}
int     nap          {prompt="Numero de aperturas"}
string  calc         {enum="c|p", prompt="Calcita (c) / Polaroid (p)"}
real    readnoise    {prompt="Readnoise (adu)"}
real    ganho        {prompt="Ganho (e/adu)"}
real    deltatheta   {prompt="Delta do angulo"}
real    zero	     {prompt="Zero da Lamina"}
string  fileout      {prompt="Archivo de saida (.log)"}
string  fileexe      {prompt="Archivo pccd (.exe)"}

 
begin
  
 string file1, file2, roda
  
 file1 = "entrada"
 print ("'", filename, "'", >> file1)
 print (nstars, >> file1)
 print (nhw, >> file1)
 print (nap, >> file1)
 print (calc, >> file1)
 print (readnoise, >> file1)
 print (ganho, >> file1)
 print (deltatheta, >> file1)
 print (zero, >> file1)
 
 
 file2 = "roda"
 print ("rm ", fileout, >> file2)
 print ("/bin/time ", fileexe, " <", file1, " >&", fileout, >> file2)  
 
 
 !source roda
 delete entrada
 delete roda
   
  
end 
  
