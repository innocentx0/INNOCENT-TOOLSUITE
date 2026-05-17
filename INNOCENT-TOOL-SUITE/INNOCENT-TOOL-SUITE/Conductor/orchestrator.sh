#!/bin/bash

echo This is the cron job for Conductor, it will run every day at 3:00 AM and execute the main script of Conductor. 
echo Make sure to set up the cron job properly to ensure that it runs as expected.


if [ -d ../Getsub/ ]; then
    cd ../Getsub/
    chmod +x getsub.sh
    ./getsub.sh
    cd ../Ghostsub/
    chmod +x ghostsub.sh
    ./ghostsub.sh
else
    echo "make sure to place the scripts in the correct directory"
fi



