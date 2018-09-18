#!/bin/bash -e

. ../common.sh

task=$1
fastq=$dataDir/$task.fastq.gz
base=$(basename $task)
log=$logDir/$base.log
out=$base.trim.fastq.gz

logStepStart $log
logTaskToSlurmOutput $task $log
checkFastq $fastq $log

function doTrim()
{
    # Remove the output file before doing anything, in case we fail for
    # some reason (e.g., a bad option name or AdapterRemoval not found).
    rm -f $out

    AdapterRemoval --file1 $fastq --output1 $out --gzip --trimns --minlength 30 \
                   --trimqualities --minquality 2 --settings $base.settings \
                   --discarded $base.discarded.gz > $base.out 2>&1
}

if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Trimming is being skipped on this run." >> $log
    elif [ -f $out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output file $out exists, but --force was used. Overwriting." >> $log
            doTrim
        else
            echo "  Will not overwrite pre-existing output file $out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output file $out does not exist. Trimming." >> $log
        doTrim
    fi
fi

logStepStop $log
