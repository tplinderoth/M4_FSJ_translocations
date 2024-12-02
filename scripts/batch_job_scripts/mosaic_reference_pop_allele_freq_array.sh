#!/bin/bash
#! This line is a comment
#! Make sure you only have comments and #SBATCH directives between here and the end of the #SBATCH directives, or things will break
#! Name of the job:
#SBATCH -J mosaic_pop_snps_af
#! Account name for group, use SL2 for paying queue:
#! #SBATCH -A ACCOUNT_NAME
#! Output filename:
#! %A means slurm job ID and %a means array index
#SBATCH --output=mosaic_snps_af_%A_%a.out
#! Errors filename:
#SBATCH --error=mosaic_snps_af_%A_%a.err

#! Number of nodes to be allocated for the job (for single core jobs always leave this at 1)
#SBATCH --nodes=1
#! Number of tasks. By default SLURM assumes 1 task per node and 1 CPU per task.
#SBATCH --ntasks=1
#! How many many cores will be allocated per task?
#SBATCH --cpus-per-task=12
#! Estimated runtime: hh:mm:ss (job is force-stopped after if exceeded):
#SBATCH --time=36:00:00
#! Estimated maximum memory needed (job is force-stopped if exceeded):
#SBATCH --mem=36000mb
#! Submit a job array with index values between 0 and 31
#! NOTE: This must be a range, not a single number
#SBATCH --array=1-7

#! This is the partition name.
#! #SBATCH -p cclake

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
#! export OMP_NUM_THREADS=1

#! The variable $SLURM_ARRAY_TASK_ID contains the array index for each job.
#! In this example, each job will be passed its index, so each output file will contain a different value
echo "This is job" $SLURM_ARRAY_TASK_ID

#! Command line that we want to run:
#! jobDir=Job_$SLURM_ARRAY_TASK_ID
#! mkdir $jobDir
#! cd $jobDir

workdir="$SLURM_SUBMIT_DIR" # The value of SLURM_SUBMIT_DIR sets workdir to the directory
cd $workdir

INPUT_LIST='/mnt/research/Fitz_Lab/projects/mosaic/popgen/roh/scripts/mosaic_reference_pop_maxr0.4_af_estimate_inputs.txt'
POP=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$INPUT_LIST" | cut -f1)
BAMS=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$INPUT_LIST" | cut -f2)
SITESFILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$INPUT_LIST" | cut -f3)
OUTPREFIX="/mnt/research/Fitz_Lab/projects/mosaic/popgen/roh/inputs/${POP}_maxr0.4_biallelic_snps_main_autosomes_qc"

CMD="angsd -bam $BAMS -out $OUTPREFIX -GL 1 -doMaf 1 -doMajorMinor 3 -sites $SITESFILE -minQ 20 -minMapQ 20 -remove_bads 1 -only_proper_pairs 1 -uniqueOnly 1 -P 8"

printf "\n%s\n\n" "$CMD"

eval $CMD
