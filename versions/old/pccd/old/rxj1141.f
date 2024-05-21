	Program PCCD
c
c	Correcao da fotometria de rxj1141. superposicao de imagens
c	ordinaria e extraordinaria.
c
c						v. Mar 21 97
c
c	Mudada dimensao de a() de 10 para 19	13 Oct 92
c	Mudada dimensao de ano,ane,areao,areae para 7	15 Apr 94.
c	Testado ok na Argus.
c       Numero maximo de aberturas= 15
c       Numero de estrelas=30    *    06 Jun 95    *    VEM - CVR
c
c       ano(# estrelas, pos. lamina, aberturas)
c
	implicit real*8 (a-h, o-z)
	dimension ano(30,64,15), skyo(30,64)
	dimension ap(15), areao(30,64,15), a(60)
 	dimension areaso(30,64)
	character*60 filename
	character*12  image
	character*350 line
c
        common/delta/deltatheta,ganho,npsky
c
	read *, filename
c	filename = filename(1:index(filename,' ')-1) // '.dat'
c
	read*, nstars
c
	read*, nhw
c
	read*, nap
c
c Le numero (nao valor) da abertura a ser subtraida
c
	read*, nsub
c
	open(8, file=filename, status='old')
c
	do i=1, nhw
		do j=1, nstars
			read(8,'(a)') line
			image = line(1:index(line,' '))
			read(line(index(line,' '):),*) (a(l),
     $							l=1,2+3*nap)
c      			print*,a 
c			stop
			skyo(j,i) = a(1)
			areaso(j,i) =a(2)
			if (i.eq.1 .and. j.eq.1) then
				do k=1, nap
					ap(k) = a(2+k)
				end do
			end if
			do k=1, nap
				ano(j,i,k) = a(2+nap+k)
			end do
			do k=1, nap
				areao(j,i,k) = a(2+nap+nap+k)
			end do
		end do
		cont=ano(3,i,nsub)-areao(3,i,nsub)*skyo(3,i)
	        do k=1,nap
		  ano(2,i,k)=ano(2,i,k)-cont
		end do
		do j=1,2
		  write(6,100) image,skyo(j,i),areaso(j,i),(ap(k),k=1,nap),
     * (ano(j,i,k),k=1,nap),(areao(j,i,k),k=1,nap)
		end do
	end do
c
	close (unit=8)
100  	format(a12,f10.5,f6.0,8f5.1,16f11.4)
c
	end
