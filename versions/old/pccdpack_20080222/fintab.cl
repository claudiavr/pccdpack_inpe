#
# Ver. Feb05
#

procedure fintab

string file_mgn        {prompt = "input magnit file (.mgn)"}
string file_txt        {prompt = "input refer file (.txt)"}
string file_img        {prompt = "reference image (.imh,.fits)"}
string file_out        {prompt = "output file (.ftb)"}
bool   mapa = no       {prompt = "create .txt for map?"}
string imgmapa         {prompt = "map image (.imh,.fits)"}
string txt_mapa        {prompt = "output map file (.txt)"}
struct *flist1
struct *flist2

begin

int    id
real   mag,emag,pol,sigma,theta,xx,yy,xmap,ymap,p,the, sig, xzero,yzero
string linedata,lix,ar,dec,temp0,temp1,temp2,temp3,temp4,fileout,equiref,equimap
string xlong,ylong,txtmapa
struct line1

delete(file_out//".ftb",ver-)
temp0 = mktemp("tmp$fin")
temp1 = mktemp("tmp$fin")
fileout = mktemp("tmp$fin")
#fileout = file_out//".ftb"

flist1 = file_txt 
while(fscan(flist1,line1) != EOF) {
    linedata = fscan(line1,lix,lix,p,the,sig)
    print(line1, >> temp0)
   
}    
      

####### calcula alfa e delta de file_txt ############

unlearn rimcursor
rimcursor.wcs      = "world"
rimcursor.wxformat = "%12.2H"
rimcursor.wyformat = "%12.2h"
rimcursor.cursor   = temp0

unlearn imgets
imgets(file_img,"EQUINOX")
equiref = imgets.value



rimcursor (file_img, >> temp1)

flist1 = temp1
flist2 = file_mgn

print("ID   AR("//equiref//")  DEC("//equiref//")  P(%)  SIGMA(%) THETA    MAG     EMAG", >> fileout)

while (fscan(flist2,line1) != EOF) {

   linedata = fscan(line1,mag,emag,pol,sigma,theta,id)
   linedata = fscan(flist1,ar,dec,lix,lix,lix)
   print (id,"  ",ar,"   ",dec,"  ",pol,"  ",sigma,"  ",theta,"  ",mag,"  ",emag, >> fileout)
}

copy(fileout,file_out//".ftb")

delete(temp0, ver-)
delete(temp1, ver-)
delete(fileout, ver-)


if (mapa == yes) {
    
    delete(txt_mapa//".txt",ver-)

    temp0 = mktemp("tmp$fin")
    temp1 = mktemp("tmp$fin")
    temp2 = mktemp("tmp$fin")
    temp3 = mktemp("tmp$fin")
    temp4 = mktemp("tmp$fin")
    txtmapa = mktemp("tmp$fin")
    
#    txtmapa = txt_mapa//".txt"
    
    print("creating coordinates over image ",imgmapa," ...")
    
    
    unlearn tdump
    tdump (file_out//".ftb",datafile=temp0,columns="2,3",rows="2-",>>temp4)
      
    imgets(imgmapa,"EQUINOX")
    equimap = imgets.value 
    
    print('precessing ',equiref,' ----> ',equimap)
    precess(temp0,real(equiref),real(equimap), >> temp1)
       
    imgets(imgmapa,"CNPIX1")
    xzero = real(imgets.value)
    imgets(imgmapa,"CNPIX2")
    yzero = real(imgets.value)

    unlearn eqxy
    eqxy.original = yes
    eqxy.new      = no
    eqxy.ra_hours = yes
    eqxy.xformat  = ""
    eqxy.yformat  = ""

    eqxy(yes,imgmapa,"",temp1,"iraf",1,2,0, >> temp2)
    print(temp2)

    unlearn tdump
    tdump(temp2,datafile=temp3,columns="3,4",rows="2-",>>temp4)
   

    flist1 = temp3
    flist2 = file_txt

    while (fscan(flist1,line1) != EOF) {

    linedata = fscan(line1,xmap,ymap)
    linedata = fscan(flist2,lix,lix,pol,theta,sigma,id)
    print (xmap,"  ",ymap,"   ",pol,"  ",theta,"  ",sigma,"  ",id, >> txtmapa)

    }



imgets(imgmapa,"i_naxis1")
xlong = imgets.value
imgets(imgmapa,"i_naxis2")
ylong = imgets.value

print("0 0 0 0 0", >> txtmap)
print(xlong," ",ylong," 0 0 0", >> txtmap)

copy(txtmapa,txt_mapa//".txt")

delete(temp0, ver-)
delete(temp1, ver-)
delete(temp2, ver-)
delete(temp3, ver-)
delete(temp4, ver-)
delete(txtmapa, ver-)


print (txt_mapa)

}

flist1 = ""
flist2 = ""
end
    
    
               
