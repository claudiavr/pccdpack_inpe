procedure listgraf

string file_sel      {prompt="arquivo de saida do SELECT (.sel)"}
string file_log       {prompt="arquivo de saida do PCCD (.log)"}

bool   postype   = no  {prompt="posicoes da lamina sao contiguas?"}
bool   metafiles = no  {prompt="deseja arquivos metacode da saida?"}
struct *flist        
struct line          {length=160}

begin

     int nn = 0
     int star, aperture
     string linedata, lix
     
     
     
     flist = file_sel
     while (fscan (flist, line) != EOF ) {
         nn = nn+1
         if (nn > 2) {
             
             linedata = fscan(line, lix,lix,lix,lix,lix,lix,lix,lix, aperture, star)
             print (nn, " ",aperture," ", star)
             graf.file_in   = file_log
             graf.estar     = star
             graf.eaperture = aperture
             graf.postype   = postype
             graf.metafile  = no
             
             if (star < 10) {
                 graf , >G "star0"//star//".mc"
                 stdgraph("star0"//star//".mc")
             } else   {
                 graf , >G "star"//star//".mc"
                 stdgraph("star"//star//".mc")  
             }
             
         }
     } 
     
     #if (metafiles == yes) {
          
     #    gkimosaic.input  = "star*.mc"
     #    gkimosaic.device = stdgraph
     #    gkimosaic.output =    
             
     
            
        
end             

 
 
 
 
