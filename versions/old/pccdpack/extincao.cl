#	Calcula extincoes do archivo obtido pela tarefa 'conta' do
#       PCCDPACK.
 

procedure extincao 

string  filename     {prompt="Archivo de entrada de CONTA (.cou)"}
real    nceldacomp   {prompt="numero de estrelas de celda de comparacao"}
real    bslope       {prompt="slope de log n vs mag"}
real    correc=1     {prompt="fator de correcao na extinceldaao"}
real    nzero=0.1    {prompt="numero asumido para nzero"} 
string  fileout      {prompt="Archivo de saida (.ext)"}
struct  *flist       
struct  line         {length=160}
 
begin
 
 real   ncelda, nstar, xcelda, ycelda, decmin, decmax, erro_ext
 real   armininf, arminsup, armaxinf, armaxsup, extincao
 string linedata 
  
 flist = filename
 while (fscan (flist, line) != EOF) {
 
     linedata = fscan(line, xcelda, ycelda, nstar, ncelda, decmin, decmax, armininf, arminsup, armaxinf, armaxsup)
     if ( nstar > nceldacomp) {
         nstar = nceldacomp
     }
     if ( nstar == 0 ) {
         nstar = nzero
     }         
     extincao = log10 ( nceldacomp / nstar ) / bslope
     extincao = correc*extincao
     erro_ext = (correc/bslope) * sqrt( (nceldacomp + nstar) / (nceldacomp * nstar) )
     print ("Celda ", ncelda, " extincao ", int(extincao*1e3)/1e3, " erro ", int(erro_ext*1e3)/1e3 )
     print (xcelda, " ", ycelda, " ", int(extincao*1e3)/1e3, " ", ncelda, " ", decmin, " ", decmax, " ", armininf, " ", arminsup, " ", armaxinf, " ", armaxsup, " ", erro_ext, >> fileout)
     
 }   
 
end 
  
