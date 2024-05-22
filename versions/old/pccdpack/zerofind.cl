#
# Ver. Oct/03
#
######### CVR - Oct-2009
# Retirei a opcao fixa da tipo de lamina na chamada do pccdgen. Estava wave=other. Agora
# usara o que estiver setado no pccdgen.
#####################
######### CVR - Oct-2014
# Incluido header 
#####################


procedure	zerofind(indat)

string  indat			{prompt="Input file"}
string  outmac			{prompt="Macrol output file"}
string  emin="first"    {prompt="macrol: minimum? (first|full)"}
int	platebeg = 0		{prompt="Initial zero (degrees)"}
int	plateend = 90		{prompt="Final zero (degrees)"}
int	passo =1			{prompt="step for zero (degrees)"}

begin
	string arqin,arqout,outlog,arqmac
	real plate,zero
	int i
	string file_zero
	string file_full0, file_full1, file_header, file_full2
	string file_rms, file_rms_zero

	# arquivo de entrada
	arqin = indat
	outlog = "lixolog"
	arqmac = "macrol.in"

	file_zero = mktemp("tmp$zero")

	for (i=platebeg; i <= plateend; i+=passo)
	  {
	  plate=i
	  if (i < 10)
	        {
		arqout = outlog//".00"//i
	        }
          else {  if ( i < 100)
                     {
		     arqout = outlog//".0"//i
		     }
		   else
                     {
		     arqout = outlog//"."//i
		     }
                }
	  #print (i,frac(i/16.),plate)

	  pccdgen(filename=arqin,zero=plate,fileout=arqout)
	  #delete (outdat//j, ver-)

	  print(i,>> file_zero)
	  }

	delete(arqmac,ver-)
	files(outlog//"*", >> arqmac)
	macrol(file_in="@"//arqmac,file_out=outmac,minimun=emin)
	delete(arqmac,ver-)
	delete(outlog//"*",ver-)

        file_full0      = mktemp("tmp$zero")
	file_rms        = mktemp("tmp$zero")

        unlearn filecalc
        filecalc(outmac//".out","$1;$2;$3;$4;$5;$6;$7;$8;$9;$10;$11",lines="2-",
                 format="%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%7.1f%10.5f%10.7f%4.0f%4.0f",>file_full0)
	filecalc(outmac//".out","$9",lines="2-",format="%10.7f",>> file_rms)

    file_full1        = mktemp("tmp$zero")
	file_rms_zero      = mktemp("tmp$zero")

    unlearn tmerge
	unlearn sgraph
	unlearn axispar
    axispar.xlabel = "zero"

    tmerge(file_zero//","//file_rms,file_rms_zero,"merge")
	axispar.ylabel = "rms"
    sgraph(file_rms_zero)

    tmerge(file_zero//","//file_full0,file_full1,"merge")
    file_header        = mktemp("tmp$zero")
    file_full2        = mktemp("tmp$zero")
    print("Lamina    V       SIGMAV      Q        U       SIGMA        P     THETA  SIGMAth.     rms   APER. STAR", >> file_header)
	type(file_full1, >> file_header)
    type(file_header)

    del(outmac//".out",ver-)
    copy(file_header,outmac//".out")

    del(file_full0,ver-)
    del(file_full1,ver-)
    del(file_header,ver-)
	del(file_rms,ver-)
	del(file_rms_zero,ver-)

end







