#!/bin/bash
#! This line is a comment
#! Make sure you only have comments and #SBATCH directives between here and the end of the #SBATCH directives, or things will break
#! Name of the job:
#SBATCH -J bed_mask
#! Account name for group, use SL2 for paying queue:
#! #SBATCH -A ACCOUNT_NAME
#! Output filename:
#! %A means slurm job ID and %a means array index
#SBATCH --output=mosaic_bed_mask_%A_%a.out
#! Errors filename:
#SBATCH --error=mosaic_bed_mask_%A_%a.err

#! Number of nodes to be allocated for the job (for single core jobs always leave this at 1)
#SBATCH --nodes=1
#! Number of tasks. By default SLURM assumes 1 task per node and 1 CPU per task.
#SBATCH --ntasks=1
#! How many many cores will be allocated per task?
#SBATCH --cpus-per-task=2
#! Estimated runtime: hh:mm:ss (job is force-stopped after if exceeded):
#SBATCH --time=36:00:00
#! Estimated maximum memory needed (job is force-stopped if exceeded):
#! #SBATCH --mem=12000mb
#! Submit a job array with index values between 0 and 31
#! NOTE: This must be a range, not a single number
#SBATCH --array=1-1153

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

EXEC='/mnt/research/Fitz_Lab/projects/mosaic/variants/masks/bedmask.pl'
SCAFLIST='/mnt/research/Fitz_Lab/ref/bird/FSJ_V3/FSJ_V3_scaffolds.txt'
SCAF=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SCAFLIST")
BAMSTATS="/mnt/research/Fitz_Lab/projects/mosaic/variants/masks/bam_stats/fsj_mosaic_allind_${SCAF}.bamstats"
OUTPREFIX="/mnt/research/Fitz_Lab/projects/mosaic/variants/masks/bed/fsj_mosaic_mask_${SCAF}"

CMD="$EXEC --mindepth 523 --maxdepth 741 --minmq 35 --maxmq0 0.1 --minbq 20 --maxbq0 0.003 $BAMSTATS $OUTPREFIX"

if [ "$SCAF" = 'Chromosome24' ]
then
	CMD="$EXEC --mindepth 386 --maxdepth 681 --minmq 35 --maxmq0 0.1 --minbq 20 --maxbq0 0.003 $BAMSTATS $OUTPREFIX"
fi

printf "\n%s\n\n" "$CMD"

eval $CMD
