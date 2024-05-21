procedure compara

string file_pix        {prompt = "lista de pixels"}
string file_img        {prompt = "imagem"}
string file_out        {prompt = "arquivo de saida"}

struct *flist1
struct *flist2

begin

int    id, xint, yint
real   xpix, ypix
struct line1
string linedata


#flist1 = file_pix 

#while(fscan(flist1,line1) != EOF) {
#    linedata = fscan(line1,xpix,ypix)
#    xint=int(xpix)
#    yint=int(ypix)
#    print(xint," ",yint)
   
#}     
      
end