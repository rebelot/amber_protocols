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

The best way to visualize amber structures in PyMOL is to load them as `pdb` files,
which can be easily generated from coupled topology/coordinate files using the
`ambpdb` utility shipped with Amber tools.

```bash
ambpdb -p system.prmtop -c system.inpcrd -ext -conect > system.pdb

# Or use the coordinates from the last equilibration step
ambpdb -p system.prmtop -c md_equil_07.rst7 -ext -conect > system_eq.pdb
```

Amber topology files (`parmtop`) can also be used, but this might require a few tweaks:
- assign secondary structure elements with: `dss polymer.protein`
- remove bond between WAT H1-H2: `unbond r. WAT & n. H1, r. WAT & n. H2`
- when loading coordinates using restart files (`rst7`/`netCDF`), use: `load_traj coords.rst7, format=nc`
