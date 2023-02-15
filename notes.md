# Notes

<!--toc:start-->
- [Notes](#notes)
  - [System preparation](#system-preparation)
    - [PDB preparation](#pdb-preparation)
    - [Small molecules parameterization](#small-molecules-parameterization)
    - [Glycosilation](#glycosilation)
  - [Visualization using PyMOL](#visualization-using-pymol)
<!--toc:end-->

## System preparation

### PDB preparation

### Small molecules parameterization

### Glycosilation

## Visualization using PyMOL

```pymol
load system.prmtop; load_traj system.inpcrd, format=rst7
load system.prmtop; load_traj system.rst7, format=rst7
load system.prmtop; load_traj system.rst7, format=nc

```
```bash
ambpdb -p system.prmtop -c system.inpcrd -ext -conect > system.pdb

# Or use the coordinates from the last equilibration step
ambpdb -p system.prmtop -c md_equil_07.rst7 -ext -conect > system_eq.pdb
```

Amber topology files (`parmtop`) can also be used, but this might require a few tweaks:
- assign secondary structure elements with: `dss polymer.protein`
- remove bond between WAT H1-H2: `unbond r. WAT & n. H1, r. WAT & n. H2`
- when loading coordinates using restart files (`rst7`/`netCDF`), use: `load_traj coords.rst7, format=nc`
