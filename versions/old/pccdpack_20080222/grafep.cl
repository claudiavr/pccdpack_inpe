#
# Ver. Aug05
#

procedure grafep

string    file_epl        {prompt="Arquivo de entrada (.epl)"}
bool      outgraph = no   {prompt="Cria criar file eps?"}      
bool      erro = no       {prompt="plotear erros de polarizacao?"}
real      escala = 100    {prompt="escala x decccurvas?"}
struct    *flist          


begin

string fileigi, file1, file2, linedata1, aa, bb, cc, dd, ee, ff, gg, hh, ii, lixo
real   maxx, maxy, minx, c1, c2, rms, npts, e_c1, e_c2
struct line1

fileigi = mktemp("tmp$grafep")

#fileigi = "igi"

print("erase", >> fileigi)
#print("location 0.1 0.9 0.5 0.9", >> fileigi)
print("move -0.06 1", >> fileigi)
print ("label a)", >> fileigi)
print("move -0.06 0.42", >> fileigi)
print ("label b)", >> fileigi)


print ("window 1 2 2", >> fileigi)
print ("data "//file_epl, >> fileigi)
print ("xcol 1; ycol 3; yevaluate y*100", >> fileigi)

unlearn tstat
tstat (file_epl,outtable = "",column = 1)
maxx = tstat.vmax
minx = tstat.vmin
unlearn tstat
tstat (file_epl,outtable = "",column = 2)
maxy = tstat.vmax

print ("limits; margin 0.04", >> fileigi)
#print ("limits 0 "//maxx*1.1//" 0 "//maxy*1.1*100, >> fileigi)
print ("expand .5 ; ptype 4 1; points", >> fileigi)
if (erro == yes) { 
    print ("ecol 4; eevaluate e*100", >> fileigi)
    print ("etype 2; errorbar 2; errorbar -2", >> fileigi)
#    print ("ecol 2; eevaluate e*1", >> fileigi)
#    print ("etype 2; errorbar 1; errorbar -1", >> fileigi)
}    
print ("xcol 1; xevaluate r/"//escala, >> fileigi)
print ("ycol 3; yevaluate 3*r/"//escala, >> fileigi)
print ("expand .5; ptype 0 0", >> fileigi)
print ("ltype 0 ; connect; box", >> fileigi)
print ("xcol 1; xevaluate r/"//escala, >> fileigi)
print ("ycol 3; yevaluate 4.5*r/"//escala, >> fileigi)
print ("expand .5; ptype 0 0", >> fileigi)
print ("ltype 6 ; connect; box", >> fileigi)


print ("xlabel A\dV (mag)", >> fileigi)
print ("ylabel P\dV (%)", >> fileigi)
#print ("title  Polarization vs. Extinction "//file_epl, >> fileigi)


print ("window 1", >> fileigi)
print ("data "//file_epl, >> fileigi)
print ("xcol 1;ycol 3; yevaluate y*100/x", >> fileigi)
print ("limits; margin 0.04", >> fileigi)
#print ("limits 0 "//maxx*1.1//" 0 "//maxy*1.1*100/minx, >> fileigi)
if (erro == yes) {
    print ("ecol 4; eevaluate e*100/x", >> fileigi)
    print ("etype 2; errorbar 2; errorbar -2", >> fileigi)
#    print ("ecol 2; eevaluate e*1", >> fileigi)
#    print ("etype 2; errorbar 1; errorbar -1", >> fileigi)
}  
print ("expand .5 ; ptype 4 1; points", >> fileigi)  
print ("box", >> fileigi)
print ("xlabel A\dV (mag)", >> fileigi)
print ("ylabel P\dV / A\dV  (% mag\\\u-1\\d)", >> fileigi)
#print ("title Polarization  Efficiency "//file_epl, >> fileigi)

file1 = "tab"
file2 = "as"
unlearn nfit1d
nfit1d.function = "user"
nfit1d.interactive = no
#nfit1d.errors = yes

unlearn userpars
userpars.function = "c1*x**(1-c2)"
userpars.c1       =  1
userpars.c2       =  1
userpars.v2       =  yes 

lixo = file_epl//" 1 3"

nfit1d(lixo,file1)

prfit(file1, >> file2) 

flist = file2


while (fscan (flist, line1) != EOF) {

      linedata1 = fscan(line1,aa,bb,cc,dd,ee,ff,gg,hh,ii)
      
      if (substr(line1,1,9) == "Function:") 
           rms = real(dd)
     
      if (substr(line1,1,6) == "Units:") 
           npts = real(dd)
 
      if (substr(line1,1,2) == "c1") {
           c1   = real(substr(cc,1,strlen(cc)-1))
           e_c1 = real(substr(dd,1,strlen(dd)-1)) 
      }
      
      if (substr(line1,1,2) == "c2") {
           c2   = real(substr(cc,1,strlen(cc)-1))
           e_c2 = real(substr(dd,1,strlen(dd)-1)) 
      }
           
}
delete (file1//".tab")
delete (file2)
print ("npts   : ",npts)
print ("Ajuste: Pv/Av = "//c1*100//"("//e_c1*100//") Av** "//(-1*c2)//"("//e_c2//")")
print ("rms   : ",rms*100)


print ("xcol 1; xevaluate r/"//escala, >> fileigi)

print ("ycol 2; yevaluate "//c1*100//"*(r/"//escala//")**"//(-1*c2), >> fileigi)
print ("expand .5; ptype 0 0", >> fileigi)
print ("ltype 6 ; connect; box", >> fileigi)
print ("expand 0.7", >> fileigi)
print ("vmove 0.6 0.80; putlab 9 npts: "//npts, >> fileigi)
print ("vmove 0.6 0.75; putlab 9 rms : "//rms*100, >> fileigi)
print ("vmove 0.6 0.70; putlab 9 P\dV / A\dV = "//c1*100//"("//e_c1*100//") A\dV \\\u"//(-1*c2)//"("//e_c2//")", >> fileigi)




unlearn igi
igi < fileigi//""



if (outgraph == yes) {
          delete(file_epl//".eps")
          
     #     igi <igi, >G temp1   
     #     print("criando PostScript...")
     #     unlearn psikern
     #     psikern.device = "psi_port"
     #     psikern.output = file_epl//".eps"
     #     psikern("temp1")
     #     delete ("temp1", ver-)
          
          igi < fileigi//"", >G file_epl//".mc"    
          set stdplot = epsh
          stdplot(file_epl//".mc")
          sleep 1 
          rename ("sgi*.eps",file_epl//".eps")
          delete(file_epl//".mc")
}
    
unlearn igi 
delete (fileigi)
end
