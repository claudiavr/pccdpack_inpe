# pccdpack_inpe
 
## Introduction

The pccdpack_inpe repository has a set of IRAF routines to polarimetric reduction of data obtained using the IAGPOL or SPARC4 instruments. It is heavily based on the original pccdpack package developed by Antonio Pereyra.

## Developers

Many routines were originally written by Antonio Pereyra with the collaboration of Antonio Mario Magalhaes.

Development at INPE were done by:
Claudia Vilega Rodrigues
Victor de Souza Magalhaes
Karleyne M. G. de Souza

## Installation and other comments

No IRAF V2.18, MacOS, os pacotes externos (e portanto o diretório do pccdpack) devem ser colocados no diretório:

/Applications/IRAF.app/Contents/iraf-v218/extern .

No arquivo pccdpack_inpe.cl, modifique a linha abaixo para ficar de acordo com a localizacao do pccdpack_inpe:

	set      pccdpack_inpe          = "/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/"

Toda a secao de "rotinas fortran" precisa ter o caminho alterado.

Nova versao do IRAF: https://iraf.noirlab.edu/

https://arxiv.org/abs/2401.01982

A Claudia, usando o MacOS, só conseguir interacao com a imagem no XImtool. Isto eh, nao consegui selecionar estrelas na imagem no DS9.

## Versioning

2024-05-22b

	Bug correction in padrao_pol
	
	time_pol tested and corrected where necessary. Working okay if you have phot_pol_e.e
	
	plota_pol tested
	
    plota_luz tested
	
	_
2024-05-22

	Zerofind_inpe corrected to work in IRAF V2.18.

	Task zerofind_inpe renamed to zerofind._

	Padrao_pol tested.
			 _
	2024-05-19 - Modified to work in IRAF V2.18

2023-11-02 - Bug correction.

2023-10-11 - graf_inpe.cl was modified in order to be consistent with previous modification.
_
2023-09-09 - Correction of the position angle of the linear polarization. The solution of atan was not correctly considering the quadrants. The fortran code pccd4000gen23.f should be compiled in used as the exe in the pccdgen_inpe IRAF task.

2022-02-04 - First version in the github.
