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
      integer n,i
      character*20 arq1,lxchar
!!
!!*** Leitura de dados
!!  
c	Le um arquivo tipo ".out": saida do macrol/pccdpack
!!
!!     write(6,*) 'Nome do primeiro arquivo '
      read(*,*) arq1
!!     write(6,*) 'Numero de estrelas '
!!     read *, n
!!     write(6,*) arq1
      open (unit=1,file=arq1,status='old')
      read (1,*) lxchar
!!     write(6,*) lxchar
      read (1,*) lxchar
!!     write(6,*) lxchar
      i=1
      cont=.true.
      do while (cont)
!!      read (1,*,end=20) lx,lx,p1(i),t1(i),q(i),u(i),e1(i) !leitura sel
	   read (1,*,end=30) lx,lx,lx,lx,lx,lx,lx,p1(i),e1(i),t1(i) !leitura ftb
       !write(6,*) p1(i),e1(i),t1(i)
	   p1(i)=0.01*p1(i) !conversao ftb
	   e1(i)=0.01*e1(i) !conversao ftb
       i=i+1
      end do
!!20   n=i-3 !leitura sel
 30   n=i-1   !leitura ftb
      close(unit=1)
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
	    t1(i)=t1(i)*0.017453
	    q(i)=p1(i)*cos(2.*t1(i))
	    u(i)=p1(i)*sin(2.*t1(i))
    	peso=1./(e1(i)*e1(i))
        qpond=q(i)*peso+qpond
        upond=u(i)*peso+upond
        qdisp=q(i)+qdisp
        udisp=u(i)+udisp
        pt=peso+pt
        eth_med=eth_med+e1(i)/p1(i)*kk
		pol_med=pol_med+p1(i)
		pol_mod_pond = pol_mod_pond + p1(i)*peso
		write(6,*), p1(i)*peso,pol_mod_pond,p1(i),peso
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
	  write(6,*) pol_mod_pond,pt
	  pol_mod_pond = pol_mod_pond/pt
	  write(6,*)pol_mod_pond
	  lovo=pol_mod_pond
!!    
c	Dispersao
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
  10  format(4f11.4,f7.1)
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
	  write(6,*) 'Media pond mod pol: ',100*pol_mod_pond
	  write(6,*) ' '

      end 

             


