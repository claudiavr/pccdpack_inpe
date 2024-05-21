#
# Ver. Feb03
#

procedure correfer

string file_sel     {prompt="select file (.sel)"}
string file_txt     {prompt="refer file (.txt)"}
real   radius=0     {prompt="maximum distance permitted (in pixels)"}
struct *flist
struct *flist1
struct line         {length=160}
struct line1        {length=160}

begin

  real xcenter, ycenter, p, q, u, theta, sigma, deltatheta, cq, cu
  int  nl = 0
  string linedata, lix, line0, temp0, id
  string temp3, temp4, temp5, temp6, temp7, temp8, temp50
  string filetxt, aa
  real  xx1, yy1, xx2, yy2, cbox, dif
  int  ml, id1, id2, nll, star
  bool bb

  if (access("c"//file_txt)) delete("c"//file_txt,ver-)

  print("")
  print("Checking for objects with near (x,y) coordinates in ",file_txt)
  print("")
  temp3 = mktemp("tmp$ref")
  temp4 = mktemp("tmp$ref")
  temp5 = mktemp("tmp$ref")

  filetxt = file_txt

  temp3 = filetxt
  temp4 = filetxt


  flist  = temp3

  nl = 0
  while (fscan(flist,line) != EOF) {

      linedata = fscan(line,xx1,yy1,lix,lix,lix,id1)

      flist1 = temp4

      while (fscan(flist1,line1) != EOF) {

          linedata = fscan(line1,xx2,yy2,lix,lix,lix,id2)

	  dif = sqrt((xx2-xx1)**2 + (yy2-yy1)**2)

          if ((dif <= radius) && (id1 < id2)) {
	      nl = nl + 1
	      temp50 = mktemp("tmp$ref")
	      print ("Pair ",nl,": ",id1," ", id2)
	      print(line, >> temp50)
	      print(line1, >> temp50)
              unlearn filecalc
	      filecalc.lines="-"
	      filecalc.format="%10.3f%10.3f%10.5f%10.1f%10.5f%9.0f"
              filecalc(temp50//"","$1;$2;$3;$4;$5;$6")
	      print (id1,>> temp5)
	      print (id2,>> temp5)
	      delete(temp50,ver-)
          }
      }
   }

   nll = nl

   if (nll > 0) {

     print("")
     print("Creating a select file for filtered objects...")
     print("")

     temp6 = mktemp("tmp$ref")

     flist = temp5

     ml = 0
     while (fscan(flist,line) != EOF) {
       ml = ml + 1
       linedata = fscan(line,id)

       flist1 = file_sel
       nl=0
       while (fscan(flist1, line1) != EOF) {
           nl= nl + 1


	   if (ml == 1) if ((nl == 1) || (nl == 2)) print(line1,>> temp6)

           if (nl > 2) {
	   linedata = fscan(line1,xcenter,ycenter,p,theta,q,u,sigma,lix,lix,star)
	   if (int(id) == star) print(line1, >> temp6)
	   }
       }
    }

    unlearn filecalc

    print("   XCENTER   YCENTER      P        THETA     SIGMA   ID  APERTURE    STAR")

    filecalc.lines = "3-"
    filecalc.format = "%10.3f%10.3f%10.5f%10.1f%10.5f%5.0f%7.0f%9.0f"
    filecalc(temp6//"","$1;$2;$3;$4;$7;$8;$9;$10")

    print("")
    print("Re-run refer for filtered objects...")
    print("cbox parameter: ",refer.cbox)

    temp7 = mktemp("tmp$ref")

    bb = no

    while (bb == no) {

    print("New cbox parameter?")
    scan(cbox)

    refer.file_sel = temp6
    refer.file_txt = temp7
    refer.cbox = cbox
    refer
    print("")

    unlearn filecalc
    filecalc.lines = "-"//(nll*2)
    filecalc.format = "%10.3f%10.3f%10.5f%10.1f%10.5f%9.0f"
    filecalc(temp7//"","$1;$2;$3;$4;$5;$6")


    print("")
    print("is it correct (yes|no)?")
    aa=scan(bb)
    }

    print("")
    print("Editing ",file_txt," with new data for filtered objects...")
    print("")

    flist = file_txt
    temp8 = "c"//file_txt

    while (fscan(flist,line) != EOF) {
      linedata = fscan(line,xx1,yy1,lix,lix,lix,id1)
      flist1 = temp7
      line0 = line
      for (nl=1; nl <= nll*2; nl+=1) {
          linedata = fscan(flist1,line1)
          linedata = fscan(line1,xx2,yy2,lix,lix,lix,id2)
          if (id1 == id2) {
	      line0 = line1
	      print("object ", id1," fixed.")
          }
      }
      print(line0, >> temp8)
     }

     print("")
     print(temp8," created.")
     print("")

  del(temp5,ver-)
  del(temp6,ver-)
  del(temp7,ver-)

  } else {

  print ("0 objects founded.")
  print("")

  }

  flist=""
  flist1=""
  line=""
  line1=""
end            
