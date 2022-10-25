# amber_protocols

<!--toc:start-->
- [amber_protocols](#amberprotocols)
  - [Resources](#resources)
  - [Example workflow](#example-workflow)
      - [Restart/Extend simulations](#restartextend-simulations)
    - [Run replicas](#run-replicas)
      - [Restart individual replicas](#restart-individual-replicas)
  - [Utils](#utils)
    - [`loop_step: prmtop inpcrd step nrep basename`](#loopstep-prmtop-inpcrd-step-nrep-basename)
    - [`run_steps: prmtop inpcrd protdir protglob basename"`](#runsteps-prmtop-inpcrd-protdir-protglob-basename)
    - [`rep_step: step rep`](#repstep-step-rep)
<!--toc:end-->

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

#### Restart/Extend simulations

- To restart a simulation, simply re-run the `sbatch` command; the checkpoint (`.ok`) files will cause already completed steps to be skipped.
- To extend a simulation, simply increase the value of `NSTEP` variable in the `run.sh` script (`RUN_PROD` section) and restart the simulation.

**_WARNING:_** be careful of the **0-padding**.
A 0-padded suffix specifying the step number will be appended automatically to the filenames generated by the MD.
By default, the length of the padding is the same of the digits of `NSTEPS`.
For example, `NSTEPS=10` will generate suffixes from `01` to `10`,
but `NSTEPS=100` will generate suffixes from `001` to `100`.
This might be a problem when extending a simulation requires increasing the number of digits in `NSTEPS` (e.g., `50` ⇒ `100`),
as previously generated checkpoint and restart files won't be recognized,
causing the simulation to restart from the beginning.
The easiest solution to this is to add a suffix to `NAME` (e.g., `my_md` ⇒ `my_md_ext`)
or to run the simulation in a separate folder. With this approach, `INPCRD` variable should now be modified
to point to the last step of the previous simulation (you can prepend absolute/relative path if needed) and
`NSTEPS` should now correspond to the number of steps **_to be added_** to the previous steps.

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

#### Restart individual replicas

```bash
# re-launch job for replica_3
env REPLICA_DIR=replica_3 sbatch run.sh
```

To extend replicas, modify `run.sh` as explained in [Restart/Extend simulations](restartextend-simulations).

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
Useful to repeat the same step multiple times using `run_steps`.
