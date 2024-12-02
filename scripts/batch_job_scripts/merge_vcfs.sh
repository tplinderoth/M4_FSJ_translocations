#!/bin/bash
#! This line is a comment
#! Make sure you only have comments and #SBATCH directives between here and the end of the #SBATCH directives, or things will break
#! Name of the job:
#SBATCH -J merge_vcfs
#! Account name for group, use SL2 for paying queue:
#! #SBATCH -A ACCOUNT_NAME

#! Number of nodes to be allocated for the job (for single core jobs always leave this at 1)
#SBATCH --nodes=1
#! Number of tasks. By default SLURM assumes 1 task per node and 1 CPU per task. (for single core jobs always leave this at 1)
#SBATCH --ntasks=1
#! How many many cores will be allocated per task? (for single core jobs always leave this at 1)
#SBATCH --cpus-per-task=24
#! Estimated runtime: hh:mm:ss (job is force-stopped after if exceeded):
#SBATCH --time=36:00:00
#! Estimated maximum memory needed (job is force-stopped if exceeded):
#SBATCH --mem=66000mb
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

VCFLIST='/mnt/gs18/scratch/users/lindero1/mosaic/vcf/annotate/fsj_mosaic_vcf.list'
OUTFILE='/mnt/research/Fitz_Lab/projects/mosaic/variants/vcf/all_sites/fsj_mosaic_allsites_genome.vcf.gz'

CMD="bcftools concat -f $VCFLIST -O z -o $OUTFILE --threads 20"

printf "\n%s\n\n" "$CMD"

eval $CMD
wait
tabix -p vcf "$OUTFILE"
