############
# Victor Magalhaes 20/09/2011
# Padronizar a fabricação dos catalogos
#################################################################
# Retiradas as opcoes de colocar a escala de placa e tamanhos da imagem de referencia
# Agora eles sao pegos do header da imagem de referencia
# 30/09/2011
##################################################################
# 
# Claudia V. Rodrigues - Oct/2014
# Translation of messages to English
#
##################################################################

procedure coords_real

string 	objeto			{prompt="Root of the output files"}
string 	referencia     	{prompt="Skyview reference image"}
string 	imgccd			{prompt="CCD image (your data!)"}
#real  	espref        	{prompt="Escala de placa da referencia (arcsec/pixel) "}
real   	espccd        	{prompt="Plate scale in the CCD image (arcsec/pixel) "}
#real  	xtamref      	{prompt="Tamanho da referencia em x (pixels)"}
#real   ytamref      	{prompt="Tamanho da referencia em y (pixels)"}
real   	xtamccd        	{prompt="CCD size in X direction (pixels)"}
real   	ytamccd      	{prompt="CCD size in Y direction (pixels)"}
string 	norde       	{enum="right|left|top|bottom", prompt="Norte direction in CCD image"}
string 	ost        		{enum="right|left|top|bottom", prompt="East direction in CCD image"}
real   	inclina = 0    	{prompt="Angle between axis and equatorial reference frame[?]"}
bool   	recentra   		{prompt="Recenter objects?"}
real   	centrobox = 5   {prompt="centering box width in scale units"}


struct *flist1
struct *flist2

begin

	string temp1, temp2, scontinua, lixo, linedataref, linedataccd, refcoo, ccdcoo, check
	bool bb,prossegue
	real xref,yref,xccd,yccd,lixo2,espref,xtamref,ytamref
	int nlin,alterpar, continua
	struct line1, line2
	
	
	package | grep stsdas | scan(check)
	package | grep apphot | scan(check)
	
	
	if(check=="stsdas") print("apphot nao carregado, carregar e tentar de novo")
	if(check=="apphot"){
	
#	print("achei apphot!!!")
	hselect(referencia,fields="CDELT2",expr=yes) | scan(espref)
	hselect(referencia,fields="crpix1",expr=yes) | scan(xtamref)
	hselect(referencia,fields="crpix2",expr=yes) | scan(ytamref)
	espref = espref * 3600
	xtamref = (xtamref-0.5) * 2
	ytamref = (ytamref-0.5) * 2
#	print(espref)
#	print(xtamref)
#	print(ytamref)	
	alterpar = 10
	continua = 0
	display(referencia, frame=1)
	display(imgccd, frame=2)
	tvmark(2, objeto//".sel")
	if(norde == "right" && ost == "bottom"){
		print("")
		print("Frame 2:")
		print("Invert <y> and rotate by 90 deg")
		print("")
	}
	if(norde == "top" && ost == "right"){
		print("")
		print("Frame 2:")
		print("Invert <x>")
		print("")
	}
	print("Find the same object in the two images (different frames)")
	#print("Que esteja marcada no frame 2")
	print("When ready, type <continua>")
	print("To exit, type <sair>")

	while(continua == 0){
		lixo=scan(scontinua)
		if(scontinua == "continua") continua = 1
		if(scontinua == "sair") continua = 2
	}
	if(continua == 1){
	bb=no
	while(bb == no){
		display(referencia, frame=1)
		temp1 = mktemp("tmp$coords")
		print("")
		print("Mark the object in the reference image:")
		print("Use <a> to mark e <q> to exit")
		print("")
		daoedit(referencia, > temp1//"")
		#type temp1//""
		flist1=temp1
		nlin=0
		while (fscan(flist1,line1) != EOF) {
			nlin=nlin+1
			if (nlin==3){
				linedataref=fscan(line1, xref, yref)
			}
		}
		refcoo = mktemp("tmp$coords")
		print(xref,yref,> refcoo)
		tvm(1,refcoo)
		print("Object coordinates")
		print(xref,yref)
		print("")
		print("Is TVMARK showing the correct object? (yes|no)")
		lixo=scan(bb)
	}
	bb=no
	while(bb == no){
		display(imgccd, frame=2)
		tvmark(2, objeto//".sel")
		temp2 = mktemp("tmp$coords")
		print("")
		print("Mark the same object in your CCD image.")
		print("Use the pair image that is marked by a circle")
		print("Use <a> to mark and <q> to exit")
		print("")
		daoedit(imgccd, > temp2//"")
		#type temp2//""
		flist2=temp2
		nlin=0
		while (fscan(flist2,line2)!= EOF) {
			nlin=nlin+1
			if (nlin==3){
				linedataccd=fscan(line2, xccd, yccd)
			}
		}
		ccdcoo = mktemp("tmp$coords")
		print(xccd,yccd,> ccdcoo)
		print("Object coordinates")
		print(xccd,yccd)
		display(imgccd, frame=2)
		tvm(2,ccdcoo)
		print("")
		print("Is TVMARK showing the correct object? (yes|no)")
		lixo=scan(bb)
	}
	bb=no
	while(bb ==  no){
		unlearn refer_inpe
		refer_inpe.epimg = espref
		refer_inpe.epccd	= espccd
		refer_inpe.ximagem = xtamref
		refer_inpe.yimagem = ytamref
		refer_inpe.xside = xtamccd
		refer_inpe.yside = ytamccd
		refer_inpe.norte = norde
		refer_inpe.leste = ost
		refer_inpe.incli = inclina
		refer_inpe.recen = recentra
		refer_inpe.imgrefer = referencia
		refer_inpe.cbox = centrobox
		refer_inpe(file_sel=objeto//".sel",file_txt=objeto//".txt",xo=xref,yo=yref,xoi=xccd,yoi=yccd)
		displa(imgccd,frame=2)
		tvmark(2, objeto//".sel")
		displa(referencia,frame=1)
		tvmark(1, objeto//".txt")
		print("")
		print("Check the marks in the reference image.")
		print("It they are correct, type <yes>")
		lixo=scan(bb)
		if(bb == no){
			prossegue = no
			while(prossegue == no){
				print("")
				print("What would you like to do now?")
				print("To quit, type 0")
				print("To change the plate scale of the reference image, type 1")
				print("To change the plate scale of your image, type 2")
				print("To change the centering parameters, type 3")
				lixo=scan(alterpar)
				if(alterpar == 0){
					prossegue = yes
					bb = yes
				}
				if(alterpar == 1){
					print("")
					print("Present plate scale of the reference image:")
					print(espref)
					print("New plate scale of the reference image:")
					lixo=scan(espref)
				}
				if(alterpar == 2){
					print("")
					print("Present plate scale of your image:")
					print(espccd)
					print("New plate scale of your image:")
					lixo=scan(espccd)
				}
				if(alterpar == 3){
					print("")
					print("Center again? (yes|no)")
					lixo=scan(recentra)
					if(recentra){
						print("")
						print("Present centering boxsize:")
						print(centrobox)
						print("New centering boxsize:")
						lixo=scan(centrobox)
					}
				}
				if(alterpar != 0){
					print("")
					print("Continue with the new references? (yes|no)")
					lixo=scan(prossegue)
				}
			}
		}
	}
	if(alterpar != 0){
		fintab_sopol(file_txt=objeto//".txt",file_img=referencia,file_out=objeto)
		print("")
		print("Load ",objeto,".ftb and ",referencia," in aladin. Use the correct filter to plot polarization vectors.")
		#print("Exit  do apphot para evitar conflitos com as outras rotinas do inpepackage")
	}
	coords_real.espccd = espccd #????
#	coords_real.espref = espref
	coords_real.centrobox = centrobox
	delete(temp1, ver-)
	delete(temp2, ver-)
	delete(refcoo, ver-)
	delete(ccdcoo, ver-)
	}
	}

end

