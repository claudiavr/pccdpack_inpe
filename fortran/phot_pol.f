c
c	program phot_pol (ver 1.0 - agosto/1999)
c
c	fortran-iraf para fazer fotometria de campos com calcita
c
c	Usa pccd do Antonio Mario Magalhaes
c
c
c	uso: phot_pol arq_mag
c
c
c Resumo:  
c
c	1. le arquivo com contagens - saida do phot 
c	2. calcula fluxo relativo a uma estrela de comparacao, comp  
c
c

	program phot_pol_e
c
c
c       Numero maximo de aberturas= 18
c       Numero de estrelas=100    *    06 Jun 95    *    VEM - CVR
c
c       ano(# estrelas, pos. lamina, aberturas)
c
	implicit real*8 (a-h, o-z)
	real ganho
	integer i,j,k,nap,nhw,nstars,comp,nout
	dimension ano(100,2000,18), ane(100,2000,18), skyo(100,2000)
	dimension an(100,2000,18),dif(100,2000,18), skye(100,2000)
	dimension ap(18), areao(100,2000,18), areae(100,2000,18), a(60)
	dimension areaso(100,2000),arease(100,2000),antot(100,2000)
	dimension ruido(100,18),erro(100,18),ceu(100,18)
	character*60 arq_in,arq_out
	character*12  image
	character*380 line
c
c
c	lendo parametros da linha de comando
c
Ccall clnarg(nargs)
Cif (nargs.eq.8) then
C	call clargc(1,arq_in,ier)
C	if (ier.ne.0) goto 100
C	call clargc(2,arq_out,ier)
C	if (ier.ne.0) goto 100
C	call clargi(3,nstars,ier)
C	if (ier.ne.0) goto 100
C	call clargi(4,nhw,ier)
C	if (ier.ne.0) goto 100
C	call clargi(5,nap,ier)
C	if (ier.ne.0) goto 100
C	call clargi(6,comp,ier)
C	if (ier.ne.0) goto 100
C	call clargi(7,nout,ier)
C	if (ier.ne.0) goto 100
C	call clargr(8,ganho,ier)
C	if (ier.ne.0) goto 100
Celse
C	write(*,*)'No. de parametros incorreto em PHOT_POL'
C	write(*,*)' '
C	write(*,*)'Uso: phot_pol ??? '
C	goto 110
Cendif
	
	read *, arq_in
	read *, arq_out
	read *, nstars
	read *, nhw
	read *, nap
	read *, comp
	read *, nout
	read *, ganho	
	
c
c	Verificando se valores de variaveis estao dentro do intervalo
c		permitido
c
	if (nap.gt.18) then
		print*, 'Numero de aberturas fora do limite'
		stop
	end if
	if (nstars.gt.100) then
		print*, 'Numero de estrelas fora do limite'
		stop
	end if
	if (nhw.gt.2000) then
		print*, 'Numero de laminas fora do limite'
		stop
	end if
c
c lendo arquivos com fotometria
c
	open(8,file=arq_in, status='old')
c
	do i=1, nhw
		do j=1, nstars
c			print*, j
			read(8,'(a)') line
			image = line(1:index(line,' '))
c			print*, line
			read(line(index(line,' '):),*) (a(l),
     $							l=1,2+3*nap)
c      			print*,a 
c			stop
			skyo(j,i) = a(1)
			areaso(j,i) =a(2)
c			print*
c			print*, skyo(j,i)
c			print*
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
c
		       	read(8,'(a)') line
			image = line(1:index(line,' '))
			read(line(index(line,' '):),*) (a(l),
     $							l=1,2+3*nap)
		 	skye(j,i) = a(1)
			arease(j,i) = a(2)
			do k=1, nap
			 	ane(j,i,k) = a(2+nap+k)
			end do
			do k=1, nap
				areae(j,i,k) = a(2+nap+nap+k)
			end do
c			print *, image
c			print *, (ap(k), k=1,nap)
c			print *, (ane(j,i,k), k=1,nap)
c			print *, (areae(j,i,k), k=1,nap)
c			print *, (ano(j,i,k), k=1,nap)
c			print *, (areao(j,i,k), k=1,nap)
c			print*, image, skyo(j,i), (ap(k), k=1,nap),
c     $				(ano(j,i,k), k=1,nap),
c     $				(areao(j,i,k), k=1,nap)
c     			print*, ' '
c			print*, image, skye(j,i), (ap(k), k=1,nap),
c     $				(ane(j,i,k), k=1,nap),
c     $				(areae(j,i,k), k=1,nap)
c 			    print*, ' '
c
		end do
	end do
c
	close (unit=8)
c
c
c	Calculando contagens de cada estrela
c
c
	open(8, file=arq_out, status='new')
	do i=1, nhw
	  do j=1, nstars
		do k=1,nap
c			write(8,*) ' j i k ', j,i,k
c			write(8,*) 'skyo skye ano areao ane areae '
c	write(8,*)  skyo(j,i),skye(j,i),ano(j,i,k),areao(j,i,k),ane(j,i,k),areae(j,i,k)
			ano(j,i,k)=ano(j,i,k)-skyo(j,i)*areao(j,i,k)
			ane(j,i,k)=ane(j,i,k)-skye(j,i)*areae(j,i,k)
			an(j,i,k)=ganho*(ano(j,i,k)+ane(j,i,k))
c			write(8,*) 'ano ane an'
c			write(8,*) ano(j,i,k),ane(j,i,k),an(j,i,k)
c			write(8,*) ' '
		end do
	  end do
	end do
c
c	Zerando variaveis referentes a estrela composta pela soma de todas as estrelas
c
	do i=1, nhw
		do k=1,nap
		  an(nstars+1,i,k)=0.0
		end do
	end do
c
c
c	Zerando variaveis para calcular ruido de fotons
c
	do j=1, nstars
		do k=1,nap
		    antot(j,k)=0.
		    ceu(j,k)=0.		 
		end do
	end do
c
c	Calculando somatorias para calcular ruido de fotons
c
	do j=1, nstars
        do k=1,nap
	    do i=1, nhw
		antot(j,k)=antot(j,k)+an(j,i,k)
		ceu(j,k)=ceu(j,k)+skye(j,i)*areae(j,i,k)+skyo(j,i)*areao(j,i,k)
		end do
	    end do
	end do
c
c	Calculando ruido de fotons para cada estrela
c
c        write(6,*) ganho
	do j=1, nstars
            do k=1,nap
		antot(j,k)=antot(j,k)/nhw
		ceu(j,k)=ganho*ceu(j,k)/nhw
		ruido(j,k)=dsqrt(antot(j,k)+ceu(j,k))
	    end do
	end do
c
c
c	Propagando erro: Erro de saida = erro da razao entre fluxo da estrela e
c		fluxo da estrela de comparacao
c
	do j=1, nstars
            do k=1,nap
		if (j.ne.comp) then
		  erro(j,k)=antot(j,k)*antot(j,k)*ruido(comp,k)*ruido(comp,k)
		  erro(j,k)=erro(j,k)+ruido(j,k)**2*antot(comp,k)**2
		  erro(j,k)=dsqrt(erro(j,k))/(antot(comp,k)*antot(comp,k))
		end if
	    end do
	end do

c
c
c	FAzendo fotometria de todas as estrelas do campo com relacao a estrela de comparacao
c
c
	do i=1, nhw
	  do j=1, nstars
	  do k=1,nap
	  if ((j.ne.comp).and.(j.ne.nout)) then
	    an(nstars+1,i,k)=an(nstars+1,i,k)+an(j,i,k)
	  end if
	  dif(j,i,k)=an(j,i,k)/an(comp,i,k)
	  end do
	  end do
	end do
c
c
c	FAzendo fotometria da estrela composta pela soma de todas as estrelas
c	de campo com a comparacao
c
c
	do i=1, nhw
		do k=1,nap
		    dif(nstars+1,i,k)=an(nstars+1,i,k)/an(comp,i,k)
c		  end if
		end do
	end do

c
c	Saida
c
c
   10 format(1i4,30e13.5) 
   11 format(1i4,30e15.5)
c
	do j=1,nstars+1
	  write(8,*) "# "
	  write(8,*) "#   *** Estrela de campo ...: ",j
	  write(8,*) "#"
	  do i=1,nhw
	    write(8,10) i,(dif(j,i,k), k=1,nap)
	  end do
	end do
c
c	Imprimindo ruido de fotons para cada abertura de cada estrela
c
	write(8,*) "# "
	write(8,*) "#      Ruido de fotons   "
	write(8,*) "# "
	do j=1,nstars
	    write(8,11) j,(ruido(j,k), k=1,nap)
	end do
c
c
c	Imprimindo Erro no fluxo relativo
c
	write(8,*) "# "
	write(8,*) "#      Erro no fluxo relativo   "
	write(8,*) "# "
	do j=1,nstars
	    write(8,10) j,(erro(j,k), k=1,nap)
	end do
c
c	Imprimindo Fluxo total medio
c
c	write(8,*) "# "
c	write(8,*) "#      Fluxo total medio   "
c	write(8,*) "# "
c	do j=1,nstars
c	    write(8,*) j,(antot(j,k), k=1,nap)
c	end do
c
	close(8)
c
	goto 120
100	call imemsg(ier,errmsg)
	write(*,'(''Erro: '',a80)')errmsg
110	stop
120	end
