#!/bin/bash
gcc psuedocode.c -o test

program=$1

if [ $program == 0 ]; then
    ./test $program > out.txt
    diff out.txt outDist.txt
elif [ $program == 1 ]; then
    ./test $program > out.txt
    diff out.txt outMult.txt
else 
    echo "Argument Error: Unrecognized test argument '$program'."
fi

rm test
echo "Script finished."