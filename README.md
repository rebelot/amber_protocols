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

1. Copy the desired protocol folder to your working directory

```bash
cp -r $AMBERPROTOCOLS/protocols/protein/protocol protocol
```

2. (optional) If needed, edit the protocol files

3. Edit the loader script with the appropriate atom selection masks for your system.
  Note, the `&` character must be escaped, e.g.: `&` → `\&`

4. Run `load.sh` to load the protocol and the `run.sh` template in your working directory.
  This also loads the `loop_step` and `run_steps` runner scripts.

```bash
./protocol/load.sh
```

5. Edit the `run.sh` script with the appropriate parameters for your system:

```bash
RUN_EQUIL=true               # Whether to run the equilibration steps
NAME=MD_equil                # The basename for MD files
PRMTOP=system.prmtop         # Input topology
INPCRD=system.inpcrd         # Input coordinates
PROTDIR=.                    # Directory containing protocol *.in files
PROTGLOB='*.in'              # Glob pattern matching MD input files (mdin)

...

RUN_PROD=false               # Whether to run the production MD
NAME=MD_prod                 # The basename for MD files
INPCRD=last_step.rst7        # The input coordinates for the production run (usually the rst7 from the last equilibration step)
STEP_IN=Prod.mdin            # The name of the production step
NSTEPS=10                    # The number of times to repeat the production step

```

6. Run the simulation

```bash
sbatch run.sh
```

### Run replicas

5. Edit the `run.sh` script with the appropriate parameters for your system:
   use the `$REPLICA_DIR` env variable to specify paths relative to each replica.

```bash
RUN_EQUIL=true               # Whether to run the equilibration steps
NAME=$REPLICA_DIR/MD_equil                # The basename for MD files
PRMTOP=system.prmtop         # Input topology
INPCRD=system.inpcrd         # Input coordinates
PROTDIR=.                    # Directory containing protocol *.in files
PROTGLOB='*.in'              # Glob pattern matching MD input files (mdin)

...

RUN_PROD=false               # Whether to run the production MD
NAME=$REPLICA_DIR/MD_prod                 # The basename for MD files
INPCRD=$REPLICA_DIR/last_step.rst7        # The input coordinates for the production run (usually the rst7 from the last equilibration step)
STEP_IN=Prod.mdin            # The name of the production step
NSTEPS=10                    # The number of times to repeat the production step

```

6. Edit the `run_replica.sh` script

```bash
NREPLICAS=6           # Number of replicas
BASENAME=replica      # Basename of replica directory
```

7. Run the simulations in parallel

```bash
./run_replica.sh
```

## Utils

### `loop_step: prmtop inpcrd step nrep basename`

Repeat a step (`mdin`) `nrep` times,
with the output of each run being used as the input for the next one.

### `run_steps: prmtop inpcrd protdir protglob basename"`

Launch a series of steps (`mdin`) in sequence,
with the output of each step being used as the input for the next one.
Step configurations are searched for in `protdir` directory, sorting
any file matching the `protglob` pattern.

### `rep_step: step rep`

Copy a configuration (`mdin`) file `rep` times, adding a progressive suffix.
