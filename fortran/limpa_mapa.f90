        program limpa_mapa

	!		USE ISO_VARYING_STRING

        IMPLICIT NONE
        logical incluir
        integer modo, nchar, error,i,id(2000),j,k,l,m
        integer main_id(4000),ah(4000),am(4000),dg(4000),dm(4000)
        DOUBLE PRECISION xsel(4000),ysel(4000),xtxt(4000),ytxt(4000)
        DOUBLE PRECISION as(4000),ds(4000),polarization(4000),sigma(4000),theta(4000)
		CHARACTER*100 BUFFER,lixochar
		CHARACTER(len=20) arq1,arq2,arq3


        CALL GETARG(1,BUFFER)
        READ(BUFFER,*) modo		
        
        if(modo==3)then
        	write(*,*)"#####################HELP####################"
	 		write(*,*)"## uso:                                    ##"
			write(*,*)"## limpa_mapa [modo (1|2)] arq1 arq2 arq3  ##"
			write(*,*)"##                                         ##"
			write(*,*)"## modo 1:                                 ##"
			write(*,*)"##                                         ##"
			write(*,*)"## arq1 = arquivo .ftb.inspec              ##"
			write(*,*)"## arq2 = arquivo .sel                     ##"
			write(*,*)"## arq3 = arquivo .txt                     ##"
			write(*,*)"##                                         ##"
	  		write(*,*)"## modo 2:                                 ##"
	  		write(*,*)"##                                         ##"
	  		write(*,*)"## arq1 = arquivo .ftb.inspec editado      ##"
			write(*,*)"## arq2 = arquivo .ftb original            ##"
			write(*,*)"## arq3 = arquivo .ftb de saida            ##"
	 	 	write(*,*)"#################END#HELP####################"	
	 	 	stop
        end if
        	
		CALL GETARG(2,BUFFER)
        READ(BUFFER,*) arq1
        CALL GETARG(3,BUFFER)
        READ(BUFFER,*) arq2
		CALL GETARG(4,BUFFER)
	    READ(BUFFER,*) arq3


		if(modo==1) then !!!extrai objetos q aparecem no .inspec no .txt e no .sel
		
			open(unit=310,file=arq1,status='old', iostat=error)
				read(310,*)lixochar
				read(310,*)lixochar
				i=0
				do while(.true.)
					i=i+1
					read(310,*,end=20) id(i)
				end do
20			close(310)
			i=i-1
			
			open(unit=320,file=arq2,status='old',iostat=error)
				read(320,*)lixochar				
				read(320,*)lixochar
				k=0
				do while(.true.)
					k=k+1
					read(320,*,end=30) xsel(k),ysel(k)
				end do
30			close(320)
			k=k-3
			
			open(unit=330,file=arq3,status='old',iostat=error)
				l=0
				do while(.true.)
					l=l+1
					read(330,*,end=40) xtxt(l),ytxt(l)
				end do
40			close(320)
			l=l-3
			!write(*,*) i,k,l
			open(unit=410,file=arq2//".inspec",status="new")
			open(unit=411,file=arq3//".inspec",status="new")			
				do j=1, i 
					do m=1, k
						!write(*,*)m,id(j)
						if(m==id(j)) then
							!write(*,*)m,id(j)
							write(410,*)xsel(m),ysel(m),id(j)
							write(411,*)xtxt(m),ytxt(m),id(j)
						end if
					end do
				end do
			close(410)
			close(411)
		end if
	
		if(modo == 2) then !!Limpa o ftb a partir do .ftb.inpec
			open(unit=510,file=arq1,status='old', iostat=error) !Primeiro o inspec!
				read(510,*) lixochar
				read(510,*) lixochar
				i=0
				do while(.true.)
					i=i+1
					read(510,*,end=50) id(i)
				end do
50			close(510)
			i=i-1
			
			open(unit=511, file=arq2,status="old", iostat=error)
				read(511,*) lixochar
				read(511,*) lixochar
				j=0
				do while(.true.)
					j=j+1
					read(511,*,end=60) main_id(j),ah(j),am(j),as(j),dg(j),dm(j),ds(j),polarization(j),sigma(j),theta(j)
				end do

60			close(511)
			j=j-1			
			
			open(unit=610,file=arq3, status="new")
				write(610,*)"MAIN_ID	RA	DEC	POLARIZATION	SIGMA	THETA"	
				write(610,*)"----	-----------	------------	-----	-----	------"
				do k=1, j
					incluir=.true.
					do l=1, i
						if(k == id(l)) incluir=.false.
					end do
					if(incluir) then
						write(610,100)main_id(k),"	",ah(k)," ",am(k)," ",as(k),"	",dg(k)," ", &
							dm(k)," ",ds(k),"	",polarization(k),"	",sigma(k),"	",theta(k)
					end if
				end do
			close(610)
					
			
		end if

100		format(I4,A,I2,A,I2,A,F5.2,A,I3,A,I2,A,F5.2,A,F6.3,A,F6.4,A,F6.2)

        end program limpa_mapa