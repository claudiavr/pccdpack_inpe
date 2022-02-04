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
#
# CVR - Nov 2014
# when possible, changed calls to *_inpe tasks
#
##################


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
	string file_full0,file_full1,file_header,file_full2,file_final
	string file_rms, tab_macrol, tab_zero, tab_total

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

	  pccdpack_inpe.pccdgen_inpe(filename=arqin,zero=plate,fileout=arqout)
	  #delete (outdat//j, ver-)

	  print(i,>> file_zero)
	  }

	delete(arqmac,ver-)
	files(outlog//"*", >> arqmac)
	macrol_inpe(file_in="@"//arqmac,file_out=outmac,minimun=emin)
	delete(arqmac,ver-)
	delete(outlog//"*",ver-)

    file_full0      = mktemp("tmp$full0")
	file_rms        = mktemp("tmp$rms")
	file_final        = mktemp("tmp$final")

######
# criando tabela com resultados do macrol
#
	tab_macrol = mktemp("tmp$tab_macrol")
	tcreate(tab_macrol,cdfile="pccdpack_inpe$zerofind_header_1.txt",datafile=outmac//".out",nskip=1)
#
	tab_zero = mktemp("tmp$tab_zero")
	tcreate(tab_zero,cdfile="pccdpack_inpe$zerofind_header_2.txt",datafile=file_zero,nskip=0)
#
# criando arquivo com RMS
#
    stty ncols=200
 	tdump(tab_macrol,cdfile="",pfile="",datafile=file_rms,columns="RMS")
 	tdump(tab_macrol,cdfile="",pfile="",datafile=file_full0,columns="")
# 
#    unlearn filecalc
#        filecalc(outmac//".out","$1;$2;$3;$4;$5;$6;$7;$8;$9;$10;$11",lines="2-",
#                 format="%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%7.1f%10.5f%10.7f%4.0f%4.0f",>file_full0)
#	filecalc(outmac//".out","$9",lines="2-",format="%10.7f",>> file_rms)

    file_full1        = mktemp("tmp$full1")

# Fazendo o grafico
#
    unlearn tmerge
	unlearn sgraph
	unlearn axispar
    axispar.xlabel = "zero"
	axispar.ylabel = "rms"
    sgraph(file_rms)
    sgraph(file_rms)

# Juntando tabela com valores da posicao da lamina e resultados da polarimetra
#
    tmerge(file_zero//","//file_full0,file_full1,"merge")
    file_header        = mktemp("tmp$zero")
    file_full2        = mktemp("tmp$zero")
    print("Lamina      V          SIGMAV          Q              U           SIGMA           P            THETA      SIGMAth.          rms          APER.        STAR", >> file_header)
	concatenate(file_header//","//file_full1, file_final)
#	unlearn tmerge
#    tmerge(file_header//","//file_full1,file_final,"app")
    type(file_final)
    del(outmac//".out",ver-)
    copy(file_final,outmac//".out")

    del(file_full0,ver-)
    del(file_full1,ver-)
    del(file_header,ver-)
	del(file_rms,ver-)
	del(tab_macrol//".tab",ver-)
	del(tab_zero//".tab",ver-)
	del(file_final,ver-)
	del(file_zero,ver-)
	stty ncols=80
end








