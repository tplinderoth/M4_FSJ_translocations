#!/bin/bash
#! This line is a comment
#! Make sure you only have comments and #SBATCH directives between here and the end of the #SBATCH directives, or things will break
#! Name of the job:
#SBATCH -J const_notrans3
#! Account name for group, use SL2 for paying queue:
#SBATCH -A general
#! Output filename:
#! %A means slurm job ID and %a means array index
#SBATCH --output=const_notrans3_%A_%a.out
#! Errors filename:
#SBATCH --error=const_notrans3_%A_%a.err

#! Number of nodes to be allocated for the job (for single core jobs always leave this at 1)
#SBATCH --nodes=1
#! Number of tasks. By default SLURM assumes 1 task per node and 1 CPU per task.
#SBATCH --ntasks=1
#! How many many cores will be allocated per task?
#SBATCH --cpus-per-task=6
#! Estimated runtime: hh:mm:ss (job is force-stopped after if exceeded):
#SBATCH --time=01:00:00
#! Estimated maximum memory needed (job is force-stopped if exceeded):
#SBATCH --mem=12000mb
#! Submit a job array with index values between 0 and 31
#! NOTE: This must be a range, not a single number
#SBATCH --array=1-1000

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

SIM_EXEC='/mnt/research/Fitz_Lab/projects/mosaic/simulations/pop_sims/scripts/simJay.R'
RELATESTATS='/mnt/research/Fitz_Lab/software/PopGenomicsTools/relateStats'
SEED_FILE='/mnt/research/Fitz_Lab/projects/mosaic/simulations/pop_sims/inputs/sim_seeds.txt'
SEED=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SEED_FILE")
MODEL='const_notrans'
INDIVIDUALS_FILE='/mnt/research/Fitz_Lab/projects/mosaic/simulations/pop_sims/inputs/cr_individuals_no_trans_20241014.tsv'
SURVIVAL_FILE='/mnt/research/Fitz_Lab/projects/mosaic/simulations/pop_sims/inputs/mixed_poisson_survival_pmf2.txt'
REPRODUCTION_FILE='/mnt/research/Fitz_Lab/projects/mosaic/simulations/pop_sims/inputs/empiric_offspring_pmf.tsv'
EVENTS_FILE='/mnt/research/Fitz_Lab/projects/mosaic/simulations/pop_sims/inputs/pair_limits_const.tsv'
OUTPREFIX="/mnt/research/Fitz_Lab/projects/mosaic/simulations/pop_sims/simulations3/${MODEL}_${SEED}"

$SIM_EXEC --ind_file "$INDIVIDUALS_FILE" --offspring_file "$REPRODUCTION_FILE" --pair_param 0.93120 0.03563 --n_timesteps 21 --out "$OUTPREFIX" --mature 2 --max_offspring 8 --survive_file "$SURVIVAL_FILE" --empiric_survive --min_survive_obs 19 --male_p 0.5 --events_file "$EVENTS_FILE" --relate_matrix --seed "$SEED"

wait

cut -f1 "${OUTPREFIX}.id" > "${OUTPREFIX}.anc"

wait

for YEAR in {2002..2022};
do
	$RELATESTATS --pedstat 1 --ped "${OUTPREFIX}.ped" --rmat "${OUTPREFIX}.rmat" --anc "${OUTPREFIX}.anc" --time2 "$YEAR" --out "${OUTPREFIX}_${YEAR}"
	wait
done
