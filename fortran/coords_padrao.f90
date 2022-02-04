! Programa coords padrao reescrito em 17/06/2011

program coords_padrao
implicit real (c)
integer file_in,file_out

open(unit=file_in,file="imex_padrao")
read(file_in,*) 
read(file_in,*) 
read(file_in,*) coordsx1, coordsy1
read(file_in,*) 
read(file_in,*) coordsx2, coordsy2
close(file_in)
open(unit=file_out,file="padrao.coo", status="new")
write(file_out,*)"#XCENTER  YCENTER   ID"
write(file_out,*)coordsx1, coordsy1, "1"
write(file_out,*)coordsx2, coordsy2, "2"
close(file_out)
end program coords_padrao