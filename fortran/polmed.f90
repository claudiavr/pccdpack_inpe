!!
!! Calcula polarizacao media de varias maneiras
!!
      	program polmed
!!
      	real p1(4000),e1(4000),t1(4000),q(4000),u(4000)
      	real qdisp,udisp,pdisp,tdisp,epdisp,lx,pol_mod_pond
      	real qpond,upond,pt,peso,ppond,tpond,eppond
      	real eu,eq,lovo
      	logical cont
      	integer n,i,modo, lix
      	character*30 arq1,arq2,lxchar
	  	character*100 BUFFER
	  
	 	CALL GETARG(1,BUFFER)
      	READ(BUFFER,*) arq1
	  
	  	if(arq1=="-h") then
	  	write(*,*)"#####################HELP####################"
	  	write(*,*)"## uso:                                    ##"
	  	write(*,*)"## polmed [arquivo] [modo (1|2)]           ##"
	  	write(*,*)"##                                         ##"
	  	write(*,*)"## modo 1: arquivo .sel                    ##"
	  	write(*,*)"## modo 2: arquivo .ftb                    ##"
	  	write(*,*)"#################END#HELP####################"
	  	stop
	  	endif

	  	CALL GETARG(2,BUFFER)
      	READ(BUFFER,*) modo
      	CALL GETARG(3,BUFFER)
      	READ(BUFFER,*) arq2
!!
!!*** Leitura de dados
!!  
!!	Le um arquivo tipo ".ftb/.sel"
!!  modo = 1 -> .sel
!!  modo = 2 -> .ftb	
!!
!!     	write(6,*) 'Nome do primeiro arquivo '
      !	read(*,*) arq1
!!     	write(6,*) 'Numero de estrelas '
!!     	read *, n
!!     	write(6,*) arq1


      
      	open (unit=1,file=arq1,status='old')
      	read (1,*) lxchar
!!     	write(6,*) lxchar
      	read (1,*) lxchar
!!     	write(6,*) lxchar
      	i=1
      	cont=.true.
      	do while (cont)
      		if(modo==1)read (1,*,end=20) lx,lx,p1(i),t1(i),q(i),u(i),e1(i) !leitura sel
	  		if(modo==2)read (1,*,end=20) lix,lix,lix,lx,lix,lix,lx,p1(i),e1(i),t1(i) !leitura ftb
       		!write(6,*) p1(i),e1(i),t1(i)
	   		if(modo==2) then 
	   			p1(i)=0.01*p1(i) !conversao ftb
	   			e1(i)=0.01*e1(i) !conversao ftb
	   		end if
	   		t1(i)=t1(i)*0.017453
	    	q(i)=p1(i)*cos(2.*t1(i))
	    	u(i)=p1(i)*sin(2.*t1(i))
       		i=i+1
      	end do
20 		close(unit=1)
		if(modo==1) n=i-3 !leitura sel
 		if(modo==2) n=i-3   !leitura ftb
      	
      	!write(*,*) n
      	
      	if (n.gt.4000) then
       		write(6,*) 'Numero de estrelas maior que 4000!'
       		stop
      	end if
!!
!!  *** fazendo medias
!!
      	qpond=0.
      	upond=0.
      	ppond=0.
      	epond=0.
      	qdisp=0.
      	udisp=0.
      	pdisp=0.
      	edisp=0. 
      	pt=0.  
      	eth_med=0.
	  	pol_med=0.
	  	pol_mod_pond=0.
      	kk=28.6479
      	do i=1,n
    		peso=1./(e1(i)*e1(i))
        	qpond=q(i)*peso+qpond
        	upond=u(i)*peso+upond
        	qdisp=q(i)+qdisp
        	udisp=u(i)+udisp
        	pt=peso+pt
        	eth_med=eth_med+e1(i)/p1(i)*kk
			pol_med=pol_med+p1(i)
			pol_mod_pond = pol_mod_pond + p1(i)*peso
			!write(6,*), p1(i)*peso,pol_mod_pond,p1(i),peso
      	end do
      	eth_med=eth_med/n
	  	pol_med=pol_med/n
!!
!!    Ponderado
!!
      	qpond=qpond/pt
		upond=upond/pt
      	eppond=sqrt(1./pt)
      	ppond=sqrt(qpond*qpond+upond*upond)
      	tpond=atan2(upond,qpond)
      	tpond=0.5*tpond*57.29578
      	if (tpond.lt.0.) tpond=tpond+180.
	  	!write(6,*) pol_mod_pond,pt
	  	pol_mod_pond = pol_mod_pond/pt
	  	!write(6,*)pol_mod_pond
	  	!lovo=pol_mod_pond
!!    
!!	Dispersao
!!
      	eq=0.
      	eu=0.
      	qdisp=qdisp/n
      	udisp=udisp/n	
      	do i=1,n
       		eq=eq+(q(i)-qdisp)**2
       		eu=eu+(u(i)-udisp)**2
      	end do
      	eq=sqrt(eq/(n-1))
      	eu=sqrt(eu/(n-1))
      	pdisp=sqrt(qdisp*qdisp+udisp*udisp)
      	epdisp=sqrt((qdisp*qdisp*eq*eq+udisp*udisp*eu*eu)/pdisp)
      	tdisp=atan2(udisp,qdisp)
      	tdisp=0.5*tdisp*57.29578
      	if (tdisp.lt.0.) tdisp=tdisp+180.

      	write(6,*) ' '
      	write(6,*) '        Valores em porcentagem '
	    write(6,*) ' '
      	write(6,*) 'Media ponderada com erro da polarizacao '
      	write(6,*) ' '
      	write(6,*) '     <Q>        <U>        <P>       erro    Theta'
      	write(6,10) 100.*qpond,100.*upond,100.*ppond,100.*eppond,tpond
      	write(6,*) ' '
      	write(6,*) ' '
      	write(6,*) 'Media simples e desvio padrao'
      	write(6,*) ' '
      	write(6,*) '     <Q>        <U>        <P>       erro    Theta'
      	write(6,10) 100.*qdisp,100.*udisp,100.*pdisp,100.*epdisp,tdisp
      	write(6,*) ' '
      	write(6,*) 'Media do erro de PA:',eth_med
	  	write(6,*) ' '
	  	write(6,*) 'Media do modulo da polarizacao: ',100*pol_med
	  	write(6,*) ' '
	  	write(6,*) 'Media ponderada do modulo polarizacao: ',100*pol_mod_pond
	  	write(6,*) ' '

		
		open(unit=912,file=arq2,status="new")
		write(912,*) ' '
    	write(912,*) '        Valores em porcentagem '
    	write(912,*) ' '
    	write(912,*) 'Media ponderada com erro da polarizacao '
      	write(912,*) ' '
      	write(912,*) '     <Q>        <U>        <P>       erro    Theta'
      	write(912,10) 100.*qpond,100.*upond,100.*ppond,100.*eppond,tpond
      	write(912,*) ' '
      	write(912,*) ' '
      	write(912,*) 'Media simples e desvio padrao'
      	write(912,*) ' '
      	write(912,*) '     <Q>        <U>        <P>       erro    Theta'
      	write(912,10) 100.*qdisp,100.*udisp,100.*pdisp,100.*epdisp,tdisp
      	write(912,*) ' '
      	write(912,*) 'Media do erro de PA:',eth_med
	  	write(912,*) ' '
	  	write(912,*) 'Media do modulo da polarizacao: ',100*pol_med
	  	write(912,*) ' '
	  	write(912,*) 'Media pond mod pol: ',100*pol_mod_pond
	  	write(912,*) ' '
	  	
	  	write(912,*)100*ppond,"	",100*eppond,"	",tpond,"	",100*pdisp,"	",100*epdisp,"	",tdisp &
		,"	",eth_med,"	",100*pol_med,"	",100*pol_mod_pond
	  	close(912)

		
		
10  	format(4f11.4,f7.1)

      	end 

             


