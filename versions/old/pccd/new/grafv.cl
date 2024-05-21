procedure grafv

string file_in       {prompt = "arquivo de saida do PCCD (.log)"}
int    estar         {prompt = "numero de estrela a analizar"}
int    eaperture     {prompt = "abertura a analizar"}
real   zero	     {prompt = "Zero da Lamina "}
bool   postype = no  {prompt = "posicoes da lamina sao contiguas?"}
bool   metafile = no {prompt = "deseja arquivo metacode da saida?"}
struct *flist 

begin

     int    nl = 0
     int    nla = 0
     int    nstar = 0
     int    naperture = 0
     int    positions = 0
                  
     int    stars, apertures, apermin, i, j
     string lix, imagem, file1, file2, file3, file4
     struct line, line7, line10, line12, line14, line26, linestar
     struct lineaperture, linedata
     struct linegraf5, linegraf6, linegraf7, linegraf8 
     string kq,ku,ks,kp,kt,kst,kv,ksv
     real   v,sigmav,q,u,s,p,t,st, pi,r1, top1, top2, bot1, bot2, top, bot
     real   z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12,z13,z14,z15,z16
     real   z[16],cs,ss
 
     z = 0
     nl = 0
          
     # Inicializa o puntero de lectura 'flist' ao archivo (.log)
     flist = file_in
     
     print ("Analizando file... ")
     # Comeca letura do archivo (.log) com 'flist'
     while (fscan (flist, line) != EOF) {
      
         # Conta o numero de linha
         nl = nl + 1 
         
         # lee nome de imagem
         if (nl == 7)  
             line7 = fscan(line,imagem)

         # lee o numero de estrelas do arquivo de entrada (.log)
         if (nl == 10) {
             line10 = fscan (line, lix, lix, lix, lix, stars)
             if (estar > stars){
	         print("estrela escolhida e' maior que numero total de estrelas no file")
                 stop
             } 
         }
                       
	 # lee o numero de posicoes do arquivo de entrada (.log)
         if (nl == 12) 
             line12 = fscan (line, lix, lix, lix, lix, lix, positions)
          
         # lee o numero de aperturas do arquivo de entrada (.log) 
         if (nl == 14) 
             line14 = fscan (line, lix, lix, lix, lix, apertures)
             
         # lee tamanho da primeira apertura
         if (nl == 26) {
             line26 = fscan (line, lix, lix, apermin)
             if (eaperture > apertures+apermin || eaperture < apermin) {
                 print("abertura escolhida esta fora da faixa de aberturas no file")
                 stop
             }
         }    
                 
         # lee numero de estrela 
         if (substr (line,1,5) == " STAR" || substr (line,1,4) == "STAR")
               linestar = fscan(line,lix,lix,nstar,lix)
      
         # lee numero de abertura 
         if (substr (line,1,9) == " APERTURE" || substr (line,1,8) == "APERTURE")
               lineaperture = fscan(line,lix,lix,naperture)

                 
         if (nstar == estar && naperture == eaperture) {
             nla = nla + 1
             if (substr (line,1,4) == " NaN" || substr (line,1,3) == "NaN") {
               print("Abertura escolhida sem dados...")
               stop
             }
             
             if (nla == 3) { 
                 linedata = fscan(line,kv,ksv,kq,ku,ks,kp,kt,kst)
                 q  = real(kq)
                 u  = real(ku)
                 s  = real(ks)
                 p  = real(kp)
                 t  = real(kt)
                 st = real(kst)
		 v  = real(kv)
	         sigmav = real(ksv)
                 
             }    
                  
             if (nla == 6) {
                 linegraf5 = fscan(line, z1, z2, z3, z4)
                 z[1] = z1; z[2] = z2; z[3] = z3; z[4] = z4
             }    
                  
             if (nla == 7 && positions/4 > 1) {
                 linegraf6 = fscan(line, z5, z6, z7, z8)
                 z[5] = z5; z[6] = z6; z[7] = z7; z[8] = z8
             }
                                      
             if (nla == 8 && positions/4 > 2) {
                 linegraf7 = fscan(line, z9, z10, z11, z12)
                 z[9] = z9; z[10] = z10; z[11] = z11; z[12] = z12
             }
                         
             if (nla == 9 && positions/4 > 3) {
                 linegraf8 = fscan(line, z13, z14, z15, z16)
                 z[13] = z13; z[14] = z14; z[15] = z15; z[16] = z16 
             }
                         
         }  

     } 
     
     pi = 3.14159265359
     file1 = "ajuste"
     
     for (i=0; i <= 360; i += 1) {
	  ss=(zero + 2*i)*pi/180
	  cs=cos(ss)
	  ss=sin(ss)
	  r1 = q*cs*cs+u*ss*cs-v*ss
	  print (i, r1, >> file1)
     }                
     
     file2 = "dados"
     
     if (positions == 8 && postype == no) 
         for (j=0; j <= 3; j += 1) {
              z[9+j] = z[5+j]
              z[5+j] = 0
         }
   
     top1 = sqrt(abs(q)**2 + abs(u)**2)
     bot1 = -top1
     top2 = 0
     bot2 = 0
          
     for (i = 1; i <= 16; i+= 1) 
          if (z[i] != 0) {
              print (22.5*(i-1),z[i],s, >> file2)
              if (z[i] > top2)
                  top2 = z[i] 
              if (z[i] < bot2)
                  bot2 = z[i]   
          }        
     
   
    
                          
     if (top2 > top1)
         top1 = top2
         
     if (bot2 < bot1)
         bot1 = bot2
         

             
     file3 = "igi1"
   
     print ("erase", >> file3)
     print ("location .10 1 .10 .80", >> file3)
     print ("data "//file2, >> file3)
     print ("xcolumn 1; ycolumn 2; ecolumn 3", >> file3)
     print ("limits 0 360 "//bot1-st//" "//top1+st//"; margin .04", >> file3)
     print ("points", >> file3)
     print ("etype 1; errorbar 2; errorbar -2", >> file3)
    
     print ("data "//file1, >> file3)
     print ("xcolumn 1; ycolumn 2", >> file3)
     print ("limits 0 360 "//bot1-st//" "//top1+st//"; margin .04", >> file3)
     print ("connect", >> file3)
     
     print ("ticksize 11.25 45", >> file3)
     print ("notation 0 370 1e-3 2", >> file3)
     print ("expand 1.2; box", >> file3)
     print ("ltype 1; lweight 1", >> file3) 
     print ('xlabel "\\\iPosic\b\d\d \u\d,\d \\\ua\b\u\u \d\u~\\\do da Lamina (graus)"', >> file3)
     print ("ylabel '\\\iAmplitude de Modulac\b\d\d \u\d,\d \\\ua\b\u\u \d\u~\\\do'", >> file3)
	  
     print ("location .10 1 .80 .93", >> file3)
     print ("expand 1.7", >> file3)
     print ("fillpat 2", >> file3)
     print ("title "//imagem, >> file3)
	
     print ("vmove .05 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iQ'", >> file3)
     print ("vmove .15 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iU'", >> file3)
     print ("vmove .25 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iP'", >> file3)
     print ("vmove .35 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iSigmaP'", >> file3)
     print ("vmove .45 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iTHETA'", >> file3)
     print ("vmove .55 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iV.'", >> file3)
     print ("vmove .65 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iSigmaV.'", >> file3)
     print ("vmove .78 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iSIGMAth.'", >> file3)
     print ("vmove .90 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iAPERTURE'", >> file3)
	
    # q = int(q * 1e5) / 1e5
    # u = int(u * 1e5) / 1e5
    # print (q," ",u)
          
     print ("vmove .05 .85", >> file3)
     print ("justify 5; expand 1; label "//kq, >> file3)
     print ("vmove .15 .85", >> file3)
     print ("justify 5; expand 1; label "//ku, >> file3)
     print ("vmove .25 .85", >> file3)
     print ("justify 5; expand 1; label "//kp, >> file3)
     print ("vmove .35 .85", >> file3)
     print ("justify 5; expand 1; label "//ks, >> file3)
     print ("vmove .45 .85", >> file3)
     print ("justify 5; expand 1; label "//kt, >> file3)
     print ("vmove .55 .85", >> file3)
     print ("justify 5; expand 1; label "//kv, >> file3)
     print ("vmove .65 .85", >> file3)
     print ("justify 5; expand 1; label "//ksv, >> file3)
     print ("vmove .78 .85", >> file3)
     print ("justify 5; expand 1; label "//kst, >> file3)
     print ("vmove .90 .85", >> file3)
     print ("justify 5; expand 1; label "//eaperture, >> file3)
	
     
     unlearn igi 
     igi <igi1
     
     if (metafile == yes) {
          delete(imagem//".mc")  
          igi <igi1, >G imagem//".mc"
     }
      
     unlearn igi  
    
           
     delete(file1)
     delete(file2)
     delete(file3)
end 
  

 
 
 
 
 
