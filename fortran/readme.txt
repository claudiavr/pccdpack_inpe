Alguns codigos devem ser compilados no fortran do unix, isto eh, fora do IRAF.

== NO TERMINAL UNIX

-- gfortran ou equivalente (fortran do Unix)

pccd4000*
ordem_ie.f
estat_cl.f90
phot_pol.f

gfortran -ffixed-line-length-132 pccd4000*.f -e XXX.e

OU

gfortran -ffixed-line-length-132 pccd4000*.f -o XXX.e




