#!/bin/bash
# My first script


echo "Hello World"

rm -f test.out
bsub -q gpu -a gpuexcel_p -W 00:30 -o CUDA.out ./Sobel

