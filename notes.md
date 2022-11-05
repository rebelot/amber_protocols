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

