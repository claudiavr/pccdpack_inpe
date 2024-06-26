#
# Ver. Ago11
#
##################################
# CVR - agosto-2011
#  1- incluida a opcao do novo modulo polarimetrico que gira em sentido contrario e, portanto, da
#     o angulo da polarizacao linear e o sinal da polarizacao circular com sinais errados.
#  2 - o pccdgen para se o numero de linhas do datfile for inconsistente com parametros de
#	entrada
##########################################################
##
## August/2015 - CVR
##
## * Task is aborted, if we got errors.
##
##########################################################
##

#
procedure pccdgen_inpe(filename)

string  filename        {prompt="input file (.dat)"}
int     nstars          {prompt="number of stars (max. 2000)"}
string  wavetype        {enum="half|quarter|other|v0other", prompt="wave-plate used ? (half,quarter,other,v0other)"}
real    retar=180       {prompt="retardance of waveplate (degrees)"}
int     nhw             {prompt="number of total wave-plate positions in input file? (max. 16)"}
pset    pospars_inpe         {prompt="wave-plate positions used to calculus? :e"}
int     nap             {prompt="number of apertures (max. 10)"}
string  calc            {enum="c|p", prompt="analyser: calcite (c) / polaroid (p)"}
real    readnoise       {prompt="CCD readnoise (adu)"}
real    ganho           {prompt="CCD gain (e/adu)"}
real    deltatheta      {prompt="correction in polarization angle (degrees)"}
real    zero=0          {prompt="Zero of waveplate"}
string  fileout         {prompt="output file (.log)"}
string  fileexe         {prompt="pccd execute file (.exe)"}
bool    new_module = yes  {prompt="Did you use the new polarimetric module (after 2007)?"}
bool    norm = yes      {prompt="include normalization?"}
bool	erro = no		{prompt="Leave it no"}
struct  *flist
struct  line1            {length=1000}
struct  line2            {length=1000}

begin

 string file1, file2, roda, aa, temp0, file_name, image, tmp, dum,conti
 string filenorm
 int pt[16] = 16(0)
 int pu[16] = 16(0)
 int nhw_used = 0
 int posline = 1
 int i = 1
 int j = 1
 int k = 0
 int compara, calc_num, nrows

## VERIFICANDO SE ARQUIVO FILEEXE EXISTE - CVR
##
 if  (access (fileexe))
 	print (" pccd execute file exists!")
 else {
	print (fileexe)
	erro=yes
	error (1," pccd execute file does not exist!")
 } 
 ##
 
 if  (pospars_inpe.pos_1 == yes)  pt[1]  = 1
 if  (pospars_inpe.pos_2 == yes)  pt[2]  = 1
 if  (pospars_inpe.pos_3 == yes)  pt[3]  = 1
 if  (pospars_inpe.pos_4 == yes)  pt[4]  = 1
 if  (pospars_inpe.pos_5 == yes)  pt[5]  = 1
 if  (pospars_inpe.pos_6 == yes)  pt[6]  = 1
 if  (pospars_inpe.pos_7 == yes)  pt[7]  = 1
 if  (pospars_inpe.pos_8 == yes)  pt[8]  = 1
 if  (pospars_inpe.pos_9 == yes)  pt[9]  = 1
 if  (pospars_inpe.pos_10 == yes) pt[10] = 1
 if  (pospars_inpe.pos_11 == yes) pt[11] = 1
 if  (pospars_inpe.pos_12 == yes) pt[12] = 1
 if  (pospars_inpe.pos_13 == yes) pt[13] = 1
 if  (pospars_inpe.pos_14 == yes) pt[14] = 1
 if  (pospars_inpe.pos_15 == yes) pt[15] = 1
 if  (pospars_inpe.pos_16 == yes) pt[16] = 1

 for (i=1; i <= 16; i+=1) {
 nhw_used = nhw_used + pt[i]
 }
 
 if (nhw == 8) {
        
        ## case [1-4,9-12]

        if ((pt[5] == 0) && (pt[6] == 0) && (pt[7] == 0) && (pt[8] == 0)) {
            for (i=1; i <= 4; i+=1) pu[i] = pt[i]
            for (i=9; i <= 12; i+=1) pu[i-4] = pt[i]
        }

        ## case [1-4,8-11]

        if ((pt[5] == 0) && (pt[6] == 0) && (pt[7] == 0) && (pt[8] == 1) && (pt[9] == 1) && (pt[10] == 1) && (pt[11] ==1)) {
            for (i=1; i <= 4; i+=1)  pu[i] = pt[i]
            for (i=8; i <= 11; i+=1) pu[i-3] = pt[i]
        }

        ## case [1-8]
        if ((pt[1] == 1) && (pt[2] == 1) && (pt[3] == 1) && (pt[4] == 1) && (pt[5] == 1) && (pt[6] == 1) && (pt[7] == 1) && (pt[8] == 1))
            for (i=1; i <= 8; i+=1)  pu[i] = pt[i]

        ## case nhw_used < 8
	if (nhw_used < 8) {
	    for (i=1; i<=16; i+=1)  pu[i] = pt[i]
        }


 }
 else {
 for (i=1; i<=16; i+=1)  pu[i] = pt[i]
 }


 #for (i=1; i<=16; i+=1) {
 #print(pu[i])
 #}

 tmp = envget("tmp")
  
 file_name = filename

 ## checagem de consistencia entre .dat e (nstars,nhw,calc)
 # determinando numero de linhas do arquivo dat.*
 dum = mktemp("tmp$dum")
 count(file_name,> dum)
 # print (dum)
 flist = dum
 while (fscan(flist,line1) != EOF) {
 aa = fscan(line1,nrows)
 }
 # print(nrows)
 #
 if (calc == "c") calc_num = 2
 if (calc == "p") calc_num = 1
 compara = nstars*nhw*calc_num
 #print(compara)
#
 if (compara != nrows) {
     delete(dum,ver-)
     print("")
     print(" *** ERROR ****")
     print("The number of lines in the datfile is inconsistent with (nstars*nhw*calc)")
     print("Number of lines in the datfile: ",nrows)
     print("(nstars*nhw*calc): ",compara)
     print("nstars  ",nstars)
     print("nhw  ",nhw)
     print("calc  ",calc)     
     print("")
     erro=yes
     error(1,"-- pccdgen_inpe aborted --")
#     print("continue(y/n)?")
#     scan (conti)
#     if (conti == "n") print('oi')
     }
#
 delete(dum,ver-)
#
 #####

 copy(file_name,tmp,ver-)
 cd tmp

 temp0 = mktemp("pccdgen")
 flist = file_name

 for (i=1; i <= nhw; i += 1) {
      for (k=1; k <= nstars ; k += 1) {
           aa = fscan(flist,line1)
           if (calc_num == 2) aa = fscan(flist,line2)  ## 2007/jun/26

           if (pu[i] == 1) {
               print(line1, >> temp0)
               if (calc_num == 2) print(line2, >> temp0) ## 2007/jun/26
           }
      }
 }


 print("Extracting sequence of waveplate positions from ",file_name)

 flist = temp0
 while (fscan(flist,line1) != EOF) {
 aa = fscan(line1,image)
 print(image)
 }


 file1 = "entrada"
 if (access(file1)) delete(file1, ver-)

# print ("'", file_name, "'", >> file1)
 print ("'", temp0, "'", >> file1)
 print (nstars, >> file1)
 print (nhw, >> file1)
 print (nap, >> file1)
 print (calc, >> file1)
 print (readnoise, >> file1)
 print (ganho, >> file1)
 print (deltatheta, >> file1)
 print (zero, >> file1)
 print (wavetype, >> file1)
 i = 1
 while (i <= 16) {
 print (pt[i], >> file1)
 i = i + 1
 }
 print (nhw_used, >> file1)
 if (norm == no) print ("0",>> file1)
 if (norm == yes) print ("1",>> file1)
 if (wavetype == 'other') print (retar, >> file1)
 if (wavetype == 'v0other') print (retar, >> file1)
 if (new_module == no) print ("0",>> file1)
 if (new_module == yes) print ("1",>> file1)


 file2 = "roda"
 if (access(file2)) delete(file2,ver-)

 if (access(fileout)) delete(fileout,ver-)
 print (fileexe, " <", file1, " >&", fileout, >> file2)


 if ((wavetype == "quarter") && (norm == yes)) {
 if (access("pccdvar.running") == no)  {
        filenorm="convergencia.txt"
#        pwd
		touch("tmp$"//filenorm)
#		print("aqui -1 ")	
 }
 }
 !source roda
 delete(file1, ver-)
 delete(temp0, ver-)
 delete(file2, ver-)
 delete(file_name, ver-)

 dum = mktemp("tmp$dum")
 back > dum//""
# pwd
 if ((wavetype == "quarter") && (norm == yes)) {
 if (access("pccdvar.running") == no)  {
# 		print("aqui - 2")	
 		if (access (filenorm)) del(filenorm,ver-)
 	    if (access("tmp$"//filenorm)) rename("tmp$"//filenorm,".")
#		print("aqui - 3")	
 }
 }
 delete(dum,ver-)

 if (access(fileout)) delete(fileout,ver-)
 copy(tmp//fileout,".")
 delete(tmp//fileout,ver-)


end








