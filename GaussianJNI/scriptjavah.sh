#!/bin/bash
# My first script


echo "Hello World"

rm -f Gaussian.h
bsub -n 1 -q long -o ./ javah Gaussian

