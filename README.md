# pccdpack_inpe
 
## Introduction

The pccdpack_inpe repository has a set of IRAF routines to polarimetric reduction of data obtained using the IAGPOL polarimeter. It is heavily based on the original pccdpack package developed by Antonio Pereyra.

## Developers

Many routines were originally written by Antonio Pereyra with the collaboration of Antonio Mario Magalhaes.

Development at INPE were done by:
Claudia Vilega Rodrigues
Victor de Souza Magalhães
Karleyne M. G. de Souza

## Versioning

2023-09-09 - Correction of the position angle of the linear polarization. The solution of atan was not correctly considering the quadrants. The fortran code pccd4000gen23.f should be compiled in used as the exe in the pccdgen_inpe IRAF task.

2022-02-04 - First version in the github.
