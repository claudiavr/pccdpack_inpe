### Ver Nov.05

procedure selstat (file_sel)

string file_sel     {prompt="Arquivo de entrada: SELECT (.sel)"}
struct *flist
struct line         {length=160}

begin
  
 
  real xcenter, ycenter, p, q, u, theta, sigma, deltatheta, cq, cu, qq, uu
  int  nl = 0
  int  star
  string linedata, lix, line0, linedata1, file_aux, file_aux2, filesel
 
  filesel = file_sel
  
  delete(filesel//".sta", ver-)
  
  file_aux = mktemp("tmp$aux")
   
  
 
  flist = filesel
 
 
  while (fscan(flist, line) != EOF) {
         linedata = fscan(line,xcenter,ycenter,p,theta,q,u,sigma,lix,lix,star)
         nl = nl + 1
          
         if (nl == 1) {
             line0 = substr(line,stridx("dt",line),strlen(line))
             linedata1 = fscan(line0,lix,deltatheta,lix,cq,lix,cu)          
         }
            
         if (nl > 2) {
             if (p != 0 && theta != deltatheta && q != cq && u != cu && sigma != 0) {
                 print(p, theta, sigma, 28.65 * sigma / p, q, u, >> file_aux)
        
             }
         }        
  }  
  

  
  print("calculando...")
 
  file_aux2 = mktemp("tmp$aux")
 
  tstat(file_aux,5)
  print(file_aux," objects ",tstat.nrows, >> file_aux2)
  print("",>> file_aux2)
  print("              mean    stddev    median    min     max",>> file_aux2)
  qq = tstat.mean
  
  print("Q           ", int(tstat.mean*1e5)/1e5, " ",
                        int(tstat.stddev*1e5)/1e5, " ",
                        int(tstat.median*1e5)/1e5, " ",
                        int(tstat.vmin*1e5)/1e5, " ", 
                        int(tstat.vmax*1e5)/1e5, >> file_aux2)
   
  tstat(file_aux,6)
  uu = tstat.mean
  print("U           ", int(tstat.mean*1e5)/1e5, " ",
                        int(tstat.stddev*1e5)/1e5, " ",
                        int(tstat.median*1e5)/1e5, " ",
                        int(tstat.vmin*1e5)/1e5, " ", 
                        int(tstat.vmax*1e5)/1e5, >> file_aux2)
 
 
  print("Pmean = sqrt(q^2 + u^2) ", int(sqrt(qq**2+uu**2)*1e5)/1e5,>> file_aux2)
  tstat(file_aux,1)
  print("P           ",int(tstat.mean*1e5)/1e5, " ", int(tstat.stddev*1e5)/1e5, " ", int(tstat.median*1e5)/1e5, " " //
         int(tstat.vmin*1e5)/1e5, " ", int(tstat.vmax*1e5)/1e5, >> file_aux2)
  tstat(file_aux,2)
  print("theta       ",int(tstat.mean*1e5)/1e5, " ", int(tstat.stddev*1e5)/1e5, " ", int(tstat.median*1e5)/1e5, " " //
         int(tstat.vmin*1e5)/1e5, " ", int(tstat.vmax*1e5)/1e5, >> file_aux2)
  tstat(file_aux,3) 
  print("sigma_pol   ",int(tstat.mean*1e5)/1e5, " ", int(tstat.stddev*1e5)/1e5, " ", int(tstat.median*1e5)/1e5, " " //
         int(tstat.vmin*1e5)/1e5, " ", int(tstat.vmax*1e5)/1e5, >> file_aux2)
  tstat(file_aux,4)
  print("sigma_theta ",int(tstat.mean*1e5)/1e5, " ", int(tstat.stddev*1e5)/1e5, " ", int(tstat.median*1e5)/1e5, " " //
         int(tstat.vmin*1e5)/1e5, " ", int(tstat.vmax*1e5)/1e5, >> file_aux2)
  
  
  print(" ",>> file_aux2)
  print(" ")

  copy(file_aux2,filesel//".sta")
  type(filesel//".sta")      
  
  delete(file_aux,ver-)
  delete(file_aux2,ver-)
  flist=""
end            

