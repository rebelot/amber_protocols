#!/bin/sh 

# http://ambermd.org/tutorials/advanced/tutorial34/index.html

#=============================================================================
#  Using RISM and metatwist to place waters around a solute.
#    (copy this script to your working directory, and edit it as needed.
#
#    (This example uses a KH closure and pure water as a solvent, just
#    to illustrate the ideas. There is next to no error checking.)
#=============================================================================

id=$1    # identifier for this calculation
         # inputs: $id.parm7, $id.rst7, $id.pdb

thresh=0.5  # threshold for including explicit waters at the centers
            # of negative Laplacian regions.  These will be in order
            # with the most probable ones first, so you can edit the
            # output pdb file to inclcude as many as you think you want.
            # Setting a smaller threshhold will give you more waters,
            # but with increasingly less connection to the rism density.

            # Current thinking: use a thresh value of about 0.5, then
            # use add_to_box to randomly pack in any remaining waters,
            # which don't have any particular justification in the RISM
            # density.

#  main output: $id.wat.pdb = $id.pdb + placed waters (occ=1, B=0)
#               wats.pdb: just oxygen positions, with estimated
#                         occupations and B-factors

if false; then    # <-- use false if you've already done the 3D-RISM
                  #     calcualtion, true otherwise.

#---------------------------------------------------------------------------
# 1.  Run a single-point of 3D-RISM, here using the sander interface;
#       (could also be with rism3d.snglpnt):
#---------------------------------------------------------------------------

cat > mdin.rism <<EOF
  single-point 3D-RISM calculation using the sander interface
 &cntrl
    ntx=1, nstlim=0, irism=1,
 /
 &rism
    periodic='pme',
    closure='kh', tolerance=1e-6,
    grdspc=0.35,0.35,0.35, centering=0,
    mdiis_del=0.4, mdiis_nvec=20, maxstep=5000, mdiis_restart=50,
    solvcut=9.0,
    verbose=2, npropagate=0,
    apply_rism_force=0,
    volfmt='ccp4', ntwrism=1,
 /
EOF

sander -O -i mdin.rism -o $id.kh.r3d \
    -p $id.parm7 -c $id.rst7 -xvv cSPCE_kh.xvv -guv $id.kh

/bin/rm -f mdin.rism restrt mdinfo $id.kh.H1.0.ccp4

fi

#---------------------------------------------------------------------------
# 2.  Run metatwist to to a Lapacian analysis on the oxygen distribution:
#---------------------------------------------------------------------------

metatwist --dx $id.kh.O.0.ccp4 --species O  \
     --convolve 4 --sigma 1.0 --odx $id.kh.O.ccp4 > $id.lp

#---------------------------------------------------------------------------
# 3.  Place water molecules at the centers of the negative Laplacians:
#---------------------------------------------------------------------------

metatwist --dx $id.kh.O.0.ccp4 \
      --ldx convolution-$id.kh.O.ccp4 --map blobsper \
      --species O WAT --bulk 55.55 --threshold $thresh  > $id.blobs 

grep -v TER $id.kh.O.0-convolution-$id.kh.O-blobs-centroid.pdb > wats.pdb

# ===== Add hydrogens using gwh

sed 's/END/TER/' $id.amber.pdb > $id.wat.pdb
gwh -p $id.parm7 -w wats.pdb < $id.amber.pdb >> $id.wat.pdb 2>> $id.blobs
  

/bin/rm -f $id..kh.O.0-convolut* convolu*

