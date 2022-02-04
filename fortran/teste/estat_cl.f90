! Programa estat_cl escrito em 22/06/2011
! Para ser usado de dentro da rotina clestat.
!! VERSAO ORIGINAL FEITA POR VICTOR DE SOUZA MAGALHAES
!
! MODIFICADO EM OUTUBRO/2014 - CLAUDIA V. RODRIGUES
! INSTRUCOES TRADUZIDAS PARA INGLES
!
program estat_cl
implicit real (v)
real coordsx(1000),coordsy(1000),ceu(1000),psf(1000),sigma(1000),difx(1000),dify(1000),mag(1000),difmag(1000)
real somaceu,somapsf, somadifx,somadify, somadesvx, somadesvy, somadifmag, somasigma, sky
integer file_in,file_out,cont,error
file_in=15
file_out=16
open(unit=file_in,file="clestat.dao",action='read',status='old',iostat=error)
i=0
cont=0
somaceu=0
somapsf = 0
somasigma = 0
somadifx = 0
somadify = 0
somadifmag = 0
somadesvx =0
somadesvy = 0
k=1
l=1

do while (i<100)
   i=i+1
   if(i<=2) then
      read(file_in,*)
   else
	  read(file_in,*,iostat=error)var1,var2,var3,var4,var5,var6,var7
      if(error==0) then
         cont=cont+1
         coordsx(cont)=var1
		 coordsy(cont)=var2
		 ceu(cont)=var3
		 sigma(cont)=var4
		 psf(cont)=var5
		 mag(cont)=var7
		 !write(*,*) coordsx(cont),coordsy(cont),ceu(cont),sigma(cont),psf(cont),mag(cont) 
      end if
   end if
end do
close(file_in)
do j=1, cont
	somaceu = somaceu+ceu(j)
	somapsf = somapsf+psf(j)
	somasigma = somasigma+sigma(j)
end do
!write(*,*)somaceu,somapsf,somasigma
do while (k<=cont/2)
	difx(k)=coordsx(2*k)-coordsx(2*k-1)
	dify(k)=coordsy(2*k)-coordsy(2*k-1)
	difmag(k)=mag(2*k)-mag(2*k-1)
	somadifx = somadifx + difx(k)
	somadify = somadify + dify(k)
	somadifmag = somadifmag + difmag(k)
	k = k +1
end do
!write(*,*)somadifx,somadify,somadifmag
do while (l<=cont/2)
	somadesvx = somadesvx + ((difx(l)-(2*somadifx/cont))**2)
	somadesvy = somadesvy + ((dify(l)-(2*somadify/cont))**2)
	l=l+1
end do
errox= sqrt((somadesvx)/(l-1))
erroy= sqrt((somadesvy)/(l-1))
sky=somaceu/cont
skysigma=somasigma/cont
!skysigma=sqrt(sky)
!write(*,*)"<Difference in X>    <Difference in Y>  <Dispersion in X>  <Dispersion in Y>  <Dispersion in mag>"
!write(*,*)2*somadifx/cont,2*somadify/cont,errox,erroy,2*somadifmag/cont
!write(*,*)"Sky_average   Sky_dispersion       PSF"
!write(*,*)somaceu/cont,somasigma/cont,somapsf/cont

open(unit=file_out,file="estat.log")
write(file_out,*)"   Delta(X)        Delta(Y)        Sigma(X)        Sigma(Y)        Sigma(mag)"
write(file_out,*)2*somadifx/cont,2*somadify/cont,errox,erroy,2*somadifmag/cont
write(file_out,*)"Sky_average       Sky_sigma          PSF"
write(file_out,*)sky,skysigma,somapsf/cont
close(file_out)

end

