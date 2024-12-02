#!/bin/bash
#! This line is a comment
#! Make sure you only have comments and #SBATCH directives between here and the end of the #SBATCH directives, or things will break
#! Name of the job:
#SBATCH -J resident_cr_F
#! Account name for group, use SL2 for paying queue:
#! #SBATCH -A ACCOUNT_NAME

#! Number of nodes to be allocated for the job (for single core jobs always leave this at 1)
#SBATCH --nodes=1
#! Number of tasks. By default SLURM assumes 1 task per node and 1 CPU per task. (for single core jobs always leave this at 1)
#SBATCH --ntasks=1
#! How many many cores will be allocated per task? (for single core jobs always leave this at 1)
#SBATCH --cpus-per-task=24
#! Estimated runtime: hh:mm:ss (job is force-stopped after if exceeded):
#SBATCH --time=24:00:00
#! Estimated maximum memory needed (job is force-stopped if exceeded):
#SBATCH --mem=96000mb
#! #SBATCH --no-requeue

#! This is the partition name.
#! #SBATCH -p skylake-himem

#! mail alert at start, end and abortion of execution
#! emails will default to going to your email address
#! you can specify a different email address manually if needed.
#SBATCH --mail-type=FAIL

#! Don't put any #SBATCH directives below this line

#! Modify the environment seen by the application. For this example we need the default modules.
#! . /etc/profile.d/modules.sh                # This line enables the module command
#! module purge                               # Removes all modules still loaded
#! module load rhel7/default-peta4            # REQUIRED - loads the basic environment

module load Java/1.8.0_152 bzip2/1.0.6 zlib/1.2.11 Boost/1.67.0 GSL/2.6

#! Are you using OpenMP (NB this is unrelated to OpenMPI)? If so increase this
#! safe value to no more than 32:
#! export OMP_NUM_THREADS=1

echo "This is job ${SLURM_JOB_ID}"

workdir="$SLURM_SUBMIT_DIR" # The value of SLURM_SUBMIT_DIR sets workdir to the directory
cd $workdir

GENOLIKES='/mnt/research/Fitz_Lab/projects/mosaic/popgen/genotypes/resident_cr_biallelic_snps_main_autosomes_qc_glf3.glf'
OUTFILE='/mnt/research/Fitz_Lab/projects/mosaic/popgen/fstats/resident_cr_biallelic_snps_main_autosomes_qc_F.txt'

CMD="ngsF --glf $GENOLIKES --init_values e --out $OUTFILE --n_ind 16 --n_sites 1204026 --max_iters 3000 --n_threads 20"

printf "\n%s\n\n" "$CMD"

eval $CMD
