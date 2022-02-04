c
c	programa ordem
c
c	versao em fortran-iraf da task ordem criada por A. Pereyra
c
c
c	uso: ordem arq_in arq_out shiftx shifty dx dy dmag side
c
c
c 
c Script ORDEM  (Ver 1.40)
c
c Resumo:  Selecciona e ordena o arquivo de coordenadas obtido pelo DAOFIND
c          (file_in.coo) em pares de estrelas (x1,y1) inferior, e (x2,y2)  
c          superior. As posicoes do par estao dadas por: 
c 
c          shiftx - deltax   <  x2 - x1  <  shiftx + deltax 
c          shiftx - deltay   <  y2 - y1  <  shiftx + deltay 
c
c          Se side = 'right' , shiftx > 0 e (x2,y2) ficara acima e a direita
c                                                   de (x1,y1)
c
c          Se side = 'left'  , shiftx < 0 e (x2,y2) ficara acima e a izquerda
c                                                   de (x1,y1)
c
c          Uma ultima seleccao e feita sempre e quando:
c
c          abs (mag1 - mag2) < deltamag,
c 
c          onde mag1 e mag2 sao as magnitudes da primera e segunda estrela
c          respectivamente, obtidas do (.coo) .
c
c          A saida e dirigida a um archivo (file_name.ord) com os campos 
c          XCENTER, YCENTER, ID para cada par achado. O archivo (.ord)
c          fica pronto para ser usado como archivo de ccordenadas 
c          pelo PHOT (DAOPHOTX).      
c
c
	  program ordem
c
	  character*90 arq_in,arq_out,side,lixo
	  character*1 pripar
	  real x(30000),y(30000),mag(30000),shiftx,shifty,deltax,deltay,deltamag,shiftx1
	  real shiftxinf,shiftxsup,xc1,xc2,yc1,yc2,mag1,mag2,difx,dify,difmag
	  integer i,j,npar,nstar
	  logical continua,par(30000),ppripar
c
c	  write(*,*) 'debug1'
c	  write(*,*) 'debug2'
      shiftx=32
c      write(*,*) shiftx*shiftx
c        call testelib (nargs)
c	  call clnarg (nargs)
c	  write(*,*) 'debug3'
c	  if (nargs.eq.9) then
c	  	call clargc(1,arq_in,ier)
c        write(*,*) 'debug123'
c		if (ier.ne.0) goto 100
c		call clargc(2,arq_out,ier)
c		if (ier.ne.0) goto 100
c		call clargr(3,shiftx,ier)
c		if (ier.ne.0) goto 100
c		call clargr(4,shifty,ier)
c		if (ier.ne.0) goto 100
c		call clargr(5,deltax,ier)
c		if (ier.ne.0) goto 100
c		call clargr(6,deltay,ier)
c		if (ier.ne.0) goto 100
c		call clargr(7,deltamag,ier)
c		if (ier.ne.0) goto 100
c		call clargc(8,side,ier)
c		if (ier.ne.0) goto 100
c		call clargc(9,pripar,ier)
c		if (ier.ne.0) goto 100
		open(unit=330,file="ord.par",status="old")
			read(330,*)
			read(330,*)arq_in
			read(330,*)arq_out
			read(330,*)shiftx
			read(330,*)shifty
			read(330,*)deltax
			read(330,*)deltay
			read(330,*)deltamag
			read(330,*)side
			read(330,*)pripar
		close(330)

                if (pripar.eq.'y') then 
		    ppripar=.true. 
                    else 
		    ppripar=.false.
                endif
c	  else
c	  	write(*,*)'No. de parametros incorreto em ORDEM'
c		write(*,*)' '
c		write(*,*)'Uso: ordem arq_in arq_out shiftx shifty dx dy dmag side pripar'
c		goto 110
c	  endif
c        write(*,*)'debug2'
c
c lendo arquivo de entrada
c
		open(4,file=arq_in)
		do i=1,41
			read(4,*) lixo
c			write(6,*) i, lixo
		end do
		continua=.true.
		i=0
		do while (continua)
		  i=i+1
		  if (i.gt.30000) then
		    write(*,*) 'O n estrelas eh maior que ordem do array.'
		    write(*,*) 'mudar a dimensao dos arrays no ordem_ie.f.'
		  end if
		  read(4,*,end=20) x(i),y(i),mag(i)
		  par(i)=.false.
c		  write(6,*) i,x(i),y(i),mag(i)
		end do
20		continua=.false.
		nstar=i-1	
c		write(6,*) 'nstar ',nstar
		close(4)
c
c Da valor logico a posicao do par superior
c
      	if (side.eq.'left') then
          shiftx1 = -1 * shiftx
        else  
          shiftx1 = shiftx
    	end if
c
c Define rangos de comparacao X do 'shiftx'  
c
        shiftxinf = shiftx1 - deltax
        shiftxsup = shiftx1 + deltax
c      
c Define rangos de comparacao Y do 'shifty'
c
      	shiftyinf = shifty - deltay  
      	shiftysup = shifty + deltay
c      
c Imprime cabecario no archivo de saida
   	open(4,file=arq_out)
      	write(4,*) "XCENTER  YCENTER   ID"
c	do i=1,nstar
c	write(4,*) x(i),y(i)
c	end do
c	goto 110
c      
c 
c 	Escolhendo pares
c
	npar=0
	do i=1,nstar-1
	  xc1=x(i)
	  yc1=y(i)
	  mag1=mag(i)
	  j=i
	  continua=.true.
	  if (par(i).eqv..true.) continua=.false.
	  do while (continua)
	   j=j+1
           xc2=x(j)
	   yc2=y(j)
	   mag2=mag(j)
c
           difx   =  xc2 - xc1                           
c Define distancia Y entre (1) e (2)
           dify   =  yc2 - yc1                
c Define diferencia entre magnitudes de (1) e (2)
           difmag = abs (mag1 - mag2)
c
c Verifica sim (1) e (2) estao entre os rangos X
c
c	   write(*,*) i,j,xc1,yc1,xc2,yc2,x(i),y(i),x(j),y(j)
c	   read(*,*) lixo
           if (difx.lt.shiftxsup) then
           	if (difx.gt.shiftxinf) then
c                   
c Verifica sim (1) e (2) estao entre os rangos Y
c
             		if (dify.lt.shiftysup) then
                        	if (dify.gt.shiftyinf) then
c
c Verifica sim a dif. de mags. e menor a 'deltamag'
c
                                 	if (difmag.lt.deltamag) then
c    
c Conta o numero de pares achados
c
                                              npar = npar + 1
                                              par(i)=.true.
                                              if (ppripar) par(j)=.true.
c
c Imprime na tela os pares achados
c
                                              write(*,*) 'PAR ', npar 
                                              write(*,*) xc1,yc1,i
                                              write(*,*) xc2,yc2,j
c Imprime no archivo de saida os pares achados
					      write(4,*) xc1,yc1,i
					      write(4,*) xc2,yc2,j
					      continua=.false.
					end if
				end if
			end if
		end if
	  end if
	  if (j.eq.nstar) continua=.false.
	 end do
	end do
  	close(4)
	goto 120
100	call imemsg(ier,errmsg)
	write(*,'(''Erro: '',a80)')errmsg
110	stop
120	end
