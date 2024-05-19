# pccdpack_inpe
 
## Introduction

The pccdpack_inpe repository has a set of IRAF routines to polarimetric reduction of data obtained using the IAGPOL polarimeter. It is heavily based on the original pccdpack package developed by Antonio Pereyra.

## Developers

Many routines were originally written by Antonio Pereyra with the collaboration of Antonio Mario Magalhaes.

Development at INPE were done by:
Claudia Vilega Rodrigues
Victor de Souza Magalhães
Karleyne M. G. de Souza

## Installation

No IRAF V2.18, MacOS, os pacotes externos (e portanto o diretório do pccdpack) devem ser colocados no diretório:

/Applications/IRAF.app/Contents/iraf-v218/extern .

No arquivo pccdpack_inpe.cl, modifique a linha abaixo para ficar de acordo com a localizacao do pccdpack_inpe:

	set      pccdpack_inpe          = "/Applications/IRAF.app/Contents/iraf-v218/extern/pccdpack_inpe/"

Toda a secao de "rotinas fortran" precisa ter o caminho alterado.

## Versioning

2024-05-19 - Modified to work in IRAF V2.18

2023-11-02 - Bug correction.

2023-10-11 - graf_inpe.cl was modified in order to be consistent with previous modification.
_
2023-09-09 - Correction of the position angle of the linear polarization. The solution of atan was not correctly considering the quadrants. The fortran code pccd4000gen23.f should be compiled in used as the exe in the pccdgen_inpe IRAF task.

2022-02-04 - First version in the github.
