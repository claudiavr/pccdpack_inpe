/* phot_pol_e.f -- translated by f2c (version 20100827).
   You must link the resulting object file with libf2c:
	on Microsoft Windows system, link with libf2c.lib;
	on Linux or Unix systems, link with .../path/to/libf2c.a -lm
	or, if you install libf2c.a in a standard place, with -lf2c -lm
	-- in that order, at the end of the command line, as in
		cc *.o -lf2c -lm
	Source for libf2c is in /netlib/f2c/libf2c.zip, e.g.,

		http://www.netlib.org/f2c/libf2c.zip
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;
static integer c__2 = 2;
static integer c__3 = 3;
static integer c__4 = 4;
static integer c__5 = 5;
static integer c__6 = 6;
static integer c__7 = 7;
static integer c__8 = 8;
static integer c__9 = 9;


/* 	program phot_pol (ver 1.0 - agosto/1999) */

/* 	fortran-iraf para fazer fotometria de campos com calcita */

/* 	Usa pccd do Antonio Mario Magalhaes */


/* 	uso: phot_pol arq_mag */


/* Resumo: */

/* 	1. le arquivo com contagens - saida do phot */
/* 	2. calcula fluxo relativo a uma estrela de comparacao, comp */


/* Main program */ int MAIN__()
{
    /* Format strings */
    static char fmt_10[] = "(1i3,30e13.5)";
    static char fmt_11[] = "(1i3,30e15.5)";

    /* System generated locals */
    integer i__1, i__2, i__3, i__4;
    doublereal d__1, d__2;
    icilist ici__1;
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    integer s_wsle(), do_lio(), e_wsle();
    /* Subroutine */ int s_stop();
    integer f_open(), s_rsfe(), do_fio(), e_rsfe(), i_indx();
    /* Subroutine */ int s_copy();
    integer s_rsli(), e_rsli(), f_clos();
    double sqrt();
    integer s_wsfe(), e_wsfe();

    /* Local variables */
    static doublereal a[60];
    static integer i__, j, k, l;
    static doublereal an[3600000]	/* was [100][2000][18] */, ap[18], 
	    dif[3600000]	/* was [100][2000][18] */, ane[3600000]	/* 
	    was [100][2000][18] */, ceu[1800]	/* was [100][18] */, ano[
	    3600000]	/* was [100][2000][18] */;
    static integer nap, ier, nhw;
    static char line[380];
    static integer comp;
    static doublereal erro[1800]	/* was [100][18] */, skye[200000]	
	    /* was [100][2000] */;
    static integer nout;
    static doublereal skyo[200000]	/* was [100][2000] */, areae[3600000]	
	    /* was [100][2000][18] */;
    static char image[12];
    static doublereal areao[3600000]	/* was [100][2000][18] */;
    static real ganho;
    static integer nargs;
    static doublereal ruido[1800]	/* was [100][18] */, antot[200000]	
	    /* was [100][2000] */;
    extern /* Subroutine */ int clargc_();
    static doublereal arease[200000]	/* was [100][2000] */;
    extern /* Subroutine */ int clargi_(), clnarg_();
    static char arq_in__[60];
    static doublereal areaso[200000]	/* was [100][2000] */;
    extern /* Subroutine */ int clargr_(), imemsg_();
    static doublereal errmsg;
    static integer nstars;
    static char arq_out__[60];

    /* Fortran I/O blocks */
    static cilist io___11 = { 0, 6, 0, 0, 0 };
    static cilist io___12 = { 0, 6, 0, 0, 0 };
    static cilist io___13 = { 0, 6, 0, 0, 0 };
    static cilist io___14 = { 0, 6, 0, 0, 0 };
    static cilist io___15 = { 0, 6, 0, 0, 0 };
    static cilist io___16 = { 0, 6, 0, 0, 0 };
    static cilist io___19 = { 0, 8, 0, "(a)", 0 };
    static cilist io___30 = { 0, 8, 0, "(a)", 0 };
    static cilist io___41 = { 0, 8, 0, 0, 0 };
    static cilist io___42 = { 0, 8, 0, 0, 0 };
    static cilist io___43 = { 0, 8, 0, 0, 0 };
    static cilist io___44 = { 0, 8, 0, fmt_10, 0 };
    static cilist io___45 = { 0, 8, 0, 0, 0 };
    static cilist io___46 = { 0, 8, 0, 0, 0 };
    static cilist io___47 = { 0, 8, 0, 0, 0 };
    static cilist io___48 = { 0, 8, 0, fmt_11, 0 };
    static cilist io___49 = { 0, 8, 0, 0, 0 };
    static cilist io___50 = { 0, 8, 0, 0, 0 };
    static cilist io___51 = { 0, 8, 0, 0, 0 };
    static cilist io___52 = { 0, 8, 0, fmt_10, 0 };
    static cilist io___54 = { 0, 6, 0, "('Erro: ',a80)", 0 };




/*       Numero maximo de aberturas= 18 */
/*       Numero de estrelas=100    *    06 Jun 95    *    VEM - CVR */

/*       ano(# estrelas, pos. lamina, aberturas) */



/* 	lendo parametros da linha de comando */

    clnarg_(&nargs);
    if (nargs == 8) {
	clargc_(&c__1, arq_in__, &ier, (ftnlen)60);
	if (ier != 0) {
	    goto L100;
	}
	clargc_(&c__2, arq_out__, &ier, (ftnlen)60);
	if (ier != 0) {
	    goto L100;
	}
	clargi_(&c__3, &nstars, &ier);
	if (ier != 0) {
	    goto L100;
	}
	clargi_(&c__4, &nhw, &ier);
	if (ier != 0) {
	    goto L100;
	}
	clargi_(&c__5, &nap, &ier);
	if (ier != 0) {
	    goto L100;
	}
	clargi_(&c__6, &comp, &ier);
	if (ier != 0) {
	    goto L100;
	}
	clargi_(&c__7, &nout, &ier);
	if (ier != 0) {
	    goto L100;
	}
	clargr_(&c__8, &ganho, &ier);
	if (ier != 0) {
	    goto L100;
	}
    } else {
	s_wsle(&io___11);
	do_lio(&c__9, &c__1, "No. de parametros incorreto em PHOT_POL", (
		ftnlen)39);
	e_wsle();
	s_wsle(&io___12);
	do_lio(&c__9, &c__1, " ", (ftnlen)1);
	e_wsle();
	s_wsle(&io___13);
	do_lio(&c__9, &c__1, "Uso: phot_pol ??? ", (ftnlen)18);
	e_wsle();
	goto L110;
    }

/* 	Verificando se valores de variaveis estao dentro do intervalo */
/* 		permitido */

    if (nap > 18) {
	s_wsle(&io___14);
	do_lio(&c__9, &c__1, "Numero de aberturas fora do limite", (ftnlen)34)
		;
	e_wsle();
	s_stop("", (ftnlen)0);
    }
    if (nstars > 100) {
	s_wsle(&io___15);
	do_lio(&c__9, &c__1, "Numero de estrelas fora do limite", (ftnlen)33);
	e_wsle();
	s_stop("", (ftnlen)0);
    }
    if (nhw > 2000) {
	s_wsle(&io___16);
	do_lio(&c__9, &c__1, "Numero de laminas fora do limite", (ftnlen)32);
	e_wsle();
	s_stop("", (ftnlen)0);
    }

/* lendo arquivos com fotometria */

    o__1.oerr = 0;
    o__1.ounit = 8;
    o__1.ofnmlen = 60;
    o__1.ofnm = arq_in__;
    o__1.orl = 0;
    o__1.osta = "old";
    o__1.oacc = 0;
    o__1.ofm = 0;
    o__1.oblnk = 0;
    f_open(&o__1);

    i__1 = nhw;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__2 = nstars;
	for (j = 1; j <= i__2; ++j) {
/* 			print*, j */
	    s_rsfe(&io___19);
	    do_fio(&c__1, line, (ftnlen)380);
	    e_rsfe();
	    s_copy(image, line, (ftnlen)12, (ftnlen)(i_indx(line, " ", (
		    ftnlen)380, (ftnlen)1)));
/* 			print*, line */
	    i__3 = i_indx(line, " ", (ftnlen)380, (ftnlen)1) - 1;
	    ici__1.icierr = 0;
	    ici__1.iciend = 0;
	    ici__1.icirnum = 1;
	    ici__1.icirlen = 380 - i__3;
	    ici__1.iciunit = line + i__3;
	    ici__1.icifmt = 0;
	    s_rsli(&ici__1);
	    i__4 = nap * 3 + 2;
	    for (l = 1; l <= i__4; ++l) {
		do_lio(&c__5, &c__1, (char *)&a[l - 1], (ftnlen)sizeof(
			doublereal));
	    }
	    e_rsli();
/*      			print*,a */
/* 			stop */
	    skyo[j + i__ * 100 - 101] = a[0];
	    areaso[j + i__ * 100 - 101] = a[1];
/* 			print* */
/* 			print*, skyo(j,i) */
/* 			print* */
	    if (i__ == 1 && j == 1) {
		i__3 = nap;
		for (k = 1; k <= i__3; ++k) {
		    ap[k - 1] = a[k + 1];
		}
	    }
	    i__3 = nap;
	    for (k = 1; k <= i__3; ++k) {
		ano[j + (i__ + k * 2000) * 100 - 200101] = a[nap + 2 + k - 1];
	    }
	    i__3 = nap;
	    for (k = 1; k <= i__3; ++k) {
		areao[j + (i__ + k * 2000) * 100 - 200101] = a[nap + 2 + nap 
			+ k - 1];
	    }

	    s_rsfe(&io___30);
	    do_fio(&c__1, line, (ftnlen)380);
	    e_rsfe();
	    s_copy(image, line, (ftnlen)12, (ftnlen)(i_indx(line, " ", (
		    ftnlen)380, (ftnlen)1)));
	    i__3 = i_indx(line, " ", (ftnlen)380, (ftnlen)1) - 1;
	    ici__1.icierr = 0;
	    ici__1.iciend = 0;
	    ici__1.icirnum = 1;
	    ici__1.icirlen = 380 - i__3;
	    ici__1.iciunit = line + i__3;
	    ici__1.icifmt = 0;
	    s_rsli(&ici__1);
	    i__4 = nap * 3 + 2;
	    for (l = 1; l <= i__4; ++l) {
		do_lio(&c__5, &c__1, (char *)&a[l - 1], (ftnlen)sizeof(
			doublereal));
	    }
	    e_rsli();
	    skye[j + i__ * 100 - 101] = a[0];
	    arease[j + i__ * 100 - 101] = a[1];
	    i__3 = nap;
	    for (k = 1; k <= i__3; ++k) {
		ane[j + (i__ + k * 2000) * 100 - 200101] = a[nap + 2 + k - 1];
	    }
	    i__3 = nap;
	    for (k = 1; k <= i__3; ++k) {
		areae[j + (i__ + k * 2000) * 100 - 200101] = a[nap + 2 + nap 
			+ k - 1];
	    }
/* 			print *, image */
/* 			print *, (ap(k), k=1,nap) */
/* 			print *, (ane(j,i,k), k=1,nap) */
/* 			print *, (areae(j,i,k), k=1,nap) */
/* 			print *, (ano(j,i,k), k=1,nap) */
/* 			print *, (areao(j,i,k), k=1,nap) */
/* 			print*, image, skyo(j,i), (ap(k), k=1,nap), */
/*     $				(ano(j,i,k), k=1,nap), */
/*     $				(areao(j,i,k), k=1,nap) */
/*     			print*, ' ' */
/* 			print*, image, skye(j,i), (ap(k), k=1,nap), */
/*     $				(ane(j,i,k), k=1,nap), */
/*     $				(areae(j,i,k), k=1,nap) */
/* 			    print*, ' ' */

	}
    }

    cl__1.cerr = 0;
    cl__1.cunit = 8;
    cl__1.csta = 0;
    f_clos(&cl__1);


/* 	Calculando contagens de cada estrela */


    o__1.oerr = 0;
    o__1.ounit = 8;
    o__1.ofnmlen = 60;
    o__1.ofnm = arq_out__;
    o__1.orl = 0;
    o__1.osta = "new";
    o__1.oacc = 0;
    o__1.ofm = 0;
    o__1.oblnk = 0;
    f_open(&o__1);
    i__1 = nhw;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__2 = nstars;
	for (j = 1; j <= i__2; ++j) {
	    i__3 = nap;
	    for (k = 1; k <= i__3; ++k) {
/* 			write(8,*) ' j i k ', j,i,k */
/* 			write(8,*) 'skyo skye ano areao ane areae ' */
/* 	write(8,*)  skyo(j,i),skye(j,i),ano(j,i,k),areao(j,i,k),ane(j,i,k),areae(j,i,k) */
		ano[j + (i__ + k * 2000) * 100 - 200101] -= skyo[j + i__ * 
			100 - 101] * areao[j + (i__ + k * 2000) * 100 - 
			200101];
		ane[j + (i__ + k * 2000) * 100 - 200101] -= skye[j + i__ * 
			100 - 101] * areae[j + (i__ + k * 2000) * 100 - 
			200101];
		an[j + (i__ + k * 2000) * 100 - 200101] = ganho * (ano[j + (
			i__ + k * 2000) * 100 - 200101] + ane[j + (i__ + k * 
			2000) * 100 - 200101]);
/* 			write(8,*) 'ano ane an' */
/* 			write(8,*) ano(j,i,k),ane(j,i,k),an(j,i,k) */
/* 			write(8,*) ' ' */
	    }
	}
    }

/* 	Zerando variaveis referentes a estrela composta pela soma de todas as estrelas */

    i__1 = nhw;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__2 = nap;
	for (k = 1; k <= i__2; ++k) {
	    an[nstars + 1 + (i__ + k * 2000) * 100 - 200101] = (float)0.;
	}
    }


/* 	Zerando variaveis para calcular ruido de fotons */

    i__1 = nstars;
    for (j = 1; j <= i__1; ++j) {
	i__2 = nap;
	for (k = 1; k <= i__2; ++k) {
	    antot[j + k * 100 - 101] = (float)0.;
	    ceu[j + k * 100 - 101] = (float)0.;
	}
    }

/* 	Calculando somatorias para calcular ruido de fotons */

    i__1 = nstars;
    for (j = 1; j <= i__1; ++j) {
	i__2 = nap;
	for (k = 1; k <= i__2; ++k) {
	    i__3 = nhw;
	    for (i__ = 1; i__ <= i__3; ++i__) {
		antot[j + k * 100 - 101] += an[j + (i__ + k * 2000) * 100 - 
			200101];
		ceu[j + k * 100 - 101] = ceu[j + k * 100 - 101] + skye[j + 
			i__ * 100 - 101] * areae[j + (i__ + k * 2000) * 100 - 
			200101] + skyo[j + i__ * 100 - 101] * areao[j + (i__ 
			+ k * 2000) * 100 - 200101];
	    }
	}
    }

/* 	Calculando ruido de fotons para cada estrela */

/*        write(6,*) ganho */
    i__1 = nstars;
    for (j = 1; j <= i__1; ++j) {
	i__2 = nap;
	for (k = 1; k <= i__2; ++k) {
	    antot[j + k * 100 - 101] /= nhw;
	    ceu[j + k * 100 - 101] = ganho * ceu[j + k * 100 - 101] / nhw;
	    ruido[j + k * 100 - 101] = sqrt(antot[j + k * 100 - 101] + ceu[j 
		    + k * 100 - 101]);
	}
    }


/* 	Propagando erro: Erro de saida = erro da razao entre fluxo da estrela e */
/* 		fluxo da estrela de comparacao */

    i__1 = nstars;
    for (j = 1; j <= i__1; ++j) {
	i__2 = nap;
	for (k = 1; k <= i__2; ++k) {
	    if (j != comp) {
		erro[j + k * 100 - 101] = antot[j + k * 100 - 101] * antot[j 
			+ k * 100 - 101] * ruido[comp + k * 100 - 101] * 
			ruido[comp + k * 100 - 101];
/* Computing 2nd power */
		d__1 = ruido[j + k * 100 - 101];
/* Computing 2nd power */
		d__2 = antot[comp + k * 100 - 101];
		erro[j + k * 100 - 101] += d__1 * d__1 * (d__2 * d__2);
		erro[j + k * 100 - 101] = sqrt(erro[j + k * 100 - 101]) / (
			antot[comp + k * 100 - 101] * antot[comp + k * 100 - 
			101]);
	    }
	}
    }


/* 	FAzendo fotometria de todas as estrelas do campo com relacao a estrela de comparacao */


    i__1 = nhw;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__2 = nstars;
	for (j = 1; j <= i__2; ++j) {
	    i__3 = nap;
	    for (k = 1; k <= i__3; ++k) {
		if (j != comp && j != nout) {
		    an[nstars + 1 + (i__ + k * 2000) * 100 - 200101] += an[j 
			    + (i__ + k * 2000) * 100 - 200101];
		}
		dif[j + (i__ + k * 2000) * 100 - 200101] = an[j + (i__ + k * 
			2000) * 100 - 200101] / an[comp + (i__ + k * 2000) * 
			100 - 200101];
	    }
	}
    }


/* 	FAzendo fotometria da estrela composta pela soma de todas as estrelas */
/* 	de campo com a comparacao */


    i__1 = nhw;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i__2 = nap;
	for (k = 1; k <= i__2; ++k) {
	    dif[nstars + 1 + (i__ + k * 2000) * 100 - 200101] = an[nstars + 1 
		    + (i__ + k * 2000) * 100 - 200101] / an[comp + (i__ + k * 
		    2000) * 100 - 200101];
/* 		  end if */
	}
    }

/* 	Saida */


/* L10: */
/* L11: */

    i__1 = nstars + 1;
    for (j = 1; j <= i__1; ++j) {
	s_wsle(&io___41);
	do_lio(&c__9, &c__1, "# ", (ftnlen)2);
	e_wsle();
	s_wsle(&io___42);
	do_lio(&c__9, &c__1, "#   *** Estrela de campo ...: ", (ftnlen)30);
	do_lio(&c__3, &c__1, (char *)&j, (ftnlen)sizeof(integer));
	e_wsle();
	s_wsle(&io___43);
	do_lio(&c__9, &c__1, "#", (ftnlen)1);
	e_wsle();
	i__2 = nhw;
	for (i__ = 1; i__ <= i__2; ++i__) {
	    s_wsfe(&io___44);
	    do_fio(&c__1, (char *)&i__, (ftnlen)sizeof(integer));
	    i__3 = nap;
	    for (k = 1; k <= i__3; ++k) {
		do_fio(&c__1, (char *)&dif[j + (i__ + k * 2000) * 100 - 
			200101], (ftnlen)sizeof(doublereal));
	    }
	    e_wsfe();
	}
    }

/* 	Imprimindo ruido de fotons para cada abertura de cada estrela */

    s_wsle(&io___45);
    do_lio(&c__9, &c__1, "# ", (ftnlen)2);
    e_wsle();
    s_wsle(&io___46);
    do_lio(&c__9, &c__1, "#      Ruido de fotons   ", (ftnlen)25);
    e_wsle();
    s_wsle(&io___47);
    do_lio(&c__9, &c__1, "# ", (ftnlen)2);
    e_wsle();
    i__1 = nstars;
    for (j = 1; j <= i__1; ++j) {
	s_wsfe(&io___48);
	do_fio(&c__1, (char *)&j, (ftnlen)sizeof(integer));
	i__2 = nap;
	for (k = 1; k <= i__2; ++k) {
	    do_fio(&c__1, (char *)&ruido[j + k * 100 - 101], (ftnlen)sizeof(
		    doublereal));
	}
	e_wsfe();
    }


/* 	Imprimindo Erro no fluxo relativo */

    s_wsle(&io___49);
    do_lio(&c__9, &c__1, "# ", (ftnlen)2);
    e_wsle();
    s_wsle(&io___50);
    do_lio(&c__9, &c__1, "#      Erro no fluxo relativo   ", (ftnlen)32);
    e_wsle();
    s_wsle(&io___51);
    do_lio(&c__9, &c__1, "# ", (ftnlen)2);
    e_wsle();
    i__1 = nstars;
    for (j = 1; j <= i__1; ++j) {
	s_wsfe(&io___52);
	do_fio(&c__1, (char *)&j, (ftnlen)sizeof(integer));
	i__2 = nap;
	for (k = 1; k <= i__2; ++k) {
	    do_fio(&c__1, (char *)&erro[j + k * 100 - 101], (ftnlen)sizeof(
		    doublereal));
	}
	e_wsfe();
    }

/* 	Imprimindo Fluxo total medio */

/* 	write(8,*) "# " */
/* 	write(8,*) "#      Fluxo total medio   " */
/* 	write(8,*) "# " */
/* 	do j=1,nstars */
/* 	    write(8,*) j,(antot(j,k), k=1,nap) */
/* 	end do */

    cl__1.cerr = 0;
    cl__1.cunit = 8;
    cl__1.csta = 0;
    f_clos(&cl__1);

    goto L120;
L100:
    imemsg_(&ier, &errmsg);
    s_wsfe(&io___54);
    do_fio(&c__1, (char *)&errmsg, (ftnlen)sizeof(doublereal));
    e_wsfe();
L110:
    s_stop("", (ftnlen)0);
L120:
    ;
} /* MAIN__ */

/* Main program alias */ int phot_pol_e__ () { MAIN__ (); }
