procedure apallsp

begin
		
	apall.format = "multispec"
	apall.interac = yes
	apall.extras = yes
	
	apall.nfind = 2
	
	apall
	
	hedit (apall.input//".ms", fields = "NPONTOS", value = apall.width, add = yes,
	      delete = no, verify = no, show = no, update = yes)
	     
end	
	
