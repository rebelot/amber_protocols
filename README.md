# amber_protocols

<!--toc:start-->
- [amber_protocols](#amberprotocols)
  - [Resources](#resources)
  - [Example workflow](#example-workflow)
      - [Restart/Extend simulations](#restartextend-simulations)
    - [Run replicas](#run-replicas)
      - [Restart individual replicas](#restart-individual-replicas)
  - [Utils](#utils)
    - [`loop_step`](#loopstep)
    - [`run_steps`](#runsteps)
    - [`rep_step`](#repstep)
  - [Analysis](#analysis)
<!--toc:end-->

Repository of computational biochemistry protocols for the Amber package

Set up `AMBERPROTOCOLS` environment variable for ease of use

```bash
export AMBERPROTOCOLS=<path-to-this-repo>
```

Protocols consist of various scripts and configuration files for running and
analyzing molecular dynamics with Amber. Protocols are organized by macro-area
within the `protocol` directory:

- `protein`: protocols for simple protein-solvent simulations.
- `membrane_protein`: protocols for protein simulations with lipid membranes.
- `solvate`: protocols to solvate system binding sites using RISM.

## Resources

- [AmberTools](http://ambermd.org/AmberTools.php)
- [Amber22 Reference Manual](http://ambermd.org/doc12/Amber22.pdf)
- [Tutorials](http://ambermd.org/tutorials/)
- [AmberHub](https://amberhub.chpc.utah.edu/)

## Example workflow

1. Copy the desired protocol folder to your working directory.

```bash
cp -r $AMBERPROTOCOLS/protocols/protein/protocol .
```

2. (optional) If needed, edit the protocol files

3. Edit the loader script `load.sh` with the appropriate atom selection masks
   for your system. Atom selections are needed to specify which atoms should be
   restrained during the relaxation steps. Note, the `&` character must be
   escaped, e.g.: `&` → `\&`.

4. Run `load.sh` to load the protocol and the `run.sh` template in your working
   directory. This also creates a local copy of the `loop_step` and `run_steps`
   runner scripts.

```bash
./protocol/load.sh
```

5. Edit the `run.sh` script with the appropriate parameters for your system:

6. Run the simulation

```bash
sbatch run.sh
```

#### Restart/Extend simulations

- To restart a simulation, simply re-run the `sbatch` command; the checkpoint
  (`.ok`) files will cause already completed steps to be skipped.
- To extend a simulation, simply increase the value of `NSTEP` variable in the
  `run.sh` script (`RUN_PROD` section) and restart the simulation.

**_WARNING:_** be careful of the **0-padding**. A 0-padded suffix specifying
the step number will be appended automatically to the filenames generated by
the MD. By default, the length of the padding is the same of the digits of
`NSTEPS`. For example, `NSTEPS=10` will generate suffixes from `01` to `10`,
but `NSTEPS=100` will generate suffixes from `001` to `100`. This might be a
problem when extending a simulation requires increasing the number of digits in
`NSTEPS` (e.g., `50` ⇒ `100`). This will have the effect that previously
generated checkpoint and restart files won't be recognized, causing the
simulation to restart from the beginning. The easiest solution to this is to
add a suffix to `NAME` (e.g., `my_md` ⇒ `my_md_ext`) or to run the simulation
in a separate folder. With this approach, `INPCRD` variable should now be
modified to point to the last step of the previous simulation (you can prepend
absolute/relative path if needed) and `NSTEPS` should now correspond to the
number of steps **_to be added_** to the previous steps.

If you plan on extending your simulation, it is advised to 0-pad `NSTEPS` in
advance, e.g., using `NSTEPS=050` allows restarting up to step 999.

### Run replicas

5. Edit the `run.sh` script with the appropriate parameters for your system:
   prepend a reference to the `$REPLICA_DIR` environment variable
   to indicate input/output paths that should be relative to each replica
   (i.e., output base `NAME` and `INPCRD` input coordinates).
   The `$REPLICA_DIR` variable is set automatically by `run_replica.sh` (see the next step below).

```bash
NAME=$REPLICA_DIR/MD_equil
INPCRD=$REPLICA_DIR/last_step.rst7
```

6. Copy the `run_replica.sh` script into your working directory

```bash
cp $AMBERPROTOCOLS/utils/run_replica.sh .
```

7. Edit the local copy of `run_replica.sh` with the desired parameters:

```bash
NREPLICAS=6           # Number of replicas
BASENAME=replica      # Basename of replica directory
```

8. Run the simulations in parallel. The script will handle the creation of
   directories for each replica if they don't exist and will spawn a job for
   each replica by launching the `run.sh` script with the appropriate values of
   `$REPLICA_DIR`.

```bash
./run_replica.sh
```

#### Restart individual replicas

```bash
# re-launch job for replica_3
env REPLICA_DIR=replica_3 sbatch run.sh
```

To extend replicas, modify `run.sh` as explained in [Restart/Extend
simulations](#restartextend-simulations). To add replicas, simply add to
`NREPLICAS` within the `run_replica.sh` script file Completed jobs will be
launched but will terminate immediately as long as checkpoint (`.ok`) files
exit.

## Utils

### `loop_step`

`loop_step: prmtop inpcrd step nrep basename`

Repeat a step (`mdin`) `nrep` times,
with the output of each run being used as the input for the next one.
`step` can be a list of two filenames, if so, the first input file will be used
only for the first step. Useful to create "starter" input files.

### `run_steps`

`run_steps: prmtop inpcrd steps basename`

Launch a series of steps (`mdin`) in sequence,
with the output of each step being used as the input for the next one.
`steps` should be a list of filenames, separated by newline, spaces, or commas.
e.g., `$( find . -name "*.in" | sort )`

### `rep_step`

`rep_step: step rep`

Copy a configuration (`mdin`) file `rep` times, adding a progressive suffix.
Useful to repeat the same step multiple times using `run_steps`.

## Analysis

Some `cpptraj` recipes for common tasks.
