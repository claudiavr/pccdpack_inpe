#
# Task que faz a reducao de varios dat automaticamente
#
# Voce ja tem que ter os *dat* criados
#
# Se dados de l/2: corrige delta_theta de -45 a cada posicao da lamina
# Se dados de l/4: corrige zero_lam de +22.5 a cada posicao da lamina
#
# Claudia V. Rodrigues - 01/10/98
# modif. - Junho/2003 - inclui opcao de macrol
#    		      - inclui opcao l/2 ou l/4
#
# Outubro/2006 - considera as tasks do Antonio: macrol e pccdgen
#
##########################################################
##
## August/2015 - CVR
##
## * Task is aborted, if we got error from pccd_var.
##
##########################################################
##

procedure	pccd_var( )

int 	begindat	{prompt="Number of the first dat file"}
int 	enddat		{prompt="Number of the last dat file"}
string  indat		{prompt="Raiz do arquivo de entrada"}
string  outlog		{prompt="Raiz do arquivo de saida"}
bool	l2			{yes,prompt="Dados sao em l/2 (ou l/4)"}
real	delta_theta	{0.,prompt="Delta theta of the first image"}
real	plate_zero	{0.,prompt="Zero plate position in the first image"}
bool	nova=yes	{prompt="Are you using the new polarimetric drawer? (after 2007)"}
bool	macr		{yes,prompt="Passa macrol nos dados?"}
bool	erro=no		{prompt="Leave it no!"}

begin
	#string 	varima,vtmpfile,namev,dat
	string arqin,arqout,macrol_in,file_running
	real plate,zero,delta,passo
	int i
	bool ll2,mmacr,normalizacao,running
#		
	zero=plate_zero
	delta=delta_theta
	ll2=l2
	mmacr=macr
	macrol_in="macrolfile"
	file_running="pccdvar.running"
	if (access(macrol_in)) delete(macrol_in,ver-)
#
	pccdpack_inpe.pccdgen_inpe.new_mod=nova
    if (nova) {
       passo=-22.5
    }
    else {
       passo=22.5
    }
    
	if (ll2) {
	    pccdpack_inpe.pccdgen_inpe.wavetyp="half"
		pccdpack_inpe.pccdgen_inpe.retar=180.
	    }
 	    else {
		pccdpack_inpe.pccdgen_inpe.wavetyp="quarter"
		pccdpack_inpe.pccdgen_inpe.retar=90.
 	}


#	
	for (i=begindat; i <= enddat; i+=1)
#	  print(i)
	  {
	  if (ll2) {
	    plate=delta-frac((i-1)/8.)*360.
	    if (plate < 0) plate = plate + 180.
	    if (plate < 0) plate = plate + 180.
	    }
	    else {
	    plate = zero+passo*((mod(i,16)-1))
	    }
	  
	  if (i < 10) 
	        {
		arqout = outlog//".00"//i
		arqin = indat//".00"//i
	        } 
          else {  if ( i < 100) 
                     {
		     arqout = outlog//".0"//i
		     arqin = indat//".0"//i
		     } 
		   else 
                     {
		     arqout = outlog//"."//i
		     arqin = indat//"."//i
		     }
                }
	  #print (i,frac(i/16.),plate)
	  if (access(arqout)) delete (arqout,ver-)
	  if (ll2) {
	    pccdpack_inpe.pccdgen_inpe.deltatheta=plate
	    }
 	    else {
 	    pccdpack_inpe.pccdgen_inpe.deltatheta=delta
 	    pccdpack_inpe.pccdgen_inpe.zero=plate
 	    normalizacao=pccdpack_inpe.pccdgen_inpe.norm
	    if (normalizacao) {
			if (access(file_running)) delete(file_running,ver-)
	    	touch("file_running")
#			print("Datfile: ",i, >>"/tmp/convergencia.txt")
        }
 	  }
	  #delete (outdat//j, ver-)
	  pccdgen_inpe(filename=arqin,fileout=arqout)
	  erro=pccdgen_inpe.erro
	  if (erro == yes) {
	    	error (1," Error in pccdgen_inpe execution.")
 	  }
	  print(arqout, >> macrol_in)
	  }
#
# Passando macrol nos dados
#

	if ((mmacr) && (erro == no)) {
#	  if (ll2)
#        print("entrando no macrol")
	    macrol_inpe(file_in="@"//macrol_in,file_out=outlog,erro=erro)
#	    else
#	    macrol_inpe(file_in="@"//macrol_in,file_out=outlog)
	  delete (macrol_in, ver-)
	}
#	if ((lle == no) && (normalizacao)) delete(file_running,ver-)
end






