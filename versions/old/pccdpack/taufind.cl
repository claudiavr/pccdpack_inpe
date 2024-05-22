#
# Ver. Oct/03
#
#

procedure	taufind(indat)

string  indat		{prompt="Input file"}
string  outmac		{prompt="Macrol output file"}
string  emin="first"    {prompt="macrol: minimum? (first|full)"}
int	platebeg = 90	{prompt="Initial tau (degrees)"}
int	plateend = 180	{prompt="Final tau (degrees)"}
int	passo =1	{prompt="step for tau (degrees)"}

begin
	string arqin,arqout,outlog,arqmac
	real plate,tau
	int i
	string file_tau
	string file_full0, file_full1
	string file_rms, file_rms_tau

	# arquivo de entrada
	arqin = indat
	outlog = "lixolog"
	arqmac = "macrol.in"

	file_tau = mktemp("tmp$tau")
		
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
	
	  pccdgen(filename=arqin,wavetype="other",retar=plate,fileout=arqout)
	  #delete (outdat//j, ver-)

	  print(i,>> file_tau)
	  }
	#
	delete(arqmac,ver-)
	files(outlog//"*", >> arqmac)
	macrol(file_in="@"//arqmac,file_out=outmac,minimun=emin)
	delete(arqmac,ver-)
	delete(outlog//"*",ver-)

        file_full0      = mktemp("tmp$tau")
	file_rms        = mktemp("tmp$tau")

        unlearn filecalc
        filecalc(outmac//".out","$1;$2;$3;$4;$5;$6;$7;$8;$9;$10;$11",lines="2-",
                 format="%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%7.1f%10.5f%10.7f%4.0f%4.0f",>file_full0)
	filecalc(outmac//".out","$9",lines="2-",format="%10.7f",> file_rms)

        file_full1        = mktemp("tmp$tau")
	file_rms_tau      = mktemp("tmp$tau")

        unlearn tmerge
	unlearn sgraph
	unlearn axispar
        axispar.xlabel = "tau"

        tmerge(file_tau//","//file_rms,file_rms_tau,"merge")
	axispar.ylabel = "rms"
        sgraph(file_rms_tau)

        tmerge(file_tau//","//file_full0,file_full1,"merge")
        type(file_full1)

        del(outmac//".out",ver-)
        copy(file_full1,outmac//".out")

        del(file_full0,ver-)
        del(file_full1,ver-)
	del(file_rms,ver-)
	del(file_rms_tau,ver-)


end







