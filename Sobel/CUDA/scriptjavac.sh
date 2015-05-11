#!/bin/bash
# My first script


echo "Hello World"

rm -f Sobel.class
bsub -n 1 -q long -o ./ javac ./Sobel.java

