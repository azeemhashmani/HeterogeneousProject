#!/bin/bash
# My first script


echo "Hello World"

nvcc -I"/share/pkg/jdk/1.8.0_31/include" -I"/share/pkg/jdk/1.8.0_31/include/linux" --ptxas-options=-v --compiler-options '-fPIC' -o libGaussian.so --shared gaussian.cu

