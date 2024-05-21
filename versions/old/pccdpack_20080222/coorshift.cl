#
# Ver. Oct02
#


procedure coorshift

string infile        {prompt="imalign output file"}
string coorfile      {prompt="coordinate file to shift (.ord)"}
bool   cria = yes    {prompt="create coordinate files?"}

bool   corrige = yes {prompt="eliminate borders stars?"}
real   xside         {prompt="x ccd size (pixels)?"}
real   yside         {prompt="y ccd size (pixels)?"}
real   deltax        {prompt="x-minimum distance to the border (pixels)?"}
real   deltay        {prompt="y-minimum distance to the border (pixels)?"}

struct *flist 

begin
     int nl = 0
     int nlc = 0
     real   xshift, yshift, xcenter1, xcenter2, ycenter1, ycenter2, id1, id2, xlim, ylim
     string linedata, linedata1, linedata2, imagem,lix,signo1,signo2,saida,temp1
     bool   sinal = no 
     struct line, line1, line2
     
     print("Analyzing file...")

     temp1 = mktemp("tmp$coor")
      
     if (corrige == yes) {
     
         flist  = infile
         while (fscan(flist,line) != EOF) {
         
             if (line =="")
                 sinal = no
                    
             if (sinal == yes )  
                 linedata = fscan(line,imagem,xshift,lix,yshift,lix,lix,lix)
               
             if ((substr(line,1,2) == "#!") || (substr(line,1,2) == "#S")) {
	          sinal = yes
             }
         }
         
         cp(coorfile,coorfile//".old")
         
         flist = coorfile
         print("#XCENTER YCENTER ID", >> temp1)
         
         while (fscan(flist,line1) != EOF) {
             
             if (nl > 0) {
                 linedata1 = fscan(line1,xcenter1,ycenter1,id1)
                 linedata2 = fscan(flist,line2) 
                 linedata2 = fscan(line2,xcenter2,ycenter2,id2)
                 
                 
                 if (xshift < 0 && yshift < 0) {
                 
                     xlim = xside + xshift - deltax
                     ylim = yside + yshift - deltay
                     
                     if (xcenter1 < xlim && xcenter2 < xlim && ycenter1 < ylim && ycenter2 < ylim) {
                         print(xcenter1, " ", ycenter1," ",id1, >> temp1)
                         print(xcenter2, " ", ycenter2," ",id2, >> temp1)
                         nlc += 1

                     }
                 }

                 if (xshift > 0 && yshift > 0) {

                     xlim = xshift + deltax
                     ylim = yshift + deltay

                     if (xcenter1 > xlim && xcenter2 > xlim && ycenter1 > ylim && ycenter2 > ylim) {
                         print(xcenter1, " ", ycenter1," ",id1, >> temp1)
                         print(xcenter2, " ", ycenter2," ",id2, >> temp1)
                         nlc += 1
                        
                     } 
                 }
                 
                 if (xshift > 0 && yshift < 0) {
                 
                     xlim = xshift + deltax
                     ylim = yside + yshift - deltay
                     
                     if (xcenter1 > xlim && xcenter2 > xlim && ycenter1 < ylim && ycenter2 < ylim) {
                         print(xcenter1, " ", ycenter1," ",id1, >> temp1)
                         print(xcenter2, " ", ycenter2," ",id2, >> temp1)
                         nlc += 1
                        
                     } 
                 }    
                     
                 if (xshift < 0 && yshift > 0) {
                 
                     xlim = xside + xshift - deltax
                     ylim = yshift + deltay
                     
                     if (xcenter1 < xlim && xcenter2 < xlim && ycenter1 > ylim && ycenter2 > ylim) {
                         print(xcenter1, " ", ycenter1," ",id1, >> temp1)
                         print(xcenter2, " ", ycenter2," ",id2, >> temp1)
                         nlc += 1
                        
                     } 
                 }    
                  
             }
             nl += 1
         }    
         
     
     print(" ")
     print("shift   (X,Y) : ", xshift, " ", yshift)
     print("delta   (X,Y) : ",deltax," ",deltay)      
     print("limits  (X,Y) : ",xlim," ",ylim)
     print("filtered objects ",nlc)
     print(" ")
     
     del(coorfile)
     copy(temp1,coorfile)
     del(temp1)

     }

     nl=0
     flist  = infile
     if (cria == yes) {
         while (fscan(flist,line) != EOF) {
     
            if (line =="")
                sinal = no
     
            if (sinal == yes ) {
            
                linedata = fscan(line,imagem,xshift,lix,yshift,lix,lix,lix)
                nl += 1
                saida = coorfile//nl//".shf"
                unlearn filecalc
                print ("creating coordinate file for "//imagem//" xshift "//xshift//" yshift "//yshift)

                if (xshift > 0)
                    signo1= "-"
                else
                    signo1 = "+"
                    
                if (yshift > 0)
                    signo2= "-"
                else
                    signo2 = "+"    
                
            #    filecalc.files       = coorfile    
             #   filecalc.expressions = "$1@1"//signo1//abs(xshift)//";$2@1"//signo2//abs(yshift)
                filecalc.format      = "%6.2f %6.2f"
                if (nl < 10)
                    filecalc (coorfile, "$1@1"//signo1//abs(xshift)//";$2@1"//signo2//abs(yshift), > "coorde"//"0"//nl//".ord")
                else
                    filecalc (coorfile, "$1@1"//signo1//abs(xshift)//";$2@1"//signo2//abs(yshift), > "coorde"//nl//".ord")
                unlearn filecalc
            
            
            }
                
            if ((substr(line,1,2) == "#!") || (substr(line,1,2) == "#S")) {
                sinal = yes    
            }
         }
      del("inord")   
      dir("coorde*.ord",ncol=1, > "inord")
      flist=""
         
     }
end

