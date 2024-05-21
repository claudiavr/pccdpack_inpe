#
# Ver. Oct05
#


procedure peaks

string infile              {prompt="imalign output files (@)"}
string prefix              {prompt="prefix images"}
string output="peaks.log"  {prompt="output file"}
int   deltax=10            {prompt="x-margin (pixels)?"}
int   deltay=10            {prompt="y-margin (pixels)?"}

struct *flist
struct *flist0

begin

     string linedata, imagem, lix, line0, temp1, temp2
     int    prefixlen, imagelen, num,xmin, xmax, ymin, ymax
     real   xpos, ypos, xpos1, xpos2, ypos1, ypos2
     bool   sinal = no

delete(output, ver-)

temp1 = mktemp("tmp$peaks")
temp2 = mktemp("tmp$peaks")
prefixlen = strlen(prefix)

flist0 = infile

while (fscan(flist0,line0) != EOF) {

     flist = line0

     while (fscan(flist,line) != EOF) {

#          print(line)


	  if (substr(line,1,2) == "#R") sinal = no

          if ((sinal == yes ) && (substr(line,1,2) != "")) {
                 linedata = fscan(line,imagem,xpos,lix,ypos,lix,num)
		 imagelen=strlen(imagem)
		 imagem = substr(imagem,prefixlen+1,imagelen)
#                 print(imagem, xpos, ypos, num)

                 if (num == 1) {
	             xpos1 = xpos
	             ypos1 = ypos

                 }

                 if (num == 2) {
	             xpos2 = xpos
	             ypos2 = ypos


                     xmin = int(min(xpos1,xpos2))
	             xmax = int(max(xpos1,xpos2))
	             ymin = int(min(ypos1,ypos2))
	             ymax = int(max(ypos1,ypos2))

#		     print(xmin, xmax, ymin, ymax)
		     xmin=xmin-deltax
		     xmax=xmax+deltax
		     ymin=ymin-deltay
		     ymax=ymax+deltay
#		     print(xmin, xmax, ymin, ymax)

imstat(imagem//"["//xmin//":"//xmax//","//ymin//":"//ymax//"]",fields="image,max",>> temp1)
                 }


          }


          if (substr(line,1,2) == "#C") sinal = yes

     }

flist=""

}

type(temp1)
unlearn filecalc
filecalc(temp1,"$2", > temp2)
unlearn sgraph
unlearn dvpar
sgraph(temp2)

copy(temp1,output)

del(temp1,ver-)
del(temp2,ver-)

flist0=""



end

