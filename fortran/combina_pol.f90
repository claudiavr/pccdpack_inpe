!	
!	Pega diversos fintabs e compila um fintab final com médias e cria um arquivo separado com objetos rejeitados 
!   passa os valores para um array[i][j] onde i é o numero do ftb e j e o numero da estrela
!
		program combina_pol

		IMPLICIT NONE
		logical cont,match,escreve,achoupar(10,4000)
		integer ah(10,4000),am(10,4000),dg(10,4000),dm(10,4000),ii,jj,combinado,beta,contamesmo
		integer num_ftb,i,j,ftb,inspec_ftb,main_id(10,4000),error,parametros,combina,inspecao,nestrelas(10)
		DOUBLE PRECISION polarization(10,4000),sigma(10,4000),theta(10,4000),ascenreta(10,4000),declina(10,4000),fwhm(10)
		DOUBLE PRECISION as(10,4000),ds(10,4000),centro(10),limitesup(10),limiteinf(10),diffar,diffdec,q(10,4000),u(10,4000)
		DOUBLE PRECISION qcom,ucom,polcom,thetacom,sigmacom,dist,somapeso,separacao
		CHARACTER(LEN=12) combina_char
		CHARACTER(LEN=13) inspecao_char
		CHARACTER(LEN=20) lista_ftb(10),lixochar,nome_out
		CHARACTER(LEN=18) separa_char
		CHARACTER(LEN=7) termino
	 
	  !!! ler ascensão reata e declinacao com formatos!!! -> boa julio! -> Descobrir como fazer isso...
		termino = ".inspec"
		parametros =101
		ftb = 102
		inspec_ftb = 103
		combinado =104
		open(unit=parametros,file='combina_pol.par',status='old')
		read(parametros,*) nome_out
		read(parametros,*) lixochar
		read(parametros,*) combina_char,combina 
		read(parametros,*) inspecao_char,inspecao
		read(parametros,*) lixochar,num_ftb
		read(parametros,*) separa_char,separacao
		read(parametros,*) lixochar
		separacao = separacao/3600.		
		do i=1,num_ftb
			write(*,"(A,I1,A)")"Fintab numero ",i,":    Centro	Largura"
			read(parametros,*)lixochar, lista_ftb(i),centro(i),fwhm(i)
			write(*,"(A,F6.2,A,F5.2)") lista_ftb(i),centro(i),"	",fwhm(i)
		end do
		close(parametros)
		do i=1,num_ftb
			open(unit=ftb,file=lista_ftb(i),status='old',iostat=error)
			read(ftb,*) lixochar
			read(ftb,*) lixochar
			cont=.true.
			j=1
			do while (cont)
				read(ftb,*,end=20)main_id(i,j),ah(i,j),am(i,j),as(i,j),dg(i,j),dm(i,j),ds(i,j),polarization(i,j),sigma(i,j),theta(i,j)
				ascenreta(i,j) = 360.*ah(i,j)/24. + 360.*am(i,j)/60./24. + 360.*as(i,j)/3600./24.
				declina(i,j) = dg(i,j) + dm(i,j)/60. + ds(i,j)/3600.
				sigma(i,j)= 0.01*sigma(i,j)
				polarization(i,j) = 0.01*polarization(i,j)
				q(i,j) = (polarization(i,j))*dcos(2.*(theta(i,j)*0.01745329))
				u(i,j) = (polarization(i,j))*dsin(2.*(theta(i,j)*0.01745329))
				j = j+1
			end do
			close(ftb)
20			nestrelas(i)=j -3 
			if(fwhm(i) /= 0)then
				limitesup(i) = centro(i) + 4*fwhm(i)/2.35
				limiteinf(i) = centro(i) - 4*fwhm(i)/2.35
				if(limitesup(i) > 180) limitesup(i) = limitesup(i) - 180
				if(limiteinf(i) < 0) limiteinf(i) = limiteinf(i) + 180
			end if
			if(fwhm(i) == 0) then
				limiteinf(i)=0.
				limitesup(i)=180.
			end if
		end do
		
		!!!Inspecao 90 pronto !!!
		
		if(inspecao == 1) then
			do i=1,num_ftb
				open(unit=inspec_ftb,file=lista_ftb(i)//termino,status='new')
				write(inspec_ftb,*)"LOMAIN_ID	RA	DEC	POLARIZATION	SIGMA	THETA"
				write(inspec_ftb,*)"----	----------	------------	----	----	-----"
				write(*,*) "numero i",i
				do j=1,nestrelas(i)
					if(limiteinf(i) > limitesup(i)) then
						if(limiteinf(i) > theta(i,j) .and. theta(i,j) > limitesup(i)) then
							write(inspec_ftb,100)main_id(i,j),"	",ah(i,j)," ",am(i,j)," ",as(i,j),"	",dg(i,j)," ", &
							dm(i,j)," ",ds(i,j),"	",100.*polarization(i,j),"	",100.*sigma(i,j),"	",theta(i,j)
						end if
					end if
					if(limiteinf(i) < limitesup(i)) then 
						if(limiteinf(i) > theta(i,j) .or. theta(i,j) > limitesup(i)) then
							write(inspec_ftb,100)main_id(i,j),"	",ah(i,j)," ",am(i,j)," ",as(i,j),"	",dg(i,j)," ", &
							dm(i,j)," ",ds(i,j),"	",100.*polarization(i,j),"	",100.*sigma(i,j),"	",theta(i,j)
						end if
					end if
				end do
				close(inspec_ftb)
			end do
		end if
		
		
		!!! Aparentemente pronto também !!!
		
		achoupar=.false.
		escreve=.true.
		beta=0
		if(combina == 1) then
			open(unit=combinado,file=nome_out)
			beta=0
			write(combinado,*)"MAIN_ID	RA	DEC	POLARIZATION	SIGMA	THETA	MEASURES"
			write(combinado,*)"----	-----------	------------	-----	-----	------	-"
			do i=1,num_ftb !Varrendo Ftbs -> 1
				do j=1,nestrelas(i) !Varrendo estrelas no ftb -> 2
					qcom = q(i,j)/(sigma(i,j)*sigma(i,j))
					ucom = u(i,j)/(sigma(i,j)*sigma(i,j))
					contamesmo = 1
					sigmacom = 1./(sigma(i,j)*sigma(i,j))
					if(achoupar(i,j) .eqv. .false.) then
					do ii= i+1,num_ftb !Varrendo Ftbs seguintes -> 3
						!write(*,*) i,ii
						do jj=1,nestrelas(ii) !Varrendo estrelas no ftb seguinte ->4
							diffar = ascenreta(i,j) - ascenreta(ii,jj)
							diffdec = declina(i,j) - declina(ii,jj)
							dist=sqrt(diffar**2 + diffdec**2)
							if(dist < separacao) then
								!write(*,*) i,j,ii,jj,dist,diffar,diffdec,ascenreta(i,j),declina(i,j),ascenreta(ii,jj),declina(ii,jj)
								contamesmo = contamesmo +1
								qcom = qcom + q(ii,jj)/(sigma(i,j)*sigma(i,j))
								ucom = ucom + u(ii,jj)/(sigma(i,j)*sigma(i,j))
								sigmacom = sigmacom + 1./(sigma(i,j)*sigma(i,j))
								achoupar(ii,jj)=.true.
							end if
						end do !-> 4
					end do!-> 3
					beta=beta+1
					somapeso = sigmacom
					sigmacom = 100*sqrt(1./sigmacom)
					qcom = qcom/somapeso
					ucom = ucom/somapeso
					polcom=100.*(sqrt(qcom*qcom+ucom*ucom))
					thetacom=57.2957795*(datan2(ucom,qcom))/2.
					if (thetacom.lt.0.) thetacom=thetacom+180.
					write(combinado,300)beta,"	",ah(i,j)," ",am(i,j)," ",as(i,j),"	",dg(i,j)," ", &
					dm(i,j)," ",ds(i,j),"	",polcom,"	",sigmacom,"	",thetacom,"	",contamesmo

					end if
				end do! -> 2
			end do! -> 1
			write(combinado,*)""
			close(combinado)
		end if
		

100		format(I4,A,I2,A,I2,A,F5.2,A,I3,A,I2,A,F5.2,A,F6.3,A,F6.4,A,F6.2)
200		format(I4,A,I2,A,I2,A,F5.2,A,I3,A,I2,A,F5.2,A,F6.4,A,F6.4,A,F6.2,A)
300		format(I4,A,I2,A,I2,A,F5.2,A,I3,A,I2,A,F5.2,A,F6.3,A,F6.3,A,F7.2,A,I1)
	  end
