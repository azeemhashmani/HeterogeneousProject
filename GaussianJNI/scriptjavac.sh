#!/bin/bash
# My first script


echo "Hello World"

rm -f Gaussian.class
bsub -n 1 -q long -o ./ javac ./Gaussian.java

