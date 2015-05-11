#!/bin/bash
# My first script


echo "Hello World"

bsub -q gpu -a gpuexcel_p -W 00:30 -o ./ java -Djava.library.path=. Gaussian $1

