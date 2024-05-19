c **************************************************
c *** Modificacao do 07b para 08 feita por Claudia Vilega Rodrigues
c *** 21-10-2009
c Nas laminas other e v0other, a retardancia nao estava convertida para
c radianos em uma das equacoes.
c *** 26-10-2009
c A normalizacao so pode ser usada no caso de retardancia = 180 deg. Assim, travei essa opcao
c em "nao" nos os outros casos.
c*****
c ##################################
c CVR - agosto-2011
c 
c MODIFICACAO 1:
c Incluida a opcao do novo modulo polarimetrico que gira em sentido contrario do correto. 
c Essa informacao fica registrada no header do logfile.
c Na pratica, o que foi feito:
c - angulo = 180 - angulo calculada pela rotina polar
c - U = - U calculado pela rotina polar
c - V = - V calculado pela rotina polar
c O deltatheta eh aplicado apos essa eventual correcao.
c
c Foi feito o teste de usar o angulo da posicao da lamina 360-step*i e os resultados sao iguais.
c
c MODIFICACAO 2:
c Angulos de saida limitados entre 0 e 180.
c
C MODIFICACAO 3:
C  Se alguma posicao da lamina nao eh utilizada, se forca a nao usar normalizacao
c
c################################
c
C CVR - 2014 november
c 
c O modo que a rotina como um todo considera o sentido de rotacao da lamina foi alterado.
c Antes desta data, a rotacao era incluida como theta = 180 - theta; v=-v; u=-u. Depois, ela
c entrou no sinal de 22.5*i. Mas, com o zero da lamina nao mudando de sinal.
c
c
c################################
c
C CVR - 2015 october
c 
c Included the normalization in the circular polarization calculation.
c It is an iterative process.
c
c The normalization was wrongly always set to 0 in half-wave plate mode. Corrected.
c
c Temporariamente, estamos criando um arquivo chamado convergencia.txt
c
c **************************************************
c
	Program PCCD
c
c       Polarimetry reduction
c
c       ***************************************
c
c       Max. number os stars                   =  3000
c       Max. number of positions of waveplates =  16
c       Max. number of apertures               =  20
c
c       ano(# stars, pos. waveplate, apertures)
c
	  implicit real*8 (a-h, o-z)
	  dimension ano(3000,16,20), ane(3000,16,20), skyo(3000,16),skye(3000,16)
	  dimension ap(20), areao(3000,16,20), areae(3000,16,20), a(6000)
	  dimension sko(16), ske(16), ao(16), ae(16), areo(16), aree(16)
	  dimension z(16),areaso(3000,16),arease(3000,16)
      integer nimages,new_module,nhw_used,wave,typewave
	  character*60 filename
	  character*12  image
      character*1 calc
	  character*1000 line
	  character*7 wavetype
c
      common/delta/ganho,npsky
	  common/lamina/zerolam
	  common/wavepos/wave(16)
c	  common/posit/nhw_used,norm,retar
c	  common/type/typewave
	  common/nnew_module/new_module
c
	  print*, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'

	  read *, filename
	  read*, nstars
	  read*, nhw
	  read*, nap
	  read(*,'(a1)') calc
	  if ((calc.eq.'c').or.calc.eq.'C') then
          nimages=2
          else
          if ((calc.eq.'p').or.calc.eq.'P') nimages=1
      end if
	  read*, readnoise
	  read*, ganho
	  read*, deltatheta
	  read*, zerolam
	  read(*,'(a7)') wavetype
	  do i=1, 16
	    read*,wave(i)
	  end do
	  read*, nhw_used
	  read*, norm
      if (wavetype.eq.'other') read*, retar
	  if (wavetype.eq.'v0other') read*, retar
	  read*, new_module
c	  print*, norm


	  print*, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
	  print*, '$$$$$$$$$$$$$$ pccd4000gen22.f VERSION Oct/2015 $$$$$$$$$$$$$$'
	  print*, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
c
	  print*, '*.dat file to reduce: '
	  print *
	  print*, '***** FILENAME = '
	  print*, filename
	  print *
	  print *
	  print*, 'No. of stars : ', nstars
	  if (wavetype.eq.'half') then
	    print*, 'Waveplate type :  half'
	    typewave = 1
	    zerolam = 0.
	  end if
	  if (wavetype.eq.'quarter') then
	    print*, 'Waveplate type :  quarter'
	    typewave = 2
c	    norm=0
	  end if
      if (wavetype.eq.'other') then
	    print*, 'Waveplate type :  other'
	    typewave = 3
	    norm=0
      end if
      if (wavetype.eq.'v0other') then
	    print*, 'Waveplate type :  v0other'
	    typewave = 4
	    norm=0
	  end if
c	  print*,typewave
c
c	  print*, norm,nhw,nhw_used
c      print*,(nhw.ne.nhw_used)
c      print*,((nhw.ne.4).or.(nhw.ne.8).or.(nhw.ne.12).or.(nhw.ne.16))
      if (nhw.ne.nhw_used) norm = 0
      if ((nhw.ne.4).and.(nhw.ne.8).and.(nhw.ne.12).and.(nhw.ne.16)) norm = 0
c	  print*, norm,nhw,nhw_used
c
	  print*, 'No. of waveplate positions : ', nhw
	  print 6000, (wave(i), i=1,16),nhw_used
	  print*, 'No. of apertures observed: ', nap
	  print*, 'Calcite (c) or polaroide (p) ? ', calc
	  print*, 'Readnoise - ADU :', readnoise
	  print*, 'Gain (e/adu) :', ganho
	  print*, 'Delta of angle :', deltatheta
	  print*, 'Zero of waveplate :', zerolam
	  print*, 'No. of images of 1 star : ', nimages
	  if (norm.eq.0) then
	    print*, 'normalization included: no'
        else
	    print*, 'normalization included: yes'
	    if (typewave.eq.2) open (2, file="convergencia.txt",access='append',status='old')
c	    if (typewave.eq.2) then
c	    	open (2, file="convergencia.txt",access='append',status='old')
c	    	write(2,*) ' ' 
c	    	write(2,*) 'Arquivo ',filename
c	    end if
	  end if
      print*, 'New polarimetric module? ',new_module
      if ((wavetype.eq.'other') .or. (wavetype.eq.'v0other')) then
        print*, 'waveplate retardance: ',retar
        else
        print *
      end if
c
	open(8, file=filename, status='old')
c
	do i=1, nhw_used
		do j=1, nstars
c			print*, j
			read(8,'(a)') line
c      		print*,line
			image = line(1:index(line,' '))
c			print*, image
c
c *** esquema meio bobo para testar se linha tem tamanho correto. Primeiro tento ler
c     uma variavel a mais. Se nao der, esta errado! Se der erro, dai leio o numero 
c	  certo. Se der certo, ok. 
c     Se der erro de novo, esta faltando coisa. Com isso, testamos se a linha esta
c     mais curta ou mais longa que o correto.
c
			read(line(index(line,' '):),*,end=10) (a(l),l=1,3+3*nap)
            goto 20
10			read(line(index(line,' '):),*,err=20,end=20) (a(l),
     $							l=1,2+3*nap)
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
c
	        if ((typewave.eq.2).and.(norm.eq.1)) then
	     	   write(2,*) 'Estrela e abertura ',j,k
			end if
		call polar(ao,ae,nhw,nhw_used,sko,ske,areo,aree,nimages,
     $                      q,u,v,sigma,sigmav,sigmatheor,p,theta,
     $			    z,readnoise,typewave,norm,retar,sigmafull)
c
c	        if (new_module.eq.1) then
c	            theta=180.0d0-theta
c	            v=-v
c                    u=-u
c	        end if
                theta=theta+deltatheta
	        if (theta.lt.0.) then
		   theta = theta + 180.d0
                   else
                   if (theta.gt.180.) theta = theta - 180.d0
                end if
		if (wavetype.eq.'half') then
		print*, 'APERTURE = ', ap(k)
		print*,'  Q         U         SIGMA     P             THETA    SIGMAtheor.'
		print 2000,q,u,sigma,p,theta,sigmatheor
		print*
		print*,' Z(I)= Q*cos(4psi(I)) + U*sin(4psi(I))'
		print 3000, (z(l), l=1,nhw_used)
		print*
	        end if
c
	        if ((wavetype.eq.'quarter') .or. (wavetype.eq.'other')
     $  .or. (wavetype.eq.'v0other') ) then
		print*, 'APERTURE = ', ap(k)
		print*,'     V       SIGMAV      Q         U        SIGMA       P   THETA  SIGMAtheor.   rms'
		print 4000, v,sigmav,q,u,sigma,p,theta,sigmatheor,sigmafull
		print*
                if (wavetype.eq.'quarter') then
		print*,' Z(I)= Q*cos(2psi(I))**2 + U*sin(2psi(I))*cos(2psi(I)) - V*sin(2psi(I))'
                end if
                if (wavetype.eq.'other') then
		print*,' Z(I)= Q*(G+H*cos(4psi(I))) + U*H*sin(4psi(I))
     $ - V*sin(ret)*sin(2psi(I))'
                end if
                if (wavetype.eq.'v0other') then
		print*,' Z(I)= Q*(G+H*cos(4psi(I))) + U*H*sin(4psi(I))'
                end if


		print 5000, (z(l), l=1,nhw_used)
		print*
	        end if
c
		end do
	end do
c
	    if ((typewave.eq.2).and.(norm.eq.1)) close (2)
1000	format(a10)
2000	format(1x, 4(f10.6), 2x, f8.2, 2x, f10.6)
3000	format((1x,4(f10.6)))
4000	format(f10.6,f10.6,2f10.6,2f10.6,f6.1,f10.6,f11.7)
5000	format((1x,4(f10.5)))
6000    format('Waveplate pos. :',16i3,' =',i3)
c
		goto 30
c
20      print*, ' '
		print*, '***************  CAUTION!!! ******************'
		print*, ' ' 
		print*, ' Line size of dat file has problems... '
		print*, ' Check apertures and others parameters of pccdgen.' 
30		print*, ' '
	end
c
c================================================================================
c
	  Subroutine polar (ano,ane,n,n_used,skyo,skye,areao,areae,nim,
     $			 q,u,v,sigma,sigmav,sigmatheor,p,theta,
     $			 z,readnoise,typewave,norm,retar,sigmafull)
c
	  implicit real*8 (a-h, o-z)
      integer nim,wave,new_module,typewave,conta
	  real sumr2,as,bs,cs,hs,fs,gs,det,wq,wu,wv,aa,bb,cc,ff,gg,hh,gtau,htau
	  logical nao_convergiu,first
	  dimension ano(n), ane(n), z(n), areao(n), areae(n)
	  dimension skyo(n), skye(n)
	  dimension psi(16)
	  dimension ano1(16), ane1(16), z1(16), areao1(16), areae1(16)
	  dimension skyo1(16), skye1(16), z1_ant(16)
	  dimension a(16), b(16), c(16)
c
   	  common/delta/ganho,npsky
	  common/lamina/zerolam
	  common/wavepos/wave(16)
	  common/nnew_module/new_module
c
	  sumo=0.
	  sume=0.
	  r2= readnoise*readnoise
	  as=0.
	  bs=0.
	  cs=0.
	  fs=0.
	  gs=0.
	  hs=0.
	  det=0.
      gtau=0.
      htau=0.
      qnorm=0.
c
c **** These first calculations do not depend on the counts ****
c
	  do i=1,16
		if (new_module.eq.0) then
            psi(i) = (22.5d0*(i-1) + zerolam)*3.14159d0/180.d0
            else
            psi(i) = (-22.5d0*(i-1) + zerolam)*3.14159d0/180.d0
		end if            
c
	    if (typewave.eq.1) then
	        if (nim.eq.1) then
	          a(i) = cos(2.*psi(i))*wave(i)
	          b(i) = sin(2.*psi(i))*wave(i)
		    end if
	        if (nim.eq.2) then
	          a(i) = cos(4.*psi(i))*wave(i)
	          b(i) = sin(4.*psi(i))*wave(i)
		    end if
c
	        as = as + a(i)*a(i)
	        bs = bs + b(i)*b(i)
	        hs = hs + a(i)*b(i)
        end if
c
	    if (typewave.eq.2) then
	        a(i) = cos(2*psi(i))*cos(2*psi(i))*wave(i)
	        b(i) = sin(2*psi(i))*cos(2*psi(i))*wave(i)
	        c(i) = -1.*sin(2*psi(i))*wave(i)
c
	        as = as + a(i)*a(i)
	        bs = bs + b(i)*b(i)
	        cs = cs + c(i)*c(i)
	        fs = fs + b(i)*c(i)
	        gs = gs + a(i)*c(i)
	        hs = hs + a(i)*b(i)
	    end if

	    if (typewave.eq.3) then
c
            gtau = 0.5*(1+cos(retar*3.14159/180.))
            htau = 0.5*(1-cos(retar*3.14159/180.))
c
	        a(i) = (gtau + htau*(2*cos(2*psi(i))**2 - 1))*wave(i)
	        b(i) = htau*2*sin(2*psi(i))*cos(2*psi(i))*wave(i)
	        c(i) = -1.*sin(retar*3.14159/180.)*sin(2*psi(i))*wave(i)
c
	        as = as + a(i)*a(i)
	        bs = bs + b(i)*b(i)
	        cs = cs + c(i)*c(i)
	        fs = fs + b(i)*c(i)
	        gs = gs + a(i)*c(i)
	        hs = hs + a(i)*b(i)
	    end if

        if (typewave.eq.4) then
c
            gtau = 0.5*(1.+cos(retar*3.14159/180.))
            htau = 0.5*(1.-cos(retar*3.14159/180.))
c
	        a(i) = (gtau + htau*(2*cos(2*psi(i))**2 - 1))*wave(i)
	        b(i) = htau*2.*sin(2*psi(i))*cos(2*psi(i))*wave(i)
c	        c(i) = -1.*sin(retar*3.14159/180.)*sin(2*psi(i))*wave(i)
c
	        as = as + a(i)*a(i)
	        bs = bs + b(i)*b(i)
c	        cs = cs + c(i)*c(i)
c	        fs = fs + b(i)*c(i)
c	        gs = gs + a(i)*c(i)
	        hs = hs + a(i)*b(i)
	    end if
c
	  end do
c
      if ((typewave.eq.1) .or. (typewave.eq.4)) then
	    det = as*bs - hs**2
	    wq = det / as
	    wu = det / bs
      end if
c
	  if ((typewave.eq.2) .or. (typewave.eq.3)) then
	    aa = bs*cs - fs**2
	    bb = cs*as - gs**2
	    cc = as*bs - hs**2
	    ff = gs*hs - as*fs
	    gg = fs*hs - bs*gs
	    hh = fs*gs - cs*hs
c
	    det = as*aa + hs*hh + gs*gg
	    wq = det / aa
	    wu = det / bb
	    wv = det / cc
c
	  end if
c
c === Aqui se comeca a mexer nas contagens
c
c
c ==== Aqui comeca o while da convergencia da normalizacao.
c      Ela so eh necessaria para quarto-de-onda
c
      nao_convergiu=.true.
      first=.true.
      conta=0
      do while (nao_convergiu) 
	    i=0
	    do j=1,16
c	      print*,ano(j)
c	      print*,wave(j)
          if (wave(j).eq.1) then
           i = i + wave(j)
           ano1(j)    = ano(i)
	       ane1(j)    = ane(i)
	       areao1(j)  = areao(i)
	       areae1(j)  = areae(i)
	       skyo1(j)   = skyo(i)
	       skye1(j)   = skye(i)
	       else
	       ano1(j)    = 0
	       ane1(j)    = 0
	       areao1(j)  = 0
	       areae1(j)  = 0
	       skyo1(j)   = 0
	       skye1(j)   = 0
          end if
c	      print*,skyo1(j),ano1(j),ak
c	      print*,skyo1(j),skye1(j)
c	      print*,areao1(j),areae1(j)
	    end do
c
c
c=== aqui se subtrai o ceu e se cria contagens totais e por feixe
	    an=0.d0
	    sky = 0.d0
	    r2t = 0.d0
	    npstar = 0.d0
	    q = 0.d0
	    u = 0.d0
	    v = 0.d0
	    sumr2=0.
	    do i=1,16
	      skyoo = skyo1(i)*areao1(i)
	      ano1(i) = ano1(i) - skyoo
	      if (first) sumo = sumo + ano1(i)
c
	      if (nim.eq.2) then
                skyee = skye1(i)*areae1(i)
				ane1(i) = ane1(i) - skyee
	            if (first) sume = sume + ane1(i)
c				print*, an
				an = an + (ane1(i) + ano1(i))/2.
				sky= sky + (skyee + skyoo)/2.
                r2t = r2t + r2*(areae1(i)+areao1(i))/2.
                npstar = npstar + (areae1(i)+areao1(i))/2.
	            else
                r2t = r2t + r2*areao1(i)
                npstar = npstar + areao1(i)
                an = an + ano1(i)
                sky = sky + skyoo
          end if
	    end do
c
c       print*, an, n_used
	    an = an / n_used
	    sky = sky / n_used
        r2t = r2t / n_used
	    r2t = r2t*ganho
	    sigmatheor = an/sqrt(an + (1 + npstar/npsky)*(sky + r2t)) 
  	    sigmatheor = sigmatheor*sqrt(ganho)
	    sigmatheor = 1. / sigmatheor
	    sigmatheor = sigmatheor / sqrt (float(n_used))
        if (nim.eq.1.) sigmatheor=sigmatheor*2.
c
c === calculo da normalizacao ===
c
	    if (norm.eq.0) then
	    	ak = 1.
	    	else
	    	SELECT CASE (typewave)
   				CASE (1)
   				  	ak = sume/sumo
   				CASE (2)
c   				    print*,'sume ', sume
c   				    print*,'sumo ', sumo
c   				    print*,'sume/sumo ', sume/sumo
   				    if (first) then
   				    	ak = 1.d0
   				    	ratio = sume/sumo
   				    	write(2,*) 'conta,ratio,q_ant ',conta,ratio,q_ant
						else
   				    	write(2,*) 'conta,ratio,q_ant ',conta,ratio,q_ant	
c   				    	write(2,*) (ratio.le.1.d0)					
						if (ratio.le.1.d0) then
						  if (q_ant.le.0d0) then
							ak = ratio*((1.-0.5*q_ant)/(1.+0.5*q_ant))
c							write(2,*) "1"
							else
							ak = ratio*((1.+0.5*q_ant)/(1.-0.5*q_ant))
c							write(2,*) "2"
						  end if
						  else
						  if (q_ant.ge.0d0) then
c							write(2,*) "3"
							ak = ratio*((1.-0.5*q_ant)/(1.+0.5*q_ant))
							else
c							write(2,*) "4"
							ak = ratio*((1.+0.5*q_ant)/(1.-0.5*q_ant))
						  end if						  
						end if							
					end if  	
			    CASE DEFAULT
      				ak = 1.
			END SELECT
		end if
c	    ak = 1.074
c	    print*,'ak ', ak
c   		print*,'ak e q_ant', ak, q_ant
c
c =====
c    
c
	    do i=1,16
		  if (nim.eq.2) then
	            z1(i) = (ane1(i) - ano1(i)*ak)/(ane1(i) + ano1(i)*ak)
                else
                z1(i) = -(ano1(i)/an - 1.)
          end if
	    end do
c
	  i = 0
	  do j=1,16
	    if (wave(j).eq.1) then
              i = i + wave(j)
	          z(i) = z1(j)
	          else
	          z1(j) = 0
        end if
c        print*,z1(j),a(j),b(j)
	  end do
c      print*,q,u,v,as,bs,hs,det

	  do i=1,16
	    if ((typewave.eq.1) .or. (typewave.eq.4)) then
	        q = q + z1(i)*(a(i)*bs - b(i)*hs)/det
	        u = u + z1(i)*(b(i)*as - a(i)*hs)/det
	    end if
c
	    if ((typewave.eq.2) .or. (typewave.eq.3))then
	        q = q + z1(i)*(a(i)*aa + b(i)*hh + c(i)*gg)/det
	        u = u + z1(i)*(a(i)*hh + b(i)*bb + c(i)*ff)/det
	        v = v + z1(i)*(a(i)*gg + b(i)*ff + c(i)*cc)/det
	    end if
c
	  end do
c
c      print*, q,u,v
	  do i=1,16
	    if ((typewave.eq.1) .or. (typewave.eq.4)) then
	        sumr2 = sumr2 + (q*a(i) + u*b(i) - z1(i))**2
	    end if
c
	    if ((typewave.eq.2) .or. (typewave.eq.3))then
		sumr2 = sumr2 + (q*a(i) + u*b(i) + v*c(i) - z1(i))**2
c		print*, ''
c		print*, i, z1(i),q*a(i)+u*b(i)+v*c(i),q,a(i),u,b(i),v,c(i)
	    end if
	  end do
c    
      if (typewave.eq.2) then
	     if (norm.eq.1) then
	     	if (first) then
	     	   first=.false.
c	     	   print*, conta,0.d0,sumr2,ak,ratio,q	    
	     	   sumr2_ant=sumr2
	     	   q_ant=q
	     	   u_ant=u
	     	   v_ant=v
	     	   ak_ant=ak
	    	   do i=1,16
	    	     z1_ant(i)=z1(i)
               end do
c	     	   write(2,*) 'Primeiro passo '
	     	   else
	     	   convergencia=(sumr2_ant-sumr2)/sumr2
	     	   write(2,*) conta,ak_ant
c	     	   print*, conta,convergencia,sumr2,ak,ratio,q_ant
	     	   if (convergencia.le.0) then
	     	   	q=q_ant
	     	   	u=u_ant
	     	   	v=v_ant
	     	   	sumr2=sumr2_ant
	    	    do i=1,16
	    	         z1(i)=z1_ant(i)
                end do
	     	    nao_convergiu=.false.
	     	   	else
	     	    if (convergencia.le.0.001) then
	     	       nao_convergiu=.false.
c	     	       write(2,*) ak
	     	       else
	     	       sumr2_ant=sumr2
	     	       q_ant=q
      			   u_ant=u
      			   v_ant=v
      			   ak_ant=ak
	    	       do i=1,16
	    	         z1_ant(i)=z1(i)
                   end do
      			   if (conta.ge.100) then
      				print*, 'Normalizacao nao convergiu.'
      				stop
      			   end if
      			end if
	     	   end if
	        end if
      	    conta=conta+1	  	    
	        else
	  	    nao_convergiu=.false.
         end if   
         else
	  	 nao_convergiu=.false.
      end if
c	     	   nao_convergiu=.false.
c      print*, q,u,v,sumr2
	  end do 
c         
c == end do acima fecha o while da convergencia
c ==================================================
c
	  if  ((typewave.eq.1) .or. (typewave.eq.4)) then
	    sigma  = sqrt(sumr2/(n_used-2.))
	    sigmaq = sigma / sqrt(wq)
	    sigmau = sigma / sqrt(wu)
	    p = sqrt(q**2 + u**2)
c	    sigmap = sqrt( (q*sigmaq/p)**2 +
c     $                    (u*sigmau/p)**2 +
c     $                    2*q*u*sigmaq*sigmau/p**2 )
	    sigma = sigmaq
	  end if
c
	  if ((typewave.eq.2) .or. (typewave.eq.3)) then
	    sigma  = sqrt(sumr2/(n_used-3.))
	    sigmafull = sigma
c	    print*, sigma
	    sigmaq = sigma / sqrt(wq)
	    sigmau = sigma / sqrt(wu)
	    sigmav = sigma / sqrt(wv)
	    p = sqrt(q**2 + u**2)
	    sigmap = sqrt( (q*sigmaq/p)**2 +
     $	                   (u*sigmau/p)**2 +
     $	                   (2*sigma**2/det)*(hh*q*u/p**2) )
c
	    sigma = sigmap
c            print*, wq
c	    print*, wu
c	    print*, wv
c		print*, 'erros sigma sigmap sigmaq sigmau',sigma,sigmap,sigmaq,sigmau
        end if
c
c      print*,q,u
c
	  theta = atan2 (u,q)
	  theta = theta*180/3.14159
c	  print*, theta
c
      theta = theta/2.
c
	  q = p*cos(2*theta*3.14159/180)
	  u = p*sin(2*theta*3.14159/180)
c      print*,q,u

c
	  return
	  end
c
