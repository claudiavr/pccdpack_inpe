#
# Ver. Jul03
#

procedure ordem (file_in, file_out)
real   shiftx         {min=0, prompt="x-axis distance of pair (in pixels)"}
real   shifty         {min=0, prompt="y-axis distance of pair (in pixels)"}
real   deltax=2       {min=0, prompt="error in x-axis distance permitted"}
real   deltay=2       {min=0, prompt="error in y-axis distance permitted"}
real   deltamag=1     {min=0, prompt="error in magnitude permitted"}

string file_in        {prompt="coordinate file from DAOFIND"}
string file_out       {prompt="output file"}
string side           {enum="right|left", prompt="position of top object (right|left)"}
 
struct *flist1         

begin
      int  id1, id2, imax , id[5000]
      int  npar = 0
      int  i = 0
      int  j = 0
      real xc[5000], yc[5000], mag[5000]
      real shiftxinf, shiftxsup, shiftyinf, shiftysup, shiftx1
      real xc1, yc1, mag1
      real xc2, yc2, mag2
      real difx, dify, deltamagx, difmag, lix1, lix2

      string outfile, fileold, file0
      struct line1, line2, linedata1, linedata2

      # Da valor logico a posicao do par superior
      if (side == "left")
          shiftx1 = -1 * shiftx
        else  
          shiftx1 = shiftx
 
      # Inicializa o puntero de comparacao da estrela 1 'flist1' 
      # ao archivo (.coo) 
      flist1    = file_in
      
       
      deltamagx = deltamag
      
      # Define nome de archivo de saida (.ord)
      outfile = file_out
      delete(outfile//".ord",ver-)
      outfile = outfile // ".ord"
      file0 = mktemp("tmp$ordem")
      
      # Define rangos de comparacao X do 'shiftx'  
      shiftxinf = shiftx1 - deltax
      shiftxsup = shiftx1 + deltax
      
      # Define rangos de comparacao Y do 'shifty'
      shiftyinf = shifty - deltay  
      shiftysup = shifty + deltay
      
      # Imprime cabecario no archivo de saida
      print ("#XCENTER  YCENTER   ID", >> file0)
      
 
      while (fscan (flist1, line1) != EOF) {
      
          
          if (substr (line1,1,1) != "#") {
          
              i = i + 1
              linedata1 = fscan(line1, xc1, yc1, mag1, lix1, lix1, lix1, id1)
              xc[i] = xc1
              yc[i] = yc1
              id[i] = id1
              mag[i]= mag1
          }
      }
      
      imax = i
       
                   
      for (i=1 ; i<=imax ; i+=1) {
      
          xc1  = xc[i]
          yc1  = yc[i]
          mag1 = mag[i]
          id1  = id[i]
     
          for (j=1 ; j<=imax ; j+=1) {
          
                
               if (j > i) {
               
                   xc2  = xc[j]
                   yc2  = yc[j]
                   mag2 = mag[j]
                   id2  = id[j]
                
                   difx   =  xc2 - xc1
                   dify   =  yc2 - yc1
                   difmag =  abs (mag1 - mag2)
               
 
                   if (difx < shiftxsup) {
                       if (difx > shiftxinf) {
                  
                           if (dify < shiftysup) {
                               if (dify > shiftyinf) {
                                     
                                       
                                   if (difmag < deltamagx) {
                                               
                                       npar = npar + 1
                                             
                                       
                                       print ("PAIR ", npar)
                                       print ("        ", xc1, " ", yc1, " ", id1)
                                       print ("        ", xc2, " ", yc2, " ", id2)
                                             
                                       print (xc1, " ", yc1, " ", id1, >> file0)
                                       print (xc2, " ", yc2, " ", id2, >> file0)
                                   }    
                              }    
                          }   
                      }
                  }
              }      
          }
      }
                
copy(file0,outfile)
delete(file0,ver-)
flist1=""
      
   
end
