# Package script task for the PCCDPACK package

# load necessary packages

imred
kpnoslit
stsdas

set      alexeraprog      = "/iraf/extern/pccdpack/specp/"

package  specp            
 

#set     helpdb           = "eraprog$pccdpack.db"
#set     helpdb           = "eraprog$helpdb.mip"

task     calcpol            = "alexeraprog$calcpol.cl"
task     $apallsp        = "alexeraprog$apallsp.cl"
task     $limpa     = "alexeraprog$limpa.cl"
task     mosaic           = "alexeraprog$mosaic.cl"
task     bina           = "alexeraprog$bina.cl"
task     inter            = "alexeraprog$inter.cl"
task     grafico           = "alexeraprog$grafico.cl"
task     cfiltro           = "alexeraprog$cfiltro.cl"
task     cinter           = "alexeraprog$cinter.cl"
task     ajflat           = "alexeraprog$ajflat.cl"
task     average           = "alexeraprog$average.cl"
task     quplot            = "alexeraprog$quplot.cl"

clbye ()


