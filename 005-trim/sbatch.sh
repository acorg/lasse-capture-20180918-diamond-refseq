#!/bin/bash -e

. ../common.sh

task=$1
log=$logDir/sbatch.log

# base will be the name of the FASTQ file without the leading
# directories. We'll output that as a task name so that the subsequent step
# won't have to remove the leading directories. That's because it will be
# picking up their input from ../011-trim and the leading dirs we have are
# for the original source data - once we've processed the data from there,
# they're not needed any more.
base=$(basename $task)

# NOTE!! The following must have the identical value set and used in trim.sh
out=$base.trim.fastq.gz


echo "$(basename $(pwd)) sbatch.sh running at $(date)" >> $log
echo "  Task is $task" >> $log
echo "  Dependencies are $SP_DEPENDENCY_ARG" >> $log

if [ "$SP_FORCE" = "0" -a -f $out ]
then
    # The output file already exists and we're not using --force, so
    # there's no need to do anything. Just pass along our task name to the
    # next pipeline step.
    echo "  Ouput file $out already exists and SP_FORCE is 0. Nothing to do." >> $log
    echo "TASK: $base"
else
    if [ "$SP_SIMULATE" = "1" -o "$SP_SKIP" = "1" ]
    then
        exclusive=
        echo "  Simulating or skipping. Not requesting exclusive node." >> $log
    else
        # No need to get an exclusive machine. On a busy SLURM system it's
        # faster to just get one CPU and do it that way.
        exclusive=
        echo "  Not simulating or skipping. Not requesting exclusive node." >> $log
    fi

    jobid=$(sbatch -n 1 $exclusive $SP_DEPENDENCY_ARG $SP_NICE_ARG submit.sh $task | cut -f4 -d' ')
    echo "TASK: $base $jobid"
    echo "  Job id is $jobid" >> $log
fi

echo >> $log
