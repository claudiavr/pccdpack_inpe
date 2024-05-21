#
# Ver. Nov05
#


procedure checkcen (files_mag,star,aperture)

string files_mag     {prompt="*.mag.?"}
int    star          {prompt="star number to analyze?"}
real   aperture      {prompt="aperture ?"}
bool   cont = yes    {prompt="continue ?",mode="q"}

struct *flist
struct line          {length=160}

begin
  
 
   real   xinit,yinit,xcenter,ycenter,annulus,dannulus,msky,nsky
   real   razon, raper, sum, area, apertura, valor
   int    nl=0
   int    id, junk, nstar, i, pos, rig, lef, top, bot
   string image,linedata, file_aux, file_aux1, lixo, temp1, filesmag, imagem1
   real   p[10]
   int    xlong, ylong
      
   
   filesmag = files_mag
   nstar = star 
   apertura = aperture
  
   temp1 = mktemp ("tmp$mag")
   dir(filesmag,ncol=1,>>temp1)
   flist = temp1
   linedata = fscan(flist,imagem1)
   delete (temp1, ver-)
   
   unlearn pdump
   temp1 = mktemp ("tmp$mag")
   pdump (imagem1,"rapert","id == 1", >> temp1)
   
   flist = temp1
   linedata = fscan(flist,line)
   i = 0
   line = line//" "
   while (strlen(line) != 0) {
       i = i + 1
       
       while (substr (line,1,1) == " ") 
              line = substr (line,2,strlen (line))
       p[i] = real(substr (line,1,stridx (" ",line)))
       line = substr (line,stridx (" ",line)+1,strlen (line))
           
   }
   
      
   delete (temp1, ver-)
   
   for (i = 1; i <= 10; i +=1) {
              razon = abs(apertura - p[i])
              if (apertura == 0) pos = 1       
              if (mod(razon,10) < 1e-14) pos = i 
          }
  
  
   file_aux = mktemp("tmp$aux")
   lixo = mktemp("tmp$aux")
   
   txdump(filesmag,
         "image,xinit,yinit,xcenter,ycenter,id,annulus,dannulus,msky,nsky,raper["//pos//"],sum["//pos//"],area["//pos//"]",
         "id >= "//2*nstar-1//" && id <= "//2*nstar, >> file_aux)
   
#   txdump(filesmag,
#         "image,id,annulus,dannulus,msky,nsky,raper["//pos//"],sum["//pos//"],area["//pos//"]",
#         "id >= "//2*nstar-1//" && id <= "//2*nstar)
  
   flist = file_aux
   while (fscan(flist, line) != EOF) {
         linedata = fscan(line,image,xinit,yinit,xcenter,ycenter,id,
                          annulus,dannulus,msky,nsky,raper,sum,area)
          
         valor = sum - (area*msky)                 
         print(image," ",id," ",annulus," ",dannulus," ",msky," ",
               nsky," ",raper," ",sum," ",area, " ",int(valor*1e2)/1e2)
   
   }
   
   flist = ""
   
   
  flist = file_aux
  while (fscan(flist, line) != EOF) {
         linedata = fscan(line,image,xinit,yinit,xcenter,ycenter,id,
                          annulus,dannulus,msky,nsky,raper,sum,area)
         
         nl = nl + 1
     
         if (mod(nl,2) == 1 && cont) {

             imgets(image,"i_naxis1")
             xlong = int(imgets.value)
             imgets(image,"i_naxis2")
             ylong = int(imgets.value)
             
             lef = int(xinit-100)
	     if (lef <= 0 ) lef = 1

             rig = int(xinit+100)
	     if (rig >= xlong ) rig = xlong

             bot = int(yinit-50)
             if (bot <= 0 ) bot = 1

             top = int(yinit+150)
             if (top >= ylong ) top = ylong

    #          display(image,1, >> lixo)   # display imagem
             display(image//"["//lef//":"//rig//","//bot//":"//top//"]",1, >> lixo)   # display imagem
         }   
         
         file_aux1 = mktemp("tmp$aux")
         print(xinit,yinit, >> file_aux1)
         
               
         print(image," ",xinit,yinit)
         tvmark(1, file_aux1,mark="circle",color=204,radii=raper)   # mostra posicao inicial
         tvmark(1, file_aux1,mark="circle",color=204,radii=annulus)   # mostra posicao inicial
         tvmark(1, file_aux1,mark="circle",color=204,radii=annulus+dannulus)        
         del(file_aux1, ver-) 
         
         file_aux1 = mktemp("tmp$aux")
         print(xcenter,ycenter, >> file_aux1) 
         
            
         if (cont) {
             print(image," ",xcenter,ycenter)
             tvmark(1, file_aux1,mark="circle",color=205,radii=raper)     #mostra posicao final
             tvmark(1, file_aux1,mark="circle",color=205,radii=annulus)     #mostra posicao final
             tvmark(1, file_aux1,mark="circle",color=205,radii=annulus+dannulus)
         } else STOP
         
         unlearn pradprof
         pradprof(image,xcenter,ycenter,radius=annulus+dannulus,center=no)
         if (cont) {
             pradprof(image,xcenter,ycenter,radius=12,center=no)
         }    
         valor = sum-(area*msky)
         
         print(image," ",annulus," ",dannulus," ",msky," ",nsky," ",raper," ",
               sum," ",area," ",int(valor*1e2)/1e2)
         
         del(file_aux1, ver-) 
 
  }  
  
del(file_aux, ver-)
del(lixo, ver-)
flist=""
line=""
end            



