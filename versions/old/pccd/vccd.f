	Program VCCD
c
c   ****** Reducao da polarizacao com lamina de 1/4 onda ******
c	** Modificacao do pccd.f - CVR 25/Fev/97
c
c          ***************************************
c
c	Mudada dimensao de a() de 10 para 19	13 Oct 92
c	Mudada dimensao de ano,ane,areao,areae para 7	15 Apr 94.
c	Testado ok na Argus.
c       Numero maximo de aberturas= 25
c       Numero de estrelas=200    *    06 Jun 95    *    VEM - CVR
c	Numero de posicoes da lamina= 48
c
c       ano(# estrelas, pos. lamina, aberturas)
c
c	Fev/2004: mudei definicao de z(i) para ficar consistente com
c	pccdgen do Antonio Pereyra
c
	implicit real*8 (a-h, o-z)
	dimension ano(200,48,25), ane(200,48,25), skyo(200,48), skye(200,48)
	dimension ap(25), areao(200,48,25), areae(200,48,25), a(60)
	dimension sko(48), ske(48), ao(48), ae(48), areo(48), aree(48)
	dimension z(48),areaso(200,48),arease(200,48)
        integer nimages
	character*60 filename
	character*12  image
        character*1 calc
	character*650 line
c
        common/delta/deltatheta,ganho,npsky
	common/lamina/zerolam
c
	print*, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
	print*, '$$$$$$$$$$$$$$$ vccd.f VERSAO 25 Fev. 1997 $$$$$$$$$$$$$$$$$$'
	print*, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
c
	print*, '*.dat file to reduce: '
	read *, filename
c	filename = filename(1:index(filename,' ')-1) // '.dat'
	print*
	print*, '***** FILENAME = '
	print*, filename
	print *, ' '
c
	print*, '# of stars in the file :'
	read*, nstars
	print*, 'No. of stars : ', nstars
	if (nstars.gt.200) then
		print*, 'Numero de estrelas maior que 200!'
		stop
	end if
c
	print*, '# of waveplate positions observed :'
	read*, nhw
	print*, 'No. of waveplate positions : ', nhw
c
	print*, '# of apertures observed :'
	read*, nap
	print*, 'No. of apertures observed: ', nap
c
	print*, 'Calcita (c) ou polaroide (p) ?'
	read(*,'(a1)') calc
	print*, 'Calcita (c) ou polaroide (p) ? ',calc 	
c
	print*, 'Readnoise - ADU'
	read*, readnoise
	print*, 'Readnoise - ADU : ',readnoise
c
	print*, 'Ganho - e/adu '
	read*, ganho
	print*, 'Ganho (e/adu) : ',ganho
c
	print*, 'Delta do angulo : '
	read*, deltatheta
	print*, 'Delta do angulo : ',deltatheta
c
	print*, 'Zero da Lamina : '
	read*, zerolam
	print*, 'Zero da Lamina : ',zerolam
c
        if ((calc.eq.'c').or.calc.eq.'C') then
          nimages=2
          else
          if ((calc.eq.'p').or.calc.eq.'P') nimages=1
        end if
c
        print*, 'Numero de imagens de 1 estrela: ',nimages
c
	open(8, file=filename, status='old')
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
                        if (nimages.eq.2) then
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
c			 print *, image
c			 print *, (ap(k), k=1,nap)
c			 print *, (ane(j,i,k), k=1,nap)
c			 print *, (areae(j,i,k), k=1,nap)
c			 print *, (ano(j,i,k), k=1,nap)
c			 print *, (areao(j,i,k), k=1,nap)
c			print*, image, skyo(j,i), (ap(k), k=1,nap),
c     $				(ano(j,i,k), k=1,nap),
c     $				(areao(j,i,k), k=1,nap)
c     			print*, ' '
c			print*, image, skye(j,i), (ap(k), k=1,nap),
c     $				(ane(j,i,k), k=1,nap),
c     $				(areae(j,i,k), k=1,nap)
c 			    print*, ' '
                        end if
		end do
	end do
c
	close (unit=8)
c
	print*, 'REDUCAO CCD'
	do j=1,nstars
		print*, 'STAR #',j,' *********************************************' 
		do k=1, nap 
		        npsky=0.d+0     
			do i=1, nhw
				sko(i)=skyo(j,i)
				if (nimages.eq.2) ske(i)=skye(j,i)
				ao(i)=ano(j,i,k)
				if (nimages.eq.2) ae(i)=ane(j,i,k)
				areo(i)=areao(j,i,k)
				if (nimages.eq.2) aree(i)=areae(j,i,k)
				npsky=npsky+areaso(j,i)+arease(j,i)
			end do
			npsky=npsky/2.
		call polar(ao,ae,nhw,sko,ske,areo,aree,nimages,
     $                      q,u,v,sigma,sigmav,sigmatheor,p,theta,
     $			    z,readnoise)
c
		print*, 'APERTURE = ', ap(k)
		print*,'    V     SIGMAV      Q       U    SIGMA      P  THETA
     $ SIGMAtheor.'
		print 2000, v,sigmav,q,u,sigma,p,theta,sigmatheor
		print*
		print*,' Z(I)= Q*cos(2psi(I))**2 + U*sin(2psi(I))*cos(2psi(I))
     $ + V sin(2psi(I))'
		print 3000, (z(l), l=1,nhw)
		print*
c
		end do
	end do
1000	format(a10)
2000	format(f9.5, f8.5,2f8.4,2f8.5,f6.1,f8.5)
3000	format((1x,4(f10.5)))
c
	end
c
	Subroutine polar (ano,ane,n,skyo,skye,areao,areae,nim,
     $			 q,u,v,sigma,sigmav,sigmatheor,p,theta,z,readnoise)
c
	implicit real*8 (a-h, o-z)
        integer nim
	dimension ano(n), ane(n), z(n), areao(n), areae(n)
	dimension skyo(n), skye(n)
	dimension psi(48)
c
        common/delta/deltatheta,ganho,npsky
	common/lamina/zerolam
c   
	sumo=0.
	sume=0.
	an=0.
	sky=0.
        r2t=0.
        npstar=0.
	r2= readnoise*readnoise
        raiz=sqrt(2.)
	nv=0.5e+0*n
	nu=0.25e+0*n
	nq=nv+nu
	pi=atan(1.d+0)*4.d+0
	degtorad=pi/180.d0
c
	do i=1,n
		psi(i) = 22.5*(i-1)
		skyoo = skyo(i)*areao(i)
		ano(i) = ano(i) - skyoo
		sumo = sumo + ano(i)
		if (nim.eq.2) then 
                   skyee = skye(i)*areae(i)
		   ane(i) = ane(i) - skyee
		   an = an + (ane(i) + ano(i))/2.
      		   sume = sume + ane(i)
		   sky= sky + (skyee + skyoo)/2.
                   r2t = r2t + r2*(areae(i)+areao(i))/2.
                   npstar = npstar + (areae(i)+areao(i))/2.
                   else
                   r2t = r2t + r2*areao(i)
                   npstar = npstar + areao(i)
                   an = an + ano(i)
                   sky = sky + skyoo
                end if
	end do
	ak = sume / sumo
	an = an / n
	sky = sky / n
        r2t = r2t / n
	sigmatheor = an/sqrt(an + (1 + npstar/npsky)*(sky + r2t))
	sigmatheor = sigmatheor*sqrt(ganho)
	sigmatheor = 1. / sigmatheor
	sigmatheor = sigmatheor / sqrt (float(n))
        if (nim.eq.1.) sigmatheor=sigmatheor*2.
c
	sumz2 = 0.
	q = 0.
	u = 0.
	v = 0.
c
	do i=1,n
		if (nim.eq.2) then
                  z(i) = (ane(i) - ano(i))/(ane(i) + ano(i))
                  else
                  z(i) = -(ano(i)/an - 1.)
                end if
		sumz2 = sumz2 + z(i) * z(i)
		aang=4.*(psi(i)+zerolam)*degtorad
		q = q + z(i) * (1.+cos(aang))
		u = u + z(i) * sin(aang)
		v = v + z(i) * sin(0.5d0*aang)
	end do
c
	v = -v/nv
	q = q/nq
	u = u/nu
	p = q*q + u*u
	sigma = (sumz2-0.5*nu*u*u-nv*v*v-0.5*nq*q*q)/(n-3.)
	sigmaq = sqrt(2.*sigma/nq)
	sigmau = sqrt(2.*sigma/nu)
	sigmav = sqrt(sigma/nv)
c	sigmap = sqrt( sigma/p*(q*q/nq+u*u/nu) )
c	print*,'sigma  ',sqrt(sigma)
c	print*, 'nq ',nq
c	print*, 'nu ',nu
c	print*, 'nv ',nv
c	print*, sigmaq
c	print*, sigmau
c	print*, sigmap
	sigmap = sqrt( (q*q*sigmaq*sigmaq + u*u*sigmau*sigmau)/p )
c	print*,sigmap
	sigma = sigmap
	p = sqrt (p)
	theta = atan (u/q)
	theta = theta/degtorad
	if (q.lt.0) then
		theta = theta + 180.
	end if
	if (u.lt.0. .and. q.gt.0) then
		theta = theta + 360.
	end if
	theta = theta/2.
	if (theta.ge.180.) then
		theta = theta -180
	end if
	theta = 180 - theta + deltatheta
	if (theta.ge.180.) then
		theta = theta - 180
	end if
c
	return
c
	end
c

