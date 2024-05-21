procedure extpol

string   file_ext   {prompt="Arquivo de entrada de EXTINCAO (.ext)"}
string   file_txt   {prompt="Arquivo de entrada de REFER (.txt)"}
string   file_out   {prompt="Arquivo de saida (.epl)"}
bool     elim = yes {prompt="Eliminar estrelas com Av = 0?"}
struct   *flist0
struct   *flist1
struct   *flist2 
struct   line1      {length=160}
struct   line2      {length=160}

begin
 int nl2 = 0
 int nl1 = 0
 int nlines
 real xcelda, ycelda, extincao, starextincao, deltax, deltay
 real xleft, xright, ybottom, ytop, erro_ext
 real xstar, ystar, pol, theta, sigma
 bool acho = no
 string lix, linedata1, linedata2, filetxt,temp0, fileout
 struct ftxt
 
 filetxt = file_txt

 fileout = mktemp("tmp$extpol")
 
 if (substr(filetxt,1,1) != "@") {
    temp0 = mktemp("tmp$extpol")
    print(filetxt, >> temp0)
    filetxt = temp0
    
 } else {

    filetxt =  substr(filetxt,2,strlen(filetxt))

 }    
 
 
 
 flist0 = filetxt
 flist2 = file_ext
 
 
 
 while (fscan(flist0, ftxt) != EOF) {
  print(ftxt)
  flist1 = ftxt
  
 unlearn tstat
 tstat (ftxt,outtable = "",column = 1)
 nlines = tstat.nrows
 print(nlines)
 
 nl1 = 0

 
 
 while (fscan (flist1, line1) != EOF) {
 
        flist2 = file_ext
        nl1 = nl1 + 1
        
       
        
           linedata1 = fscan(line1, xstar, ystar, pol, theta, sigma)
        
           while (fscan (flist2, line2) != EOF) {
               
               
               
                  nl2= nl2 + 1
                  linedata2 = fscan(line2, xcelda, ycelda, extincao,lix,lix,lix,lix,lix,lix,lix, erro_ext)   
               
                  if (nl2 == 1) {
                      deltax = xcelda
                      deltay = ycelda
                  }
               
                  xleft   = xcelda - deltax
                  xright  = xcelda + deltax
                  ybottom = ycelda - deltay
                  ytop    = ycelda + deltay  
                 
               
               
               
                  if (xstar >= xleft && xstar < xright && ystar >= ybottom && ystar < ytop && pol != 0) {
               
                      starextincao = extincao
                      if (elim == yes) {
                        if (starextincao != 0) {
                          print (starextincao, int(erro_ext*1e3)/1e3, pol, sigma, >> fileout)
                          acho = yes
                          }
                       
                      } else {
                          print (starextincao, int(erro_ext*1e3)/1e3, pol, sigma, >> fileout)
                          acho = yes
                      }
                  } 
                   
                   
               
               
             }       
           
           
          if (nl1 != (nlines-1) && nl1 != nlines) { 
           
              if (acho == no ) print("out of limits", >>fileout) 
              if (acho == yes) acho = no
          }
 
 
 } 
 
}
 
if (substr(file_txt,1,1) != "@") delete (temp0, ver-) 

if (access(file_out)) delete(file_out,ver-)
copy(fileout,file_out)
delete(fileout,ver-)
 

end       

