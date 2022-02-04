Alguns codigos devem ser compilados no fortran do unix outros no fortran do IRAF.

== DENTRO DO IRAF

-- fc (fortran do IRAF)

phot_pol_e.f


== NO TERMINAL UNIX

-- gfortran ou equivalente (fortran do Unix)

pccd4000*
ordem_ie.f
estat_cl.f90

gfortran -ffixed-line-length-132 pccd4000*.f -e XXX.e

OU

gfortran -ffixed-line-length-132 pccd4000*.f -o XXX.e




