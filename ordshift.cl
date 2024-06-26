#
##### Claudia VR - Outubro/2014
#
# Removed calls for ctio.filecalc
##
##### Claudia VR - Julho/2014
#
# acrescentei ver- nos deletes
#
##### Claudia VR - Junho/2011
#
# Foram feitas varias alteracoes:
# 1 - determina quais os shifts maximos e minimos em x e y
# 2 - usa-se os valores acima em conjunto com o deltax e deltay para
#     criar limites diferenciados a esquerda, a direita, acima e abaixo
# 3 - Foi introduzida uma variavel que eh de saida
#
##### Claudia VR - Abril/2010
#
# Modificacao do coorshift do Antonio Pereyra
# O input file eh a saida do xregister
#####################################

procedure ordshift

string infile        {prompt="xregister output file"}
string coorfile      {prompt="coordinate file to shift (.ord)"}
bool   cria = yes    {prompt="create coordinate files?"}
bool   corrige = yes {prompt="eliminate borders stars?"}
real   xside=2048.   {prompt="x ccd size (pixels)?"}
real   yside=2048.   {prompt="y ccd size (pixels)?"}
real   deltax = 0.   {prompt="x-minimum distance to the border (pixels)?"}
real   deltay = 0.   {prompt="y-minimum distance to the border (pixels)?"}
int    nobj          {prompt="Remaining objects"}

struct *flist 

begin
     int nl = 0
     int nlc = 0
     int nlines = 0 
     real   xshift, yshift, xcenter1, xcenter2, ycenter1, ycenter2, id1, id2
     real   xshiftmin, yshiftmin, xshiftmax, yshiftmax, xlimmin, ylimmin, xlimmax, ylimmax
     real xnew,ynew,xx[30000],yy[30000],dertax,dertay
     string linedata, linedata1, linedata2,imagem,lix,signo1,signo2,saida,temp1
     string nome_arquivo
     bool   sinal = no 
     struct line, line1, line2, lixo

#########################     
### creating vectors with coordinates of the file to shift
##
     flist = coorfile
     linedata2 = fscan(flist,lix) 
     while (fscan(flist,line1) != EOF) {
                 linedata1 = fscan(line1,xcenter1,ycenter1,id1)
                 nlines += 1
                 # print(nlines,xcenter1,ycenter1)
                 if (nlines > 30000) {
                                 error (1,"More than 30000 stars!")
                 }
#                 print (xcenter1,ycenter1)                 
                 xx[nlines] = xcenter1 
                 yy[nlines] = ycenter1 
     }
#     print("ordshift 1")
#
################################
#
     print("Analyzing file...")

     temp1 = mktemp("tmp$coor")
     # print(temp1)
      
     if (corrige == yes) {
     
         flist  = infile
         xshiftmin=0
         xshiftmax=0
         yshiftmin=0
         yshiftmax=0
         while (fscan(flist,line) != EOF) {
                 linedata = fscan(line,imagem,xshift,yshift)
	         if (xshift > 0) {
                   if (xshift > xshiftmax) xshiftmax=xshift 	
	         }
                 else
                   if (xshift < xshiftmin) xshiftmin=xshift 
	         if (yshift > 0) {
                   if (yshift > yshiftmax) yshiftmax=yshift 	
	         }
                 else
                   if (yshift < yshiftmin) yshiftmin=yshift 
         }


         cp(coorfile,coorfile//".old")
         
         flist = coorfile
         print("#XCENTER YCENTER ID", >> temp1)
         while (fscan(flist,line1) != EOF) {
             if (nl > 0) {
                 linedata1 = fscan(line1,xcenter1,ycenter1,id1)
                 linedata2 = fscan(flist,line2) 
                 linedata2 = fscan(line2,xcenter2,ycenter2,id2)
                 # print (line1)
                 # print (xcenter1,xcenter2,ycenter1,ycenter2)                 
                 xlimmin = deltax + xshiftmax
                 ylimmin = deltay + yshiftmax
                 xlimmax = xside + xshiftmin - deltax
                 ylimmax = yside + yshiftmin - deltay
                 if (xcenter1 > xlimmin && xcenter1 < xlimmax && ycenter1 > ylimmin && ycenter1 < ylimmax) {
                  if (xcenter2 > xlimmin && xcenter2 < xlimmax && ycenter2 > ylimmin && ycenter2 < ylimmax) {
                         print(xcenter1, " ", ycenter1," ",id1, >> temp1)
                         print(xcenter2, " ", ycenter2," ",id2, >> temp1)
                         nlc += 1
                  }
                 }
             }
             nl += 1
         }    
             
     # print(" ")
     # print("Shifts  (Xmin,Xmax,Ymin,Ymax) : ", xshiftmin, " ", xshiftmax, " ", yshiftmin, " ", yshiftmax)
     # print("delta   (X,Y) : ",deltax," ",deltay)      
     # print("Limits  (Xmin,Xmax,Ymin,Ymax) : ",xlimmin," ",xlimmax," ",ylimmin," ",ylimmax)
     # print("Remaining objects ",nlc)
     # print(" ")
     
     del(coorfile,ver-)
     copy(temp1,coorfile)
     del(temp1,ver-)

     }

     nl=0
     flist  = infile
     if (cria == yes) {
         delete("coorde*.ord",ver-)
         while (fscan(flist,line) != EOF) {
     
                linedata = fscan(line,imagem,xshift,yshift)
                nl += 1
                saida = coorfile//nl//".shf"
#                unlearn filecalc
                print ("creating coordinate file for "//imagem//" xshift "//xshift//" yshift "//yshift)

                if (xshift > 0)
#                    signo1= "-"
					 dertax = xshift * (-1)
                else
#                    signo1 = "+"
 					 dertax = abs(xshift)                   
                    
                if (yshift > 0)
#                    signo2= "-"
					 dertay = yshift * (-1)
                else
#                    signo2 = "+"    
 					 dertay = abs(yshift)                   
                
            #    filecalc.files       = coorfile    
            #    filecalc.expressions = "$1@1"//signo1//abs(xshift)//";$2@1"//signo2//abs(yshift)
            #   filecalc.format      = "%6.2f %6.2f"
                if (nl < 10)
					nome_arquivo = "coorde"//"000"//nl//".ord"
                else
                if (nl < 100)
					nome_arquivo = "coorde"//"00"//nl//".ord"
                else
                if (nl < 1000)
					nome_arquivo = "coorde"//"0"//nl//".ord"
				else
					nome_arquivo = "coorde"//nl//".ord"
#
#         print(nlines)
         for (i = 1; i < nlines+1 ; i = i + 1) {
#            print(xx[i]+dertax, yy[i]+dertay)
            print(xx[i]+dertax, " ", yy[i]+dertay," ", >> nome_arquivo)
		 }

         }
         
      if (access("inord")) del("inord",ver-)   
      dir("coorde*.ord",ncol=1, > "inord")
      flist=""        
     }
     nobj=nlc
end

