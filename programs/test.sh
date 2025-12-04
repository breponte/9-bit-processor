#!/bin/bash
gcc psuedocode.c -o test
./test > out.txt
diff out.txt outTrue.txt
rm test
echo "Script finished."