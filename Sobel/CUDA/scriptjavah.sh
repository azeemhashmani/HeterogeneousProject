#!/bin/bash
# My first script


echo "Hello World"

rm -f Sobel.h
bsub -n 1 -q long -o ./ javah Sobel

