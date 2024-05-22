# Package script task for the PCCDPACK package
# mar/05

# load necessary packages

print ('loading necessary packages ...')


language
print ('language')
bool motd = no
stsdas
print ('stsdas')
graphics
print ('graphics')
stplot
print ('stplot')
digiphot
print ('digiphot')
daophot
print ('daophot')
apphot
print ('apphot')
fitting
print ('fitting')
ctio
print ('ctio')
astutil
print ('astutil')
gasp
print ('gasp')


set      eraprog          = "/Users/claudiarodrigues/iraf/pccdpack/"
set      specperaprog      = "/Users/claudiarodrigues/iraf/pccdpack/specp/"

package  pccdpack            
 

#set     helpdb           = "eraprog$pccdpack.db"
#set      helpdb           = "eraprog$helpdb.mip"

task     macrol           = "eraprog$macrol.cl"
task     ordem            = "eraprog$ordem.cl"
task     pccd             = "eraprog$pccd.cl"
task     select           = "eraprog$select.cl"
task     conta            = "eraprog$conta.cl"
task     extincao         = "eraprog$extincao.cl"
task     specp            = "specperaprog$specp.cl"
task     graf             = "eraprog$graf.cl" 
task     coorshift        = "eraprog$coorshift.cl"
task     refer            = "eraprog$refer.cl"
task     extpol           = "eraprog$extpol.cl"
task     grafep           = "eraprog$grafep.cl"
task     magnit           = "eraprog$magnit.cl"
task     vecplot          = "eraprog$vecplot.cl"
task     fintab           = "eraprog$fintab.cl"
task     listgraf         = "eraprog$listgraf.cl"
task     selstat          = "eraprog$selstat.cl"
task     checkcen         = "eraprog$checkcen.cl" 
task     compara          = "eraprog$compara.cl"
task     pospars          = "eraprog$pospars.par"
task     pccdgen          = "eraprog$pccdgen.cl"
task     quickpol         = "eraprog$quickpol.cl"
task     correfer         = "eraprog$correfer.cl"
task     taufind          = "eraprog$taufind.cl"
task     zerofind         = "eraprog$zerofind.cl"
task     prepiv           = "eraprog$prepiv.cl"
task     extfib           = "eraprog$extfib.cl"
task     peaks            = "eraprog$peaks.cl"
task     align            = "eraprog$align.cl"
task     aperquick        = "eraprog$aperquick.cl"

type pccdpack$welcome


clbye ()