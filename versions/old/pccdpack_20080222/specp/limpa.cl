procedure limpa

begin
		
	bool ver1
	
	ver1 = access("tmp$")
	
	if (ver1 == yes) {
		delete ("dir.txt", ver-, >& "dev$null")
		cd ("tmp$")
		imdelete ("*.fits", ver-, >& "dev$null")
		delete ("*.txt", ver-, >& "dev$null")
		back (>& "dev$null")
	}
	
	     
end	
	

