# amber_protocols

Repository of computational biochemistry protocols for the Amber package

Set up `AMBERPROTOCOLS` environment variable for ease of use

```bash
export AMBERPROTOCOLS=<path-to-this-repo>
```

## Resources

- [AmberTools](http://ambermd.org/AmberTools.php)
- [Amber22 Reference Manual](http://ambermd.org/doc12/Amber22.pdf)
- [Tutorials](http://ambermd.org/tutorials/)
- [AmberHub](https://amberhub.chpc.utah.edu/)

## Example workflow

- Copy the desired protocol folder to your working directory

```bash
cp -r $AMBERPROTOCOLS/protocols/protein/protocol protocol
```

- (optional) If needed, edit the protocol files

- Edit the loader script with the appropriate atom selection masks for your system.
  Note, the `&` character must be escaped, e.g.: `&` → `\&`

- Run `load.sh` to load the protocol and the `run.sh` template in your working directory
```bash
./protocol/load.sh
```

- Edit the `run.sh` script with the appropriate parameters for your system:
```bash
NAME=MD                      # The basename for MD files
PRMTOP=system.prmtop         # Input topology
INPCRD=system.inpcrd         # Input coordinates

PROD_INPCRD=last_step.rst7   # The input coordinates for the production run (usually the rst7 from the last equilibration step)
PROD_STEP=Prod.in            # The name of the production step
NSTEPS=10                    # The number of times to repeat the production step
```

- Run the simulation
```bash
sbatch run.sh
```
